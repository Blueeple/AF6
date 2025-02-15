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
local InputTransulator = require(ControlModules.InputTransulator)
local Utilities = require(SharedModules.Utility)

--//Variables
local ModuleStartTime = tick()

--//Object Oriented Module Constructor
local PlayerScriptsController = {}
PlayerScriptsController.__index = PlayerScriptsController

function PlayerScriptsController:InitializeScirpts()
    local StartTime = tick()
    local RbxCharacterSounds = PlayerScripts:WaitForChild("RbxCharacterSounds")
    
    RbxCharacterSounds.Enabled = false
    RbxCharacterSounds:Destroy()
    
    PlayerScriptsController["InitializeScirpts"] = nil --Removes the function from the "PlayerScriptsController" 
    Utilities:OutputLog({"Initialized Scripts in:", tick()- StartTime})
end

--//Contructs a new Character controller class.
function PlayerScriptsController.new(Chracter, ...: {Animations: table, })
    local args = ...
    local self = {}

    local ChracterAnimations = args.Animations

    self.Chracter = Chracter
    self.Animations = ChracterAnimations

    print(self)

    return setmetatable(self, PlayerScriptsController)
end

--//
function PlayerScriptsController:Bind()
    
end

--//
function PlayerScriptsController:UnBind()

end

return PlayerScriptsController