--Services
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

--Core server folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")
local ServerBindings = ServerScriptService:FindFirstChild("ServerBindings")

--Server module folders
local Admin = ServerModulesFolder.Admin
local Cmdr = ServerModulesFolder.Cmdr
local Core = ServerModulesFolder.Core
local Management = ServerModulesFolder.Management
local Network = ServerModulesFolder.Network
local ServerUtility = ServerModulesFolder.ServerUtility

--ServerFolders
local GameMaps = ServerStorage:FindFirstChild("GameMaps")

--Shared folders
local NetworkShared = ReplicatedStorage:FindFirstChild("Network")

--Shared modules
local Utilities = require(SharedModulesFolder.Utility)

--Modules
local Cmdr = require(ServerModulesFolder.Cmdr)
local MoveSetManager = require(Management.MoveSetManager)
local PlayerManager = require(Management.PlayerManager)
local DynamicContentLoader = require(Network.DynamicContentLoader)
local RemoteManager = require(Network.RemoteManager)
local MapConfigurator = require(ServerUtility.MapConfigurator)

--Variables
local TimerSkipped = false
local isPlayerVotingAllowed = false

--Tables
local MapsAvailable = {}
local PlayerVotes = {}

MapScanParams = { --Remove this later!
    Tags_Options = {
        isStandardMapEnabled = true,
    },
    Settings = {
        quarantineInfectedMaps = false, --This does nothing for now.

    }
}

local MoveSetsReplicationTable = {
    Test = true,
}

local GameplayProvider = {}

local function TallyVotes(Votes: {})
    local ItemVotes = Votes
    local SameVotes = {}
    local HighestVoteCount = 0
    local HighestVoteName = nil

    Utilities:Print("Tallying votes.")

    for Name, VoteName in PlayerVotes do
        if VoteName then
            table.insert(ItemVotes[VoteName], Name)
        end
    end

    for VoteName, Votes in pairs(ItemVotes) do
        local VoteCount = #Votes
         if VoteCount > HighestVoteCount then
            HighestVoteName = VoteName
            HighestVoteCount = VoteCount
        elseif VoteCount == HighestVoteCount then
            table.insert(SameVotes, HighestVoteName)
            table.insert(SameVotes, VoteName)
            HighestVoteName = nil
        end
    end

    Utilities:Print("Processing tally.")

    if #SameVotes >= 2 and HighestVoteName == nil then
        local randomIndex = math.random(1, #SameVotes)
        return tostring(SameVotes[randomIndex])
    elseif HighestVoteName then
        return HighestVoteName
    else
        for index, Player in Players:GetPlayers() do
            if Player then
                Utilities:Warn("[Error - 002]: Failed to process votes.")
                PlayerManager:Kick(PlayerManager:AllPlayers(), "Voting system failure.")
            end
        end
    end
end

local function SetupServerFightSystem()
    
    
    local FighterEvent = RemoteManager.new({
        Name = "FighterEvent",
        Parent = NetworkShared.RemoteEvents,
        Activated = false,
        RemoteType = "Event",
        DebouceTime = 0.5,
        FallOffTime = 3,
        AllowedTypes = {
            table = true,
            string = true,
            vector = true,
            CFrame = true,
        }
    })

    MoveSetManager:InitializeMoveSets(MoveSetsReplicationTable)-- Chnage this later bro.

    task.wait(0.1)

    FighterEvent:SetActivation(true)

    FighterEvent.Event:Connect(function(Player, Data)
        MoveSetManager:ProccessMove(Player, Data)
    end)
end

local function LoadMap(MapName : string, Directory: Folder) --Add lighting loading.
    local Map = nil

    Utilities:Print({"Attempting to load map:", MapName})

    if Directory[MapName] ~= nil then
        Utilities:Print({"Found map file for map: ", MapName})
        Map = Directory[MapName]:Clone()
        Map.Parent = workspace.GameMap
        PlayerManager:Reload(PlayerManager:AllPlayers())
        task.wait()
        SetupServerFightSystem()
        Utilities:Print("Map loading completed.")
    else
        Utilities:Warn({"Failed to load map:", MapName})
        PlayerManager:Kick(PlayerManager:AllPlayers(), "Failed to load map.")
    end

   return Map
end

local function QuickProccesMaps(Maps: table, Amount: number)
    local MapsProccesed = {}

    if #Maps["Whitelist"] < Amount then Utilities:Warn("Not enough maps are the game to start.") return end
    
    Utilities:Print("Proccessing quick maps.")

    for MapId = 1, Amount do
        local newMapId = math.random(1, #Maps["Whitelist"])
        local newMap = Maps["Whitelist"][MapId]
        Maps["Whitelist"][MapId] = nil
        MapsProccesed[newMap.Name] = {
            ImageId = "Placeholder: 10910082",
            Type = "Open border",
            Size = "Small"
        }
    end

    Utilities:Print("Quick map processing completed.")
    
    return MapsProccesed
end

function GameplayProvider.StartLobby(...: {StoreKey: table})
    Utilities:Print("Starting up core modules.")

    local args = ...

    local CountTime = 5

    local DynamicStore = args["StoreKey"]

    MapsAvailable = MapConfigurator:ScanForMaps(MapScanParams, GameMaps.RankedServerMaps)

    local QuickProcessedMaps = QuickProccesMaps(MapsAvailable, 6)

    local VoteRankedMaps = RemoteManager.new({
        Name = "VoteRankedMap",
        Parent = NetworkShared.RemoteEvents,
        Activated = false,
        RemoteType = "Event",
        DebouceTime = 0.5,
        FallOffTime = 3,
        AllowedTypes = {
            string = true,
        }
    })

    VoteRankedMaps.Event:Connect(function(Player: Player, Data: string)
        PlayerVotes[Player.Name] = Data
    end)

    VoteRankedMaps:SetActivation(true)
    VoteRankedMaps:Fire(RemoteManager:AllPlayers(), {Task = "Create", Maps = QuickProcessedMaps})

    for Time = 1, CountTime do
        Utilities:Print({"Starting game in:", CountTime + 1 - Time})

        if Time == CountTime or TimerSkipped == true then
            Utilities:Print("Starting vote processing.")
            local newMap = TallyVotes(QuickProcessedMaps)
            task.wait()
            LoadMap(newMap, GameMaps.RankedServerMaps)
            VoteRankedMaps:Fire(RemoteManager:AllPlayers(), true)
            VoteRankedMaps:Shutdown()
            return
        end

        task.wait(1)
    end
end

return GameplayProvider