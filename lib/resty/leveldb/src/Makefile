LEVELDB_INCS = -I../deps/leveldb@3080a4/include
LEVELDB_LIB_DIR = -L../deps/leveldb@3080a4/out-static
CFLAGS = -lleveldb -Wunused-result -lpthread -std=c++11 -stdlib=libc++

ifeq ($(shell uname), "Linux")
	SharedLib = "liblua_leveldb.a"
else
	SharedLib = "liblua_leveldb.dylib"
endif

OBJS = lua_leveldb.o

$(SharedLib): $(OBJS)
	g++ -shared -o $(SharedLib) $(OBJS) $(LEVELDB_LIB_DIR) $(CFLAGS)

lua_leveldb.o: lua_leveldb.h lua_leveldb.cc
	g++ ${LEVELDB_INCS} -c lua_leveldb.cc

clean:
	rm -fr *.o $(SharedLib)
