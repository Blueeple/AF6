--!strict
--!optimize 2

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local ReplicatorRemoteStorage = ReplicatedStorage:WaitForChild("ReplicatorRemoteStorage")

-- Variables
local StartTick = tick()
local PacketDataLoaded = false
local ObjectEngine = {}

-- Roblox Objects
local LocalPlayer = Players.LocalPlayer :: Player
local PlayerVerifyRemote = ReplicatedStorage:WaitForChild("PlayerVerify") :: RemoteEvent

-- Modules
local DataTypes = require(ReplicatedStorage:WaitForChild("EZN-Types"))
local GoodSignal = require(ReplicatedStorage.Frameworks:WaitForChild("GoodSignal"))
local Types = require(script.Types)

-- Object oriented module constructor
local EZNet = {}
EZNet.Packets = {} :: { [number]: Types.InternalPacket }
EZNet.PacketYeilds = {} :: { [number]: string }
EZNet.DataType = DataTypes.Types
EZNet.Engine = {
	Cached = {
		Tables = {},
		Arrays = {},
	},
	ReplicatorHandlers = {} :: {
		[string]: {
			Receiver: RBXScriptConnection | {},
			OutBoundQueue: { [number]: { Player: Player, Buffer: buffer | any } },
			IsUnreliable: boolean?,
		},
	},
	PacketObjectEngine = {},
	Settings = {
		DebugMode = true,
		MaxBufferSize = 64,
		ProcessPacketOnFire = false, -- Will be added in rmv4.1
		SkipReplicatorOutboundQueue = false, -- Will be added in rmv4.1
	},
}
EZNet.Engine.PacketObjectEngine.__index = EZNet.Engine.PacketObjectEngine
ObjectEngine = EZNet.Engine.PacketObjectEngine

-- [[ Debug Engine]]
--[=[
	Debug print function

	@param ...
]=]
local function DebugPrint(...)
	if EZNet.Engine.Settings.DebugMode then
		print(...)
	end
end

--[=[
	Debug warn function

	@param ...
]=]
local function DebugWarn(...)
	if EZNet.Engine.Settings.DebugMode then
		warn(...)
	end
end

-- [[ Packet handling Engine ]]
--[=[
	Unpacks buffers from a single buffer

	@param ...
]=]
local function HandleInBoundPacket(...)
	-- Variables
	local PacketReciveData = table.pack(...)
	local PacketId = nil :: number?
	local PacketMemoryInfo = nil :: Types.InternalPacket?
	local BufferTypesInfo = nil :: { [number]: string }?
	local Signal = nil :: Types.Signal?
	local InBoundData = {} :: { [number]: buffer }
	local DecodedData = {} :: { [number]: any }

	-- Converts all argument into tables
	for index, Data: buffer in PacketReciveData do
		InBoundData[index] = Data
	end

	-- Sets the packet ID and memory info
	PacketId = buffer.readu8(PacketReciveData[1], 0) + 1
	PacketMemoryInfo = EZNet.Packets[PacketId]
	BufferTypesInfo = PacketMemoryInfo.Types
	Signal = PacketMemoryInfo.Signal

	-- Decodes all inbound data
	for index, TypeName in BufferTypesInfo do
		local BufferData = InBoundData[index + 1]
		local ReadData = DataTypes.Reads[TypeName](BufferData)
		DecodedData[index] = ReadData
	end

	-- Fires the decoded data to the signal
	Signal:Fire(table.unpack(DecodedData))
end

--[[ EZNet Internal ]]
--[=[
	Requests a packet by its name.
	
	@param Name: string
	@return PacketObjectEngine?
	@return number?
]=]
local function RequestPacketByName(Name: string): (Types.InternalPacket?, number?)
	for Id, Packet in EZNet.Packets do
		if Packet.Name == Name then
			return Packet, Id
		end
	end

	return nil, nil
end

--[=[
	Handles initial packet data loading from the server.
]=]
local function HandleInitialPacketData()
	PlayerVerifyRemote.OnClientEvent:Once(function(PacketData)
		if #EZNet.Packets == 0 then
			-- Load packet data
			PacketDataLoaded = true
			EZNet.Packets = PacketData

			-- Initialize all packet signals
			for _, PacketMemoryInfo: Types.InternalPacket in EZNet.Packets do
				PacketMemoryInfo.Signal = GoodSignal.new()
			end
		else
			DebugWarn("[EZNet][Compiler] - Temp packets detected.")

			for PacketId, PacketMemoryInfo: Types.InternalPacket in PacketData do
				-- Start variables
				local ExistingPacketName = PacketMemoryInfo.Name
				local ExistingPacket, _ = RequestPacketByName(ExistingPacketName)

				if ExistingPacket then
					local ExistingSignal = ExistingPacket.Signal
					EZNet.Packets[PacketId] = PacketMemoryInfo
					EZNet.Packets[PacketId].Signal = ExistingSignal

					table.remove(EZNet.PacketYeilds, table.find(EZNet.PacketYeilds, ExistingPacketName) :: number)

					DebugPrint("[EZNet][Compiler] - Yeild destroyed for Packet: " .. ExistingPacketName)
				else
					EZNet.Packets[PacketId] = PacketMemoryInfo
					EZNet.Packets[PacketId].Signal = GoodSignal.new()
				end
			end

			print(EZNet.Packets)

			if #EZNet.PacketYeilds > 0 then
				for _, YeildedPacketName in EZNet.PacketYeilds do
					DebugWarn("[EZNet][Client] - Packet load failure detected for Packet: " .. YeildedPacketName)
				end
			end

			table.clear(EZNet.PacketYeilds)

			PacketDataLoaded = true
		end

		-- Attach all replicators to a handler
		for _, Replicator: RemoteEvent & UnreliableRemoteEvent in ReplicatorRemoteStorage:GetChildren() do
			if Replicator:IsA("RemoteEvent") then
				EZNet.Engine.ReplicatorHandlers[Replicator.Name] = {
					Receiver = Replicator.OnClientEvent:Connect(HandleInBoundPacket),
					OutBoundQueue = {},
				}
			elseif Replicator:IsA("UnreliableRemoteEvent") then
				EZNet.Engine.ReplicatorHandlers[Replicator.Name] = {
					Receiver = Replicator.OnClientEvent:Connect(HandleInBoundPacket),
					OutBoundQueue = {},
					IsUnreliable = true,
				}
			end
		end

		PlayerVerifyRemote:FireServer()

		DebugPrint("[EZNet][Client] - " .. tostring(tick() - StartTick))
	end)
