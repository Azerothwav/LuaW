![LuaW](LuaW.png)

# LuaW

A lightweight HTTP server implementation in Lua inspired by Deno's simplicity, using LuaSocket and Copas for concurrent request handling.

## Features

- Simple routing system
- Concurrent request handling with Copas
- JSON request/response support
- JWT authentication support
- Modular structure (controllers, middlewares, libs)
- Easy error handling
- Configuration via command line arguments
- Dynamic route pattern support (e.g. /test/:file_name)
- Local file storage support
- Distributed worker system

## Prerequisites

- Lua 5.1+ or LuaJIT
- Luarocks package manager

## Installation
```bash
luarocks install luasocket
luarocks install copas
luarocks install luasec # For JWT support
```

## Clone the repository
```bash
git clone https://github.com/Azerothwav/LuaW.git
cd LuaW
```

## Project structure
```bash
.
├── uploads/ # Upload folder
├── inits/ # Initialization files
│ ├── config.lua # Configuration loader
│ └── server.lua # Server setup
├── libs/ # Utility libraries
│ ├── json.lua # JSON handling
│ └── jwt.lua # JWT utilities
├── utils/ # Common utilities
│ ├── file.lua # File utility
│ └── parser.lua # Parser utility
├── handlers/ # Request handlers
│ ├── router.lua # Route dispatcher
│ └── error_handlers.lua # Error responses
├── controllers/ # Business logic
│ ├── file.lua # File example controller
│ ├── test.lua # Route example controller
│ └── auth.lua # Authentication example controller
├── middlewares/ # Middleware functions
│ ├── logger.lua # Request logging
│ ├── parser.lua # Request parsing
│ └── auth.lua # JWT verification middleware
├── luaw.lua # Entry point
```
## Getting Started

Starting a server with default setting :
```bash
lua luaw.lua
```

Available options:

- --host: Server host (default: 0.0.0.0)
- --port: Server port (default: 8080)
- --debug: Enable debug mode

Exemple :
```bash
lua luaw.lua --server=0.0.0.0 --port=8080 --debug=true
```

### Testing your server

A starter controller is already implemented, it have the endpoint /test, here how to test it :
```bash
curl "http://localhost:8080/test?name=Backend
```

JWT authentication example:
```bash
# Get a token
curl -X POST -H "Content-Type: application/json" -d '{"username":"admin","password":"secret"}' http://localhost:8080/login

# Access protected route
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8080/auth
```

### Dynamic Route Patterns

You can now define routes with dynamic segments like /files/:file_name or /users/:id.

In your controller, dynamic parameters are automatically passed into the request context, e.g.:

```lua
router.add_route("GET", "/file/:file_name", function(client, request)
  local file_name = request.params.file_name
end)
```

### Worker System

LuaW now supports a distributed worker system, allowing the main server to offload certain tasks to secondary servers called workers.

#### Starting a Worker

To launch a server in worker mode, use the following command:

```bash
lua luaw.lua --worker_mode=true --worker_host=127.0.0.1 --worker_port=8080
```

Available options:

- --worker_mode=true: Enables worker mode.
- --worker_host: The IP address of the main server to connect to.
- --worker_port: The port of the main server.

Once connected, the main server will automatically delegate tasks to the available workers.

#### Creating a Task

The workers.manager module allows you to define and send tasks to workers. A task includes:

- A main function executed on the worker.
- A callback function executed on the main server after the task completes.

Example:
```lua
local manager = require('workers.manager')

manager.add_task(function()
  local config = require('initiers.config')
  print('This is a task executed on ' .. config.host())
end, function()
  local config = require('initiers.config')
  print('This is an end task callback executed on ' .. config.host())
end)
```

The first function runs on the worker.
The second function is called on the main server with the result of the first function after execution.

#### Benefits

- Prevents the main server from being overloaded by heavy or non-urgent tasks.
- Enables background processing.
- Easily scalable by adding multiple workers.

#### Example Usage

You can find a usage example of this worker system in: `controllers/worker.lua`.

## Inspiration

This project takes inspiration from Deno's approach to backend development:

- Minimal setup required
- Standard library approach
- Simple module system
- Built-in support for common needs (JSON, JWT)
