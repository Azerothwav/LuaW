local lustache = require('lustache')
local file = require('utils.file')

local Renderer = {}

function Renderer.load_template(view_name)
   return file.get_view(view_name)
end

function Renderer.render(name, context)
   local layout = Renderer.load_template('layout.html')
   local template = Renderer.load_template(name)
   if not template then
      error('Template not found: ' .. name)
   end

   local body = lustache:render(template, context or {})
   context.body = body

   local tailwind_css = file.get_static('css/tailwind.css') or ''
   context.tailwind = tailwind_css

   return lustache:render(layout, context)
end

function Renderer.raw_render(name, context)
   local template = Renderer.load_template(name)
   if not template then
      error('Template not found: ' .. name)
   end

   return lustache:render(template, context or {})
end

return Renderer
