--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TextChatService = game:GetService("TextChatService")

--//Core server folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")
local ServerBindings = ServerScriptService:FindFirstChild("ServerBindings")
local MoveSetsFolder = ServerStorage.MoveSets

--//Server module folders
local Admin = ServerModulesFolder.Admin
local Cmdr = ServerModulesFolder.Cmdr

--//Shared folders
local NetworkShared = ReplicatedStorage.Network
local ClientContentFolder = ReplicatedStorage.Content

--//Shared modules
local Utilities = require(SharedModulesFolder.Utility)

--//Variables
local PlayersJoined = {}
local LoadedPlayers = 0

--//Modules
local Cmdr = require(ServerModulesFolder.Cmdr)
local GameplayProvider = require(ServerModulesFolder.GameplayProvider)
local PlayerManager = require(ServerModulesFolder.PlayerManager)
local DynamicContentLoader = require(ServerModulesFolder.DynamicContentLoader)
local RemoteManager = require(ServerModulesFolder.RemoteManager)
local UserDataManager = require(ServerModulesFolder.UserDataManager)

--//Objects
local PlayerManagerBinding = Instance.new("BindableEvent", ServerBindings)

--//PlayerManagerBinding Properties
PlayerManagerBinding.Name = "PlayerManagerBinding"

--//Triggers when a player joined
Players.PlayerAdded:Once(function(player)--Should totaly check if a client fired the vote difficulty event.
    Utilities:OutputLog("Starting game.")

    --local GameStore_ServerSettings = DynamicStoreFetcher:Get("ServerSettings.json")

    --//Cmdr Setup
    --[[Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(Admin.CustomCommands)
    Cmdr:RegisterHooksIn(Admin.Hooks)
    -- CmdrModule:RegisterTypesIn(TypesFolder)]]

    --//Links and BindableEvent to PlayerManager
    PlayerManager:LinkEvent(PlayerManagerBinding)

    --//Gets all the movesets in the game.
    local MoveSets = MoveSetsFolder:GetChildren()

    --//Loads the player content???
    for i = 1, #MoveSets do
        local MoveSetName = MoveSets[i].Name
        GameplayProvider.LoadContent(MoveSetName, MoveSetsFolder, ClientContentFolder)
    end

    --//RemoteEvent for detecting when a player's client has loaded.
    local PlayerLoaded = RemoteManager.new({
        Name = "PlayerLoaded",
        Parent = NetworkShared.RemoteEvents,
        Activated = true,
        RemoteType = "Event",
        DebouceTime = 100,
        FallOffTime = 1,
        AllowedTypes = {
            boolean = true,
        }
    })

    --//RemoteEvent for sending player data.
    local GetPlayerData = RemoteManager.new({
        Name = "GetPlayerData",
        Parent = NetworkShared.RemoteEvents,
        Activated = true,
        RemoteType = "Event",
        DebouceTime = 0.95,
        FallOffTime = 1,
        AllowedTypes = {
            boolean = true,
        }
    })

    --//Retrives the player data then returning it.
    GetPlayerData.Event:Connect(function(Player, Data)
        local Profile = UserDataManager:Get(Player)["Data"]
        GetPlayerData:Fire(Player, Profile)
    end)

    --//Adds up a vot count to detect how many players have loaded in.
    PlayerLoaded.Event:Connect(function(Player, Data)
        LoadedPlayers += 1

        if LoadedPlayers == #PlayersJoined then
            PlayerLoaded:Shutdown()
            local GameLobby = GameplayProvider.StartLobby({
                StoreKey = nil, --GameStore_ServerSettings
            })
        end
    end)
end)

--//Triggers when a player joins creates a new class.
Players.PlayerAdded:Connect(function(Player : Player)
    local NewPlayer = PlayerManager.new(Player)
    table.insert(PlayersJoined, Player)

    if Player:GetRankInGroup(15561950) > 250 then
        Utilities:OutputLog({"Player:", Player.Name, "is a developer."})
    end
end)

--//Triggers when a player left the game and removes the class.
Players.PlayerRemoving:Connect(function(Player : Player)
    Utilities:OutputLog("Removing player from game.")
    
    RemoteManager:RemovePlayerFrom(Player, "$Active")

    Player:Destroy()

    Utilities:OutputLog({"Removed Player:", (Player.Name .. ".")})
end)