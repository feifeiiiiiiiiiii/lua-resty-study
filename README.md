# lua-resty-elasticsearch
使用OpenResty&amp;Lua写点es相关的东西来学习一下OpenResty&Lua

# lua-resty-leveldb
使用OpenResty&amp;Lua学习Leveldb相关的知识

# lua-resty-steam
封装Steam的API

```

lua_package_path "/path/?.lua;";

server {
  location /api {
    access_by_lua_block {
      local steam = require "resty.steam"
      local s = steam:new(steam_key)
      -- eg
      s:getPlayerSummaries(steamid)
    }
  }
}

```
