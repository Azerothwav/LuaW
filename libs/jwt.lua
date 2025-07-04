-- https://github.com/x25/luajwt
local cjson = require('libs.json')
local base64 = require('libs.base64')
local hmac = require('openssl.hmac')

local alg_sign = {
   ['HS256'] = function(data, key)
      return hmac.new(key, 'sha256'):final(data)
   end,
   ['HS384'] = function(data, key)
      return hmac.new(key, 'sha384'):final(data)
   end,
   ['HS512'] = function(data, key)
      return hmac.new(key, 'sha512'):final(data)
   end
}

local alg_verify = {
   ['HS256'] = function(data, signature, key)
      return signature == alg_sign['HS256'](data, key)
   end,
   ['HS384'] = function(data, signature, key)
      return signature == alg_sign['HS384'](data, key)
   end,
   ['HS512'] = function(data, signature, key)
      return signature == alg_sign['HS512'](data, key)
   end
}

local function b64_encode(input)
   local result = base64.encode(input)

   result = result:gsub('+', '-'):gsub('/', '_'):gsub('=', '')

   return result
end

local function b64_decode(input)
   local reminder = #input % 4

   if reminder > 0 then
      local padlen = 4 - reminder
      input = input .. string.rep('=', padlen)
   end

   input = input:gsub('-', '+'):gsub('_', '/')

   return base64.decode(input)
end

local function tokenize(str, div, len)
   local result, pos = {}, 0

   for st, sp in function()
      return str:find(div, pos, true)
   end do
      result[#result + 1] = str:sub(pos, st - 1)
      pos = sp + 1

      len = len - 1
      if len <= 1 then
         break
      end
   end

   result[#result + 1] = str:sub(pos)

   return result
end

local M = {}

function M.encode(data, key, alg)
   if type(data) ~= 'table' then
      return nil, 'Argument #1 must be table'
   end
   if type(key) ~= 'string' then
      return nil, 'Argument #2 must be string'
   end

   alg = alg or 'HS256'

   if not alg_sign[alg] then
      return nil, 'Algorithm not supported'
   end

   local header = { typ = 'JWT', alg = alg }

   local segments = { b64_encode(cjson.encode(header)), b64_encode(cjson.encode(data)) }

   local signing_input = table.concat(segments, '.')
   local signature = alg_sign[alg](signing_input, key)

   segments[#segments + 1] = b64_encode(signature)

   return table.concat(segments, '.')
end

function M.decode(data, key, verify)
   if key and verify == nil then
      verify = true
   end
   if type(data) ~= 'string' then
      return nil, 'Argument #1 must be string'
   end
   if verify and type(key) ~= 'string' then
      return nil, 'Argument #2 must be string'
   end

   local token = tokenize(data, '.', 3)

   if #token ~= 3 then
      return nil, 'Invalid token'
   end

   local headerb64, bodyb64, sigb64 = token[1], token[2], token[3]

   local ok, header, body, sig = pcall(function()
      return cjson.decode(b64_decode(headerb64)), cjson.decode(b64_decode(bodyb64)), b64_decode(sigb64)
   end)

   if not ok then
      return nil, 'Invalid json'
   end

   if verify then
      if not header.typ or header.typ ~= 'JWT' then
         return nil, 'Invalid typ'
      end

      if not header.alg or type(header.alg) ~= 'string' then
         return nil, 'Invalid alg'
      end

      if body.exp and type(body.exp) ~= 'number' then
         return nil, 'exp must be number'
      end

      if body.nbf and type(body.nbf) ~= 'number' then
         return nil, 'nbf must be number'
      end

      if not alg_verify[header.alg] then
         return nil, 'Algorithm not supported'
      end

      if not alg_verify[header.alg](headerb64 .. '.' .. bodyb64, sig, key) then
         return nil, 'Invalid signature'
      end

      if body.exp and os.time() >= body.exp then
         return nil, 'Not acceptable by exp'
      end

      if body.nbf and os.time() < body.nbf then
         return nil, 'Not acceptable by nbf'
      end
   end

   return body
end

return M
