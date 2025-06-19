local config = {
   host = '0.0.0.0',
   port = 8080,
   debug = false,
   jwt_secret = function()
      return os.getenv('JWT_SECRET') or 'fallback-secret'
   end,
   files_path = './uploads', -- Example : /home/azeroth/Documents/LuaW/uploads
   worker_mode = false,
   worker_host = nil,
   worker_port = nil
}

local function parse_args()
   for _, arg in ipairs(arg) do
      if arg:find('--server=') == 1 then
         config.host = arg:match('--server=(.+)')
      elseif arg:find('--port=') == 1 then
         config.port = tonumber(arg:match('--port=(.+)'))
      elseif arg:find('--debug') then
         config.debug = true
      elseif arg:find('--worker_mode') then
         config.worker_mode = true
      elseif arg:find('--worker_host=') then
         config.worker_host = arg:match('--worker_host=(.+)')
      elseif arg:find('--worker_port=') then
         config.worker_port = arg:match('--worker_port=(.+)')
      elseif arg == '--help' then
         print('Usage: lua main.lua [options]')
         print('Options:')
         print('  --server=HOST  IP address (default: 0.0.0.0)')
         print('  --port=PORT    Port (default: 8080)')
         print('  --debug        Debug mode')
         print('  --help         Show help')
         print('  --worker_mode  Active worker mode')
         print('  --worker_host  IP address of the main server')
         print('  --worker_port  Port of the main server')
         os.exit(0)
      elseif arg == '--routes' then
         require('handlers.router').show_routes()
      end
   end
end

return {
   parse_args = parse_args,
   host = function()
      return config.host
   end,
   port = function()
      return config.port
   end,
   debug = function()
      return config.debug
   end,
   jwt_secret = config.jwt_secret,
   files_path = config.files_path,
   worker_mode = function()
      return config.worker_mode
   end,
   worker_host = function()
      return config.worker_host
   end,
   worker_port = function()
      return config.worker_port
   end
}
