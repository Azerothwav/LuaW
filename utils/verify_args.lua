local copas = require('copas')
local parser = require('utils.parser')

local function value_exist(table_values, expected_value)
   if type(table_values) ~= 'table' then
      table_values = { table_values }
   end
   for _, v in pairs(table_values) do
      if v == expected_value then
         return true
      end
   end
   return false
end

local function verify_args(client, ...)
   for _, args in pairs({ ... }) do
      if args.value == nil or type(args.value) ~= args.type or (args.should_be ~= nil and not value_exist(args.should_be, args.value)) then
         copas.send(client, parser.json_response(400,
                                                 {
            status = 'failure',
            code = 400,
            message = 'Argument incorrect',
            timestamp = os.time()
         }))

         error('Argument incorrect')
      end
   end
end

return verify_args
