local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local ControlsFolder = ReplicatedStorage:WaitForChild("Controls")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local ControlTemplates = ControlsFolder:WaitForChild("Templates")
local ControlInterfaces = ControlsFolder:WaitForChild("Interfaces")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
local SoundGroupFolder = SoundService:FindFirstChild("SoundGroups")

local Cmdr = require(ControlsFolder.Modules:WaitForChild("CmdrClient"))
local Promise = require(SharedModules.Promise)
local Utilities = require(SharedModules.Utility)

local VoteForRankedMapEvent = NetworkFolder.RemoteEvents:WaitForChild("VoteRankedMap")

Cmdr:SetActivationKeys({Enum.KeyCode.F2})

--Fades out all the game's sounds.
local function FadeOutSounds(...: boolean)
    if ... then
        Utilities:Print("Fading out all sounds.")
        for index, SoundGroup in SoundGroupFolder:GetChildren() do
            TweenService:Create(SoundGroup, TweenInfo.new(2.3), {Volume = 0.1}):Play()
        end
    else
        Utilities:Print("Fading in all sounds.")
        for index, SoundGroup in SoundGroupFolder:GetChildren() do
            TweenService:Create(SoundGroup, TweenInfo.new(2.3), {Volume = 1}):Play()
        end
    end
end

--User expirence [Beta]
--[[UserInputService.WindowFocusReleased:Connect(function()
    Utilities:Print("Window focus left.")
    FadeOutSounds(true)
end)

UserInputService.WindowFocused:Connect(function()
    Utilities:Print("Window focus back.")
    FadeOutSounds(false)
end)
]]