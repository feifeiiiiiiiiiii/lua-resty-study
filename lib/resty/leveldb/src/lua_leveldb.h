#include "leveldb/db.h"
#include "leveldb/cache.h"
#include <iostream>
using namespace std;

class LuaLeveldb {
  public:
    LuaLeveldb(const char *path, size_t max_open_files);
    ~LuaLeveldb();
    const char *get(const char *key);
    int set(const char *key, const char *value);
    int del(const char *key);
  private:
    leveldb::DB* db;
};

extern "C" {
  LuaLeveldb *new_leveldb(const char *path, size_t max_open_files) {
    return new LuaLeveldb(path, max_open_files);
  }

  const char *get(LuaLeveldb *_this, const char *key) {
    return _this->get(key);
  }

  int set(LuaLeveldb *_this, const char *key, const char *value) {
    return _this->set(key, value);
  }

  int del(LuaLeveldb *_this, const char *key) {
    return _this->del(key);
  }

  void LuaLeveldb_gc(LuaLeveldb *_this) {
    delete _this;
  }
}
