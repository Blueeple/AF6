local StartTick = tick()

-- Services
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

-- Paths
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Controllers = ReplicatedStorage:WaitForChild("Controllers")
local Network = ReplicatedStorage:WaitForChild("Network")
local Cache = ReplicatedStorage:WaitForChild("Cache")

-- Folders
local Controllers_Modules = Controllers.Modules
local Controllers_Interface = Controllers.Interfaces
local Controllers_Templates = Controllers.Templates

-- Roblox Core
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

-- Variables
local RBX_GN = game.Name
local RBX_Version = game.PlaceVersion
local RBX_GID = game.PlaceId

local ContentWaitTime = 10
local Streamer = nil
local ClientLoad = false

-- Modules
local ContentStreamer = require(Modules.ContentStreamer)
local DiscordRPC = require(Controllers_Modules["Bloxstrap-rpc-sdk-v1.1.0"])

-- Initialize
ReplicatedFirst:RemoveDefaultLoadingScreen()

-- Global Functions
-- Loads all networking infastructre
local function LoadNetworker()
    
end

-- Creates the loading screen.
local function BeginLoading()
    -- Variables
    local StreamingAssets = nil
    local LoadingPercent = 0 -- Counts all game elements

    -- Callbacks
    local PreloadAsyncCallback = function(Status: Enum.AssetFetchStatus, AssetId: number)
        print(Status, AssetId)
    end

    -- Initiialize
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

    if not RunService:IsStudio() then
        DiscordRPC.SetRichPresence({
            details = "Example details value",
            state = "Example state value",
            timeStart = os.clock(),
            timeEnd = os.clock() + 60,
            largeImage = {
                assetId = 10630555127,
                hoverText = "Example hover text"
            },
            smallImage = {
                assetId = 13409122839,
                hoverText = "Example hover text"
            }
        })
    end

    GuiService.TouchControlsEnabled = false

    -- Instances
    -- MainScreenGui
    local LoadingScreenUi = Instance.new("ScreenGui")
    LoadingScreenUi.Parent = playerGui
    LoadingScreenUi.Name = "LoadingScreen"
    LoadingScreenUi.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadingScreenUi.IgnoreGuiInset = true

    -- Background
    local Background = Instance.new("Frame")
    Background.Parent = LoadingScreenUi
    Background.Name = "Background"
    Background.BackgroundColor3 = Color3.fromRGB(43, 43, 43)
    Background.AnchorPoint = Vector2.new(0.5, 0.5)
    Background.Position = UDim2.fromScale(0.5, 0.5)
    Background.Size = UDim2.fromScale(1, 1)

    -- Loading BarBackground
    local LoadingBarBackground = Instance.new("CanvasGroup")
    LoadingBarBackground.Parent = Background
    LoadingBarBackground.Name = "LoadingBarBackground"
    LoadingBarBackground.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingBarBackground.Position = UDim2.fromScale(0.5, 0.9)
    LoadingBarBackground.Size = UDim2.fromScale(0.85, 0.05)

    -- Loading Background Corner
    local Corner_B = Instance.new("UICorner")
    Corner_B.Parent = LoadingBarBackground
    Corner_B.CornerRadius = UDim.new(1, 0)

    -- Loading Bar
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Parent = LoadingBarBackground
    LoadingBar.Name = "LoadingBarBackground"
    LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    LoadingBar.AnchorPoint = Vector2.new(0, 0.5)
    LoadingBar.Position = UDim2.fromScale(0, .5)
    LoadingBar.Size = UDim2.fromScale(LoadingPercent, 1)

    -- Loading Text
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Parent = LoadingBarBackground
    LoadingText.BackgroundTransparency = 1
    LoadingText.Size = UDim2.fromScale(1, 1)
    LoadingText.Text = "Waiting for streamer..."
    LoadingText.ZIndex = 2

    -- Initializes content streamer
    ContentStreamer.Init()
end

if game then
    BeginLoading()
else
    Players.LocalPlayer:Destroy()
end