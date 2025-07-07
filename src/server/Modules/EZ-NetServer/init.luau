--!strict
--!native
--!optimize 2

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Exports
export type CustomRemoteEvent = {
	--[=[
		Connects an callback funtion to the event.
			
		@param Callback: function
		@return Player: Player
		@return Args: any?
	]=]
	OnPacket: (Player: Player, Args: any) -> ()?,

	--[=[
		Sends a packet to the client.

		@param Player: Player
		@param Args: any
	]=]
	FirePacket: (Player: Player, Args: any) -> never,

	--[=[
		Indicates weather the Event is connected.
	]=]
	Connected: boolean,

	--[=[
		Disconnects the callback function assigned to the event.
	]=]
	Disconnect: () -> never,
}

-- Variables
local Heartbeat: RBXScriptConnection
local PlayersConnected: RBXScriptConnection
local PlayersDiconnected: RBXScriptConnection

local _InstanceAPI = {}
local TypeCodecs = {}
local PlayersLoaded = {}

local AreCustomInstancesAllowed = false

local EZ_NetContainer = Instance.new("Folder")
EZ_NetContainer.Name = "EZ-NetShared"
EZ_NetContainer.Parent = ReplicatedStorage

local ReliableEvent = Instance.new("RemoteEvent")
ReliableEvent.Name = "EZNetReliableEvent"
ReliableEvent.Parent = EZ_NetContainer

local UnreliableEvent = Instance.new("UnreliableRemoteEvent")
UnreliableEvent.Name = "EZNetUnreliableEvent"
UnreliableEvent.Parent = EZ_NetContainer

local ReliableRemoteConnection = nil :: RBXScriptConnection?
local UnreliableRemoteConnection = nil :: RBXScriptConnection?

-- Folder
local CodecsFolder = script.Codecs

-- Modules
local Configurations = require(script.Configurations)

-- Global functions
--[=[
	Encodes strings into bytes.	
]=]
local function EncodeStringToBytes(String: string)
	local ByteCharacters = {}
		
	for i = 1, string.len(String) do
		local StringCharacter = string.byte(string.sub(String, i, i))
		table.insert(ByteCharacters, StringCharacter)
	end

	return ByteCharacters
end

--[=[
	Loads all type handlers into the module
]=]
local function LoadNetworkCodecs()
	for _, Codec in CodecsFolder:GetChildren() do
		if Codec:IsA("ModuleScript") then
			local Success = pcall(function()
				TypeCodecs[Codec.Name] = require(Codec) :: () -> { Decode: (Args: any) -> any, Encode: (Args: any) -> any }
			end)

			if Success then
				continue
			else
				warn("[EZ-Net][Server]: Error loading Codec: " .. Codec.Name)
			end
		end
	end

	CodecsFolder.Parent = EZ_NetContainer
end

--[=[
	Initializes the RemoteManager server.
]=]
local function Initialize(EZNet: { Index: { [string]: () -> any }, Queue: { any } })
	-- Downloads instance API
	if HttpService.HttpEnabled then
		print("[EZ-Net]: Downloading roblox api dump.")
		--InstanceAPI = HttpService:JSONDecode(HttpService:GetAsync("https://anaminus.github.io/rbx/json/api/latest.json")) -- PCall this
		AreCustomInstancesAllowed = true
		print(AreCustomInstancesAllowed)
	else
		warn("[EZ-Net]: External web access was denied, certian instances will not be replicated.")
	end

	LoadNetworkCodecs()

	-- Connections
	-- Main callback thread
	Heartbeat = RunService.PreAnimation:Connect(function()
		for i = 1, Configurations.MaxRemoteProcessingBuffer do

			-- Variables
			local _Packet = EZNet.Queue[i]

			--print(Packet)
		end
	end)

	-- Auto sync remotes with players
	PlayersConnected = Players.PlayerAdded:Connect(function(Player: Player)
		PlayersLoaded[Player] = true
	end)

	PlayersDiconnected = Players.PlayerRemoving:Connect(function(Player: Player)
		PlayersLoaded[Player] = nil
	end)

	-- Remote event connections.
	ReliableRemoteConnection = ReliableEvent.OnServerEvent:Connect(function(Player: Player, RemoteName: string, DataBuffer: buffer)
		table.insert(EZNet.Queue, { RemoteName, Player, DataBuffer })
	end)

	UnreliableRemoteConnection = UnreliableEvent.OnServerEvent:Connect(function(Player: Player, RemoteName: string, DataBuffer: buffer)
		table.insert(EZNet.Queue, { RemoteName, Player, DataBuffer })
	end)
