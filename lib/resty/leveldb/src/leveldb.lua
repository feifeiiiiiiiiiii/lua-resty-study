ffi = require 'ffi'

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
local leveldb

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

function find_shared_obj(cpath, so_name)
	local string_gmatch = string.gmatch
	local string_match = string.match
	local io_open = io.open

	for k in string_gmatch(cpath, "[^;]+") do
		print(k)
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
		local so_path = find_shared_obj(package.cpath, "libllua_leveldb.so")
		if so_path ~= nil then
			leveldb = ffi.load(so_path)
			return leveldb
		end
	end
end

function _M.new(self, path, max_open_files)
  if not leveldb then
		load_leveldb()
  end
  local self = {super=leveldb.new_leveldb(path, max_open_files)}
  ffi.gc(self.super, leveldb.LuaLeveldb_gc)
  return setmetatable(self, mt)
end

return _M
