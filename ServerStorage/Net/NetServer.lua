local NetUtil = require(game.ReplicatedStorage.Script.Net.NetUtil)

local NetServer = {}

function NetServer:Init()
	NetUtil:CacheNetEvent()
	
	-- Bind Event
	NetUtil.RemoteEvent.OnServerEvent:Connect(function(player, data)
		NetServer:OnSend(player, data)
	end)
	
	NetUtil.RemoteFunction.OnServerInvoke = function(player, data)
		return NetServer:OnRequest(player, data)
	end
	
	NetUtil.RemoteFunctionQueue.OnServerInvoke = function(player, data)
		return NetServer:OnRequestQueue(player, data)
	end
end

function NetServer:OnSend(player, request)
	local module = request.Module
	local action = request.Action
	local param = request.Param
	NetServer:DispatchDataPack("Send", player, module, action, param)
end

function NetServer:OnRequest(player, request)
	local module = request.Module
	local action = request.Action
	local param = request.Param
	
	local result = NetServer:DispatchDataPack("Request", player, module, action, param)
	return result
end

function NetServer:OnRequestQueue(player, requestList)
	local result = {}
	for _, request in pairs(requestList) do
		local requestResult = NetServer:OnRequest(player, request)
		table.insert(result, requestResult)
	end
	return result
end

function NetServer:Broadcast(player, module, action, param)
	local request = {
		Module = module,
		Action = action,
		Param = param
	}
	
	NetUtil.RemoteEvent:FireClient(player, request)
end

function NetServer:BroadcastAll(module, action, param)
	local players = game.Players:GetPlayers()
	for _, player in pairs(players) do
		NetServer:Broadcast(player, module, action, param)
	end
end

function NetServer:DispatchDataPack(moduleType, player, module, action, param)
	local moduleFolder = nil
	if moduleType == "Send" then
		moduleFolder = game.ServerStorage.Net.Send
	elseif moduleType == "Request" then
		moduleFolder = game.ServerStorage.Net.Request
	elseif moduleType == "Broadcast" then
		moduleFolder = game.ServerStorage.Net.Boardcast
	end
	
	if not module then
		warn("[Server] Module not found!")
		return
	end
	
	local moduleScript = require(moduleFolder[module])
	if not moduleScript then
		print(module.." "..action.." "..tostring(param))
		return
	end
	
	local success, msg = xpcall(function()
		local actionFunc = moduleScript[action]
		if not actionFunc or type(actionFunc) ~= "function" then
			warn("[Server] Action ["..module.."/"..action.."] not found!")
			return
		end

		if moduleType == "Request" then
			local result = actionFunc(moduleScript, player, param)
			return result
		else
			actionFunc(moduleScript, player, param)
		end
	end, function(err)
		NetUtil:HandleError(err)
	end)

	if success then
		return msg
	end
end

return NetServer