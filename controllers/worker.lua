local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local manager = require('workers.manager')

--[[
curl -X POST http://0.0.0.0:9000/new_task \
  -H "Content-Type: application/json"
--]]

router.add_route('POST', '/new_task', function(client, request)
   local task_id = manager.add_task(function()
      local config = require('initiers.config')
      print('This is a task executed on ' .. config.host())
   end, function()
      local config = require('initiers.config')
      print('This is a end task callback executed on ' .. config.host())
   end)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Your task have the id : ' .. task_id,
      timestamp = os.time()
   }))
end)
