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

--//Object Oriented Module Constructor FIX THIS SHIT PLEASE!
local PlayerScriptsController = {}
PlayerScriptsController.__index = PlayerScriptsController

PlayerScriptsController.Characters = {}

local function GetMovementDirection(Humanoid: Humanoid, HumanoidRootPart: BasePart): Vector3
    local forward_direction = HumanoidRootPart.CFrame.LookVector;
    local right_direction = HumanoidRootPart.CFrame.RightVector;
        
    local wishdir = forward_direction * Humanoid.MoveDirection.Z + right_direction * Humanoid.MoveDirection.X;
    local Direction = wishdir.Unit;

    return Vector3.new(math.round(Direction.X), math.round(Direction.Y), math.round(Direction.Z))
end

RunTime = RunService.PreSimulation:Connect(function(deltaTimeSim)
    for Index, Character in pairs(workspace.Players) do
        if Character.PrimaryPart ~= nil then
            local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
            local HumanoidRootPart: Part = Character.PrimaryPart

            PlayerScriptsController.Characters[Character.Name] = {
                Character = Character,
                MoveDirection = GetMovementDirection(Humanoid, HumanoidRootPart),
                MoveAceleration = HumanoidRootPart.AssemblyLinearVelocity,
            }
        end
    end
end)

function PlayerScriptsController:InitializeScirpts()
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

return PlayerScriptsController