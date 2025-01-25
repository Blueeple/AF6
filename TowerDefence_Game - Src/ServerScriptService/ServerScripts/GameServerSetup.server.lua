--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

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

--Shared modules
local Utilities = require(SharedModulesFolder.Utility)

--Modules
local Cmdr = require(ServerModulesFolder.Cmdr)
local GameplayProvider = require(Core.GameplayProvider)
local MoveSetManager = require(Management.MoveSetManager)
local PlayerManager = require(Management.PlayerManager)
local DynamicContentLoader = require(Network.DynamicContentLoader)
local RemoteManager = require(Network.RemoteManager)
local MapConfigurator = require(ServerUtility.MapConfigurator)

--Script Logic
Players.PlayerAdded:Once(function(player)--Should totaly check if a client fired the vote difficulty event.
    Utilities:Print("Starting game.")

    --local GameStore_ServerSettings = DynamicStoreFetcher:Get("ServerSettings.json")

    Cmdr:RegisterDefaultCommands()
    Cmdr:RegisterCommandsIn(Admin.CustomCommands)
    Cmdr:RegisterHooksIn(Admin.Hooks)
   -- CmdrModule:RegisterTypesIn(TypesFolder)

    local GameLobby = GameplayProvider.StartLobby({
        StoreKey = nil, --GameStore_ServerSettings
    })
end)

Players.PlayerAdded:Connect(function(Player : Player)
    local newPlayer = PlayerManager.new(Player)
end)

Players.PlayerRemoving:Connect(function(Player : Player)
    Utilities:Print("Removing player from game.")
    Player:Destroy()
end)