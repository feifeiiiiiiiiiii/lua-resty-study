local leveldb = require("../leveldb")

local db = leveldb:new("/tmp/db2", 2000)

db:set("hello", "world")
for i = 1, 1000 do
  print(db:get("hello"))
end
