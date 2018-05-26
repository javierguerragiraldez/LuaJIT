/*
** UTF-8 library.
** Copyright (C) 2018.
**
** Major portions taken verbatim or adapted from the Lua interpreter.
** Copyright (C) 1994-2008 Lua.org, PUC-Rio. See Copyright Notice in lua.h
*/

#define lib_utf8_c
#define LUA_LIB

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include "lj_obj.h"
#include "lj_err.h"
#include "lj_buf.h"
#include "lj_lib.h"


/* ------------------------------------------------------------------------ */

#define LJLIB_MODULE_utf8

#define MAXUNICODE	0x10FFFF
#define iscont(p)	((*(p) & 0xC0) == 0x80)

/*
** Decode one UTF-8 sequence, returning NULL if byte sequence is invalid.
*/
static const char *utf8_decode (const char *o, int *val) {
  static const unsigned int limits[] = {0xFF, 0x7F, 0x7FF, 0xFFFF};
  const unsigned char *s = (const unsigned char *)o;
  unsigned int c = s[0];
  unsigned int res = 0;  /* final result */
  if (c < 0x80)  /* ascii? */
    res = c;
  else {
    int count = 0;  /* to count number of continuation bytes */
    while (c & 0x40) {  /* still have continuation bytes? */
      int cc = s[++count];  /* read next byte */
      if ((cc & 0xC0) != 0x80)  /* not a continuation byte? */
        return NULL;  /* invalid byte sequence */
      res = (res << 6) | (cc & 0x3F);  /* add lower 6 bits from cont. byte */
      c <<= 1;  /* to test next bit */
    }
    res |= ((c & 0x7F) << (count * 5));  /* add first byte */
    if (count > 3 || res > MAXUNICODE || res <= limits[count])
      return NULL;  /* invalid byte sequence */
    s += count;  /* skip continuation bytes read */
  }
  if (val) *val = res;
  return (const char *)s + 1;  /* +1 to include first byte */
}


LJLIB_CF(utf8_char)
{
  int i, nargs = (int)(L->top - L->base);
  SBuf *sb = lj_buf_tmp_(L);
  for (i = 1; i <= nargs; i++) {
    int32_t k = lj_lib_checkint(L, i);
    if (!checku32(k))
      lj_err_arg(L, i, LJ_ERR_BADVAL);
    lj_buf_pututf8(sb, k);
  }
  setstrV(L, L->top-1, lj_buf_str(L, sb));
  lj_gc_check(L);
  return 1;
}


/*
** utf8len(s [, i [, j]]) --> number of characters that start in the
** range [i,j], or nil + current position if 's' is not well formed in
** that interval
*/
LJLIB_CF(utf8_len)
{
  int n = 0;
  GCstr *str = lj_lib_checkstr(L, 1);
  int32_t len = (int32_t)str->len;
  int32_t posi = lj_lib_optint(L, 2, 1);
  int32_t posj = lj_lib_optint(L, 3, -1);

  if (posj < 0) posj += len+1;
  if (posi < 0) posi += len+1;

  luaL_argcheck(L, 1 <= posi && posi <= len+1, 2,
                   "initial position out of string");
  luaL_argcheck(L, posj <= len, 3,
                   "final position out of string");

  const char *s = strdata(str);
  const char *p = s + posi-1;
  const char *stop = s+posj;

  while (p < stop) {
    const char *nextp = utf8_decode(p, NULL);
    if (nextp == NULL) {  /* conversion error? */
      lua_pushnil(L);  /* return nil ... */
      lua_pushinteger(L, p - s + 1);  /* ... and current position */
      return 2;
    }
    p = nextp;
    n++;
  }
  lua_pushinteger(L, n);
  return 1;
}



