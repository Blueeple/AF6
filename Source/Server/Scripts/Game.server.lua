-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TextChatService = game:GetService("TextChatService")

-- Paths
local Network = ReplicatedStorage.Network
local Modules = ServerScriptService.Modules

-- Variables
local PlayersJoined = {}
local LoadedPlayers = 0

-- Modules
--local Cmdr = require(Modules.Cmdr)
--local GameplayProvider = require( Modules.GameplayProvider)
--local PlayerManager = require(Modules.PlayerManager)
--local DynamicContentLoader = require(Modules.DynamicContentLoader)
local RemoteManager = require(Modules.RemoteManager)
--local UserDataManager = require(Modules.UserDataManager)

RemoteManager:Register(ReplicatedStorage.temo, "RMM", Network)

local StreamerEvent = RemoteManager.new(
    "Streamer",
    "QuickFire",
    Network,
    {
        Debounce = 1,
        MaxPingPerMinite = 5,
        Activated = true
    }
)