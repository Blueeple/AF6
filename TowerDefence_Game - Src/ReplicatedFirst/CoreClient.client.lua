--//Services
local ContentProvider = game:GetService("ContentProvider")
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
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
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
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

--//Client Modules
local Cmdr = require(ControlModules:WaitForChild("CmdrClient"))
local Promise = require(SharedModules.Promise)
local MenuController = require(ControlModules.MenuController)
local MoveSetController = require(ControlModules.MoveSetController)
local PlayerScriptsController = require(ControlModules.PlayerScriptsController)
local InputTransulator = require(ControlModules.InputTransulator)
local TopBarPlus = require(ControlModules.Icon)
local Utilities = require(SharedModules.Utility)

--//Variables
local ClientStartTime = tick()
local ClientLoaded = false

--//Tables
local LoadableContentTypes = {
    ImageLabel = true,
    ImageButton = true,
    Sound = true,
    MeshPart = true,
    Model = true,
    Decal = true,
    Texture = true,
    Sky = true,
    VideoFrame = true,
}

--//Remote Events
local PlayerLoadedEvent = NetworkFolder.RemoteEvents:WaitForChild("PlayerJoined")
local VoteForRankedMapEvent: RemoteEvent = nil
local RequestForData: RemoteFunction = nil -- remote function...

--//CallBacks

--//Module Initializers
Cmdr:SetActivationKeys({Enum.KeyCode.F2})
PlayerScriptsController:InitializeScirpts()

--//Initializes game remotes | YOU SHOULD TOTALLY SWITCH TO THE PROMISE MODULE
local function InitializeRemoteEvent()
    local StartTime = tick()

    VoteForRankedMapEvent = NetworkFolder.RemoteEvents:WaitForChild("VoteRankedMap")
    RequestForData = NetworkFolder.RemoteFunctions:WaitForChild("GetPlayerData")

    if RequestForData then
        RequestForData:InvokeServer(true)

        print(RequestForData)
    end

    Utilities:OutputLog({"Initialized Remote in: ", tick() - StartTime})
end

--//Initializes Topbar plus
local function LoadTopBarIcons()
    --//Create a TopBarPlus interface.
    local ExitRankedGame = TopBarPlus.new()
    :setImage("71173794577999")
    :setEnabled(true)
    :setRight()
    :bindEvent("Selected", MenuController)


end

--//Setup game menus.
local function SetupMenus()
    --//Variables
    local StartTime = tick()

    --//Triggers when there is an event from VoteForRankedMap event.
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
                --MoveSetController:InitializeRemotes()
            end
        end
    end)



    --//Completed
    Utilities:OutputLog({"Initialized Menus in:", tick() - StartTime})
end

