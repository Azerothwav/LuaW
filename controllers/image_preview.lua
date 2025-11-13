local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local sql = require('database.connect')
local verify_args = require('utils.verify_args')
local sql_utility = require('database.utility')
local files = require('utils.file')
local renderer = require('utils.renderer')
local config = require('initiers.config')

router.add_route('GET', '/image_preview/:image_name', function(client, request)
   verify_args(client, { value = request.params.image_name, type = 'string' })

   local file_data = files.file_exists(string.format('static/images/%s', request.params.image_name))
   if not file_data then
      copas.send(client, parser.json_response(400, {
         status = 'failed',
         code = 400,
         message = 'File does not exist on server',
         timestamp = os.time()
      }))
   else
      local html = renderer.raw_render('image-preview.html', {
         image_name = request.params.image_name,
         host = string.format('%s:%s', config.real_host(), config.port())
      })

      copas.send(client, parser.html_response(200, html))
   end
end)
