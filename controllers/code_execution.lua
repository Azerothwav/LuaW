local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local code_execution = require('utils.code_execution')

router.add_route('POST', '/ruby_execution', function(client, request)
   local sucess, result = code_execution.run_code('ruby', request.params.code)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Your code execution in ruby have ' .. (sucess and 'worked' or 'failed') .. ', the result of it is ' .. tostring(result),
      code_result = result,
      timestamp = os.time()
   }))
end)

router.add_route('POST', '/javascript_execution', function(client, request)
   local sucess, result = code_execution.run_code('node', request.params.code)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Your code execution in javascript have ' .. (sucess and 'worked' or 'failed') .. ', the result of it is ' ..
         tostring(result),
      code_result = result,
      timestamp = os.time()
   }))
end)
