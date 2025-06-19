local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local json = require('json')
local files = require('utils.file')

router.add_route('POST', '/file', function(client, request)
   for _, v in pairs(request.files) do
      files.store(v.data, v.filename)
   end
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Files created',
      timestamp = os.time()
   }))
end)

router.add_route('GET', '/file/:file_name', function(client, request)
   local file_data = files.retrieve(request.params.file_name)
   if not file_data then
      copas.send(client, parser.json_response(400, {
         status = 'failed',
         code = 400,
         message = 'File does not exist on server',
         timestamp = os.time()
      }))
   else
      copas.send(client, parser.json_response(200, {
         status = 'sucess',
         code = 200,
         message = 'File data : ' .. file_data,
         timestamp = os.time()
      }))
   end
end)

router.add_route('GET', '/files', function(client)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'Files on server : ' .. files.list(true),
      files = json.encode(files.list(false)),
      timestamp = os.time()
   }))
end)

router.add_route('DELETE', '/file', function(client, request)
   files.remove(request.params.file_name)
   copas.send(client, parser.json_response(200, {
      status = 'sucess',
      code = 200,
      message = 'File : ' .. request.params.file_name .. ' have been deleted',
      timestamp = os.time()
   }))
end)
