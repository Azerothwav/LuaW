local socket = require('socket')
local copas = require('copas')
local config = require('initiers.config')
local logger = require('middlewares.logger')

local function package_verify()
   local packages = { 'socket', 'copas' }

   if config.jwt_secret() ~= 'fallback-secret' then
      table.insert(packages, 'luasec')
   end

   for _, v in pairs(packages) do
      local ok, _ = pcall(require, v)
      if not ok then
         return false, v
      end
   end

   return true
end

local function create_server()
   local packages_correct, error = package_verify()
   if not packages_correct then
      print('Missing package : ' .. error)
      return os.exit(1)
   end

   local server = socket.bind(config.host(), config.port())
   if not server then
      logger.error('Server can\'t launch')
      return os.exit(1)
   end

   server:settimeout(0)
   return server
end

local function run(server)
   copas.addserver(server, function(client)
      require('handlers.router').handle(client)
   end)

   copas.setErrorHandler(function(err)
      logger.error('Client handler: ' .. tostring(err))
   end)

   while true do
      copas.step()
   end
end

return { create_server = create_server, run = run }
