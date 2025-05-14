local logger = require("middlewares.logger")
local parser = require("middlewares.parser")
local error_handler = require("handlers.errors")
local parser_util = require("utils.parser")

local router = {}
local routes = {
	["GET"] = {},
	["POST"] = {},
}

router.add_route = function(method, routeName, ...)
	method = string.upper(method)
	routes[method][routeName] = { ... }
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

	local handlers = routes[request.method] and routes[request.method][request.path]
	if not handlers then
		error_handler.not_found(client)
		return
	end

	for _, v in pairs(handlers) do
		local have_succed, route_error = v(client, request)
		if have_succed ~= nil and not have_succed then
			client:send(parser_util.json_response(400, {
				status = "error",
				message = route_error,
			}))
			client:close()
			break
		end
	end
end

router.show_routes = function()
	print("All routes available :")
	for method, all_routes in pairs(routes) do
		print("\n-- " .. method .. " --")
		for route_name, _ in pairs(all_routes) do
			print("- " .. route_name)
		end
	end
end

return router
