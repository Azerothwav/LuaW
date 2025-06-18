local copas = require("copas")
local parser = require("utils.parser")
local router = require("handlers.router")
local config = require("initiers.config")

local shorter_urls = {}

local generate_uuid = function()
  math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 9)))
  local template = 'xxxxxxyx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
    return string.format('%x', v)
  end)
end

router.add_route("POST", "/new_url", function(client, request)
  local url_to_short = request.params.url
  local new_uuid = generate_uuid()
  shorter_urls[new_uuid] = url_to_short
  copas.send(
    client,
    parser.json_response(200, {
      status = "sucess",
      code = 200,
      message = "http://" .. config.host()
          ..
          ":" .. config.port() .. "/shorter/" .. new_uuid,
      timestamp = os.time(),
    })
  )
end)

router.add_route("GET", "/shorter/:uuid", function(client, request)
  local uuid = request.params.uuid or nil
  if shorter_urls[uuid] == nil then
    copas.send(
      client,
      parser.json_response(400, {
        status = "failure",
        code = 400,
        message = "This url is unknown",
        timestamp = os.time(),
      })
    )
  else
    copas.send(
      client,
      parser.redirect_response(302, shorter_urls[uuid])
    )
  end
end)
