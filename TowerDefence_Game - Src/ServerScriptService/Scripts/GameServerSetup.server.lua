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
local ServerModules = ServerScriptService:FindFirstChild("Modules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local CmdrHooksFolder = ServerModules.Hooks
local TypesFolder = ServerModules.Types
local CmdrCommandsFolder = ServerModules.Commands

local CmdrModule = require(ServerModules.Cmdr)
local DynamicStoreFetcher = require(ServerModules.DynamicUpdateFetcher)
local GameplayProviderModule = require(ServerModules.GameplayProvider)
local PlayersManager = require(ServerModules.PlayerManager)
local Utilities = require(SharedModules.Utility)

local CanPlayerVote = false
local CmdrActivated = false

local PlayersVoted = {}

local function fetchData(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url)
    end)

    if success then
        return response
    else
        return response
    end
end

Players.PlayerAdded:Once(function(player)--Should totaly check if a client fired the vote difficulty event.
    Utilities:Print("Starting game.")

    CmdrModule:RegisterDefaultCommands()
    CmdrModule:RegisterCommandsIn(CmdrCommandsFolder)
    CmdrModule:RegisterHooksIn(CmdrHooksFolder)
   -- CmdrModule:RegisterTypesIn(TypesFolder)

   for index, value in game:GetDescendants() do
        if value:IsA("SpawnLocation") then
            value.Duration = 0
        end
    end

    local GameLobby = GameplayProviderModule.newLobby()

    --local w = DynamicStoreFetcher:Get("ItemShop")
end)

Players.PlayerAdded:Connect(function(Player : Player)
    local newPlayer = PlayersManager.new(Player)
end)

Players.PlayerRemoving:Connect(function(Player : Player)
    Utilities:Print("Removing player from game.")
    Player:Destroy()
end)