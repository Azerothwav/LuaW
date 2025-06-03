local logger = require("middlewares.logger")
local parser = require("middlewares.parser")
local error_handler = require("handlers.errors")
local parser_util = require("utils.parser")

local router = {}
local routes = {
  ["GET"] = {},
  ["POST"] = {},
  ["DELETE"] = {},
  ["PUT"] = {},
  ["PATCH"] = {}
}

local function convert_route_to_pattern(route)
  return route:gsub(":([%w_]+)", "([^/]+)")
end

local function extract_param_names(route)
  local names = {}
  for name in route:gmatch(":([%w_]+)") do
    table.insert(names, name)
  end
  return names
end

router.add_route = function(method, route_name, ...)
  method = string.upper(method)

  if route_name:match(":") then
    local pattern = "^" .. convert_route_to_pattern(route_name) .. "$"
    routes[method][route_name] = {
      pattern = pattern,
      param_names = extract_param_names(route_name),
      handlers = { ... }
    }
  else
    routes[method][route_name] = { ... }
  end
end

local function find_matching_route(method, path)
  if not routes[method] then return nil end

  if routes[method][path] then
    return {
      handlers = routes[method][path],
      params = {}
    }
  end

  for route_name, route_data in pairs(routes[method]) do
    if route_name:match(":") then
      local matches = { path:match(route_data.pattern) }
      if #matches > 0 then
        local params = {}
        for i, name in ipairs(route_data.param_names) do
          params[name] = matches[i]
        end
        return {
          handlers = route_data.handlers,
          params = params
        }
      end
    end
  end

  return nil
end

router.handle = function(client)
  local request, error = parser.request(client)
  if error then
    print(error)
  end
  if not request then
    error_handler.bad_request(client)
    return
  end

  logger.request(request.method, request.path)

  local route_match = find_matching_route(request.method, request.path)
  if not route_match then
    error_handler.not_found(client)
    return
  end

  request.params = request.params or {}
  for k, v in pairs(route_match.params) do
    request.params[k] = v
  end

  for _, handler in ipairs(route_match.handlers) do
    local have_succeeded, route_error = handler(client, request)
    if have_succeeded ~= nil and not have_succeeded then
      client:send(parser_util.json_response(400, {
        status = "error",
        message = route_error,
      }))
      client:close()
      break
    end
  end
end

router.show_routes = function()
  print("All routes available :")
  for method, all_routes in pairs(routes) do
    print("\n-- " .. method .. " --")
    for route_name, _ in pairs(all_routes) do
      print("- " .. route_name)
    end
  end
end

return router
