local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Promise = require(SharedModules.Promise)
local Utilities = require(SharedModules.Utility)

local Move = {}

function Move:Get()
    return {
        Name = "Test",
        IconId = "",
        Description = "Use a funny description I guess LOL."
    }
end

function Move:Dash(...: {Position: Vector3})
    Utilities:Print("Performing server dash.")
    
    local FighterEvent = NetworkFolder.RemoteEvents:WaitForChild("FighterEvent")
    FighterEvent:FireServer("Dash")
end

return Move