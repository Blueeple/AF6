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
local ControlModules = ControlsFolder:WaitForChild("Modules")
local ControlTemplates = ControlsFolder:WaitForChild("Templates")
local ControlInterfaces = ControlsFolder:WaitForChild("Interfaces")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
local SoundGroupFolder = SoundService:FindFirstChild("SoundGroups")

local Cmdr = require(ControlsFolder.Modules:WaitForChild("CmdrClient"))
local Promise = require(SharedModules.Promise)
local InputTransulator = require(ControlModules.InputTransulator)
local MoveSetController = require(ControlsFolder.Modules:WaitForChild("MoveSetController"))
local Utilities = require(SharedModules.Utility)

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

local VoteForRankedMapEvent:RemoteEvent = NetworkFolder.RemoteEvents:WaitForChild("VoteRankedMap")

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

VoteForRankedMapEvent.OnClientEvent:Connect(function(Data: table)
    local MainUX = PlayerGui:WaitForChild("MainGameUX")

    if Data ~= true and Data["Task"] == "Create" then
        local VotingUiTemplate = ControlTemplates:WaitForChild("Template_RankedMapVote")
        local VotingUI = ControlInterfaces:WaitForChild("VoteSystem"):Clone()
        VotingUI.Parent = MainUX

        for MapName, Settings in pairs(Data["Maps"]) do
            local newTemplate = VotingUiTemplate:Clone()
            newTemplate.Name = MapName
            newTemplate.MapName.Text = MapName

            newTemplate.Parent = VotingUI

            newTemplate.VoteMap.Activated:Connect(function()
                VoteForRankedMapEvent:FireServer(MapName)
            end)
        end
    else
        if MainUX["VoteSystem"] ~= nil then
            MainUX["VoteSystem"]:Destroy()
            MoveSetController:Initialize()
        end
    end
end)