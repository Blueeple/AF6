--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--//Core Server Folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")

local Utilities = require(SharedModulesFolder.Utility)
local ServerSettings = require(ServerModulesFolder.ServerConfigurations)
local UserDataManager = require(ServerModulesFolder.UserDataManager)
local PlayerSettingDefault = require(ServerModulesFolder.PlayerDefaults)

--//Objects
local PlayersFolder = workspace.Players
local ExternalDataRequests = nil

--//Exported types
export type PlayerManagerCmds = {
    CmdName: string,
    DispacherInfo: string,
    DispacherArgs: any,
}

local PlayerManager = {}
PlayerManager.__index = PlayerManager

PlayerManager.Players = {}

Players.PlayerRemoving:Connect(function(Player)
    if PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]] ~= nil then
        PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]] = nil
    end
end)

--//Pass argument in the functions.
local function SetupExternalDataRequests()
    local Cmds = script.Commands

    ExternalDataRequests.Event:Connect(function(Data: PlayerManagerCmds)
        if Data.CmdName ~= nil and Cmds[Data.CmdName] ~= nil then
            local Module = require(Cmds[Data.CmdName])
            local DispacherInfo = Data.DispacherInfo

            if Module[DispacherInfo] ~= nil then
                Module[DispacherInfo](Data.DispacherArgs)
            else
                Module = nil
                return
            end
        end
    end)
end

--//Generates a new Color for players.
local function GenerateNewUserColor()
    return Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
end

--//Setup a character for a player.
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

    Humanoid.AutoRotate = false
    Humanoid.BreakJointsOnDeath = false
    Humanoid.AutoJumpEnabled = false
    Humanoid.NameOcclusion = Enum.NameOcclusion.NoOcclusion

    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    Animate:Destroy()
    Health:Destroy()

    if Character then
        Character.PrimaryPart = HumanoidRootPart
        Character.Parent = PlayersFolder

        for index, BasePart in pairs(Character:GetDescendants()) do
            if BasePart:IsA("BasePart") then
                BasePart.CollisionGroup = "Player"
            end
        end
    end

end

--//Creates a player instance.
function PlayerManager.new(Player: Player)
    --//Self
    local self = {}

    --//Applications
    PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]] = {}
    PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]].Settings = PlayerSettingDefault

    --//Variables
    local PlayerTable = PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]]

    --//Player variables
    local PlayerSettings = PlayerTable["Settings"]

    --//Self Variables
    self.Settings = PlayerSettings
    
    --//PlayerSettings
    PlayerSettings.RespawningEnabled = true

    --//Objects
    local UserColor = GenerateNewUserColor()
    local PlayerInformation = Instance.new("Folder", Player)

    --//Log
    Utilities:OutputLog({"Indexing new player for:", Player.Name})

    --//Confifurations
    local PlayerStoreData = UserDataManager.new({
        Player = Player,
        TemplateKey = {},
    })

    --//Functions
    --//Kicks the player
    function self:Kick(...: string)
        Player:Kick(...)
    end

    --//Reloads the player
    function self:Reload()
        Player:LoadCharacter()
    end

    --//Sets the provided settings of the player
    function self:SetSettings(Name: string, Value: any)
        if PlayerSettings[Name] ~= nil then
            PlayerSettings[Name] = Value
        else
            Utilities:OutputWarn({"Settings:", (tostring(Name) .. " does not exist.")})
        end
    end

    --//Read the data from the player
    function self:Read()
        return self.Settings
    end

    --PlayerInformation Properties
    PlayerInformation.Name = "PlayerInfo"

    --//Player Character
    if Player.Character == nil then
        Player:LoadCharacter()
        Player.Character.Parent = PlayersFolder
    end

    --//Checks for when the player's character is added
    Player.CharacterAdded:Connect(function(Character)
        local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")
        local RootPart: Part  = Character:FindFirstChild("HumanoidRootPart")

        SetupCharacter(Character, Humanoid)

        RootPart.Transparency = 0.5
        RootPart.Color = Color3.fromRGB(76, 63, 255)

        Humanoid.Died:Once(function()
            if PlayerSettings.RespawningEnabled == true then
                task.wait(ServerSettings.PlayerRespawnTime)
                Player:LoadCharacter()
            end
        end)

        Utilities:OutputLog({"Created character for player:", (Player.Name .. ".")})
    end)

    return setmetatable(self, PlayerManager)
end

--//Gets the external data of a player.
function PlayerManager:ReadPlayerExternal(Player: Player)
    if PlayerManager.Players[Player.UserId] ~= nil then
        return PlayerManager.Players[Player.UserId]
    else
        Utilities:OutputWarn({"No player found for name:", tostring(Player)})
    end
end

--//Returns all the players in game.
function PlayerManager:AllPlayers()
    return Players:GetChildren()
end

--//Kicks all the players passed in the script
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

--//Reloads all the players passed in the script.
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

--//Returns the external player (WILL NOT WORK IN SCRIPTS WHERE THE PLAYER IS NOT INITIALIZED)
function PlayerManager:GetExternalPlayer(Player: Player)
    if PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]] ~= nil then
        --//Self
        local self = {}

        --//Variables
        local PlayerSettings = PlayerManager.Players[Player[ServerSettings.PlayerIndexingType]].Settings

        --//Self functions
        function self:Kick(...: string)
            Player:Kick(...)
        end

        --//Reloads the player
        function self:Reload()
            Player:LoadCharacter()
        end

        --//Sets the provided settings of the player
        function self:SetSettings(Name: string, Value: any)
            if PlayerSettings[Name] ~= nil then
                PlayerSettings[Name] = Value
            else
                Utilities:OutputWarn({"Settings:", (tostring(Name) .. " does not exist.")})
            end
        end

        --//Read the data from the player
        function self:Read()
            return self.Settings
        end

        return setmetatable(self, PlayerManager)
    else
        Utilities:OutputWarn({"Failed to get player:", (tostring(Player) .. ".")})
        return nil
    end
end

--//Links a Bindable event to the module for datastore editing for external scripts or threads.
function PlayerManager:LinkEvent(...: BindableEvent)
    Utilities:OutputLog({"Linking Bind:", (tostring(...) .. ".")})

    ExternalDataRequests = ...
    
    if ServerSettings.ExternalDataRequestsEnabled == true then
        SetupExternalDataRequests()
    end
end 

return PlayerManager