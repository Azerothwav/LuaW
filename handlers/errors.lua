local logger = require("middlewares.logger")
local config = require("initiers.config")
local copas = require("copas")
local parser = require("utils.parser")

local errors = {}

errors.send_error_response = function(client, status, error_data)
	if config.debug() then
		logger.error(string.format("%d %s: %s", status, parser.get_status_message(status), error_data.message or ""))
	end

	local response = {
		status = "error",
		code = status,
		message = error_data.message or parser.get_status_message(status),
		timestamp = os.time(),
	}

	if config.debug() and error_data.details then
		response.details = error_data.details
	end

	copas.send(client, parser.json_response(status, response))
	client:close()
end

errors.bad_request = function(client, details)
	errors.send_error_response(client, 400, {
		message = "Malformed request",
		details = details,
	})
	copas.close(client)
end

errors.not_found = function(client, details)
	errors.send_error_response(client, 404, {
		message = "Resource not found",
		details = details,
	})
end

errors.method_not_allowed = function(client, details)
	errors.send_error_response(client, 405, {
		message = "Unauthorized method",
		details = details,
	})
end

errors.internal_error = function(client, err)
	errors.send_error_response(client, 500, {
		message = "Internal server error",
		details = tostring(err),
	})
	copas.close(client)
end

errors.unauthorized = function(client, details)
	errors.send_error_response(client, 401, {
		message = "Authentication required",
		details = details,
	})
	copas.close(client)
end

return errors
