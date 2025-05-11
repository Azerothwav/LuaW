local config = require("initiers.config")
local logger = {}

logger.init = function()
	if config.debug() then
		print("== Debug mode activated ==")
	end
end

logger.info = function(message)
	print(string.format("[%s] INFO: %s", os.date("%Y-%m-%d %H:%M:%S"), message))
end

logger.error = function(message)
	io.stderr:write(string.format("[%s] ERROR: %s\n", os.date("%Y-%m-%d %H:%M:%S"), message))
end

logger.request = function(method, path)
	if config.debug() then
		print(string.format("[%s] %s %s", os.date("%H:%M:%S"), method, path))
	end
end

return logger
