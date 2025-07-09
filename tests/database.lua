local http = require('copas.http')
local copas = require('copas')
local ltn12 = require('ltn12')
local json = require('libs.json')
local sql = require('database.connect')

describe('POST /database', function()
   setup(function()
      os.execute('lua luaw.lua --server=0.0.0.0 --port=9000 --debug=true &')
      os.execute('sleep 1')

      sql.insert('INSERT INTO `users` (`name`) VALUES ("luaw-test-database-1")')
   end)

   teardown(function()
      sql.delete('DELETE FROM users WHERE name = "luaw-test-database-1"')
      os.execute('sleep 1')
      os.execute('pkill -f \'lua luaw.lua --server=0.0.0.0 --port=9000\'')
   end)

   it('should return 200 and the correct uuid when sending correct value', function()
      local code_result, execution_result

      copas.addthread(function()
         local response_body = {}
         local body_table = {}
         local body = json.encode(body_table)

         local _, code = http.request {
            url = 'http://127.0.0.1:9000/database?name=luaw-test-database-1',
            method = 'GET',
            headers = { ['Content-Type'] = 'application/json', ['Content-Length'] = tostring(#body) },
            source = ltn12.source.string(body),
            sink = ltn12.sink.table(response_body)
         }

         code_result = code
         execution_result = json.decode(response_body[1]).uuids
      end)

      copas.loop()

      assert.are.equal(200, code_result)
      assert.not_nil(execution_result)
   end)
end)
