local ffi = require("ffi")
local C = ffi.C

if ffi.os == "OSX" then
  path = "out-shared/libleveldb.dylib"
else
  path = "out-shared/libleveldb.so"
end

local first = ffi.load(path)

ffi.cdef[[
  int add(int a, int b);
  void free(void* ptr);
]]

io.write(string.format("11 + 22 = %d\n", first.add(11, 22)))