end

-- Object oriented module constructor
local EZNet = {
	Index = {} :: { [string]: (Player: Player, Args: any) -> any },
	Queue = {},
}
EZNet.__index = EZNet

-- Initializes EZNet
Initialize(EZNet)

-- Function methods
--[=[
		Kills the remote manager instance.
	]=]
function EZNet.Kill()
	if Heartbeat then
		EZNet = nil

		if UnreliableRemoteConnection and ReliableRemoteConnection then
			UnreliableRemoteConnection:Disconnect()
			ReliableRemoteConnection:Disconnect()
		end

		Heartbeat:Disconnect()
		PlayersConnected:Disconnect()
		PlayersDiconnected:Disconnect()
	else
		warn("[EZ-Net]: Failed to Kill the EZ-Net process.")
	end
end

--[=[
		Creates a new custom remote.
		
		@param Name: string
		@param: Reliable: boolean?
	]=]
function EZNet.new(Name: string, UnReliable: boolean?, Types: { any })
	-- Assertions
	assert(not EZNet.Index[Name], "Remote with this name already exists.")

	-- self
	local self = {}

	-- Binds remote to EZ-Net
	EZNet.Index[Name] = nil

	-- Variables
	self.Connected = false
	self.Types = Types

	-- Methods
	--[=[
		Connects an callback funtion to the event.

		@param Callback: function
	]=]
	function self.OnPacket(Callback: (Player: Player, Args: any) -> any)
		-- Assertions
		if self.Connected then
			error("Failed to connect a new function to remote: " .. Name .. ", disconnect the old one.")
		end

		-- Adds the callback into the remotes index
		EZNet.Index[Name] = Callback
		self.Connected = true :: any?
	end

	--[=[
			Fires a packet to an client.

			@param Player: Player
			@param Args: any?
		]=]
	function self.FirePacket(Player: Player, _Args: any?)
		if PlayersLoaded[Player] or true then
			-- Variables
			local NameToBytes = EncodeStringToBytes(Name)
			local NameLength = math.clamp(#NameToBytes, 0, Configurations.MaxStringLength)
			local UnReliableStatusToBit = if UnReliable then 0 else 1

			local PacketInfo = buffer.create(1 + NameLength + 4 + 0)
			
			for _ = 1, NameLength do
				
			end

			buffer.writei8(PacketInfo, 0, UnReliableStatusToBit)
			buffer.writeu8(PacketInfo, 1, NameLength)
			buffer.writeu32(PacketInfo, NameLength + 1, Player.UserId)

			print(buffer.readi8(PacketInfo, 0))
			print(buffer.readu8(PacketInfo, 1))
			--print(buffer.readu32(PacketInfo, NameLength + 1))

			--[[
			for i = 1, NameLength do
				table.insert(nameChars, string.char(buffer.readu8(PacketInfo, 1 + i)))
				print(nameChars)
			end]]

			if UnReliable and buffer.len(PacketInfo) <= Configurations.UnReliableEventMaxBufferSize then
				UnreliableEvent:FireClient(Player, PacketInfo)
			elseif not UnReliable and buffer.len(PacketInfo) <= Configurations.ReliableEventMaxBufferSize then
				ReliableEvent:FireClient(Player, PacketInfo)
			else
				warn("[EZ-Net][Server]: Data overload detected on event: " .. Name)
			end
		else
			warn("[EZ-Net][Server]: Player: " .. Player.Name .. " has not loaded, Implement your remotes properly.")
		end
	end

	--[=[
		Disconnects the function from the remote safely
	]=]
	function self.Disconnect()
		print("Disconnecting.")

		EZNet.Index[Name] = nil
		self.Connected = false
	end

	-- Return the instance
	return setmetatable(self, EZNet) :: CustomRemoteEvent
end

return EZNet
