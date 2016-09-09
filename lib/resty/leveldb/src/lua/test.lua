local leveldb = require("leveldb")

local db = leveldb:new("/tmp/db2")

for i = 1, 1000 do
  local ok = db:set("hello3", "foo")
  print(db:get("hello3"))
end
