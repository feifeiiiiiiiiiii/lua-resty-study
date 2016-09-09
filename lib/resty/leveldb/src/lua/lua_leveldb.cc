#include "lua_leveldb.h"
#include <cassert>

LuaLeveldb::LuaLeveldb(const char *path) {
  leveldb::Options options;
  options.create_if_missing = true;
  options.error_if_exists = false;
  options.write_buffer_size = 100 * 1024 * 1024;
  options.block_cache = cache_;
  options.compression = leveldb::kNoCompression;
  leveldb::Status status = leveldb::DB::Open(options, path, &db);
  assert(status.ok());
}

LuaLeveldb::~LuaLeveldb() {
  if(db) {
     delete db;
  }
}

void LuaLeveldb::get(const char *key, RecordResponse *record) {
  std::string value;
  leveldb::Status s = db->Get(leveldb::ReadOptions(), key, &value);
  if(s.ok()) {
    record->code = Success;
    record->len= value.size();
    memcpy(record->data, value.c_str(), value.size());
    return;
  }
  record->code = RecordNotFound;
}

int LuaLeveldb::set(const char *key, const char *value) {
  leveldb::WriteOptions write_opts;
  write_opts.sync = true;
  leveldb::Status s = db->Put(write_opts, key, value);
  if(s.ok()) return 1;
  return 0;
}

int LuaLeveldb::del(const char *key) {
  leveldb::WriteOptions options;
  options.sync = true;
  leveldb::Status s = db->Delete(options, key);
  if (s.IsNotFound()) {
    return 0;
  }
  if(s.ok()) return 1;
  return -1;
}
