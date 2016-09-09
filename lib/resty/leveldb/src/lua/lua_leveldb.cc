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
    record->data = (char *)malloc(sizeof(char)*record->len);
    memcpy(record->data, value.c_str(), value.size());
    return;
  }
  record->code = RecordNotFound;
}

int LuaLeveldb::set(const char *key, const char *value) {
  leveldb::WriteOptions write_opts;
  write_opts.sync = true;
  leveldb::Status s = db->Put(write_opts, key, value);
  if(s.ok()) return Success;
  return Error;
}

int LuaLeveldb::del(const char *key) {
  leveldb::WriteOptions options;
  options.sync = true;
  leveldb::Status s = db->Delete(options, key);
  if (s.IsNotFound()) {
    return RecordNotFound;
  }
  if(s.ok()) return Success;
  return Error;
}

int LuaLeveldb::insert(const char *key, const char *value) {
  leveldb::Status s;
  std::string record;

  s = db->Get(leveldb::ReadOptions(), key, &record);
  if(s.ok()) {
    return RecordExists;
  }

  leveldb::WriteOptions options;
  options.sync = true;
  s = db->Put(options, key, value);
  if(s.ok()) return Success;
  return Error;
}

int LuaLeveldb::update(const char *key, const char *value) {
  leveldb::Status s;
  std::string record;

  s = db->Get(leveldb::ReadOptions(), key, &record);
  if(s.IsNotFound()) {
    return RecordNotFound;
  }

  leveldb::WriteOptions options;
  options.sync = true;
  s = db->Put(options, key, value);
  if(s.ok()) return Success;
  return Error;
}

