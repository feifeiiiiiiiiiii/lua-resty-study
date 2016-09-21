local conf  = require "./conf"
local util  = require "./util"

local dispatch = {}
local dispatch_cache = ngx.shared.dispatch_cache

local ngx_now = ngx.now
local json_encode = util.json_encode
local json_decode = util.json_decode
local write_logger = util.write_logger

local function running(v)
  local before, doing, after

  before = function(o)
    if not o then
      return nil
    end

    local key = o["cache_name"]
    if not key then
      return nil
    end

    local value, flags = dispatch_cache:get(key)
    if value then
      return value
    end

    local http_endpoint = o["http_endpoint"]
    local method = o["method"]
    local data = o["data"]

    local status_code, time_escape, body = util.request(http_endpoint, method, data)
    if status_code == ngx.HTTP_OK then
      local expired = o["expired"]
      if not expired then
        expired = 7200
      end
      dispatch_cache:safe_add(key, body, expired)
    end
    return data
  end

  doing = function(before_obj_str, o)
    local obj, tag, method, data
    if not before_obj_str then
      before_obj_str = "{}"
    end
    local required = o["required"]
    if not required then
      required = {}
    end

    obj = json_decode(before_obj_str)
    local http_endpoint = o["http_endpoint"]
    if #required > 0 then
      http_endpoint = http_endpoint .. '?'
    end

    local new_http_endpoint
    for _, v in pairs(required) do
      local val = obj[v]
      if not val then
        val = ""
      end
      local function add(v0, v1)
        return v0 .. v1
      end
      http_endpoint = add(http_endpoint, v .. "=" .. val .. "&")
    end

    method = o["method"]
    data = o["data"]
    tag = o["tag"]
    local status_code, time_escape, body = util.request(http_endpoint, method, data)
    return {
      http_endpoint=http_endpoint,
      status_code=status_code,
      time_escape=time_escape,
      tag=tag,
      method=method
    }
  end

  after = function(doing_obj, o)
    local result = doing_obj
    write_logger(result, o["log_conf"])
  end
  return after(doing(before(v["before"]), v["doing"]), v["after"])
end

local function start(delay)
  local timer = ngx.timer
  local log = ngx.log
  local handler

  dispatch_cache:flush_all()

  handler = function(premature)
    if not premature then
      local ok, err = ngx.timer.at(delay, handler)
      if not ok then
        log(ngx.ERR, "failed to create timer: ", err)
      end
    end
    for k, v in pairs(conf) do
      ngx.thread.spawn(running, v)
    end
  end

  if 0 == ngx.worker.id() then -- just use a worker
    local ok, err = timer.at(delay, handler)
    if not ok then
      log(ngx.ERR, "failed to create timer: ", err)
    end
  end
end

function dispatch.init(second)
  start(second)
end

return dispatch
