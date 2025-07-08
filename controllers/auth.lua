local jwt = require('libs.jwt')
local error_handler = require('handlers.errors')
local copas = require('copas')
local router = require('handlers.router')
local parser = require('utils.parser')
local config = require('initiers.config')
local auth_middleware = require('middlewares.auth')

local auth = {}

router.add_route('POST', '/login', function(client, request)
   local username = request.params.username
   local password = request.params.password

   if not username or not password then
      return error_handler.bad_request(client, 'Username and password required')
   end

   if username ~= 'admin' or password ~= 'password' then
      return error_handler.unauthorized(client, 'Invalid credentials')
   end

   local token = jwt.encode({
      username = username,
      nbf = os.time(),
      exp = os.time() + 3600 -- 1 hour
   }, config.jwt_secret())

   copas.send(client, parser.json_response(200, { token = token, expires_in = 3600 }))
   copas.close(client)
end)

router.add_route('POST', '/auth', auth_middleware.auth_middleware, function(client)
   client:send(parser.json_response(200, { message = 'You accessed a protected route!' }))
   client:close()
end)

return auth
