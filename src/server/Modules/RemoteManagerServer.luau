--!strict
--!native
--!optimize 2

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Exports
export type CustomRemoteEvent = {
	OnEvent: (Player: Player, Args: any) -> ()?,
}

-- Variables
local Heartbeat = nil :: RBXScriptConnection?

local ReliableEvent = Instance.new("RemoteEvent")
ReliableEvent.Name = "RemoteManagerServerReliableEvent"
ReliableEvent.Parent = ReplicatedStorage

local UnreliableEvent = Instance.new("UnreliableRemoteEvent")
UnreliableEvent.Name = "RemoteManagerServerUnreliableEvent"
UnreliableEvent.Parent = ReplicatedStorage

local ReliableRemoteConnection = nil :: RBXScriptConnection?
local UnreliableRemoteConnection = nil :: RBXScriptConnection?

-- Object oriented module constructor
local RemoteManagerServer = {
	RemoteIndex = {} :: { [string]: (Player: Player, Args: any) -> any },
	NetworkQueue = {},
}
RemoteManagerServer.__index = RemoteManagerServer

function RemoteManagerServer.Init()
	-- self
	local self = {}

	-- Connections
	Heartbeat = RunService.PreAnimation:Connect(function()
		if not next(RemoteManagerServer.NetworkQueue, nil) then
			return
		end

		local lol = RemoteManagerServer.NetworkQueue[next(RemoteManagerServer.NetworkQueue)]

		RemoteManagerServer.RemoteIndex[lol[1]].Callback(lol[2], lol[3])

		RemoteManagerServer.NetworkQueue[next(RemoteManagerServer.NetworkQueue)] = nil
	end)

	ReliableRemoteConnection = ReliableEvent.OnServerEvent:Connect(function(Player: Player, DataBuffer: buffer)
		print(Player, DataBuffer)
	end)

	-- Methods
	--[[
		Kills the remote manager instance.
	]]
	function self.Kill()
		RemoteManagerServer = nil

		if Heartbeat and Heartbeat.Connected then
			Heartbeat:Disconnect()
		end

		if ReliableRemoteConnection and ReliableRemoteConnection.Connected then
			ReliableRemoteConnection:Disconnect()
		end

		if UnreliableRemoteConnection and UnreliableRemoteConnection.Connected then
			UnreliableRemoteConnection:Disconnect()
		end
	end

	--[[
		Creates a new custom remote.
		@param Name: string
		@param: Reliable: boolean?
	]]
	function RemoteManagerServer.new(Name: string, Reliable: boolean?)
		-- Assertions
		assert(not RemoteManagerServer.RemoteIndex[Name], "Remote with this name already exists.")

		-- self
		local self = {}

		-- Initialize
		RemoteManagerServer.RemoteIndex[Name] = nil

		-- Variables
		self.DataSender = if Reliable then ReliableEvent else UnreliableEvent

		-- Methods
		--[[
			Connects an callback funtion to the event.
			@param Callback: function
		]]
		function self.OnEvent(Callback: (Player: Player, Args: any) -> any)
			-- Assertions
			assert(RemoteManagerServer.RemoteIndex[Name] ~= nil, "Remote was already connected disconnect the previous one.")

			-- Adds the callback into the remotes index
			RemoteManagerServer.RemoteIndex[Name] = Callback
		end

		-- Return the instance
		return setmetatable(self, RemoteManagerServer) :: CustomRemoteEvent
	end
end

return RemoteManagerServer
