# lua-resty-steam

使用Openresty&Lua封装[Steam Web API](https://developer.valvesoftware.com/wiki/Steam_Web_API).

# 用法

local http = require "resty.steam.steam"

# API

## new

`语法: s = steam:new(key)`

接收`参数`如下:

* `key` steam平台上申请的key.

## getFriendList

`语法: s:getFriendList(steamid)`

返回steamid的好友列表id

接收`参数`如下:

* `steamid` steam平台上对应的用户唯一id.

## getPlayerSummaries

`语法: s:getPlayerSummaries(steamids)`

返回用户的详细信息

接收`参数`如下:

* `steamids` steam平台的用户id,查找多个使用逗号分隔.

## getOwnedGames

`语法: s:getOwnedGames(steamid)`

返回用户拥有的游戏列表

接收`参数`如下:

* `steamid` steam平台的用户id.

## getRecentlyPlayedGames

`语法: s:getRecentlyPlayedGames(steamid)`

返回用户最近两周玩过的游戏列表

接收`参数`如下:

* `steamid` steam平台的用户id.

## getSchemaForGame

`语法: s:getSchemaForGame(appid)`

返回游戏为appid的详细信息

接收`参数`如下:

* `appid` steam平台的游戏id.

