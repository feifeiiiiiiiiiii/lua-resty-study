local leveldb = require("leveldb")

local db = leveldb:new("/tmp/db2")

db:set("hello12", "hello345")
print(db:get("hello12"))

db:insert("hello12", "hello567")
print(db:get("hello12"))

db:update("hello12", "hello567")
print(db:get("hello12"))

db:del("hello12")
print(db:get("hello12"))
