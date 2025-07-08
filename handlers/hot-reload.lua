local copas = require('copas')
local lfs = require('lfs')
local logger = require('middlewares.logger')

local watched_files = {}

local function watch_folder(folder)
   for file in lfs.dir(folder) do
      if file:match('%.lua$') then
         local full_path = folder .. '/' .. file
         local attr = lfs.attributes(full_path)
         if attr then
            watched_files[full_path] = { last_modified = attr.modification }
            logger.info(string.format('Watching %s', full_path))
         end
      end
   end
end

local function reload_file_if_changed(path)
   local attr = lfs.attributes(path)
   if attr then
      if attr.modification > (watched_files[path].last_modified or 0) then
         logger.info(string.format('Hot-Reload of %s', path))
         watched_files[path].last_modified = attr.modification
         dofile(path)
      end
   else
      logger.error(string.format('File not available %s', path))
   end
end

watch_folder('controllers')

copas.addthread(function()
   while true do
      for file in pairs(watched_files) do
         reload_file_if_changed(file)
      end

      copas.sleep(5)
   end
end)
