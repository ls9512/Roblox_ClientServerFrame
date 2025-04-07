local NetUtil = require(game.ReplicatedStorage.Script.Net.NetUtil)

local NetClient = {}

function NetClient:Init()
	NetUtil:CacheNetEvent()
	
	-- Bind Event
	NetUtil.RemoteEvent.OnClientEvent:Connect(function(request)
		NetClient:OnBroadCast(request)
	end)
end

function NetClient:Send(module, action, param)
	local request = {
		Module = module,
		Action = action,
		Param = param
	}
	
	NetUtil.RemoteEvent:FireServer(request)
end

function NetClient:Request(module, action, param, callback)
	if param and not callback and typeof(param) == "function"  then
		callback = param
		param = nil
	end
	
	local request = {
		Module = module,
		Action = action,
		Param = param
	}

	local result = NetUtil.RemoteFunction:InvokeServer(request)
	if callback then
		callback(result)
	end
end

function NetClient:RequestWait(module, action, param)
	local result = nil
	NetClient:Request(module, action, param, function(value)
		result = value
	end)
	
	local startTime = os.time()
	while not result do
		task.wait(0.00001)
		local time = os.time()
		if time - startTime > 5 then
			return nil
		end
	end
	return result
end

function NetClient:RequestQueue(requestList, callback)
	local result = NetUtil.RemoteFunctionQueue:InvokeServer(requestList)
	if callback then
		callback(result)
	end
end

function NetClient:OnBroadCast(request)
	local player = game.Players.LocalPlayer
	local module = request.Module
	local action = request.Action
	local param = request.Param
	NetClient:DispatchDataPack("Broadcast", player, module, action, param)
end

function NetClient:DispatchDataPack(moduleType, player, module, action, param)
	local moduleFolder = nil
	if moduleType == "Broadcast" then
		moduleFolder = game.ReplicatedStorage.Script.Net.Broadcast
	else
		return
	end
	
	local moduleScript = require(moduleFolder[module])
	if not moduleScript then
		warn("[Server] Module ["..module.."] not found!")
		return
	end

	local actionFunc = moduleScript[action]
	if not actionFunc or type(actionFunc) ~= "function" then
		warn("[Server] Action ["..module.."/"..action.."] not found!")
		return
	end

	local success, msg = xpcall(function()
		actionFunc(moduleScript, player, param)
	end, function(err)
		NetUtil:HandleError(err)
	end)
end

return NetClient