local http = require('copas.http')
local copas = require('copas')
local ltn12 = require('ltn12')
local json = require('libs.json')

describe('POST /ruby_execution', function()
   setup(function()
      os.execute('lua luaw.lua --server=0.0.0.0 --port=9000 --debug=true &')
      os.execute('sleep 1')
   end)

   teardown(function()
      os.execute('sleep 1')
      os.execute('pkill -f \'lua luaw.lua --server=0.0.0.0 --port=9000\'')
   end)

   it('should return 200 and the correct result when sending ruby code', function()
      local code_result, execution_result

      copas.addthread(function()
         local response_body = {}
         local body_table = { code = 'puts 3*9' }
         local body = json.encode(body_table)

         local ok, code = http.request {
            url = 'http://127.0.0.1:9000/ruby_execution',
            method = 'POST',
            headers = { ['Content-Type'] = 'application/json', ['Content-Length'] = tostring(#body) },
            source = ltn12.source.string(body),
            sink = ltn12.sink.table(response_body)
         }

         code_result = code
         execution_result = json.decode(response_body[1]).code_result
      end)

      copas.loop()

      assert.are.equal(200, code_result)
      assert.are.equal(27, tonumber(execution_result))
   end)
end)
