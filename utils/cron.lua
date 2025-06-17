local uuid = require("utils.uuid")
local cron = {}
local logger = require("middlewares.logger")

cron.add_job = function(run_date, fun)
  local job_uuid = uuid()
  if run_date == nil then
    return logger.warn("Invalid date for creation of a new cron task")
  end
  local job_name = run_date .. "|" .. job_uuid

  local file = io.open("cron_tasks/" .. job_name, "wb")
  if not file then
    return nil, "Cound not open file for writing"
  end

  file:write(string.dump(fun))
  file:close()

  return job_uuid
end

cron.remove_job = function(job_path)
  local ok, err = os.remove(job_path)
  if not ok then
    return false, err or "Could not delete file"
  end
  return true
end

cron.get_jobs = function()
  local cron_jobs = {}

  for dir in io.popen("ls -pa cron_tasks | grep -v /"):lines() do
    local separator_pos = string.find(dir, "|")
    if separator_pos == nil then
      logger.warn("Invalid cron task name file : " .. dir)
    else
      local job_uuid = string.sub(dir, separator_pos + 1, -1)
      local run_date = string.sub(dir, 1, separator_pos - 1)
      table.insert(cron_jobs, {
        uuid = job_uuid,
        run_date = run_date,
        file_name = dir,
        file_path = "cron_tasks/" .. dir
      })
    end
  end

  return cron_jobs
end

return cron
