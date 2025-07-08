local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')

router.add_route('GET', '/test', function(client, request)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Your test is good',
      timestamp = os.time()
   }))
end)
