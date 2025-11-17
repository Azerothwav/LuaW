local url = require('socket.url')
local copas = require('copas')
local json = require('json')
local logger = require('middlewares.logger')
local parsers = {}

parsers.get_status_message = function(status_code)
   local status_messages = {
      [200] = 'OK',
      [201] = 'Created',
      [400] = 'Bad Request',
      [401] = 'Unauthorized',
      [403] = 'Forbidden',
      [404] = 'Not Found',
      [405] = 'Method Not Allowed',
      [500] = 'Internal Server Error'
   }
   return status_messages[status_code] or 'Unknown Status'
end

parsers.response = function(status, body, headers)
   headers = headers or {}

   headers['Content-Length'] = #body
   headers['Connection'] = headers['Connection'] or 'close'

   local response = string.format('HTTP/1.1 %d %s\r\n', status, parsers.get_status_message(status))

   for k, v in pairs(headers) do
      response = response .. string.format('%s: %s\r\n', k, v)
   end

   response = response .. '\r\n' .. body
   return response
end

parsers.json_response = function(status, data, headers)
   local json_body = json.encode(data)

   headers = headers or {}
   headers['Content-Type'] = 'application/json'

   return parsers.response(status, json_body, headers)
end

parsers.html_response = function(status, html, headers)
   local html_size = #html / 1024
   logger.info(string.format('HTML Size : %s KB', html_size))

   headers = headers or {}
   headers['Content-Type'] = 'text/html; charset=UTF-8'

   return parsers.response(status, html, headers)
end

parsers.redirect_response = function(status, redirect_url, headers)
   local body = 'Redirect to: ' .. redirect_url

   headers = headers or {}

   headers['Content-Type'] = 'text/plain'
   headers['Location'] = redirect_url

   return parsers.response(status, body, headers)
end

parsers.query = function(query)
   local params = {}
   if not query then
      return params
   end

   for key, val in query:gmatch('([^&=]+)=([^&=]*)') do
      params[url.unescape(key)] = url.unescape(val)
   end
   return params
end

parsers.headers = function(client)
   local headers = {}
   copas.settimeout(client, 10)
   while true do
      local line, err = copas.receive(client)
      if err then
         break
      end
      if line == '' then
         break
      end
      if not line then
         break
      end
      local key, value = line:match('^([%w-]+):%s*(.+)')
      if key then
         headers[key:lower()] = value
      end
   end
   return headers
end

parsers.read_post_body = function(client, headers)
   local content_length = tonumber(headers['content-length']) or 0
   if content_length <= 0 then
      return ''
   end

   local body_chunks = {}
   local received = 0
   local chunk_size = 4096

   copas.settimeout(client, 10)

   while received < content_length do
      local to_read = math.min(chunk_size, content_length - received)
      local chunk, _ = copas.receive(client, to_read)
      if not chunk then
         break
      end

      table.insert(body_chunks, chunk)
      received = received + #chunk
   end

   return table.concat(body_chunks)
end

parsers.parse_multipart = function(body, boundary)
   local params = {}
   local files = {}

   local boundary_marker = '--' .. boundary
   local closing_boundary = boundary_marker .. '--'
   local CRLF = '\r\n'

   local pos = 1
   local first_s, first_e = body:find(boundary_marker, pos, true)
   if not first_s then
      return params, files
   end
   pos = first_e + 1

   local parts = {}
   while true do
      if body:sub(pos, pos + 1) == CRLF then
         pos = pos + #CRLF
      end

      local next_boundary_s, next_boundary_e = body:find(CRLF .. boundary_marker, pos, true)
      local next_closing_s, _ = body:find(CRLF .. closing_boundary, pos, true)

      if next_closing_s and (not next_boundary_s or next_closing_s < next_boundary_s) then
         local chunk = body:sub(pos, next_closing_s - 1)
         table.insert(parts, chunk)
         break
      end

      if next_boundary_s then
         local chunk = body:sub(pos, next_boundary_s - 1)
         table.insert(parts, chunk)
         pos = next_boundary_e + 1
      else
         break
      end
   end

   for _, part in ipairs(parts) do
      local header_end = part:find(CRLF .. CRLF, 1, true)
      if not header_end then
         goto continue
      end

      local headers_block = part:sub(1, header_end - 1)
      local content = part:sub(header_end + 4)

      local headers = {}
      for line in headers_block:gmatch('([^\r\n]+)') do
         local name, val = line:match('^([%w%-]+):%s*(.+)$')
         if name and val then
            headers[name:lower()] = val
         end
      end

      local disp = headers['content-disposition']
      if disp then
         local field_name = disp:match('name="([^"]+)"')
         local filename = disp:match('filename="([^"]+)"')

         if filename then
            table.insert(files, {
               name = field_name,
               filename = filename,
               content_type = headers['content-type'] or 'application/octet-stream',
               data = content
            })
         elseif field_name then
            params[field_name] = content
         end
      end

      ::continue::
   end

   return params, files
end

parsers.static_response = function(client, request)
   local file_path = '.' .. request.params.static_path
   local f = io.open(file_path, 'rb')
   if not f then
      return string.format('Static file not found %s', file_path)
   end

   local content = f:read('*a')
   f:close()

   local ext = file_path:match('%.([^%.]+)$')
   local mime_types = {
      png = 'image/png',
      jpg = 'image/jpeg',
      jpeg = 'image/jpeg',
      gif = 'image/gif',
      svg = 'image/svg+xml',
      css = 'text/css',
      js = 'application/javascript',
      woff = 'font/woff',
      woff2 = 'font/woff2',
      ttf = 'font/ttf',
      otf = 'font/otf',
      ico = 'image/x-icon'
   }
   local mime = mime_types[ext] or 'application/octet-stream'

   logger.info(string.format('Serving static file: %s (%s, %.2f KB)', file_path, mime, #content / 1024))
   copas.send(client, parsers.response(200, content, { ['Content-Type'] = mime }))
end

return parsers
