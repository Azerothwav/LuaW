local copas = require("copas")
local parser = require("utils.parser")
local router = require("handlers.router")
local json = require("json")

router.add_route("GET", "/test", function(client, request)
	print(json.encode(request))
	copas.send(
		client,
		parser.json_response(200, {
			status = "sucess",
			code = 200,
			message = "Your test is good : " .. request.params.name,
			timestamp = os.time(),
		})
	)
end)
