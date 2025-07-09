local task = { worker_connected = false, host_ip = nil, host_port = nil }
local router = require('handlers.router')
local copas = require('copas')
local parser = require('utils.parser')
local config = require('initiers.config')
local json = require('libs.json')
local http = require('copas.http')
local shared = require('workers.shared')
local ltn12 = require('ltn12')
local logger = require('middlewares.logger')

local function connect_to_host()
   local body = { ip = config.host(), port = config.port() }

   local bodyStr = json.encode(body)

   local response, _ = http.request({
      method = 'POST',
      url = 'http://' .. config.worker_host() .. ':' .. config.worker_port() .. '/new_worker',
      headers = { ['content-type'] = 'application/json', ['content-length'] = tostring(#bodyStr) },
      source = ltn12.source.string(bodyStr),
      timeout = 5
   })

   return response ~= nil
end

task.connect_to_host = function()
   copas.addthread(function()
      local ok, have_connect = pcall(connect_to_host)
      if not ok then
         logger.error('Worker can\'t connect to host properly')
         os.exit(1)
         return
      end
      while not have_connect do
         logger.warn('Connection to host impossible, retry in 2s...')
         copas.sleep(2)

         ok, have_connect = pcall(connect_to_host)
         if not ok then
            logger.error('Worker can\'t connect to host properly')
            os.exit(1)
            return
         end
      end
      logger.info('Worker connected to host, waiting for task')
      task.worker_connected = true
   end)
end

if config.worker_mode() then
   copas.addthread(function()
      while true do
         local ok, have_connection = pcall(shared.heartbeat_check, config.worker_host() .. ':' .. config.worker_port(), false)
         if not ok then
            logger.error('Worker can\'t work properly')
            os.exit(1)
         end

         if not have_connection and task.worker_connected then
            task.worker_connected = false
            logger.warn('Worker is not connected anymore to the host, re-amorcing heartbeat')
         end

         if have_connection and not task.worker_connected then
            task.connect_to_host()
         end
         copas.sleep(5)
      end
   end)

   router.add_route('POST', '/task', function(client, request)
      local fn, err = load(request.params.task)
      if not fn then
         logger.error('Erreur de chargement de la fonction : ' .. err)
         return os.exit(0)
      end

      local task_function = fn()
      local ok, result = pcall(task_function)

      if ok then
         copas.send(client, parser.json_response(200, {
            status = 'sucess',
            code = 200,
            message = 'Task has been handled',
            result = result,
            task_id = request.params.task_id,
            timestamp = os.time()
         }))
      else
         copas.send(client, parser.json_response(200, {
            status = 'sucess',
            code = 200,
            message = 'Error when handling the task',
            error = result,
            task_id = request.params.task_id,
            timestamp = os.time()
         }))
      end
   end)
end

return task
