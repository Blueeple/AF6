--!strict
--!native
--!optimize 2

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Variables
local Heartbeat: RBXScriptConnection
local PlayersDiconnected: RBXScriptConnection

local TypeCodecs = {} :: { [string]: {DecoderId: number, Encode: (Data: any) -> buffer, Decode: (Data: any) -> any} }
local DecoderIndex = {}
local PlayersLoaded = {}

-- Folder
local CodecsFolder = script.Codecs

-- Modules
local Settings = require(script.Settings)

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
	
	return ByteCharacters :: { number }
end

--[=[
	Loads all type handlers into the module
]=]
local function LoadNetworkCodecs()
	-- Iterates through all codecs and requires them.
	for _, Codec in CodecsFolder:GetChildren() do
		if Codec:IsA("ModuleScript") then
			local Success = pcall(function()
				local CodecModule = require(Codec) :: any
				TypeCodecs[Codec.Name] = CodecModule
				DecoderIndex[CodecModule.DecoderId] = CodecModule.Decode
			end)

			if Success then
				continue
			else
				warn("[EZ-Net][Server] - Error loading Codec: " .. Codec.Name)
			end
		end
	end

	CodecsFolder.Parent = EZ_NetContainer
end

--[=[
	Initializes the RemoteManager server.
]=]
local function Initialize(EZNet: { Index: { [string]: { Activation: boolean, Codecs: { any }, Callback: (Player: Player, Data: any) -> any} }, Queue: { any } })
	-- Initialize
	LoadNetworkCodecs()

	-- Connections
	-- Main callback thread
	Heartbeat = RunService.PreAnimation:Connect(function()
		for i = 1, Configurations.MaxRemoteProcessingBuffer do
			local Packet = EZNet.Queue[i] :: { Player: Player, Remote: buffer}

			if not Packet then return end 
			
			local Player = Packet.Player
			local Remote = Packet.Remote

			if Remote and PlayersLoaded[Player] then
				local RemoteType = if buffer.readi8(Remote, 0) == 0 then false else true
				local NameLength = buffer.readu8(Remote, 1)
				local NameCharacters = {}
				local DecoderId = buffer.readu8(Remote, buffer.len(Remote) - 1)
				local DecodedData = nil :: any

				for i = 2, NameLength + 1 do
					local Byte = buffer.readu8(Remote, i)
					table.insert(NameCharacters, string.char(Byte))
				end

				local RemoteName = table.concat(NameCharacters)

				-- Compute data offsets
				local totalLength = buffer.len(Remote)
				local dataStart = NameLength + 2
				local copyLength = totalLength - dataStart - 1 -- exclude last byte

				local RemoteData = buffer.create(copyLength)
				buffer.copy(RemoteData, 0, Remote, dataStart, copyLength)

				DecodedData = DecoderIndex[DecoderId](RemoteData)
				
				if not table.find(EZNet.Index[RemoteName].Codecs, typeof(DecodedData)) then
					Player:Kick("Packet type mismatch detected.")
				end
				
				coroutine.wrap(EZNet.Index[RemoteName].Callback)(Player, DecodedData)

				table.remove(EZNet.Queue, i)
			elseif Player and not PlayersLoaded[Player] then
				Player:Kick("Attempt to fire remote when not loaded on the server.")
			else
				error("[EZ-Net][Server] - Crashed.")
			end
		end
	end)

	PlayersDiconnected = Players.PlayerRemoving:Connect(function(Player: Player)
		PlayersLoaded[Player] = nil
	end)

	-- Remote event connections.
	ReliableRemoteConnection = ReliableEvent.OnServerEvent:Connect(function(Player: Player, Data: buffer)
		if typeof(Data) == "nil" and not PlayersLoaded[Player] then
			PlayersLoaded[Player] = true
		elseif typeof(Data) == "buffer" then
			table.insert(EZNet.Queue, { Player = Player, Remote = Data })
		else
			Player:Kick("Remote violation detected.")
		end
	end)

	UnreliableRemoteConnection = UnreliableEvent.OnServerEvent:Connect(function(Player: Player, Data: buffer)
		if typeof(Data) == "buffer" then
			table.insert(EZNet.Queue, { Player, Data })
		else
			Player:Kick("Remote violation detected.")
		end
	end)
