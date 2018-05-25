
do --- is there an utf-8 library?
  assert(utf8)
end


do --- string from integer codepoints
  local s = utf8.char(20334, 3425, 1265, 165)
  assert(s == '佮ൡӱ¥', s)
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
  local s = '佮ൡӱ¥'
  local a, b, c, d = utf8.codepoint(s, 1, -1)
  assert(a == 20334)
  assert(b == 3425)
  assert(c == 1265)
  assert(d == 165)

  assert(not pcall(utf8.codepoint, s, 0))

  local t = {}
  for i = 0, #s+1 do
    local ok, x = pcall(utf8.codepoint, s, i)
    t[#t+1] = ok and string.format('%d:ok:%d', i, x)
                  or string.format('%d:bad', i)
  end
  assert(table.concat(t, '\n') ==
         ([[0:bad 1:ok:20334 2:bad 3:bad 4:ok:3425 5:bad
           6:bad 7:ok:1265 8:bad 9:ok:165 10:bad 11:bad]]):gsub('%s+', '\n'))

  local t = {}
  for i = 0, #s+1 do
    for j = 0, #s+1 do
      local ok, a, b, c, d = pcall(utf8.codepoint, s, i, j)
      t[#t+1] = ok and string.format('%d,%d:ok:%s,%s,%s,%s', i, j, a, b, c, d, e)
                    or string.format('%d,%d:bad', i, j)
    end
  end
  assert(table.concat(t, '\n') ==
      ([[0,0:bad 0,1:bad 0,2:bad 0,3:bad 0,4:bad 0,5:bad 0,6:bad 0,7:bad 0,8:bad 0,9:bad 0,10:bad 0,11:bad
        1,0:ok:nil,nil,nil,nil 1,1:ok:20334,nil,nil,nil 1,2:ok:20334,nil,nil,nil
        1,3:ok:20334,nil,nil,nil 1,4:ok:20334,3425,nil,nil 1,5:ok:20334,3425,nil,nil
        1,6:ok:20334,3425,nil,nil 1,7:ok:20334,3425,1265,nil 1,8:ok:20334,3425,1265,nil
        1,9:ok:20334,3425,1265,165 1,10:ok:20334,3425,1265,165 1,11:bad

        2,0:ok:nil,nil,nil,nil 2,1:ok:nil,nil,nil,nil 2,2:bad
        2,3:bad 2,4:bad 2,5:bad 2,6:bad 2,7:bad 2,8:bad 2,9:bad 2,10:bad 2,11:bad

        3,0:ok:nil,nil,nil,nil 3,1:ok:nil,nil,nil,nil 3,2:ok:nil,nil,nil,nil
        3,3:bad 3,4:bad 3,5:bad 3,6:bad 3,7:bad 3,8:bad 3,9:bad 3,10:bad 3,11:bad

        4,0:ok:nil,nil,nil,nil 4,1:ok:nil,nil,nil,nil 4,2:ok:nil,nil,nil,nil
        4,3:ok:nil,nil,nil,nil 4,4:ok:3425,nil,nil,nil 4,5:ok:3425,nil,nil,nil
        4,6:ok:3425,nil,nil,nil 4,7:ok:3425,1265,nil,nil 4,8:ok:3425,1265,nil,nil
        4,9:ok:3425,1265,165,nil 4,10:ok:3425,1265,165,nil 4,11:bad

        5,0:ok:nil,nil,nil,nil 5,1:ok:nil,nil,nil,nil 5,2:ok:nil,nil,nil,nil
        5,3:ok:nil,nil,nil,nil 5,4:ok:nil,nil,nil,nil 5,5:bad
        5,6:bad 5,7:bad 5,8:bad 5,9:bad 5,10:bad 5,11:bad

        6,0:ok:nil,nil,nil,nil 6,1:ok:nil,nil,nil,nil 6,2:ok:nil,nil,nil,nil
        6,3:ok:nil,nil,nil,nil 6,4:ok:nil,nil,nil,nil 6,5:ok:nil,nil,nil,nil
        6,6:bad 6,7:bad 6,8:bad 6,9:bad 6,10:bad 6,11:bad

        7,0:ok:nil,nil,nil,nil 7,1:ok:nil,nil,nil,nil 7,2:ok:nil,nil,nil,nil
        7,3:ok:nil,nil,nil,nil 7,4:ok:nil,nil,nil,nil 7,5:ok:nil,nil,nil,nil
        7,6:ok:nil,nil,nil,nil 7,7:ok:1265,nil,nil,nil 7,8:ok:1265,nil,nil,nil
        7,9:ok:1265,165,nil,nil 7,10:ok:1265,165,nil,nil 7,11:bad

        8,0:ok:nil,nil,nil,nil 8,1:ok:nil,nil,nil,nil 8,2:ok:nil,nil,nil,nil
        8,3:ok:nil,nil,nil,nil 8,4:ok:nil,nil,nil,nil 8,5:ok:nil,nil,nil,nil
        8,6:ok:nil,nil,nil,nil 8,7:ok:nil,nil,nil,nil 8,8:bad 8,9:bad 8,10:bad 8,11:bad

        9,0:ok:nil,nil,nil,nil 9,1:ok:nil,nil,nil,nil 9,2:ok:nil,nil,nil,nil
        9,3:ok:nil,nil,nil,nil 9,4:ok:nil,nil,nil,nil 9,5:ok:nil,nil,nil,nil
        9,6:ok:nil,nil,nil,nil 9,7:ok:nil,nil,nil,nil 9,8:ok:nil,nil,nil,nil
        9,9:ok:165,nil,nil,nil 9,10:ok:165,nil,nil,nil 9,11:bad

        10,0:ok:nil,nil,nil,nil 10,1:ok:nil,nil,nil,nil 10,2:ok:nil,nil,nil,nil
        10,3:ok:nil,nil,nil,nil 10,4:ok:nil,nil,nil,nil 10,5:ok:nil,nil,nil,nil
        10,6:ok:nil,nil,nil,nil 10,7:ok:nil,nil,nil,nil 10,8:ok:nil,nil,nil,nil
        10,9:ok:nil,nil,nil,nil 10,10:bad 10,11:bad

        11,0:ok:nil,nil,nil,nil 11,1:ok:nil,nil,nil,nil 11,2:ok:nil,nil,nil,nil
        11,3:ok:nil,nil,nil,nil 11,4:ok:nil,nil,nil,nil 11,5:ok:nil,nil,nil,nil
        11,6:ok:nil,nil,nil,nil 11,7:ok:nil,nil,nil,nil 11,8:ok:nil,nil,nil,nil
        11,9:ok:nil,nil,nil,nil 11,10:ok:nil,nil,nil,nil 11,11:bad]]):gsub('%s+', '\n'))
end


do --- len
  local s = '佮ൡӱ¥'
  assert(#s == 10)
  assert(utf8.len(s) == 4)
  assert(not pcall(utf8.len, s, 0))

  local t = {}
  for i = 1, #s+1 do
    local a, b = utf8.len(s, i)
    t[#t+1] = string.format('%d:%s,%s', i, a, b)
  end
  assert(table.concat(t, '\n') ==
         ([[1:4,nil 2:nil,2 3:nil,3 4:3,nil 5:nil,5 6:nil,6
            7:2,nil 8:nil,8 9:1,nil 10:nil,10 11:0,nil]]):gsub('%s+', '\n'))

  assert(not pcall(utf8.len, s, #s+2))

  t = {}
  for i = 1, #s+1 do
    for j = 1, #s do
      local a, b = utf8.len(s, i, j)
      t[#t+1] = string.format('%d,%d:%s,%s', i, j, a, b)
    end
  end
  assert(table.concat(t, '\n') ==
         ([[1,1:1,nil 1,2:1,nil 1,3:1,nil 1,4:2,nil 1,5:2,nil
            1,6:2,nil 1,7:3,nil 1,8:3,nil 1,9:4,nil 1,10:4,nil
          2,1:0,nil 2,2:nil,2 2,3:nil,2 2,4:nil,2 2,5:nil,2
          2,6:nil,2 2,7:nil,2 2,8:nil,2 2,9:nil,2 2,10:nil,2
          3,1:0,nil 3,2:0,nil 3,3:nil,3 3,4:nil,3 3,5:nil,3
          3,6:nil,3 3,7:nil,3 3,8:nil,3 3,9:nil,3 3,10:nil,3
          4,1:0,nil 4,2:0,nil 4,3:0,nil 4,4:1,nil 4,5:1,nil
          4,6:1,nil 4,7:2,nil 4,8:2,nil 4,9:3,nil 4,10:3,nil
          5,1:0,nil 5,2:0,nil 5,3:0,nil 5,4:0,nil 5,5:nil,5
          5,6:nil,5 5,7:nil,5 5,8:nil,5 5,9:nil,5 5,10:nil,5
          6,1:0,nil 6,2:0,nil 6,3:0,nil 6,4:0,nil 6,5:0,nil
          6,6:nil,6 6,7:nil,6 6,8:nil,6 6,9:nil,6 6,10:nil,6
          7,1:0,nil 7,2:0,nil 7,3:0,nil 7,4:0,nil 7,5:0,nil
          7,6:0,nil 7,7:1,nil 7,8:1,nil 7,9:2,nil 7,10:2,nil
          8,1:0,nil 8,2:0,nil 8,3:0,nil 8,4:0,nil 8,5:0,nil
          8,6:0,nil 8,7:0,nil 8,8:nil,8 8,9:nil,8 8,10:nil,8
          9,1:0,nil 9,2:0,nil 9,3:0,nil 9,4:0,nil 9,5:0,nil
          9,6:0,nil 9,7:0,nil 9,8:0,nil 9,9:1,nil 9,10:1,nil
          10,1:0,nil 10,2:0,nil 10,3:0,nil 10,4:0,nil 10,5:0,nil
          10,6:0,nil 10,7:0,nil 10,8:0,nil 10,9:0,nil 10,10:nil,10
          11,1:0,nil 11,2:0,nil 11,3:0,nil 11,4:0,nil 11,5:0,nil
          11,6:0,nil 11,7:0,nil 11,8:0,nil 11,9:0,nil 11,10:0,nil]]):gsub('%s+', '\n'))
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
