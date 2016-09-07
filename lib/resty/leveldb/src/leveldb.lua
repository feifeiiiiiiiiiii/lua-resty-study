ffi = require 'ffi'
leveldb = ffi.load('lua_leveldb')

ffi.cdef[[
  typedef struct LuaLeveldb LuaLeveldb;
  LuaLeveldb *new_leveldb(const char *path, size_t max_open_files);
  const char *get(LuaLeveldb *db, const char *key);
  int set(LuaLeveldb *db, const char *key, const char *value);
  int del(LuaLeveldb *db, const char *key);
  void LuaLeveldb_gc(LuaLeveldb *this);
]]

local _M = {
  _VERSION = '0.0.1'
}

local mt = { __index = _M }

function _M.get(self, ...)
  val = leveldb.get(self.super, ...)
  if val == ffi.NULL then
    return nil
  end
  return ffi.string(val)
end

function _M.set(self, ...)
  return leveldb.set(self.super, ...)
end

function _M.del(self, ...)
  return leveldb.del(self.super, ...)
end

function _M.new(self, path, max_open_files)
  local self = {super=leveldb.new_leveldb(path, max_open_files)}
  ffi.gc(self.super, leveldb.LuaLeveldb_gc)
  return setmetatable(self, mt)
end

return _M
