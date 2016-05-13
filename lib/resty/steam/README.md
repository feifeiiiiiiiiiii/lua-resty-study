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

