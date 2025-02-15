local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local ServerModules = ServerScriptService:FindFirstChild("GameServerModules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Utilities = require(SharedModules.Utility)

local PlayerManager = {}
PlayerManager.__index = PlayerManager
PlayerManager.Players = {}

local function GenerateNewUserColor()
    return Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

local function SetupCharacter(Character: Model, Humanoid: Humanoid)
    local Player = Players:GetPlayerFromCharacter(Character)
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

    local Animate = Character:FindFirstChild("Animate")
    local Health = Character:FindFirstChild("Health")

    local RightArm = Character:FindFirstChild("Right Arm")
    local LeftArm = Character:FindFirstChild("Left Arm")
    local RightLeg = Character:FindFirstChild("Right Leg")
    local LeftLeg = Character:FindFirstChild("Left Leg")
    local Torso = Character:FindFirstChild("Torso Arm")

    Character.PrimaryPart = HumanoidRootPart
    Animate:Destroy()
    Health:Destroy()

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

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
end

local function SetPlayerValue(Player: Player, Name: string, Value: any)
    local PlayerId = Player.UserId
    PlayerManager.Players[PlayerId][Name] = Value
end

function PlayerManager.new(Player: Player)
    local UserColor = GenerateNewUserColor()

    Utilities:OutputLog({"Indexing new player for:", Player.Name})

    local PlayerConfigurations = {
        Name = Player.Name,
        UserColor = UserColor,
        MoveSet = "PlaceHolder",
        CanUseMove = false,
    }

    PlayerManager.Players[Player.UserId] = PlayerConfigurations
    
    SetPlayerValue(Player, "MoveSet", "Ohma_Tokita")

    local PlayerConnection = Player.CharacterAdded:Connect(function(Character: Model)
        local PlayerData = PlayerManager.Players[Player.UserId]
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")

        SetupCharacter(Character, Humanoid)
        SetupHumanoid(Humanoid)
        SetPlayerValue(Player, "CanUseMove", true)

        Character.Parent = workspace.PlayersFolder

        Humanoid.Died:Once(function()
            SetPlayerValue(Player, "CanUseMove", false)
            task.wait(2.5)
            Player:LoadCharacter()
        end)
    end)

    Player.Destroying:Once(function()
        PlayerConnection:Disconnect()
    end)

    Player:LoadCharacter()

    return setmetatable(PlayerConfigurations, PlayerManager)
end

function PlayerManager:ReadPlayer(Player: Player)
    if PlayerManager.Players[Player.UserId] ~= nil then
        return PlayerManager.Players[Player.UserId]
    else
        Utilities:OutputWarn({"No player found for name:", tostring(Player)})
    end
end

function PlayerManager:AllPlayers()
    return Players:GetChildren()
end

function PlayerManager:Kick(PlayersInGame: {}, KickInformationRaw: {})
    local PlayersToKick = if type(PlayersInGame) == "table" then PlayersInGame else Players:FindFirstChild(PlayersInGame)
    local KickText = if type(KickInformationRaw) == "table" then table.concat(KickInformationRaw, " ") else tostring(KickInformationRaw)

    Utilities:OutputLog("Kicking players.")

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
    Utilities:OutputLog("Reloading players.")

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