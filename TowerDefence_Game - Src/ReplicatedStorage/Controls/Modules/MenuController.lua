--//Services
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

--//Shared Folders
local ControlsFolder = ReplicatedStorage:WaitForChild("Controls")
local ContentFolder = ReplicatedStorage:WaitForChild("Content")
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

--//Client Modules
local Cmdr = require(ControlModules:WaitForChild("CmdrClient"))
local Promise = require(SharedModules.Promise)
local Utilities = require(SharedModules.Utility)

--//Variables
local ClientStartTime = tick()
local ClientLoaded = false

--//Remotes
local 

--//Custom Types
export type MenuType = "Menu type?"

local MenuController = {}
MenuController.__index = MenuController

function MenuController.new(Type: MenuType, Args: table)
    --//Self
    local self = {}


    return setmetatable(self, MenuController)
end

function MenuController:GetAudioProfiler()
    --//Self
    local self = {}

    --//Variables

    --//Objects
    local SoundGroups = SoundService:WaitForChild("AudioProfiles")

    --//Self functions
    function self:GetProfile(Name: string)
        if SoundGroups:FindFirstChild(Name) ~= nil then
            --//Setup
            local ProfileSetup = {}

            --//Audio profile
            local Profile: SoundGroup = SoundGroups:FindFirstChild(Name)

            --//ProfileSetup Config
            function ProfileSetup:SetVolume(Volume: number, Interpolation: number)
                TweenService:Create(Profile, TweenInfo.new(Interpolation), {Volume = Volume}):Play()
            end

            return setmetatable (ProfileSetup, self)
        else
            return
        end
    end

    return setmetatable(self, MenuController)
end

return MenuController