static int iter_aux (lua_State *L) {
  size_t len;
  const char *s = luaL_checklstring(L, 1, &len);
  lua_Integer n = lua_tointeger(L, 2) - 1;
  if (n < 0)  /* first iteration? */
    n = 0;  /* start from here */
  else if (n < (lua_Integer)len) {
    n++;  /* skip current byte */
    while (iscont(s + n)) n++;  /* and its continuations */
  }
  if (n >= (lua_Integer)len)
    return 0;  /* no more codepoints */
  else {
    int code;
    const char *next = utf8_decode(s + n, &code);
    if (next == NULL || iscont(next))
      return luaL_error(L, "invalid UTF-8 code");
    lua_pushinteger(L, n + 1);
    lua_pushinteger(L, code);
    return 2;
  }
}


LJLIB_CF(utf8_codes)
{
  luaL_checkstring(L, 1);
  lua_pushcfunction(L, iter_aux);
  lua_pushvalue(L, 1);
  lua_pushinteger(L, 0);
  return 3;
}



/*
** codepoint(s, [i, [j]])  -> returns codepoints for all characters
** that start in the range [i,j]
*/
LJLIB_CF(utf8_codepoint)
{
  GCstr *str = lj_lib_checkstr(L, 1);
  int32_t len = str->len;
  int32_t posi = lj_lib_optint(L, 2, 1);
  int32_t posj = lj_lib_optint(L, 3, posi);

  if (posj < 0) posj += len+1;
  if (posi < 0) posi += len+1;

  if (posi > posj) return 0;

  luaL_argcheck(L, 1 <= posi && posi <= len, 2,
                   "initial position out of string");
  luaL_argcheck(L, posj <= len, 3,
                   "final position out of string");

  luaL_checkstack(L, posj - posi + 1, "string slice too long");
  int n = 0;
  const char *s = strdata(str);
  const char *se = s + posj;

  for (s += posi - 1; s < se;) {
    int code;
    s = utf8_decode(s, &code);
    if (s == NULL)
      return luaL_error(L, "invalid UTF-8 code");
    lua_pushinteger(L, code);
    n++;
  }
  return n;
}


/*
** offset(s, n, [i])  -> index where n-th character counting from
**   position 'i' starts; 0 means character at 'i'.
*/
LJLIB_CF(utf8_offset)
{
  GCstr *str = lj_lib_checkstr(L, 1);
  int32_t len = str->len;
  int32_t n = lj_lib_checkint(L, 2);
  int16_t posi = lj_lib_optint(L, 3, (n >= 0) ? 1 : len + 1);
  luaL_argcheck(L, 1 <= posi && --posi <= (lua_Integer)len, 3,
                   "position out of range");

  const char *s = strdata(str);

  if (n == 0) {
    /* find beginning of current byte sequence */
    while (posi > 0 && iscont(s + posi)) posi--;
  }
  else {
    if (iscont(s + posi))
      luaL_error(L, "initial position is a continuation byte");
    if (n < 0) {
       while (n < 0 && posi > 0) {  /* move back */
         do {  /* find beginning of previous character */
           posi--;
         } while (posi > 0 && iscont(s + posi));
         n++;
       }
     }
     else {
       n--;  /* do not move for 1st character */
       while (n > 0 && posi < (lua_Integer)len) {
         do {  /* find beginning of next character */
           posi++;
         } while (iscont(s + posi));  /* (cannot pass final '\0') */
         n--;
       }
     }
  }
  if (n == 0)  /* did it find given character? */
    lua_pushinteger(L, posi + 1);
  else  /* no such character */
    lua_pushnil(L);
  return 1;
}


/* ------------------------------------------------------------------------ */

#include "lj_libdef.h"

/* pattern to match a single UTF-8 character */
#define UTF8PATT	"[\0-\x7F\xC2-\xF4][\x80-\xBF]*"

LUALIB_API int luaopen_utf8(lua_State *L)
{
  LJ_LIB_REG(L, LUA_UTF8LIBNAME, utf8);
  lua_pushlstring(L, UTF8PATT, sizeof(UTF8PATT)/sizeof(char) - 1);
  lua_setfield(L, -2, "charpattern");
  return 1;
}
