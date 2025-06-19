local cron = require('utils.cron')
local copas = require('copas')
local logger = require('middlewares.logger')
local date = require('libs.date')

local execute_cron_task = function(file_path, uuid)
   local task_file, err = io.open(file_path, 'rb')
   if not task_file then
      logger.warn(('Cron task file missing (ID: %s): %s'):format(uuid, err))
      return false, 'file_missing'
   end

   local content = task_file:read('*all')
   task_file:close()

   if not content or content == '' then
      logger.warn(('Empty cron task file (ID: %s)'):format(uuid))
      return false, 'empty_file'
   end

   local fn, err = load(content)
   if not fn then
      logger.error(('Cron task load failed (ID: %s): %s'):format(uuid, err))
      return false, 'load_error'
   end

   local ok, result = pcall(fn)
   if not ok then
      logger.error(('Cron task execution failed (ID: %s): %s'):format(uuid, result))
   else
      logger.info(('Cron task executed successfully (ID: %s)'):format(uuid))
   end

   return ok, result
end

copas.addthread(function()
   while true do
      local now = date(true)
      local jobs = cron.get_jobs()

      for _, job in pairs(jobs) do
         local run_time = date(job.run_date)
         if now >= run_time then
            if execute_cron_task(job.file_path, job.uuid) then
               cron.remove_job(job.file_path)
            end
         end
      end

      copas.sleep(5)
   end
end)
