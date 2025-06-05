local shared = {}
local router = require('handlers.router')
local copas = require('copas')
local parser = require('utils.parser')
local http = require('copas.http')

router.add_route("GET", "/heartbeat", function(client, request)
  copas.send(
    client,
    parser.json_response(200, {
      status = "sucess",
      code = 200,
      message = "Host up",
      timestamp = os.time(),
    })
  )
end)

shared.heartbeat_check = function(server)
  local response, status = http.request({
    method = "GET",
    url = string.format("http://%s/heartbeat", server),
    headers = {
      ["Content-Type"] = "application/json",
    },
    timeout = 5
  })

  return response ~= nil and status == 200
end

return shared
