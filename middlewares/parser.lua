local url = require("socket.url")
local parserUtil = require("utils.parser")
local copas = require("copas")

local parser = {}

parser.request = function(client)
	local request_line, error = copas.receive(client)
	if error then
		print(error)
	end
	if not request_line then
		return nil, "Failed to read request line"
	end

	local method, path = request_line:match("^(%u+)%s+(.-)%s+HTTP/[%d%.]+$")
	if not method then
		return nil, "Invalid request line"
	end

	local headers = parserUtil.headers(client)
	local parsed_url = url.parse(path)
	local params, body

	if method == "GET" then
		params = parserUtil.query(parsed_url.query)
	elseif method == "POST" then
		body = parserUtil.read_post_body(client, headers)
		if headers["content-type"] and headers["content-type"]:find("application/x-www-form-urlencoded") then
			params = parserUtil.query(body)
		end
	end

	return {
		method = method,
		path = parsed_url.path or "/",
		query = parsed_url.query,
		headers = headers,
		params = params or {},
		body = body,
	}
end

return parser
