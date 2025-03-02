--//Services
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--//Shared Folders
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local ControlsFolder = ReplicatedStorage:WaitForChild("Controls")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

--//Client folders
local ControlModules = ControlsFolder:WaitForChild("Modules")
local ControlTemplates = ControlsFolder:WaitForChild("Templates")
local ControlInterfaces = ControlsFolder:WaitForChild("Interfaces")

--//Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerScripts = LocalPlayer.PlayerScripts
local Camera = workspace.CurrentCamera

--//Client Modules
local Promise = require(SharedModules.Promise)
local InputTransulator = require(ControlModules.InputTranslulatorSDK)
local Utilities = require(SharedModules.Utility)

--//Variables
local ModuleStartTime = tick()

--//Exported types
export type ClassTypes = {
    DynamicCharacter: any
}

export type Constructor = {
    Name: string,
    Class:  ClassTypes,
    Settings: any?,
}

--//Object Oriented Module Constructor
local PlayerScriptsController = {}
PlayerScriptsController.__index = PlayerScriptsController

--//Type checks a table.
local function TypeCheckTable(...: table)
    if ... ~= nil then
        
    end
end

function PlayerScriptsController:InitializeScirpts()
    local StartTime = tick()
    local RbxCharacterSounds = PlayerScripts:WaitForChild("RbxCharacterSounds")
    
    RbxCharacterSounds.Enabled = false
    RbxCharacterSounds:Destroy()
    
    PlayerScriptsController["InitializeScirpts"] = nil --Removes the function from the "PlayerScriptsController" 
    Utilities:OutputLog({"Initialized Scripts in:", tick()- StartTime})
end

--//Contructs a new Character controller class.
function PlayerScriptsController:Create(Args: Constructor)
    --//Variables
    local Settings = Args.Settings or nil

    local TableTypeCheckings = TypeCheckTable(Settings)

    if Args and TableTypeCheckings == true then
        --//Self
        local self = {}

        --//Self functions
    end
end

return PlayerScriptsController