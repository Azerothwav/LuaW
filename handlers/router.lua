local logger = require("middlewares.logger")
local parser = require("middlewares.parser")
local error_handler = require("handlers.errors")

local router = {}
local routes = {
	["GET"] = {},
	["POST"] = {},
}

router.add_route = function(method, routeName, handler)
	method = string.upper(method)
	routes[method][routeName] = handler
end

router.handle = function(client)
	local request, error = parser.request(client)
	if error then
		print(error)
	end
	if not request then
		error_handler.bad_request(client)
		return
	end

	logger.request(request.method, request.path)

	local handler = routes[request.method] and routes[request.method][request.path]
	if not handler then
		error_handler.not_found(client)
		return
	end

	handler(client, request)
end

return router