--//Create loading screen.
local function CreateLoadingScreen()
    --//Variables
    local StartTime = tick()
    local AssetsToLoad = {}
    local UnCachedAssets = {}
    local LoadedContent = 0
    local LoadingPercentage = 0
    local ContentFetchTime = 0

    --//Intances
    local ScreenGui = Instance.new("ScreenGui", PlayerGui)

    local MainFrame = Instance.new("ImageLabel", ScreenGui)

    local LoadingBarFrame = Instance.new("CanvasGroup", MainFrame)
    local LoadingBarFrameText = Instance.new("TextLabel", LoadingBarFrame)
    local LoadingBarFrameTextStroke = Instance.new("UIStroke", LoadingBarFrameText)
    
    local LoadingBarFrameCorner = Instance.new("UICorner", LoadingBarFrame)
    local LoadingBarFrameStroke = Instance.new("UIStroke", LoadingBarFrame)

    local LoadingBar = Instance.new("Frame", LoadingBarFrame)
    local LoadingBarText = Instance.new("TextLabel", LoadingBar)
    local LoadingBarStroke = Instance.new("UIStroke", LoadingBar)

    --//CallBacks
    local ContentProviderCallback = function(assetId, assetFetchStatus: Enum.AssetFetchStatus)
        if assetFetchStatus == Enum.AssetFetchStatus.Success then
            LoadedContent += 1
            LoadingPercentage = math.round(LoadedContent / #AssetsToLoad * 100)
            LoadingBarFrameText.Text = "Loading content - " .. LoadingPercentage .. "%."
        else
            warn("Failed to load asset: " .. assetId)
        end
    end

    --//Core Roblox UI removers
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    Character.PrimaryPart.Anchored = true

    --//ScreenGui properties
    ScreenGui.Name = "Loading screen"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ClipToDeviceSafeArea = false
    ScreenGui.DisplayOrder = 999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    --//MainFrame properties
    MainFrame.Name = "MainScreen"
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = UDim2.fromScale(1, 1)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Interactable = true
    MainFrame.BackgroundColor3 = Color3.fromHex("#1E1E1E")
    MainFrame.LayoutOrder = 1
    MainFrame.ScaleType = Enum.ScaleType.Fit
    MainFrame.Image = "rbxassetid://13333189485"
    MainFrame.Visible = true

    --//LoadingBarFrame properties
    LoadingBarFrame.Name = "LoadingBarFrame"
    LoadingBarFrame.BackgroundColor3 = Color3.fromHex("#8A9597")
    LoadingBarFrame.ClipsDescendants = true
    LoadingBarFrame.Size = UDim2.fromScale(0.8, 0.05)
    LoadingBarFrame.Position = UDim2.fromScale(0.5, 0.95)
    LoadingBarFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadingBarFrame.Visible = true

    --//LoadingBarFrameText properties
    LoadingBarFrameText.Name = "Percentage"
    LoadingBarFrameText.Text = "Waiting on downloaded content... " .. ContentFetchTime
    LoadingBarFrameText.Size = UDim2.fromScale(1, 1)
    LoadingBarFrameText.ZIndex = 2
    LoadingBarFrameText.BackgroundTransparency = 1
    LoadingBarFrameText.TextScaled = true
    LoadingBarFrameText.FontFace = Font.fromEnum(Enum.Font.FredokaOne)
    LoadingBarFrameText.TextColor3 = Color3.new(1, 1, 1)
    
    --//LoadingBarFrameTextStroke properties
    LoadingBarFrameTextStroke.Thickness = 2
    LoadingBarFrameTextStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    --//LoadingFrameCorner properties
    LoadingBarFrameCorner.CornerRadius = UDim.new(0.5, 0)

    --//LoadingFrameStroke properties
    LoadingBarFrameStroke.Thickness = 2.25
    LoadingBarFrameStroke.LineJoinMode = Enum.LineJoinMode.Round
    LoadingBarFrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    --//LoadingBar properties
    LoadingBar.Name = "LoadingBar"
    LoadingBar.Size = UDim2.fromScale(0, 1)
    LoadingBar.Position = UDim2.fromScale(0, 0)
    LoadingBar.BackgroundColor3 = Color3.fromHex("#DC9D00")
    LoadingBar.ZIndex = 1
    LoadingBar.Visible = true
    --LoadingBar.BackgroundColor3 = Color3.fromHex()

    --//LoadingBarStroke properties
    LoadingBarStroke.Thickness = 2.25
    LoadingBarStroke.LineJoinMode = Enum.LineJoinMode.Round
    LoadingBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    --//Completed loading
    Utilities:OutputLog({"Initialized Loading screen in:", tick() - StartTime})

    --//Caching assets to load and stuff
    for i = 1, 30 do
        task.wait(1)

        local newContent = ContentFolder:GetChildren()
        ContentFetchTime = i

        LoadingBarFrameText.Text = "Waiting on downloaded content... " .. ContentFetchTime

        if ContentFetchTime == 30 and #newContent == 0 then
            LoadingBarFrameText.Text = "Error loading downloaded content."
            LocalPlayer:Kick("Failed to load downloaded content.")
            LocalPlayer:Destroy()
            break
        elseif #newContent > 0 then
            LoadingBarFrameText.Text = "Content is loading..."
            UnCachedAssets = ContentFolder:GetDescendants()
            ContentFetchTime = 0
            ClientLoaded = true
            break
        end
    end

    LoadingBarFrameText.Text = "Proccessing content..."

    --//Requests for all assets to be loaded
    for i = 1, #UnCachedAssets do
        local Content = UnCachedAssets[i]
        if LoadableContentTypes[Content.ClassName] == true then
            LoadingBarFrameText.Text = "Caching content ID: Content-" .. i .. "."
            table.insert(AssetsToLoad, Content)
        end
    end

    LoadingBarFrameText.Text = "Cached all content."

    if #AssetsToLoad > 0 then
                LoadingBarFrameText.Text = "Loading content - " .. 0 .. "%."
        ContentProvider:PreloadAsync(AssetsToLoad, ContentProviderCallback)
    elseif RunService:IsStudio() == true then
        LoadingBarFrameText.Text = "Loading content - " .. 100 .. "%."
        LoadingPercentage = 100
    end

    --//Does whate every loading screen does
    if LoadingPercentage == 100 then
        task.wait(2)

        PlayerLoadedEvent:FireServer(true)
        ScreenGui:Destroy()
        
        task.spawn(function()
            InitializeRemoteEvent()
            SetupMenus()
        end)

        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)

        if Character.PrimaryPart then
            Character.PrimaryPart.Anchored = false
        end
    end
end

--//Runs these functions once when the client script loads.
ReplicatedFirst:RemoveDefaultLoadingScreen()
CreateLoadingScreen()

--//Checks if the client is loaded.
if ClientLoaded == true then
    Utilities:OutputLog({"Loaded client in:", tick() - ClientStartTime})

    local PunchBind = InputTransulator.new("Punch Action",
    {
        PassThroughEnabled = false,
        Enabled = true,
    },
    {
        Keyboard = {
            Major = Enum.KeyCode.J,
            Alt = nil,
            EnmulateMouse = Enum.UserInputType.MouseButton1
        },
        Mobile = {
            Template = ControlTemplates.Mobile.RobloxDefaut,
            Properties = {
                Position = UDim2.fromScale(0, 0),
                Size = UDim2.fromOffset(0, 0),
            },
        },
        Console = {
            Major = Enum.KeyCode.ButtonX,
            Alt = Enum.KeyCode.ButtonR3,
            Auctuation = 0.01,
        }
    })

    PunchBind.Activated:Connect(function(Name, Data)
        warn(Name, Data)
    end)
else
    Utilities:OutputLog({"Failed to load client in:", tick() - ClientStartTime})
    LocalPlayer:Kick("Failed to load Client.")
    LocalPlayer:Destroy()
end
