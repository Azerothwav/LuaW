local copas = require('copas')
local socket = require('socket')
local http = require('copas.http')
local config = require('initiers.config')

local RPS = 30
local DURATION = 10

local HOST = config.host()
local PORT = 9000
local PATH = 'test'

local response_times = {}
local failures = 0

local function send_request()
   local start_time = socket.gettime()

   local _, code = http.request(string.format('http://%s:%s/%s', HOST, PORT, PATH))

   local elapsed = (socket.gettime() - start_time) * 1000

   if code and tostring(code):match('^2%d%d') then
      table.insert(response_times, elapsed)
   else
      failures = failures + 1
   end
end

local function scheduler()
   for s = 1, DURATION do
      for i = 1, RPS do
         copas.addthread(send_request)
      end
   end
end

copas.addthread(scheduler)
copas.loop()

local function stats()
   local n = #response_times
   if n == 0 then
      print('No successful requests.')
      return
   end

   local min, max, sum = response_times[1], response_times[1], 0
   for _, t in ipairs(response_times) do
      sum = sum + t
      if t < min then
         min = t
      end
      if t > max then
         max = t
      end
   end

   print('\n--- Results ---')
   print('Send request : ' .. RPS * DURATION)
   print('Successful: ' .. n)
   print('Failed:     ' .. failures)
   print(string.format('Average:   %.2f ms', sum / n))
   print(string.format('Min:       %.2f ms', min))
   print(string.format('Max:       %.2f ms', max))
end

stats()
