local manager = {}
local workers = {}
local tasks = {}
local router = require('handlers.router')
local copas = require('copas')
local parser = require('utils.parser')
local uuid = require('utils.uuid')
local http = require('copas.http')
local json = require('libs.json')
local shared = require('workers.shared')
local config = require('initiers.config')
local ltn12 = require('ltn12')
local logger = require('middlewares.logger')

router.add_route('POST', '/new_worker', function(client, request)
   table.insert(workers, {
      name = 'worker#' .. #workers,
      server = request.params.ip .. ':' .. request.params.port,
      busy = false
   })
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Worker added',
      timestamp = os.time()
   }))
end)

manager.add_task = function(task, callback)
   local task_id = uuid()
   tasks[task_id] = { task = task, callback = callback, handled = false }

   return task_id
end

copas.addthread(function()
   while true do
      for k, v in pairs(workers) do
         local ok, have_connection = pcall(shared.heartbeat_check, v.server, true)
         if not have_connection then
            logger.warn(v.name .. ' is down, removing the worker...')
            table.remove(workers, k)
         end
      end
      copas.sleep(5)
   end
end)

copas.addthread(function()
   while true do
      if config.debug() then
         logger.info('Searching tasks, ' .. #workers .. ' workers available')
      end
      for k, v in pairs(tasks) do
         if not v.handled then
            logger.info('Handling task : ' .. k)
            for _, w in pairs(workers) do
               if not w.busy then
                  w.busy = true
                  v.handled = true
                  logger.info('Sending task : ' .. k .. ' to ' .. w.name)

                  copas.addthread(function()
                     local body = { task_id = k, task = string.dump(v.task) }

                     local bodyStr = json.encode(body)

                     local response, status = http.request({
                        method = 'POST',
                        url = 'http://' .. w.server .. '/task',
                        headers = {
                           ['Content-Type'] = 'application/json',
                           ['content-length'] = tostring(#bodyStr)
                        },
                        source = ltn12.source.string(bodyStr)
                     })

                     v.callback(response, status)

                     v.handled = status == 200
                     w.busy = false
                  end)
               end
            end
         end
      end
      copas.sleep(2)
   end
end)

manager.get_workers = function(text)
   if text then
      local workers_str = ''
      for _, v in pairs(workers) do
         workers_str = workers_str .. '[..v.ip..]' .. v.name .. '\n'
      end
      return workers_str
   else
      local workers_list = {}
      for _, v in pairs(workers) do
         table.insert(workers_list, { ip = v.ip, name = v.name })
      end
      return workers_list
   end
end

return manager
