--!strict
--!native
--!optimize 2

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local ReplicatorStorage = Instance.new("Folder")
ReplicatorStorage.Name = "ReplicatorStorage"
ReplicatorStorage.Parent = ReplicatedStorage

-- Variables
local ObjectEngine = {}
local PlayersLoaded = {} :: { [Player]: boolean }

-- Modules
local GoodSignal = require(ReplicatedStorage.Frameworks:WaitForChild("GoodSignal"))
local Types = require(script.Types)
local DataTypes = require(ReplicatedStorage:WaitForChild("MN-Types"))

-- Object oriented module constructor
local ModNet = {}
ModNet.Packets = {} :: { [number]: Types.InternalPacket }
ModNet.DataType = DataTypes
ModNet.Engine = {
	Cached = {
		Tables = {},
		Arrays = {},
	},
	Replicators = {
		QuickR = {
			StepMode = RunService.PreAnimation,
			Reliable = true,
			TickPerSecond = 64,
			ThrottleEnabled = true,
			ThrottleRate = 8,
			ThrottleInterval = 1 / 8,
		},
	} :: { [string]: Types.Replicator },
	ReplicatorHandlers = {} :: {
		[string]: {
			Thread: RBXScriptConnection | {},
			Receiver: RBXScriptConnection | {},
			OutBoundQueue: { [number]: { Player: Player, Buffer: buffer | any } },
		},
	},
	PacketObjectEngine = {},
}
ModNet.Engine.PacketObjectEngine.__index = ModNet.Engine.PacketObjectEngine
ObjectEngine = ModNet.Engine.PacketObjectEngine

-- [[ Object Engine Methods ]]
function ObjectEngine:Fire(Player: Player, ...: any)
	print(self, Player, ...)
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

-- [[ Player Management ]]
Players.PlayerRemoving:Connect(function(Player: Player)
	if PlayersLoaded[Player] then
		PlayersLoaded[Player] = nil
	end
end)

-- [[ Replicator binding ]]
for ReplicatorName, _ in ModNet.Engine.Replicators do
	ModNet.Engine.ReplicatorHandlers[ReplicatorName] = {
		Thread = {},
		Receiver = {},
		InBoundQueue = {},
		OutBoundQueue = {},
	}
end

-- [[ Replicator Setup ]]
for ReplicatorName, ReplicatorInfo in ModNet.Engine.Replicators do
	if ReplicatorInfo.Reliable then
		-- Variables
		local ReplicatorObject = ModNet.Engine.ReplicatorHandlers[ReplicatorName]
		local ReplicatorConfig = ModNet.Engine.Replicators[ReplicatorName]
		local Remote = Instance.new("RemoteEvent")
		Remote.Name = ReplicatorName
		Remote.Parent = ReplicatorStorage
		local LastTick = tick()
		local _OldTickPerSecond = ReplicatorConfig.TickPerSecond

		-- Reciver signal connection
		ReplicatorObject.Receiver = Remote.OnServerEvent:Connect(function(Player: Player, ...: buffer | any)
			-- Arguments
			local Args = ...

			if typeof(Args) == "buffer" then
				-- Variables
				local PacketId = buffer.readu8(Args, 0)
				local Packet = ModNet.Packets[PacketId + 1]
				local PacketData = buffer.create(buffer.len(Args) - 1)

				

				print(Packet, PacketData)
			else
				print(Player, ...)
			end
		end)

		-- Thread connection
		ReplicatorObject.Thread = ReplicatorInfo.StepMode:Connect(function(_DeltaTime: number)
			for _ = 1, ReplicatorConfig.TickPerSecond do
				if #ReplicatorObject.OutBoundQueue > 0 then
					print(LastTick)
				else
					LastTick = tick()
					break
				end
			end
		end)
	else
		local Remote = Instance.new("UnreliableRemoteEvent")
		Remote.Name = ReplicatorName
		Remote.Parent = ReplicatorStorage
	end
end

--[ ModNet Methods ]

--[=[
	Creates a new custom remote.
		
	@param Name: string
	@param Reliable: boolean?
	@param Channel: string
	@param TypesList: { Types.EZN_Type }
]=]
function ModNet.CreatePacket(Name: string, Unreliable: boolean?, Channel: string, TypesList: { Types.EZN_Type })
	-- Assertions
	assert(not table.find(ModNet.Packets, Name), "Packet with this name already exists.")
	assert(table.maxn(ModNet.Packets) <= 256, "Cannot create more than 256 packets.")

	-- Variables
	local self = {}

	self.Name = Name
	self.Unreliable = Unreliable
	self.Channel = Channel
	self.Types = TypesList
	self.Signal = GoodSignal.new()

	ModNet.Packets[table.maxn(ModNet.Packets) + 1] = self :: Types.InternalPacket

	return setmetatable(self, ModNet)
end

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

	-- Packet Info
	self.Packet = Packet :: Types.InternalPacket
	self.PacketId = PacketId :: number

	return setmetatable(self, ObjectEngine) :: {
		Fire: (self: Types.PacketObjectEngine, Player: Player | { number: Player }, ...any) -> (),
		Packet: Types.InternalPacket,
		PacketId: number,
	}
end

return ModNet
