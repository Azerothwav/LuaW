local copas = require('copas')
local parser = require('utils.parser')

local function verify_args(client, ...)
   for _, args in pairs({ ... }) do
      if args.value == nil or type(args.value) ~= args.type then
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
