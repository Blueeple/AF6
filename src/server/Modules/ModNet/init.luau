--!strict
--!native
--!optimize 2

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local ReplicatorRemoteStorage = Instance.new("Folder")
ReplicatorRemoteStorage.Name = "ReplicatorRemoteStorage"
ReplicatorRemoteStorage.Parent = ReplicatedStorage

-- Variables
local StartTick = tick()
local ObjectEngine = {}
local PlayersLoaded = {} :: { [Player]: boolean }

-- Modules
local DataTypes = require(ReplicatedStorage:WaitForChild("MN-Types"))
local GoodSignal = require(ReplicatedStorage.Frameworks:WaitForChild("GoodSignal"))
local Types = require(script.Types)

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
	Settings = {
		MaxBufferSize = 64,
	},
}
ModNet.Engine.PacketObjectEngine.__index = ModNet.Engine.PacketObjectEngine
ObjectEngine = ModNet.Engine.PacketObjectEngine

-- [[ Object Engine Methods ]]
--[=[
	Fires a Pacekt to the client

	@param Player: Player
	@param ...
]=]
function ObjectEngine:Fire(Player: Player, ...)
	-- Args
	local ReplicatorObject = self :: { PacketInfo: Types.InternalPacket, PacketId: number }
	local PacketMemoryInfo = ReplicatorObject.PacketInfo

	-- Variables
	local ReplicatorName = PacketMemoryInfo.Replicator

	local Replicator = ReplicatorRemoteStorage:FindFirstChild(ReplicatorName) :: RemoteEvent
	local _PackedData = table.pack(...)

	if Replicator and Player:IsA("Player") then
		print("[ModNet] - Firing packet: " .. PacketMemoryInfo.Name .. " using replicator: " .. ReplicatorName)
		Replicator:FireClient(Player, buffer.create(1))
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

local function PerformPacketIntegrityCheck(Player: Player, ...)
	-- Checks if the player has made a handshake to the server.
	if PlayersLoaded[Player] ~= true then
		warn("[ModNet][Integrity] - Player: " .. Player.Name .. " fired an unverified event, terminating connection.")
		return false
	end


	-- Variables
	local Args = table.pack(...)
	local MNSettings = ModNet.Engine.Settings

	-- Variables
	local ArgCount = 0 :: number
	local DetectedArgs = #Args
	local VerifiedArgs = 0
	local BufferSizeCount = 0 :: number

	local BufferCheck1 = nil :: boolean?
	local BufferCheck2 = nil :: boolean?

	local PacketInfo: Types.InternalPacket

	-- Check if the first argument is a buffer and has at least 1 byte
	if Args["n"] > 0 and typeof(Args[1]) == "buffer" then
		local IdentifierPacket = Args[1]
		local PacketId = buffer.readu8(IdentifierPacket, 0) + 1

		-- Check if the packet with id exists
		if ModNet.Packets[PacketId] then
			PacketInfo = ModNet.Packets[PacketId]

			ArgCount = #PacketInfo.Types

			BufferCheck1 = true
		else
			BufferCheck1 = false
		end
	end

	-- detects if all args in the packet are a packet
	for Index = 1, #Args do
		if typeof(Args[Index]) == "buffer" then
			BufferSizeCount += buffer.len(Args[Index])
			VerifiedArgs += 1
		else
			break
		end
	end

	-- Checks if all the args are verified
	if VerifiedArgs * 2 == (DetectedArgs + ArgCount) and DetectedArgs == ArgCount and BufferSizeCount <= MNSettings.MaxBufferSize and PacketInfo.Enabled then
		BufferCheck2 = true
	else
		BufferCheck2 = false
	end

	-- Checks if the Packet passed all buffer checks
	if BufferCheck1 and BufferCheck2 then
		return true
	else
		return false
	end
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
		Remote.Parent = ReplicatorRemoteStorage

		-- Reciver signal connection
		ReplicatorObject.Receiver = Remote.OnServerEvent:Connect(function(Player: Player, ...: any)
			local Success = PerformPacketIntegrityCheck(Player, ...)

			if Success then
				-- Arguments
				local Args = table.pack(...)
				local Arg1 = Args[1] :: buffer

				-- Variables
				local PacketId = buffer.readu8(Arg1, 0)
				local Packet = ModNet.Packets[PacketId + 1]
				local PacketData = buffer.create(buffer.len(Arg1) - 1)

				buffer.copy(PacketData, 0, Arg1, 1, buffer.len(Arg1) - 1)

				print(Packet, PacketData)
			else
				if not RunService:IsStudio() then
					Player:Kick("[ModNet][Integrity] - Packet failed to pass Integrity test.")
				else
					warn("[ModNet][Integrity] - Integrity failure detected, check your packet implementation.")
				end
			end
		end)

		-- Thread connection
		-- Bulk engine handler
		ReplicatorObject.Thread = ReplicatorInfo.StepMode:Connect(function(_DeltaTime: number)
			for _ = 1, ReplicatorConfig.TickPerSecond do
				if #ReplicatorObject.OutBoundQueue > 0 then
					print("Out bound packet detected.")
				else
					break
				end
			end
		end)
	else
		local Remote = Instance.new("UnreliableRemoteEvent")
		Remote.Name = ReplicatorName
		Remote.Parent = ReplicatorRemoteStorage
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
function ModNet.CreatePacket(Name: string, Unreliable: boolean?, Replicator: string, TypesList: { Types.MN_Type })
	-- Assertions
	assert(not RequestPacketByName(Name), "Packet with this name already exists.")
	assert(table.maxn(ModNet.Packets) <= 256, "Cannot create more than 256 packets.")
	assert(ModNet.Engine.Replicators[Replicator], "Unable to find replicator with name: " .. Replicator)

	-- Variables
	local self = {}

	self.Name = Name
	self.Unreliable = Unreliable
	self.Replicator = Replicator
	self.Types = TypesList
	self.Signal = GoodSignal.new()

	ModNet.Packets[table.maxn(ModNet.Packets) + 1] = self :: Types.InternalPacket
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
	self.PacketInfo = Packet :: Types.InternalPacket
	self.PacketId = PacketId :: number

	return setmetatable(self, ObjectEngine) :: Types.PacketObjectEngine
end

print("[ModNet][Engine] - " .. tostring(tick() - StartTick))

return ModNet
