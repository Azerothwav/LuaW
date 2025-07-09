local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local sql = require('database.connect')
local verify_args = require('utils.verify_args')
local sql_utility = require('database.utility')

router.add_route('GET', '/database', function(client, request)
   verify_args(client, { value = request.params.name, type = 'string' })

   sql.execute(string.format('SELECT * FROM users WHERE name = "%s"', sql_utility.sanitize(request.params.name)), function(result)
      local uuids = {}
      for _, entry in ipairs(result) do
         table.insert(uuids, tostring(entry.uuid))
      end

      copas.send(client, parser.json_response(200, {
         status = 'sucess',
         code = 200,
         message = result and string.format('UUID(s) of %s : %s', request.params.name, table.concat(uuids, ', ')) or 'No result',
         timestamp = os.time()
      }))
   end)
end)
