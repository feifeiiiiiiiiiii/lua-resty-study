local url = require "resty.url"
local http  = require "resty.http"
local cjson = require "cjson"

local ngx_now = ngx.now
local util = {}

local function find_func(mod, funcnames)
  for _, v in ipairs(funcnames) do
    if mod[v] then
      return mod[v]
    end
  end

  return nil
end

local json_encode = find_func(cjson, { "encode", "Encode", "to_string", "stringify", "json" })
local json_decode = find_func(cjson, { "decode", "Decode", "to_value", "parse" })

local function get_now()
  return ngx_now() * 1000
end

local function generate_post_payload(method, parsed_url, body)
  return string.format(
    "%s %s HTTP/1.1\r\nHost: %s\r\nConnection: Keep-Alive\r\nContent-Type: application/json\r\nContent-Length: %s\r\n\r\n%s",
    method:upper(), parsed_url.path, parsed_url.host, string.len(body), body)
end

local function parse_url(host_url)
  local parsed_url = url.parse(host_url)
  if not parsed_url.port then
    if parsed_url.scheme == "http" then
      parsed_url.port = 80
    elseif parsed_url.scheme == "https" then
      parsed_url.port = 443
    end
  end
  if not parsed_url.path then
    parsed_url.path = "/"
  end
  return parsed_url
end

function util.request(http_endpoint, method, data, content_type)
  local httpc = http:new()
  local time_escape = 0
  local res, err, ok
  local now = get_now()

  local parsed_url = parse_url(http_endpoint)
  local host = parsed_url.host
  local port = parsed_url.port
  local path = parsed_url.path
  local scheme = parsed_url.scheme
  local query = parsed_url.query
  if query ~= nil then
    path = path .. "?" .. query
  end

  if not content_type then
    content_type = "application/json"
  end

  local params = {
    path=path,
    method=method,
    headers={
      ["Content-Type"]=content_type,
      ["Host"]=host
    }
  }
  if method == "POST" or method == "PUT" then
    params["body"] = data
  end

  ok, err = httpc:connect(host, port)
  if scheme == "https" then
    res, err = httpc:ssl_handshake(true, host, false)
    if err then
      return ngx.HTTP_SERVICE_UNAVAILABLE, time_escape, nil
    end
  end

  res, err = httpc:request(params)
  if not res then
    return ngx.HTTP_SERVICE_UNAVAILABLE, time_escape, nil
  end
  return res.status, get_now() - now, res:read_body()
end

function util.json_encode(v)
  return json_encode(v)
end

function util.json_decode(v)
  return json_decode(v)
end

function util.write_logger(data, log_conf)
  -- only support influxdb
  if not log_conf then
    return
  end

  local output, http_endpoint
  output = log_conf.output
  http_endpoint = log_conf.output_endpoint

  if output ~= "influxdb" then
    return
  end

  if not http_endpoint then
    return
  end

  local tags = {"status_code"}
  local field = {"http_endpoint", "method", "time_escape"}

  local line = data["tag"] .. ",status_code=" .. data["status_code"] .. " "
  local f, val
  for _, v in pairs(field) do
    local function add(v0, v1)
      return v0 .. v1
    end
    if f ~= nil then
      line = add(line, ",")
    end
    f = 1
    val = data[v]
    if type(data[v]) == 'string' then
      val = '"' .. data[v] .. '"'
    end
    line = add(line, v .. "=" .. val)
  end
  util.request(http_endpoint, "POST", line, "application/x-www-form-urlencoded")
end

return util
