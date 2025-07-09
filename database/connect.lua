local driver = require('luasql.mysql')
local sql_utility = require('database.utility')
local logger = require('middlewares.logger')

local connect = {}
local environment, connection
local db_hostname = os.getenv('DB_HOST') or 'mysql'
local db_port = os.getenv('DB_PORT') or '3306'
local db_name = os.getenv('DB_NAME') or 'luaw'
local db_user = os.getenv('DB_USER') or 'user'
local db_password = os.getenv('DB_PASSWORD') or 'userpassword'

local function create_environment()
   environment = driver.mysql()
   connection = environment:connect(db_name, db_user, db_password, db_hostname, db_port)

   if not connection then
      logger.error('Connection to dabase failed')
      error()
   end
end

local function close_environment()
   connection:close()
   environment:close()

   connection = nil
   environment = nil
end

connect.execute = function(sql_statement, callback)
   if environment == nil or connection == nil then
      local ok, _ = pcall(create_environment)
      if not ok then
         return
      end
   end

   callback(sql_utility.rows(connection, sql_statement))

   close_environment()
end

return connect
