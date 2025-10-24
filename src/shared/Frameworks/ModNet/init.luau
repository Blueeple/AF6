--!strict
--!optimize 2

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local ReplicatorRemoteStorage = Instance.new("Folder")
ReplicatorRemoteStorage.Name = "ReplicatorRemoteStorage"
ReplicatorRemoteStorage.Parent = ReplicatedStorage

-- Variables
local StartTick = tick()
local ObjectEngine = {}

-- Modules
local DataTypes = require(ReplicatedStorage:WaitForChild("MN-Types"))
local GoodSignal = require(ReplicatedStorage.Frameworks:WaitForChild("GoodSignal"))
local Types = require(script.Types)

-- Object oriented module constructor
local ModNet = {}
ModNet.Packets = {} :: { [number]: Types.InternalPacket }
ModNet.DataType = DataTypes.Types
ModNet.Engine = {
	Cached = {
		Tables = {},
		Arrays = {},
	},
	ReplicatorHandlers = {} :: {
		[string]: {
			Receiver: RBXScriptConnection | {},
			OutBoundQueue: { [number]: { Player: Player, Buffer: buffer | any } },
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
ModNet.Engine.PacketObjectEngine.__index = ModNet.Engine.PacketObjectEngine
ObjectEngine = ModNet.Engine.PacketObjectEngine

-- [[ Buffer Engine ]]
local function PackBuffers(Table: { buffer })
	print(Table)
end

local function _UnpackBuffers()
	
end

-- [[ Object Engine Methods ]]
--[=[
	Fires a Pacekt to the client
r
	@param ...
]=]
function ObjectEngine:Fire(...)
	-- Args
	local ReplicatorObject = self :: { PacketInfo: Types.InternalPacket, PacketId: number }
	local PacketMemoryInfo = ReplicatorObject.PacketInfo

	-- Variables
	local ReplicatorName = PacketMemoryInfo.Replicator
	local OutBoundData = {}
	local Replicator = ReplicatorRemoteStorage:FindFirstChild(ReplicatorName) :: RemoteEvent
	local PackedData = table.pack(...)

	if Replicator then
		print("[ModNet] - Firing packet: " .. PacketMemoryInfo.Name .. " using replicator: " .. ReplicatorName)
		for index, TypeName in PacketMemoryInfo.Types do
			local Data = PackedData[index]
			local WriteData = DataTypes.Writes[TypeName](Data)
			OutBoundData[index] = WriteData
		end

		print(PackBuffers(OutBoundData))

		Replicator:FireServer(table.unpack(OutBoundData))
	else
		warn("[ModNet] - Client Fire error.")
	end
end

--[=[
	Sets the activity of an remote.

	@param ...
]=]
function ObjectEngine:SetEnabled(...)
	assert(typeof(...) == "boolean", "Value must be boolean.")

	-- Variables
	local ReplicatorObject = self :: { PacketInfo: Types.InternalPacket, PacketId: number }
	local PacketMemoryInfo = ReplicatorObject.PacketInfo

	PacketMemoryInfo.Enabled = ...
end

--[=[
	Fires a function when ever a packet revices a signal

	@param func: (layer: Player, ...any) -> ()
]=]
function ObjectEngine:OnPacket(func: (Player: Player, ...any) -> ())
	-- Variables
	local ReplicatorObject = self :: { PacketInfo: Types.InternalPacket, PacketId: number }
	local PacketMemoryInfo = ReplicatorObject.PacketInfo

	PacketMemoryInfo.Signal:Connect(func)
end

--[[ ModNet Internal ]]
--[=[
	Requests a packet by its name.
	
	@param Name: string
	@return PacketObjectEngine?
	@return number?
]=]
local function RequestPacketByName(Name: string): (Types.InternalPacket?, number?)
	for Id, Packet in ModNet.Packets do
		if Packet.Name == Name then
			return Packet, Id
		end
	end

	return nil, nil
end

for _, Replicator in ReplicatorRemoteStorage:GetChildren() do
	if Replicator:IsA("RemoteEvent") or Replicator:IsA("UnreliableRemoteEvent") then
		ModNet.Engine.ReplicatorHandlers[Replicator.Name] = {
			Receiver = Replicator.OnClientEvent:Connect(function(...)
				
			end),
			OutBoundQueue = {}
		}
	end
end

--[ ModNet Methods ]
--[=[
	Gets a packet by its name.
		
	@param Name: string
	@return PacketObjectEngine
]=]
function ModNet.GetPacket(Name: string)
	-- Start variables
	local Packet, PacketId = RequestPacketByName(Name)

	-- Assertions
	assert(not table.find(ModNet.Packets, Name), "Packet with name " .. Name .. " does not exist.")
	assert(Packet, "Packet with this name: " .. Name .. " does not exist.")

	-- Variables
	local self = {}

	return setmetatable(self, ObjectEngine) :: Types.PacketObjectEngine & any
end

print("[ModNet][Engine] - " .. tostring(tick() - StartTick))

return ModNet