end

-- [[ Object Engine Methods ]]
--[=[
	Fires a Pacekt to the client
r
	@param ...
]=]
function ObjectEngine:Fire(...)
	if not PacketDataLoaded then
		DebugWarn("[EZNet][Client] - Attempted to fire a packet before packet data was loaded.")
		return
	end

	-- Args
	local PacketMemoryInfo = self :: Types.InternalPacket

	if not PacketMemoryInfo.Replicator then
		local Packet, _ = RequestPacketByName(PacketMemoryInfo.Name)

		self = Packet
		PacketMemoryInfo = self :: Types.InternalPacket
	end

	-- Variables
	local ReplicatorName = PacketMemoryInfo.Replicator
	local OutBoundData = {}
	local Replicator = ReplicatorRemoteStorage:FindFirstChild(ReplicatorName) :: RemoteEvent
	local PackedData = table.pack(...)
	local PacketId = PacketMemoryInfo.PacketId

	print(PacketMemoryInfo)

	if Replicator then
		DebugPrint("[EZNet][Client] - Firing packet: " .. PacketMemoryInfo.Name .. " using replicator: " .. ReplicatorName)

		-- Packs the buffers into the packet
		for index, TypeName in PacketMemoryInfo.Types do
			local Data = PackedData[index]
			local WriteData = DataTypes.Writes[TypeName](Data)
			OutBoundData[index + 1] = WriteData
		end

		-- Adds Packet ID to the front of the buffer list
		OutBoundData[1] = buffer.create(1)
		buffer.writeu8(OutBoundData[1], 0, (PacketId - 1))

		Replicator:FireServer(table.unpack(OutBoundData))
	else
		DebugWarn("[EZNet][Client] - Client Fire error.")
	end
end

--[=[
	Fires a function when ever a packet revices a signal

	@param func: (layer: Player, ...any) -> ()
	@return { Disconnect: () -> () }
]=]
function ObjectEngine:OnPacket(func: (Player: Player, ...any) -> ())
	-- Variables
	local PacketMemoryInfo = self :: Types.InternalPacket
	local Connection = PacketMemoryInfo.Signal:Connect(func)

	return {
		Disconnect = function()
			Connection:Disconnect()
		end,
	}
end

--[ EZNet Methods ]
--[=[
	Gets a packet by its name.
		
	@param Name: string
	@return PacketObjectEngine
]=]
function EZNet.GetPacket(Name: string)
	if PacketDataLoaded then
		-- Start variables
		local Packet, PacketId = RequestPacketByName(Name)

		-- Assertions
		assert(not table.find(EZNet.Packets, Name), "Packet with name " .. Name .. " does not exist.")
		assert(Packet, "Packet with this name: " .. Name .. " does not exist.")
		assert(PacketId, "No Packet id exists.")

		-- Variables
		local self = EZNet.Packets[PacketId]

		return setmetatable(self, ObjectEngine) :: Types.PacketObjectEngine
	else
		DebugWarn("[EZNet][Compiler] - Registered a packet that has not been loaded, yeilding until response.")

		-- Variables
		local self = {
			Name = Name,
			Signal = GoodSignal.new(),
		}

		EZNet.Packets[#EZNet.Packets + 1] = self :: Types.InternalPacket
		table.insert(EZNet.PacketYeilds, Name)

		return setmetatable(self, ObjectEngine) :: Types.PacketObjectEngine
	end
end

--[[ Server Packet Info Request ]]
HandleInitialPacketData()
PlayerVerifyRemote:FireServer()

--[[ Detects when the client fails to load packet data in time ]]
coroutine.wrap(function()
	task.wait(10)

	if not PacketDataLoaded then
		DebugWarn("[EZNet][Client] - Packet data failed to load within the time limit.")
		LocalPlayer:Kick("EZNet Packet data failed to load within the time limit.")
	end
end)()

return EZNet
