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

function Move:GetInfoMenu()
    return {
        Name = "Jumper",
        IconId = "",
        Description = "Jumper man he jumps really high."
    }
end

function Move:GetInfoBaseMoves()
    return {
        Moves = {
            Kure_Grab = {
                Text = "Kure grab",
                Order = 0,
                CoolDown = 1,
            },
        },
        UltimateInfo = {
            UltimateName = "Kure special",
            UltimateBarColor = Color3.fromRGB(113, 0, 148)
        },
        HumanoidInfo = {
            WalkSpeed = 23,
            JumpHeight = 7.2,
        }
    }
end

function Move:GetAnimations()
    return {
        Walk = "",
        Run = "",
        Jump = "",
        Land = "",
        Swim = "",
        Walk_StrafLeft = "",
        Walk_StrafRight = "",
        Run_StrafLeft = "",
        Run_StrafRight = "",
    }
end

function Move:GetInfoUltimateMoves()
    return {
        Moves = {
            Speed = {
                Text = "Super speed",
                Order = 0,
                CoolDown = false,
            },
        },
    }
end

return Move