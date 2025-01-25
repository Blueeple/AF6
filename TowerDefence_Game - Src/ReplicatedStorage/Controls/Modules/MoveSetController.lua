--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--Client folders
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local ControlsFolder = ReplicatedStorage:WaitForChild("Controls")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local ControlModules = ControlsFolder:WaitForChild("Modules")
local ControlTemplates = ControlsFolder:WaitForChild("Templates")
local ControlInterfaces = ControlsFolder:WaitForChild("Interfaces")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

--Local player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerMouse = LocalPlayer:GetMouse()

--Client modules.
local InputTransulator = require(ControlModules.InputTransulator)

--Variables
local FigtherRemoteEvent: RemoteEvent = nil

local MoveSetController = {}

local function SetUpInputKeybinds() --Chage this to sum universal.
    InputTransulator:InitializeMobileDetection(true)

    FigtherRemoteEvent = NetworkFolder.RemoteEvents:WaitForChild("FighterEvent", 2)

    local MoveSet_M1 = InputTransulator.new("M1_Key", {
        MappedInputKey = "J",
        ConsoleKeyMapping = "ButtonX",
        MobileTemplate = ControlTemplates.Mobile.RobloxDefaut,
    })

    MoveSet_M1.Activated:Connect(function(InputData: table)
        FigtherRemoteEvent:FireServer({
            Type = "",
            CFrame = Vector3.new(0, 0, 0),
        })
    end)
end

function MoveSetController:Initialize()
    local MoveSet
    SetUpInputKeybinds()
end

return MoveSetController