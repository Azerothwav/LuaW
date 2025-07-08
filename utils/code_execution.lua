local code_execution = {}

code_execution.run_code = function(language_command, code_string)
   local success, result, code_execution_result = pcall(function()
      local tmp_file = os.tmpname()
      local file_path = tmp_file .. '.txt'

      local file, err = io.open(file_path, 'w')
      if not file then
         return false, 'Error with the temporary file : ' .. tostring(err)
      end
      file:write(code_string)
      file:close()

      local exec_cmd = string.format('%s %s 2>&1', language_command, file_path)
      local handle = io.popen(exec_cmd)
      if not handle then
         os.remove(file_path)
         return false, 'Error with the launch command'
      end

      local output = handle:read('*a')
      local ok, _, exit_code = handle:close()

      os.remove(file_path)

      local is_success = ok == true or exit_code == 0

      return is_success, output
   end)

   if not success then
      return false, 'Error : ' .. tostring(result)
   end

   return result, code_execution_result
end

return code_execution
