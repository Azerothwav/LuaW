local config = require('initiers.config')
local logger = {}

logger.init = function()
   if config.debug() then
      print('== Debug mode activated ==')
   end
end

logger.info = function(message)
   if config.debug() then
      print(string.format('[%s] INFO: %s', os.date('%Y-%m-%d %H:%M:%S'), message))
   end
end

logger.warn = function(message)
   print(string.format('[%s] WARN: %s', os.date('%Y-%m-%d %H:%M:%S'), message))
end

logger.error = function(message)
   io.stderr:write(string.format('[%s] ERROR: %s\n', os.date('%Y-%m-%d %H:%M:%S'), message))
end

logger.request = function(method, path, ip, port)
   if config.debug() then
      print(string.format('[%s] {%s:%s} %s %s', os.date('%H:%M:%S'), ip, port, method, path))
   end
end

return logger
