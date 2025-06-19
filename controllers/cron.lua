local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local json = require('json')
local cron = require('utils.cron')
local date = require('libs.date')

router.add_route('POST', '/new_cron', function(client, request)
   local cron_uuid = cron.add_job(date(true):addminutes(5), function()
      print('Executed')
   end)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'New cron task created : ' .. cron_uuid,
      timestamp = os.time()
   }))
end)

router.add_route('GET', '/get_cron_tasks', function(client, request)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Cron tasks planned : ' .. json.encode(cron.get_jobs()),
      timestamp = os.time()
   }))
end)
