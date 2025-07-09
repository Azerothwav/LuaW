local utility = {}

local function shallow_copy(orig)
   local copy = {}
   for k, v in pairs(orig) do
      copy[k] = v
   end
   return copy
end

utility.rows = function(connection, sql_statement)
   local cursor, err = connection:execute(sql_statement)
   assert(cursor, string.format('Error with the following sql statement: %s\n%s', sql_statement, err))

   local results = {}
   local row = {}

   while true do
      local status = cursor:fetch(row, 'a')
      if not status then
         break
      end
      table.insert(results, shallow_copy(row))
   end

   if #results == 0 then
      results = nil
   end

   cursor:close()
   return results
end

utility.sanitize = function(input)
   if type(input) ~= 'string' then
      return input
   end

   input = input:gsub('\\', '\\\\')
   input = input:gsub('\'', '\\\'')
   input = input:gsub('"', '\\"')

   input = input:gsub(';', '')
   input = input:gsub('%z', '')
   input = input:gsub('%-%-', '')

   return input
end

return utility
