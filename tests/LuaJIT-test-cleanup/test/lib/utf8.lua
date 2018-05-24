
do --- is there an utf-8 library?
  assert(utf8)
end


do --- string from integer codepoints
  local s = utf8.char(20334, 3425, 1265, 165)
  assert(s == '佮ൡӱ¥')
  for i=1,100 do
    s = utf8.char(20334, 3425, 1265, 165)
  end
  assert(s == '佮ൡӱ¥')
end


do --- charpattern as specified on doc
  assert(utf8.charpattern == '[\0-\x7F\xC2-\xF4][\x80-\xBF]*')
end


do --- codes iterator
  local t = {}
  for p, c in utf8.codes('佮ൡӱ¥') do
    t[#t+1] = string.format('%d,%d', p, c)
  end
  assert(table.concat(t, ' - ')=='1,20334 - 4,3425 - 7,1265 - 9,165')
end


do --- codepoints
  local a, b, c, d = utf8.codepoint('佮ൡӱ¥', 1, -1)
  assert(a == 20334)
  assert(b == 3425)
  assert(c == 1265)
  assert(d == 165)
end


do --- len
  local s = '佮ൡӱ¥'
  assert(#s == 10)
  assert(utf8.len(s) == 4)
end


do --- offset in bytes of character
  local s = '佮ൡӱ¥'
  assert(utf8.offset(s, -5) == nil)
  assert(utf8.offset(s, 1) == 1)
  assert(utf8.offset(s, -4) == 1)
  assert(utf8.offset(s, 2) == 4)
  assert(utf8.offset(s, -3) == 4)
  assert(utf8.offset(s, 3) == 7)
  assert(utf8.offset(s, -2) == 7)
  assert(utf8.offset(s, 4) == 9)
  assert(utf8.offset(s, -1) == 9)
  assert(utf8.offset(s, 5) == 11)
  assert(utf8.offset(s, 6) == nil)
end
