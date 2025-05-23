package.path = package.path .. ";./libs/?.lua;./initiers/?.lua;./handlers/?.lua;./middlewares/?.lua"

local config = require("initiers.config")
local init_server = require("initiers.server")
local logger = require("middlewares.logger")

require("controllers.test")
require("controllers.auth")

config.parse_args()
logger.init()

local server = init_server.create_server()

print(string.format("\nServer HTTP launched on http://%s:%d", config.host(), config.port()))
print("Press Ctrl+C to stop\n")

init_server.run(server)
