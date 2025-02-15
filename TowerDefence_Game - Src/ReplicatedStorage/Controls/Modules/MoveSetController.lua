--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--//Client folders
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local ControlsFolder = ReplicatedStorage:WaitForChild("Controls")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local ControlModules = ControlsFolder:WaitForChild("Modules")
local ControlTemplates = ControlsFolder:WaitForChild("Templates")
local ControlInterfaces = ControlsFolder:WaitForChild("Interfaces")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

--//Local player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerMouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--//Client modules.
local Utilities = require(SharedModules.Utility)
local InputTransulator = nil

--//Variables
local ModuleStartTime = tick()
local KeybindsStartTime = 0
local CharacterStartTime = 0
local RemoteStartTime = 0

local FightingEnabled = false

local AutoRunEnabled = true
local ShiftLockEnabled = false

local CtrlKey_ShitLock

local CharacterController = nil
local MoveDirectionSubject = nil --use this for the movement direction.

local FigtherRemoteEvent: RemoteEvent = nil
local UltimateRemoteEvent: RemoteEvent = nil
local CharacterBindsRemoteEvent: RemoteEvent = nil

--Tables
PlayerCharacterInfo = {
    MoveDirection = Vector3.new(0, 0, 0),
    Character = nil,
    Humanoid = nil,

}

local MoveSetController = {}

--//Initializes the keybinds for the player.
local function SetUpInputKeybinds()
    KeybindsStartTime = tick()

    local MoveSet_M1 = InputTransulator.new("M1_Key", {
        MappedInputKey = "J",
        AltMapInputKey = "L",
        ConsoleKeyMapping = "ButtonX",
        MobileTemplate = ControlTemplates.Mobile.RobloxDefaut,
    })

    MoveSet_M1.Activated:Connect(function(InputData: table)
        if FightingEnabled == true then
            FigtherRemoteEvent:FireServer({
                Type = "",
                CFrame = Vector3.new(0, 0, 0),
            })
        end
    end)

    CtrlKey_ShitLock = InputTransulator.new("ShiftLock", {
        MappedInputKey = "LeftControl",
        AltMapInputKey = "H",
        ConsoleKeyMapping = "DPadLeft",
        MobileTemplate = ControlTemplates.Mobile.RobloxDefaut,
    })

    CtrlKey_ShitLock.Activated:Connect(function(InputData: table)
        ShiftLockEnabled = not ShiftLockEnabled
        
        if ShiftLockEnabled and PlayerCharacterInfo.Character ~= nil and PlayerCharacterInfo.Humanoid ~= nil then
            local CameraRotation = Vector3.new(Camera.CFrame.Rotation:ToOrientation(Enum.RotationOrder.XYZ))

            PlayerCharacterInfo.Humanoid.AutoRotate = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            UserInputService.MouseIconEnabled = false
            PlayerCharacterInfo.Character.PrimaryPart.CFrame = CFrame.new(PlayerCharacterInfo.Character.PrimaryPart.CFrame.X, PlayerCharacterInfo.Character.PrimaryPart.CFrame.Y, PlayerCharacterInfo.Character.PrimaryPart.CFrame.Z) * CFrame.Angles(0, CameraRotation.Y, 0)
        else
            PlayerCharacterInfo.Humanoid.AutoRotate = true
            UserInputService.MouseIconEnabled = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)

    Utilities:OutputLog({"Initialized Keybinds in:", tick() - KeybindsStartTime})
end

--//Get the movement direction of the player.
local function GetMovementDirection(Humanoid: Humanoid, HumanoidRootPart: Part)
	local ForwardDirection = HumanoidRootPart.CFrame.LookVector
	local RightDirection = HumanoidRootPart.CFrame.RightVector
	
	local MoveDirection = ForwardDirection * Humanoid.MoveDirection.Z + RightDirection * Humanoid.MoveDirection.X

    return Vector2.new(math.round(MoveDirection.Unit.X), math.round(MoveDirection.Unit.Y))
end

--//Initializes the player character controller.
local function InitializeCharacter(Character: Model)
    CharacterStartTime = tick()

    local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart: Part = Character:WaitForChild("HumanoidRootPart")

    PlayerCharacterInfo.Humanoid = Humanoid
    PlayerCharacterInfo.Character = Character

    --//Humanoid controller
    Humanoid.Changed:Connect(function(Property: any)
        if Property == "MoveDirection" then
            local RunDirection = Humanoid.MoveDirection:Dot(Camera.CFrame.LookVector)

            PlayerCharacterInfo.MoveDirection = GetMovementDirection(Humanoid, HumanoidRootPart)

            if RunDirection > 0 and AutoRunEnabled == true then
                Humanoid.WalkSpeed = 23 -- based on the moveset.
            else
                Humanoid.WalkSpeed = 16
            end
        end
    end)

    Utilities:OutputLog({"Initialized Character in:", tick() - CharacterStartTime})
end

--//Initializes the module.
function MoveSetController:Initialize()
    InputTransulator = require(ControlModules.InputTransulator)
    SetUpInputKeybinds()

    Utilities:OutputLog({"Initialized core controllers in:", tick() - ModuleStartTime})
end

return MoveSetController