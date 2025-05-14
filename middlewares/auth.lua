local jwt = require("libs.jwt")
local config = require("initiers.config")
local auth = {}

auth.auth_middleware = function(client, req)
	local auth_header = req.headers["authorization"]
	if not auth_header then
		return false, "Missing authorization header"
	end

	local token = auth_header:match("Bearer%s+(.+)")
	if not token then
		return false, "Invalid authorization format"
	end

	local decoded, error = jwt.decode(token, config.jwt_secret(), true)
	if not decoded then
		return false, error or "Invalid token"
	end

	req.user = decoded
	return true
end

return auth
