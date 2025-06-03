local config = require('initiers.config')
local files = {}

files.store = function(file_data, filename)
  local path = config.files_path .. "/" .. filename

  local file = io.open(path, "wb")
  if not file then
    return nil, "Cound not open file for writing"
  end

  file:write(file_data)
  file:close()

  return {
    path = path,
    url = config.host() .. ":" .. config.port() .. "/" .. path
  }
end

files.retrieve = function(filename)
  local path = config.files_path .. "/" .. filename
  local file = io.open(path, "rb")
  if not file then
    return nil, "File not found"
  end

  local content = file:read("*all")
  file:close()

  return content
end

files.remove = function(filename)
  local path = config.files_path .. "/" .. filename
  local ok, err = os.remove(path)
  if not ok then
    return false, err or "Could not delete file"
  end
  return true
end

files.list = function(text)
  if text then
    local list_str = ""
    for dir in io.popen("ls -pa " .. config.files_path .. " | grep -v /"):lines() do
      list_str = list_str .. dir .. "\n"
    end
    return list_str
  else
    local files_list = {}
    for dir in io.popen("ls -pa " .. config.files_path .. " | grep -v /"):lines() do
      table.insert(files_list, {
        file_name = dir,
        file_path = config.files_path .. "/" .. dir
      })
    end
    return files_list
  end
end

return files
