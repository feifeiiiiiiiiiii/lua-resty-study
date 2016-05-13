local http = require "resty.http"
local httpc = http.new()

local _M = {
  _VERSION = '0.0.1'
}

local mt = { __index = _M }

function _M.new(self, key)
  local args = {
    api = 'http://api.steampowered.com',
    key=key,
  }
  return setmetatable(args, mt)
end

local function makeRequest(self, path, args)
  local q = nil
  for k, v in pairs(args) do
    local s = k .. '=' .. v
    if(not q) then
      q = s
    else
      q = q .. '&' .. s
    end
  end
  if(not q) then
    q = ''
  end
  return self.api .. path .. '?' .. q
end

local function request(self, url)
  local res, err = httpc:request_uri(url)
  ngx.header['Content-Type'] = 'application/json'
  if res.status == ngx.HTTP_OK then
    ngx.say(res.body)
  else
    ngx.exit(res.status)
  end
end

function _M.getFriendList(self, steamid)
  local args = {
    steamid = steamid,
    key = self.key
  }
  return request(self, makeRequest(self, "/ISteamUser/GetFriendList/v0001/", args))
end

function _M.getPlayerSummaries(self, steamids)
  local args = {
    steamids = steamids,
    key = self.key
  }
  return request(self, makeRequest(self, "/ISteamUser/GetPlayerSummaries/v0002/", args))
end

return _M
