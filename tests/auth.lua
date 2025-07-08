local http = require('copas.http')
local copas = require('copas')
local ltn12 = require('ltn12')
local json = require('libs.json')

describe('POST /login and /auth', function()
   setup(function()
      os.execute('lua luaw.lua --server=0.0.0.0 --port=9000 --debug=true &')
      os.execute('sleep 1')
   end)

   teardown(function()
      os.execute('sleep 1')
      os.execute('pkill -f \'lua luaw.lua --server=0.0.0.0 --port=9000\'')
   end)

   it('should return 200 when sending valid credentials', function()
      local code_result

      copas.addthread(function()
         local response_body = {}
         local body_table = { username = 'admin', password = 'password' }
         local body = json.encode(body_table)

         local ok, code = http.request {
            url = 'http://127.0.0.1:9000/login',
            method = 'POST',
            headers = { ['Content-Type'] = 'application/json', ['Content-Length'] = tostring(#body) },
            source = ltn12.source.string(body),
            sink = ltn12.sink.table(response_body)
         }

         code_result = code
      end)

      copas.loop()

      assert.are.equal(200, code_result)
   end)

   it('should return 200 when sending a valid token throuhgt auth middleware', function()
      local code_result, token

      copas.addthread(function()
         local response_body = {}
         local body_table = { username = 'admin', password = 'password' }
         local body = json.encode(body_table)

         local ok, code = http.request {
            url = 'http://127.0.0.1:9000/login',
            method = 'POST',
            headers = { ['Content-Type'] = 'application/json', ['Content-Length'] = tostring(#body) },
            source = ltn12.source.string(body),
            sink = ltn12.sink.table(response_body)
         }

         code_result = code
         token = json.decode(response_body[1]).token
      end)

      copas.loop()

      assert.are.equal(200, code_result)
      assert.not_nil(token)

      local code_result2

      copas.addthread(function()
         local response_body = {}
         local body_table = { token = token }
         local body = json.encode(body_table)

         local ok, code = http.request {
            url = 'http://127.0.0.1:9000/auth',
            method = 'POST',
            headers = {
               ['Content-Type'] = 'application/json',
               ['Content-Length'] = tostring(#body),
               ['Authorization'] = 'Bearer ' .. token
            },
            source = ltn12.source.string(body),
            sink = ltn12.sink.table(response_body)
         }

         code_result2 = code
      end)

      copas.loop()

      assert.are.equal(200, code_result2)
   end)
end)