end

-- Object oriented module constructor
local EZNet = {
	Index = {} :: { [string]: { Activation: boolean, Codecs: { any }, Callback: (Player: Player, Data: any) -> any} },
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
		PlayersDiconnected:Disconnect()
	else
		warn("[EZ-Net - Failed to Kill the EZ-Net process.")
	end
end

--[=[
		Creates a new custom remote.
		
		@param Name: string
		@param: Reliable: boolean?
	]=]
function EZNet.new(Name: string, UnReliable: boolean?, Codecs: { any })
	-- Assertions
	assert(not EZNet.Index[Name], "Remote with this name already exists.")

	-- self
	local self = {}
	local Container = nil

	-- Binds remote to EZ-Net
	EZNet.Index[Name] = nil

	-- Variables
	self.Activation = false
	self.Connected = false
	self.Codecs = Codecs

	-- Methods
	--[=[
		Sets the remotes activation.
		
		@param Activation: boolean
	]=]
	function self.SetActivation(...: boolean)
		self.Activation = ... or not self.Activation
		
	end
	
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
		EZNet.Index[Name] = {
			Activation = self.Activation,
			Codecs = Codecs,
			Callback = Callback
		}
		
		Container = EZNet.Index[Name]
		
		self.Connected = true :: any?
	end

	--[=[
		Fires a packet to an client.

		@param Player: Player
		@param Args: any?
	]=]
	function self.FirePacket(Player: Player, Args: any)
		if PlayersLoaded[Player] then
			-- Assertions
			assert(table.find(Codecs, typeof(Args)), "Remote: " .. Name .. " expects one of the following types: " .. table.unpack(Codecs))
			
			-- Variables
			local TypeCodec = TypeCodecs[typeof(Args)]
			local NameToBytes = EncodeStringToBytes(Name)
			local NameLength = math.clamp(#NameToBytes, 1, Configurations.MaxStringLength)
			local UnReliableStatusToBit = if UnReliable then 1 else 0
			local EncodedData = TypeCodec.Encode(Args) :: buffer

			local PacketInfo = buffer.create(3 + NameLength + buffer.len(EncodedData))

			buffer.writei8(PacketInfo, 0, UnReliableStatusToBit)
			buffer.writeu8(PacketInfo, 1, NameLength)
			--buffer.writeu8(PacketInfo, NameLength + 1, 2) -- set this to the decoder id ig
			
			for i = 2, NameLength + 1 do
				local Byte = NameToBytes[i - 1]
				buffer.writeu8(PacketInfo, i, Byte)
			end
			
			buffer.copy(PacketInfo, NameLength + 2, EncodedData, 0)
			buffer.writeu8(PacketInfo, buffer.len(PacketInfo) - 1, TypeCodec.DecoderId)

			if UnReliable and buffer.len(PacketInfo) <= Configurations.UnReliableEventMaxBufferSize then
				UnreliableEvent:FireClient(Player, PacketInfo)
			elseif not UnReliable and buffer.len(PacketInfo) <= Configurations.ReliableEventMaxBufferSize then
				ReliableEvent:FireClient(Player, PacketInfo)
			else
				warn("[EZ-Net][Server - Data overload detected on event: " .. Name)
			end
		else
			warn("[EZ-Net][Server - Player: " .. Player.Name .. " has not loaded, Implement your remotes properly.")
		end
	end
	
	--[=[
		Fires a packet to all players that are loaded.
		
		@param Args: any
	]=]
	function self.FirePacketAll(Args: any)
		-- Iterates through all the players and fires the packet.
		for _, Player in Players:GetPlayers() do
			if PlayersLoaded[Player] then
				self.FirePacket(Player, Args)
			end
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
	return setmetatable(self, EZNet)
end

return {}
