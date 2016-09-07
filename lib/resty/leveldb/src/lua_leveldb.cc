#include "lua_leveldb.h"
#include <cassert>

LuaLeveldb::LuaLeveldb(const char *path, size_t max_open_files) {
  leveldb::Options options;
  options.create_if_missing = true;
  options.max_open_files = max_open_files;
  leveldb::Status status = leveldb::DB::Open(options, path, &db);
  assert(status.ok());
}

LuaLeveldb::~LuaLeveldb() {
  if(db) {
     delete db;
  }
}

const char *LuaLeveldb::get(const char *key) {
  std::string value;
  leveldb::Status s = db->Get(leveldb::ReadOptions(), key, &value);
  if(s.ok()) return value.c_str();
  return NULL;
}

int LuaLeveldb::set(const char *key, const char *value) {
  leveldb::Status s = db->Put(leveldb::WriteOptions(), key, value);
  if(s.ok()) return 1;
  return 0;
}

int LuaLeveldb::del(const char *key) {
  leveldb::Status s = db->Delete(leveldb::WriteOptions(), key);
  if(s.ok()) return 1;
  return 0;
}
