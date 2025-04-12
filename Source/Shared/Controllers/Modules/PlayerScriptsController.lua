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
local Utilities = require(SharedModules.Utility)

--//Variables
local ModuleStartTime = tick()
local RunTime = nil
local LocalCharacterData = {}

--//Objects
local RunServiceBind = Instance.new("BindableEvent")

--//Object Oriented Module Constructor
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

function PlayerScriptsController:InitializeScirpts()
    --//Variables
    local StartTime = tick()
    local RbxCharacterSounds = PlayerScripts:WaitForChild("RbxCharacterSounds")
    
    --//Initializers
    PlayerScriptsController["InitializeScirpts"] = nil

    RbxCharacterSounds.Enabled = false
    RbxCharacterSounds:Destroy()

    RunTime = RunService.PreSimulation:Connect(function(deltaTimeSim)
        for Index, Character in pairs(workspace.Players:GetChildren()) do
            if Character.PrimaryPart ~= nil then
                local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
                local HumanoidRootPart: Part = Character.PrimaryPart

                local MoveAceleration = HumanoidRootPart.AssemblyLinearVelocity
                local MoveDirection = GetMovementDirection(Humanoid, HumanoidRootPart)
    
                PlayerScriptsController.Characters[Character.Name] = {
                    Character = Character,
                    MoveAceleration = MoveAceleration,
                    MoveDirection = MoveDirection,
                }

                
            end
        end
    end)

    Utilities:OutputLog({"Initialized Scripts in:", tick()- StartTime})
end

function PlayerScriptsController:SetLocalCharcterData(...: any?)
    LocalCharacterData = ...
end

return PlayerScriptsController