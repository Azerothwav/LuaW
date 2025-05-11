local url = require("socket.url")
local copas = require("copas")
local json = require("json")
local parsers = {}

parsers.get_status_message = function(status_code)
	local status_messages = {
		[200] = "OK",
		[201] = "Created",
		[400] = "Bad Request",
		[401] = "Unauthorized",
		[403] = "Forbidden",
		[404] = "Not Found",
		[405] = "Method Not Allowed",
		[500] = "Internal Server Error",
	}
	return status_messages[status_code] or "Unknown Status"
end

parsers.json_response = function(status, data)
	local json_body = json.encode(data)
	return string.format(
		"HTTP/1.1 %d %s\r\n"
			.. "Content-Type: application/json\r\n"
			.. "Content-Length: %d\r\n"
			.. "Connection: close\r\n"
			.. "\r\n%s",
		status,
		parsers.get_status_message(status),
		#json_body,
		json_body
	)
end

parsers.query = function(query)
	local params = {}
	if not query then
		return params
	end

	for key, val in query:gmatch("([^&=]+)=([^&=]*)") do
		params[url.unescape(key)] = url.unescape(val)
	end
	return params
end

parsers.headers = function(client)
	local headers = {}
	while true do
		local line, err = copas.receive(client)
		if not line or line == "" or err then
			break
		end
		local key, value = line:match("^([%w-]+):%s*(.+)")
		if key then
			headers[key:lower()] = value
		end
	end
	return headers
end

parsers.read_post_body = function(client, headers)
	local content_length = tonumber(headers["content-length"]) or 0
	if content_length <= 0 then
		return ""
	end

	local body, error = copas.receive(client, content_length)
	if error then
		print(error)
	end
	return body or ""
end

return parsers
