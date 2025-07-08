package.path = package.path .. ';./libs/?.lua;./initiers/?.lua;./handlers/?.lua;./middlewares/?.lua'

local config = require('initiers.config')
local init_server = require('initiers.server')
local logger = require('middlewares.logger')

require('handlers.cron')

require('controllers.test')
require('controllers.auth')
require('controllers.file')
require('controllers.cron')
require('controllers.short_url')
require('controllers.code_execution')

config.parse_args()
logger.init()

local server = init_server.create_server()

require('workers.shared')

if config.worker_mode() then
   require('workers.task')
   print(string.format('\nWorker launched on http://%s:%d', config.host(), config.port()))
   print('Press Ctrl+C to stop\n')
else
   require('workers.manager')
   require('controllers.worker')
   print(string.format('\nServer HTTP launched on http://%s:%d', config.host(), config.port()))
   print('Press Ctrl+C to stop\n')
end

init_server.run(server)
