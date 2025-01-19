local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Utilities = require(SharedModules.Utility)

local PlayerManager = {}
PlayerManager.__index = PlayerManager
PlayerManager.Players = {}

local function GenerateNewUserColor()
    return Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

local function SetupCharacter(Character: Model)
    if Character then
        for index, BasePart in pairs(Character:GetDescendants()) do
            if BasePart:IsA("BasePart") then
                BasePart.CollisionGroup = "Player"
            end
        end
    end
end

local function SetupHumanoid(Humanoid: Humanoid)
    Humanoid.BreakJointsOnDeath = false
    Humanoid.AutoJumpEnabled = false
    Humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion
end

function PlayerManager.new(...: Player)
    local newPlayer = ...
    local UserColor = GenerateNewUserColor()

    Utilities:Print({"Indexing new player for:", newPlayer.Name})

    local PlayerConfigurations = {
        Name = newPlayer.Name,
        UserColor = UserColor,
        EquipedTowers = {},
    }

    PlayerManager.Players[newPlayer.UserId] = PlayerConfigurations

    local PlayerConnection = newPlayer.CharacterAdded:Connect(function(Character: Model)
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        SetupCharacter(Character)
        SetupHumanoid(Humanoid)

        Character.Parent = workspace.Players

        Humanoid.Died:Once(function()
            task.wait(0.5)
            newPlayer:LoadCharacter()
        end)
    end)

    newPlayer.Destroying:Once(function()
        PlayerConnection:Disconnect()
    end)

    newPlayer:LoadCharacter()

    return setmetatable(PlayerConfigurations, PlayerManager)
end

function PlayerManager:AllPlayers()
    return Players:GetChildren()
end

function PlayerManager:Kick(PlayersInGame: {}, KickInformationRaw: {})
    local PlayersToKick = if type(PlayersInGame) == "table" then PlayersInGame else Players:FindFirstChild(PlayersInGame)
    local KickText = if type(KickInformationRaw) == "table" then table.concat(KickInformationRaw, " ") else tostring(KickInformationRaw)

    Utilities:Print("Kicking players.")

    if type(PlayersToKick) == "table" then
        local PlayersTable = PlayersToKick or nil
        for Index, Player in PlayersToKick do
            if Players[Player.Name] then
                Player:Kick(KickText)
            end
        end
    elseif PlayersToKick:IsA("Player") then
        local Player = PlayersToKick
        if Player then
            Player:Kick(KickText)
        end
    end
end

function PlayerManager:Reload(PlayersInGame: {})
    local PlayersToReload = if type(PlayersInGame) == "table" then PlayersInGame else Players:FindFirstChild(PlayersInGame)
    Utilities:Print("Reloading players.")

    if type(PlayersToReload) == "table" then
        local PlayersTable = PlayersToReload or nil
        for Index, Player in PlayersToReload do
            if Players[Player.Name] then
                Players[Player.Name]:LoadCharacter()
            end
        end
    elseif PlayersToReload:IsA("Player") then
        local Player = PlayersToReload
        if Player then
            Player:LoadCharacter()
        end
    end
end

function PlayerManager:GetInfo()
    return self
end

return PlayerManager