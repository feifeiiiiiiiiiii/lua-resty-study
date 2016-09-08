#################################################################
#
#      Binaries we are going to build, and its source code
#
#################################################################
#
OS := $(shell uname)

SRC := lua_leveldb.cc
OBJ := $(SRC:.c=.o)

ifeq ($(OS), Darwin)
C_SO_NAME := libllua_leveldb.dylib
else
C_SO_NAME := libllua_leveldb.so
endif

#################################################################
#
#       Compile and link flags
#
#################################################################
#
CFLAGS := -Wall -O3 -flto -g -DFP_RELAX=0 #-DDEBUG
THE_CFLAGS := $(CFLAGS) -fPIC -MMD -fvisibility=hidden

#################################################################
#
#       Installtion flags
#
#################################################################
#
PREFIX := /usr/local
LUA_VERSION = 5.1
SO_TARGET_DIR := $(PREFIX)/lib/lua/$(LUA_VERSION)
LUA_TARGET_DIR := $(PREFIX)/share/lua/$(LUA_VERSION)/

LEVELDB_PREFIX := ../deps/leveldb@3080a4
LEVELDB_LIB_DIR := $(LEVELDB_PREFIX)/out-shared
LEVELDB_INCLUDE_DIR := $(LEVELDB_PREFIX)/include

#################################################################
#
#       Make recipes
#
#################################################################
#
.PHONY = all test clean install

all : $(C_SO_NAME)

${C_SO_NAME} : ${OBJ}
	$(CC) $(THE_CFLAGS) -L${LEVELDB_LIB_DIR} -lleveldb -I${LEVELDB_INCLUDE_DIR} -DBUILDING_SO $^ -shared -o $@

clean:; rm -f *.o *.so a.out *.d

install:
	install -D -m 755 $(C_SO_NAME) $(DESTDIR)/$(SO_TARGET_DIR)/$(C_SO_NAME)
	install -D -m 664 json_decoder.lua  $(DESTDIR)/$(LUA_TARGET_DIR)/json_decoder.lua
