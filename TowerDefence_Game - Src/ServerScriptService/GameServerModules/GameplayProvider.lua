local AnalyticsService = game:GetService("AnalyticsService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local ServerModules = ServerScriptService:FindFirstChild("GameServerModules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Utilities = require(SharedModules.Utility)
local RemoteManager = require(ServerModules.RemoteManager)
local PlayersManager = require(ServerModules.PlayerManager)
local GameSettings = require(SharedModules.GameSettings)
local MapsModule = require(ServerModules.MapConfiguration)

local CurrentWave = nil
local isPlayerVotingAllowed = false

local MapsAvailable = {}
local PlayerVotes = {}

local GameplayProvider = {
    ElaspedTime = 0,
    SkippedVotes = false,
    MapToLoad = nil,
}

GameplayProvider.__index = GameplayProvider

function GameplayProvider.StartLobby(...: {StoreKey: table})
    local args = ...

    local DynamicStore = args["StoreKey"]

    local VoteRankedMaps = RemoteManager.new({
        Name = "VoteRankedMap",
        Parent = NetworkFolder.RemoteEvents,
        Activated = false,
        RemoteType = "Event",
        DebouceTime = 0.5,
        FallOffTime = 0.7,
        AllowedTypes = {
            string = true
        }
    })


end

return GameplayProvider