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
local Core = ServerModulesFolder.Core
local Management = ServerModulesFolder.Management
local Network = ServerModulesFolder.Network
local ServerUtility = ServerModulesFolder.ServerUtility

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
local GameplayProvider = require(Core.GameplayProvider)
local MoveSetManager = require(Management.MoveSetManager)
local PlayerManager = require(Management.PlayerManager)
local DynamicContentLoader = require(Network.DynamicContentLoader)
local RemoteManager = require(Network.RemoteManager)
local MapConfigurator = require(ServerUtility.MapConfigurator)

--//Triggers when a player joined
Players.PlayerAdded:Once(function(player)--Should totaly check if a client fired the vote difficulty event.
    Utilities:OutputLog("Starting game.")

    --local GameStore_ServerSettings = DynamicStoreFetcher:Get("ServerSettings.json")
    --[[Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(Admin.CustomCommands)
    Cmdr:RegisterHooksIn(Admin.Hooks)
   -- CmdrModule:RegisterTypesIn(TypesFolder)]]

    local MoveSets = MoveSetsFolder:GetChildren()

    for i = 1, #MoveSets do
        local MoveSetName = MoveSets[i].Name
        GameplayProvider.LoadContent(MoveSetName, MoveSetsFolder, ClientContentFolder)
    end

    --//Remote event for players loaded.
    local PlayerLoaded = RemoteManager.new({
        Name = "",
        Parent = NetworkShared.RemoteEvents,
        Activated = true,
        RemoteType = "Event",
        DebouceTime = 100,
        FallOffTime = 1,
        AllowedTypes = {
            boolean = true,
        }
    })

    --//Remote event for sending server data.
    local PlayerLoaded = RemoteManager.new({
        Name = "PlayerJoined",
        Parent = NetworkShared.RemoteEvents,
        Activated = true,
        RemoteType = "Event",
        DebouceTime = 100,
        FallOffTime = 1,
        AllowedTypes = {
            boolean = true,
        }
    })

    --//Load the damn player data already...
    local GetPlayerData = RemoteManager.new({
        Name = "GetPlayerData",
        Parent = NetworkShared.RemoteFunctions,
        Activated = true,
        RemoteType = "Functional",
        DebouceTime = 15,
        FallOffTime = 3,
        AllowedTypes = {
            boolean = true,
        }
    })

    GetPlayerData.Event:Connect(function(Player, Data)
        return "Hello!"
    end)

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
    local newPlayer = PlayerManager.new(Player)
    table.insert(PlayersJoined, Player)

    if Player:GetRankInGroup(15561950) > 250 then

    end
end)

--//Triggers when a player left the game and removes the class.
Players.PlayerRemoving:Connect(function(Player : Player)
    Utilities:OutputLog("Removing player from game.")

    RemoteManager:RemovePlayerFrom(Player, "$Active")
    Player:Destroy()
end)