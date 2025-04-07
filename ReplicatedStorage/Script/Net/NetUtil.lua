local NetUtil = {}

NetUtil.RemoteEventName = "Net_RemoteEvent"
NetUtil.RemoteFunctionName = "Net_RemoteFunction"
NetUtil.RemoteFunctionQueueName = "Net_RemoteFunctionQueue"

NetUtil.RemoteEvent = nil
NetUtil.RemoteFunction = nil
NetUtil.RemoteFunctionQueue = nil

function NetUtil:CacheNetEvent()
	local folder = NetUtil:GetReplicatedFolder("RuntimeOnly_Event")
	local remoteEvent = folder:FindFirstChild(NetUtil.RemoteEventName)
	if not remoteEvent then
		remoteEvent = Instance.new("RemoteEvent")
		remoteEvent.Name = NetUtil.RemoteEventName
		remoteEvent.Parent = folder
	end
	NetUtil.RemoteEvent = remoteEvent

	local remoteFunction = folder:FindFirstChild(NetUtil.RemoteFunctionName)
	if not remoteFunction then
		remoteFunction = Instance.new("RemoteFunction")
		remoteFunction.Name = NetUtil.RemoteFunctionName
		remoteFunction.Parent = folder
	end
	NetUtil.RemoteFunction = remoteFunction

	local remoteFunctionQueue = folder:FindFirstChild(NetUtil.RemoteFunctionQueueName)
	if not remoteFunctionQueue then
		remoteFunctionQueue = Instance.new("RemoteFunction")
		remoteFunctionQueue.Name = NetUtil.RemoteFunctionQueueName
		remoteFunctionQueue.Parent = folder
	end
	NetUtil.RemoteFunctionQueue = remoteFunctionQueue
end

function NetUtil:GetReplicatedFolder(folderName)
	local folder = game.ReplicatedStorage:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = game.ReplicatedStorage
	end
	return folder
end

function NetUtil:HandleError(err)
	local trace = debug.traceback(err, 2)
	local formattedTrace = {}

	print("🔴 Stack Begin")
	warn(err)
	for line in trace:gmatch("[^\n]+") do
		local scriptName, lineNum = line:match("([^:]+):(%d+)") 
		if scriptName and lineNum then
			table.insert(formattedTrace,  "Script '" .. scriptName .. "': Line " .. lineNum)
		else
			table.insert(formattedTrace, line)
		end
	end

	for _, log in ipairs(formattedTrace) do
		warn(log)
	end
	print("🔴 Stack End")
end

return NetUtil
