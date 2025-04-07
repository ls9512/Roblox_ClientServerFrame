[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)
[![LICENSE](https://img.shields.io/badge/license-Anti%20996-blue.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)

# Roblox_ClientServerFrame
This is a framework designed to encapsulate Roblox RemoteEvent functionality, providing a universal network communication interface to significantly simplify and standardize the network communication development process. It helps avoid the frequent creation and management of numerous RemoteEvents. Through a few automatically maintained events and a standardized communication message structure, it automatically handles request parsing, invocation, and response processing. This framework has already been applied in several real-world projects.

# File
## NetClient.lua
The core client script. It initializes client-side network communication and is responsible for sending requests to the server and receiving returned results. All such communications must be done via this script.
## NetUtil.lua
A utility class that handles general-purpose tasks such as event creation and error handling. Usually, it does not need to be manually invoked.
## NetServer.lua
The core server script. It receives requests from clients and dispatches them to specific modules, processes the return results, and sends them back to the clients. It can also be used to actively send messages to specific clients or all players.

# How to use
## Usage Guidelines
Client-to-server request code must be called through LocalScript, while server-side logic must be invoked through Script. There are two types of network requests: Request and Broadcast. The routing structure follows a Module / Action / Param pattern, where functionality is grouped by Module, each containing multiple Actions (request handlers), each of which can accept custom Params. More details and examples are provided below.

## Request
Sent proactively from the client to the server. The server parses the request route and executes specific logic or queries data, optionally returning a result.
In server scripts under ServerStorage/Net/Request, create scripts named after the module, for example, Game.lua for managing core game logic — in this case, the module name is Game. Inside Game.lua, define request-handling functions where the function name serves as the Action name, and the parameters must be in the form (player, param) — representing the request sender and parameters. Both parameters and return values are optional, depending on the specific use case.

## Broadcast
Proactively sent from the server to the client when needed. The client parses and executes the corresponding logic.
These should be placed in ReplicatedStorage/Net/Broadcast, and named consistently with the corresponding Request modules.

# Sample
## Client Script

### Init Client
```lua
-- Call NetClient:Init in StarterPlayer/StarterPlayerScripts
local NetClient = require(game.ReplicatedStorage.Script.Net.NetClient)
NetClient:Init()
```

### Request without return value async
```lua
function NetClientDemo:RequestTest1()
	NetClient:Request("ServerRequestModuleDemo", "OnRequest", { Message = "Send message to server"})
end
```

### Request with return value async
```lua
function NetClientDemo:RequestTest2()
	NetClient:Request("ServerRequestModuleDemo", "OnRequest", { Message = "Send message to server"}, function(result)
		print(result)
	end)
end
```
### Request without param and return value async
```lua
function NetClientDemo:RequestTest3()
	NetClient:Request("ServerRequestModuleDemo", "OnRequest")
end
```

### Request and wait for return value
```lua
function NetClientDemo:RequestTest4()
	local result = NetClient:RequestWait("ServerRequestModuleDemo", "OnRequest")
	print(result)
end
```

### Request many action in once
```lua
function NetClientDemo:RequestTest5()
	NetClient:RequestQueue({
		{
			Module = "ServerRequestModuleDemo",
			Action = "OnRequest", 
			Param = { 
				Message = "Message1"
			}
		},
		{
			Module = "ServerRequestModuleDemo",
			Action = "OnRequest", 
			Param = { 
				Message = "Message2"
			}
		}
	}, function(result)
		local result1 = result[1]
		print(result1)
		
		local result2 = result[2]
		print(result2)
	end)
end
```

### Client Broadcast Process
```lua
local ClientBroadcastModuleDemo = {}

function ClientBroadcastModuleDemo:OnBroadcast(player, param)
	local message = param.Message
	print(message)
end

return ClientBroadcastModuleDemo
```

## Server Script
### Init Server
```lua
-- Call NetServer:Init in ServerStorage
local NetServer = require(game.ServerStorage.Net.NetServer)
NetServer:Init()
```

### Server Request Process
```lua
local ServerRequestModuleDemo = {}

function ServerRequestModuleDemo:OnRequest(player, param)
	if param ~= nil then
		local message = param.Message
		print(message)
	else
		print("Request without message")
	end
	
	return true
end

return ServerRequestModuleDemo

```

### Boradcast to one player
```lua
function NetServerDemo:BroadcastTest1()
	local player = game.Players:GetPlayers()[1]
	NetServer:Broadcast("ClientBroadcastModuleDemo", "OnBroadcast", { Message = "Broadcast to client message"})
end
```

### Broadcast to all player
```lua
function NetServerDemo:BroadcastTest2()
	NetServer:BroadcastAll("ClientBroadcastModuleDemo", "OnBroadcast", { Message = "Broadcast to client message"})
end
```