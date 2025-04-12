-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Core server folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")

-- Shared folders
local NetworkShared = ReplicatedStorage.Network

-- Shared modules
local Utilities = require(SharedModulesFolder.Utility)
local ServerSettings = require(ServerModulesFolder.ServerConfigurations)

-- Variables
local StartTime = tick()

-- Modules
local ProfileService = require(ServerModulesFolder.ProfileService)
local DataTemplate = require(ServerModulesFolder.DataTemplateModule)

-- Module?
local DataStoreKey = ServerSettings.DataStoreKey
local ProfileStore = ProfileService.GetProfileStore(DataStoreKey, DataTemplate)

-- Exports
export type Constructor = {
    Player: Player,
    TemplateKey: table,
}

local UserDataManager = {}
UserDataManager.__index = UserDataManager
UserDataManager.Profiles = {}

local function UpdateUserStatsLeader(Player: Player, Profile: any?)
    
end

function UserDataManager.new(Constructor: Constructor)
    Utilities:OutputLog({"Loading data for Player:", (Constructor.Player.Name .. ".")})

    -- Self
    local self = {}

    -- Variables
    local Player = Constructor.Player
    local PlayerId = Player.UserId

    -- Data
    local Profile = ProfileStore:LoadProfileAsync("Player_" .. PlayerId)

    if Profile ~= nil then
        Profile:AddUserId(PlayerId)
        Profile:Reconcile()

        Profile:ListenToRelease(function()
            UserDataManager.Profiles[PlayerId] = nil
            Player:Kick("Session expired.")
            Utilities:OutputLog({"Session for Player:", Constructor.Player.Name, "expired."})
        end)

        if Player:IsDescendantOf(Players) then
            UserDataManager.Profiles[PlayerId] = Profile
            UpdateUserStatsLeader(Player, Profile)
        else
            Profile:Release()
        end
    else
        Player:Kick("Failed to load your data in Phase 2.")
        Utilities:OutputWarn({"Failed to load data for Player:", Constructor.Player.Name, "."})
    end

    -- Self functions
    -- Removes the user in the data stores.
    function self:Get()
        if Profile ~= nil then
            Utilities:OutputLog({"Retrived Profile for player:", (Player.Name .. ".")})
            return Profile
        else
            Utilities:OutputWarn({"Failed to get Profile for player:", (Player.Name .. ".")})
            return nil
        end
    end

    -- This function DOES NOT WORK for now.
    function self:Set(...)
        Profile = UserDataManager.Profiles[PlayerId]

        if Profile ~= nil then
            Profile:Release()
        end
    end

    -- Removes the player from the avaliable profiles list.
    function self:Remove()
        Profile = UserDataManager.Profiles[PlayerId]

        if Profile ~= nil then
            Profile:Release()
        end
    end

    return setmetatable(self, UserDataManager)
end

-- The global way of setting user data.
function UserDataManager:Set(Player: Player)
    local PlayerId = Player.UserId
    local Profile = UserDataManager.Profiles[PlayerId]
    
    if Profile ~= nil then
        Utilities:OutputLog({"Retrived Profile for player:", (Player.Name .. ".")})
        return Profile
    else
        Utilities:OutputWarn({"Failed to get Profile for player:", (Player.Name .. ".")})
        return nil
    end
end

-- The global way of retiveing user data.
function UserDataManager:Get(Player: Player)
    local PlayerId = Player.UserId
    local Profile = UserDataManager.Profiles[PlayerId]
    
    if Profile ~= nil then
        Utilities:OutputLog({"Retrived Profile for player:", (Player.Name .. ".")})
        return Profile
    else
        Utilities:OutputWarn({"Failed to get Profile for player:", (Player.Name .. ".")})
        return nil
    end
end

Utilities:OutputLog({"Loaded DataManager in:", tick() - StartTime})
return UserDataManager