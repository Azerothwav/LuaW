local copas = require('copas')
local parser = require('utils.parser')
local router = require('handlers.router')
local renderer = require('utils.renderer')

router.add_route('GET', '/page', function(client, request)
   local html = renderer.render('page.html', { title = 'Page' })

   copas.send(client, parser.html_response(200, html))
end)

