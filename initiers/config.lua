local config = {
  host = "0.0.0.0",
  port = 8080,
  debug = false,
  jwt_secret = function()
    return os.getenv("JWT_SECRET") or "fallback-secret"
  end,
  files_path = "./uploads" -- Example : /home/azeroth/Documents/LuaW/uploads
}

local function parse_args()
  for _, arg in ipairs(arg) do
    if arg:find("--server=") == 1 then
      config.host = arg:match("--server=(.+)")
    elseif arg:find("--port=") == 1 then
      config.port = tonumber(arg:match("--port=(.+)"))
    elseif arg:find("--debug") then
      config.debug = true
    elseif arg == "--help" then
      print("Usage: lua main.lua [options]")
      print("Options:")
      print("  --server=HOST  IP address (default: 0.0.0.0)")
      print("  --port=PORT    Port (default: 8080)")
      print("  --debug        Debug mode")
      print("  --help         Show help")
      os.exit(0)
    elseif arg == "--routes" then
      require("handlers.router").show_routes()
    end
  end
end

return {
  parse_args = parse_args,
  host = function()
    return config.host
  end,
  port = function()
    return config.port
  end,
  debug = function()
    return config.debug
  end,
  jwt_secret = config.jwt_secret,
  files_path = config.files_path
}
