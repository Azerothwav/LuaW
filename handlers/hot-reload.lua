local copas = require('copas')
local lfs = require('lfs')
local logger = require('middlewares.logger')
local files = require('utils.file')

local watched_files = {}

local function watch_folder(folder)
   for file in lfs.dir(folder) do
      local full_path = folder .. '/' .. file
      local attr = lfs.attributes(full_path)
      if attr then
         watched_files[full_path] = { last_modified = attr.modification }
         logger.info(string.format('Watching %s', full_path))
      end
   end
end

local function recompile_tailwind()
   if not files.file_exists('tailwind.config.js') then
      return
   end

   local cmd = 'npx tailwindcss -c tailwind.config.js -o static/css/tailwind.css --minify'
   os.execute(cmd)
end

local function reload_file_if_changed(path)
   local attr = lfs.attributes(path)
   if attr then
      if attr.modification > (watched_files[path].last_modified or 0) then
         logger.info(string.format('Hot-Reload of %s', path))
         watched_files[path].last_modified = attr.modification
         if path:match('%.lua$') then
            local ok, result = pcall(dofile, path)
            if not ok then
               logger.error(string.format('Error while reloading %s %s', path, result))
            end
         end
         if string.find(path, 'views') then
            recompile_tailwind()
         end
      end
   else
      logger.error(string.format('File not available %s', path))
   end
end

watch_folder('controllers')
watch_folder('views')

copas.addthread(function()
   while true do
      for file in pairs(watched_files) do
         reload_file_if_changed(file)
      end

      copas.sleep(1)
   end
end)
