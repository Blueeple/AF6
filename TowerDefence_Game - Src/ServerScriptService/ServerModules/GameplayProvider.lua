--//Services
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

--//Core server folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")
local ServerBindings = ServerScriptService:FindFirstChild("ServerBindings")

--//Server module folders
local Admin = ServerModulesFolder.Admin
local Cmdr = ServerModulesFolder.Cmdr

--//ServerFolders
local GameMaps = ServerStorage:FindFirstChild("GameMaps")

--//Shared folders
local NetworkShared = ReplicatedStorage:FindFirstChild("Network")

--//Shared modules
local Utilities = require(SharedModulesFolder.Utility)

--//Modules
local Cmdr = require(ServerModulesFolder.Cmdr)
local MoveSetManager = require(ServerModulesFolder.MoveSetManager)
local PlayerManager = require(ServerModulesFolder.PlayerManager)
local DynamicContentLoader = require(ServerModulesFolder.DynamicContentLoader)
local RemoteManager = require(ServerModulesFolder.RemoteManager)
local MapConfigurator = require(ServerModulesFolder.MapConfigurator)

--//Variables
local TimerSkipped = false
local isPlayerVotingAllowed = false

--//Tables
local MapsAvailable = {}
local PlayerVotes = {}

--//Map scanning parameters
MapScanParams = { --Remove this later!
    Tags_Options = {
        isStandardMapEnabled = true,
    },
    Settings = {
        quarantineInfectedMaps = false, --This does nothing for now.

    }
}

local GameplayProvider = {}

--//Tallys up all votes feeded to the function.
local function TallyVotes(Votes: {})
    local ItemVotes = Votes
    local SameVotes = {}
    local HighestVoteCount = 0
    local HighestVoteName = nil

    Utilities:OutputLog("Tallying votes.")

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

    Utilities:OutputLog("Processing tally.")

    if #SameVotes >= 2 and HighestVoteName == nil then
        local randomIndex = math.random(1, #SameVotes)
        return tostring(SameVotes[randomIndex])
    elseif HighestVoteName then
        return HighestVoteName
    else
        for index, Player in Players:GetPlayers() do
            if Player then
                Utilities:OutputWarn("[Error - 002]: Failed to process votes.")
                PlayerManager:Kick(PlayerManager:AllPlayers(), "Voting system failure.")
            end
        end
    end
end

--//Sets up the essential elements for the combat system.
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
            Vector3 = true,
            CFrame = true,
        }
    })

    task.wait(0.1)

    FighterEvent:SetActivation(true)

    --//Work on the fighting system
    FighterEvent.Event:Connect(function(Player, Data)
        print(Player, Data)
    end)
end

--//Loads a map to the server.
local function LoadMap(MapName: string, Directory: Folder)
    local Map = nil

    Utilities:OutputLog({"Attempting to load map:", MapName})

    if Directory[MapName] ~= nil then
        Utilities:OutputLog({"Found map file for map: ", MapName})
        Map = Directory[MapName]:Clone()
        Workspace.Map:ClearAllChildren()
        Map.Parent = workspace.Map
        PlayerManager:Reload(PlayerManager:AllPlayers(), true)
        SetupServerFightSystem()
        Utilities:OutputLog("Map loading completed.")
    else
        Utilities:OutputWarn({"Failed to load map:", MapName})
        PlayerManager:Kick(PlayerManager:AllPlayers(), "Failed to load map.")
    end

   return Map
end

--//Gets all the maps from a certian table in a random order.
local function GenerateMapRng(Maps: table, Amount: number)
    local MapsProccesed = {}

    if #Maps["Whitelist"] < Amount then Utilities:OutputWarn("Not enough maps are the game to start.") return end
    
    Utilities:OutputLog("Proccessing quick maps.")

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

    Utilities:OutputLog("Quick map processing completed.")
    
    return MapsProccesed
end

--//Loads the game content to a specified folder
function GameplayProvider.LoadContent(ContentName: string, ContentFolder: Folder, SharedContentFolder: Folder)
    local ContentToLoad = ContentFolder[ContentName]:Clone()
    ContentToLoad.Parent = SharedContentFolder
    return ContentToLoad
end

--//Does the normal lobby functions. --Change it to wait for all client to register true after loading.
function GameplayProvider.StartLobby(...: {StoreKey: table})
    Utilities:OutputLog("Starting up core modules.")

    local args = ...

    local CountTime = 30

    local DynamicStore = args["StoreKey"]

    MapsAvailable = MapConfigurator:ScanForMaps(MapScanParams, GameMaps.RankedServerMaps)

    local QuickProcessedMaps = GenerateMapRng(MapsAvailable, 3)

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

    VoteRankedMaps.Event:Connect(function(Player: Player, ServerMessage: string)
        print(Player, ServerMessage)

        VoteRankedMaps:Fire(RemoteManager:AllPlayers(), QuickProcessedMaps)
    end)

    VoteRankedMaps:SetActivation(true)
    
    VoteRankedMaps:Fire(RemoteManager:AllPlayers(), {
        Command = "Start",
        Input = QuickProcessedMaps
    })

    for Time = 1, CountTime do
        Utilities:OutputLog({"Starting game in:", CountTime + 1 - Time})

        if Time == CountTime or TimerSkipped == true then
            Utilities:OutputLog("Starting vote processing.")

            local newMap = TallyVotes(QuickProcessedMaps)

            LoadMap(newMap, GameMaps.RankedServerMaps)

            VoteRankedMaps:Fire(RemoteManager:AllPlayers(), "End")
            VoteRankedMaps:Shutdown()

            return
        end

        task.wait(1)
    end
end

return GameplayProvider