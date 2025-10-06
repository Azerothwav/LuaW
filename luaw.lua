package.path = package.path .. ';./libs/?.lua;./initiers/?.lua;./handlers/?.lua;./middlewares/?.lua'

local config = require('initiers.config')
local init_server = require('initiers.server')
local logger = require('middlewares.logger')

require('handlers.cron')
require('handlers.hot-reload')

require('controllers.test')
require('controllers.auth')
require('controllers.file')
require('controllers.cron')
require('controllers.short_url')
require('controllers.code_execution')
require('controllers.database')
require('controllers.page')

config.parse_args()
logger.init()

local server = init_server.create_server()

init_server.run(server)
