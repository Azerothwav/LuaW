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
git clone https://github.com/yourusername/lua-minimal-backend.git
cd lua-minimal-backend
```

## Project structure
```bash
.
├── main.lua # Entry point
├── inits/ # Initialization files
│ ├── config.lua # Configuration loader
│ └── server.lua # Server setup
├── libs/ # Utility libraries
│ ├── json.lua # JSON handling
│ ├── jwt.lua # JWT utilities
│ └── utils.lua # Common utilities
├── handlers/ # Request handlers
│ ├── router.lua # Route dispatcher
│ └── error_handlers.lua # Error responses
├── controllers/ # Business logic
│ ├── test.lua # Example controller
│ └── auth.lua # Authentication controller
└── middlewares/ # Middleware functions
├── logger.lua # Request logging
├── parser.lua # Request parsing
└── auth.lua # JWT verification middleware
```
## Getting Started

Starting a server with default setting :
```bash
lua main.lua
```

Available options:

- --host: Server host (default: 0.0.0.0)
- --port: Server port (default: 8080)
- --debug: Enable debug mode

Exemple :
```bash
lua main.lua --server=0.0.0.0 --port=8080 --debug=true
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

## Inspiration

This project takes inspiration from Deno's approach to backend development:

- Minimal setup required
- Standard library approach
- Simple module system
- Built-in support for common needs (JSON, JWT)
