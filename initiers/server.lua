local socket = require("socket")
local copas = require("copas")
local config = require("initiers.config")
local logger = require("middlewares.logger")

local function create_server()
	local server = socket.bind(config.host(), config.port())
	if not server then
		logger.error("Impossible de démarrer le serveur")
		return os.exit(1)
	end

	server:settimeout(0)
	return server
end

local function run(server)
	copas.addserver(server, function(client)
		copas.setErrorHandler(function(err)
			logger.error("Client handler: " .. tostring(err))
			if client then
				client:close()
			end
		end)

		require("handlers.router").handle(client)
	end)

	while true do
		copas.step(0.1)
		socket.sleep(0.01)
	end
end

return {
	create_server = create_server,
	run = run,
}
