local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local ServerModules = ServerScriptService:FindFirstChild("GameServerModules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local CmdrHooksFolder = ServerModules.Hooks
local TypesFolder = ServerModules.Types
local CmdrCommandsFolder = ServerModules.Commands

local CmdrModule = require(ServerModules.Cmdr)
local DynamicStoreFetcher = require(ServerModules.DynamicUpdateFetcher)
local GameplayProviderModule = require(ServerModules.GameplayProvider)
local PlayersManager = require(ServerModules.PlayerManager)
local Utilities = require(SharedModules.Utility)

Players.PlayerAdded:Once(function(player)--Should totaly check if a client fired the vote difficulty event.
    Utilities:Print("Starting game.")

    local GameStore_ServerSettings = DynamicStoreFetcher:Get("ServerSettings.json")

    CmdrModule:RegisterDefaultCommands()
    CmdrModule:RegisterCommandsIn(CmdrCommandsFolder)
    CmdrModule:RegisterHooksIn(CmdrHooksFolder)
   -- CmdrModule:RegisterTypesIn(TypesFolder)

   for index, value in game:GetDescendants() do
        if value:IsA("SpawnLocation") then
            value.Duration = 0
        end
    end

    local GameLobby = GameplayProviderModule.StartLobby({
        StoreKey = GameStore_ServerSettings
    })
end)

Players.PlayerAdded:Connect(function(Player : Player)
    local newPlayer = PlayersManager.new(Player)
end)

Players.PlayerRemoving:Connect(function(Player : Player)
    Utilities:Print("Removing player from game.")
    Player:Destroy()
end)