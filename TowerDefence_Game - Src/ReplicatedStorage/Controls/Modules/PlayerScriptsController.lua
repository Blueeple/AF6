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
local RunTime = nil

--//Objects
local RunServiceBind = Instance.new("BindableEvent")

--//Exported types
export type ClassTypes = {
    DynamicCharacter: any
}

export type Constructor = {
    Name: string,
    Characer: Model,
    Class:  ClassTypes,
    Settings: any?,
}

export type ModuleImports = {
    Folder: Folder
}

--//Object Oriented Module Constructor
local PlayerScriptsController = {}
PlayerScriptsController.__index = PlayerScriptsController

PlayerScriptsController.Characters = {}

RunServiceBind.Event:Connect(function(Args: Model)
    if PlayerScriptsController.Characters[Args.Name] == nil then
        PlayerScriptsController.Characters[Args.Name] = Args.Character
    else
        Utilities:OutputWarn("Failed to add character:", (Args.Character.Name .. ", character already exists!"))
    end
end)

local function DynamicCharacterHandler(...)
    --/Variables
    local Characer = ...

    local Humanoid: Humanoid = Characer:WaitForChild("Humanoid")
    local HumanoidRootPart: Part = Characer:WaitForChild("HumanoidRootPart")

    RunServiceBind:Fire(Characer)
end

function PlayerScriptsController:InitializeScirpts(Args: ModuleImports)
    --//Variables
    local StartTime = tick()
    local RbxCharacterSounds = PlayerScripts:WaitForChild("RbxCharacterSounds")
    
    --//Initializers
    PlayerScriptsController["InitializeScirpts"] = nil

    RbxCharacterSounds.Enabled = false
    RbxCharacterSounds:Destroy()
    
    PlayerScriptsController["InitializeScirpts"] = nil --Removes the function from the "PlayerScriptsController" 
    Utilities:OutputLog({"Initialized Scripts in:", tick()- StartTime})
end

--//Contructs a new Character controller class.
function PlayerScriptsController:Create(Args: Constructor)
    
end

return PlayerScriptsController