ffi = require 'ffi'

if ffi.os == "OSX" then
  libpath = "../out-shared/libleveldb.dylib"
else
  libpath = "../out-shared/libleveldb.so"
end

ffi.cdef[[
  typedef struct RecordResponse_s {
    int code;
    int len;
    char *data;
  } RecordResponse;
  typedef struct LuaLeveldb LuaLeveldb;
  LuaLeveldb *new_leveldb(const char *path);
  void get(LuaLeveldb *db, const char *key, RecordResponse *record);
  int set(LuaLeveldb *db, const char *key, const char *value);
  int del(LuaLeveldb *db, const char *key);
  int insert(LuaLeveldb *db, const char *key, const char *value);
  int update(LuaLeveldb *db, const char *key, const char *value);
  void LuaLeveldb_gc(LuaLeveldb *this);
]]

local _M = {
  _VERSION = '0.0.1'
}

local commands = {
  "set", "del", "insert", "update"
}

local mt = { __index = _M }
local leveldb

function _M.get(self, key)
  local record = ffi.new("RecordResponse", {1})
  leveldb.get(self.super, key, record)
  if record.code == 0 then
    return ffi.string(record.data)
  else
    return nil
  end
end

for k, v in ipairs(commands) do
  _M[v] = function(self, ...)
    return leveldb[v](self.super, ...)
  end
end

function find_shared_obj(cpath, so_name)
  local string_gmatch = string.gmatch
  local string_match = string.match
  local io_open = io.open

  for k in string_gmatch(cpath, "[^;]+") do
    local so_path = string_match(k, "(.*/)")
    so_path = so_path .. so_name

    local f = io_open(so_path)
    if f ~= nil then
      io.close()
      return so_path
    end
  end
end

function load_leveldb()
  if leveldb ~= nil then
    return leveldb
  else
    local so_path = find_shared_obj(package.cpath, libpath)
    if so_path ~= nil then
      leveldb = ffi.load(so_path)
      return leveldb
    end
  end
end

function _M.new(self, path)
  if not leveldb then
    load_leveldb()
  end
  local self = {super=leveldb.new_leveldb(path)}
  ffi.gc(self.super, leveldb.LuaLeveldb_gc)
  return setmetatable(self, mt)
end

return _M
