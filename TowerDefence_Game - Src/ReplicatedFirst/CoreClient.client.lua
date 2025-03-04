--//Services
local ContentProvider = game:GetService("ContentProvider")
local GroupService = game:GetService("GroupService")
local GuiService = game:GetService("GuiService")
local MarketplaceService = game:GetService("MarketplaceService")
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
--local PlayerScriptsModules = ControlTemplates:WaitForChild("PlayerController")

--//Local Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local PlayerScripts = LocalPlayer.PlayerScripts
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

--//Client Modules
local BloxStrapSDK = require(ControlModules["Bloxstrap-rpc-sdk-v1.1.0"])
local Cmdr = require(ControlModules:WaitForChild("CmdrClient"))
local Promise = require(SharedModules.Promise)
local MenuController = require(ControlModules.MenuController)
local MoveSetController = require(ControlModules.MoveSetController)
local PlayerScriptsController = require(ControlModules.PlayerScriptsController)
local InputTransulator = require(ControlModules.InputTranslulatorSDK)
local TopBarSDK = require(ControlModules.TopBarSDK)
local Utilities = require(SharedModules.Utility)

--//Variables
local BuidDate = MarketplaceService:GetProductInfo(game.PlaceId).Updated or tostring(nil)
local ClientStartTime = tick()
local ClientLoaded = false
local CurrentGameMode = "GameMode?"
local GameClientVersion = 0
local GameName = "BattleGrounds"
local GameClientStatus = "Playing a ranked game."
local GameGroup = GroupService:GetGroupInfoAsync(game.CreatorId)
local TimeStamp = os.time()
local MaxContentFetchTime = 5

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

local RankedSystemData = {
    CurrentRank = "Rank?", --Player rank.
    CurrentRankDivision = "Division?",
    CurrentRankPercent = 0, --How much percent acheived in current rank.
    CurrentRankLeaderStat = 0, --What placement does the player have in that rank.
}

local GameIcons = {
    DiscordRPC = {
        Active = 137601480983962,
        Idle = 74473918826906,
        Away = 137601480983962,
    }
}

local PlayerUserData = nil

--//Remote Events
local PlayerLoadedEvent = NetworkFolder.RemoteEvents:WaitForChild("PlayerLoaded")
local RequestForData = NetworkFolder.RemoteEvents:WaitForChild("GetPlayerData")
local VoteForRankedMapEvent: RemoteEvent = nil

--//Global CallBacks

--//Global Connections

--//Module Initializers
Cmdr:SetActivationKeys({Enum.KeyCode.F2})
PlayerScriptsController:InitializeScirpts()

--//Converts Game RBX data to table type
local function ConverBuildDate(Date :string)
    return Date:sub(0, 19):split("T")
end

--//Yeilds until userdata is loaded
local function WaitForUserData(LoadingBar: TextLabel)
    Utilities:OutputLog({"Loading player data."})

    LoadingBar.Text = "Waiting for server reponse..."

    --//Checks if the remote event: RequestForData exists
    if RequestForData then
        Utilities:OutputLog({"RequestForData remote detected."})

        --//Detects when UserData was send to the client
        RequestForData.OnClientEvent:Once(function(UserData: any)
            PlayerUserData = UserData
            ClientLoaded = true
        end)

        --//Wait until the client recives a ping from the server DataStore
        for FetchTime = 0, MaxContentFetchTime do
            if FetchTime < MaxContentFetchTime and PlayerUserData == nil then
                LoadingBar.Text = "Pinging server for reponse... [" .. FetchTime .. "]"
                RequestForData:FireServer(true)
            elseif FetchTime == MaxContentFetchTime then
                local Num  = math.random(1, 100)

                if Num == 100 then 
                    LoadingBar.Text = "'Server not responding' in the M-Massive " .. os.date("%Y") .. " 💔 " 
                else
                    LoadingBar.Text = "Server not responding... [" .. FetchTime .. "]"
                end

                break
            elseif PlayerUserData ~= nil then
                break
            end
    
            task.wait(1)
        end
    else
        return
    end
end

--//Initializes game remotesE
local function InitializeRemoteEvent()
    --//Variables
    local StartTime = tick()
    local RequestDataConnection = nil

    --//Initializes the VoteForRankedMapEvent
    VoteForRankedMapEvent = NetworkFolder.RemoteEvents:WaitForChild("VoteRankedMap")

    Utilities:OutputLog({"Initialized Remotes in: ", tick() - StartTime})
end

--//Initializes Topbar plus
local function LoadTopBarIcons()
    --//Create a TopBarPlus interface.
    local ExitRankedGame = TopBarSDK.new()

    :setImage("71173794577999")
    :setEnabled(true)
    :setRight()
    --:bindEvent("Selected", MenuController)

end

--//Initializes the sound groups for the client.
local function InitializeSoundGroups()
    --//Objects
    local GroupFolder = Instance.new("Folder")
    local AudioListiener = SoundService:GetListener()

    --//Sound Groups
    local FXGroups = {
        UI_Group = Instance.new("SoundGroup"),
        FX_Group = Instance.new("SoundGroup"),
        Music_Group = Instance.new("SoundGroup"),
        LocalCharacter_Group = Instance.new("SoundGroup"),
        OtherCharacter_Group = Instance.new("SoundGroup"),
    }

    --//Group folder properties
    GroupFolder.Name = "AudioProfiles"
    GroupFolder.Parent = SoundService

    for Index, FXG in pairs(FXGroups) do
        FXG.Parent = GroupFolder
        FXG.Name = tostring(Index)
        FXG.Volume = 1
    end
    
    return FXGroups
end

--//Initializes SDKs for RobloxClient
local function InitializeRBLX()
    --//Objects
    local AudioProfiler = MenuController:GetAudioProfiler()

    --//Checks if the game is running on the RBLX Client.
    if RunService:IsStudio() == false then
        --//Setup the main BloxStrap rpc menus.
        BloxStrapSDK.SetRichPresence({
            details = GameName .. " | " .. CurrentGameMode,
            state = "Ranked: " .. RankedSystemData.CurrentRank,
            timeStart = TimeStamp,
            timeEnd = TimeStamp + 60,
            largeImage = {
                assetId = GameIcons.DiscordRPC.Active,
                hoverText = GameClientStatus
            },
            smallImage = {
                assetId = GameGroup.EmblemUrl,
                hoverText = "BlueVez Studios"
            }
        })
    end

    --//Window focus methods
    UserInputService.WindowFocusReleased:Connect(function()
        if RunService:IsStudio() == false then
            local AudioProfile = AudioProfiler:GetProfile("FX_Group")
            AudioProfile:SetVolume(0.15, 1.25)

            GameClientStatus = "Away from game. (Idle)"

            BloxStrapSDK.SetRichPresence({
                details = GameName .. " | " .. CurrentGameMode,
                state = "Ranked: " .. RankedSystemData.CurrentRank,
                timeStart = TimeStamp,
                timeEnd = TimeStamp + 60,
                largeImage = {
                    assetId = GameIcons.DiscordRPC.Idle,
                    hoverText = GameClientStatus
                },
                smallImage = {
                    assetId = GameGroup.EmblemUrl,
                    hoverText = "BlueVez Studios"
                }
            })

            Utilities:OutputLog("Cofigured Discord RichPresence to idle mode.")
        end
    end)

    UserInputService.WindowFocused:Connect(function()
        if RunService:IsStudio() == false then
            local AudioProfile = AudioProfiler:GetProfile("FX_Group")
            AudioProfile:SetVolume(1, 1.25)

            GameClientStatus = "Playing a ranked game."

            BloxStrapSDK.SetRichPresence({
                details = GameName .. " | " .. CurrentGameMode,
                state = "Ranked: " .. RankedSystemData.CurrentRank,
                timeStart = TimeStamp,
                timeEnd = TimeStamp + 60,
                largeImage = {
                    assetId = GameIcons.DiscordRPC.Active,
                    hoverText = GameClientStatus
                },
                smallImage = {
                    assetId = GameGroup.EmblemUrl,
                    hoverText = "BlueVez Studios"
                }
            })

            Utilities:OutputLog("Cofigured Discord RichPresence to Online mode.")
        end
    end)

    LocalPlayer.Idled:Connect(function()
        GameClientStatus = "Inactive from game."

        BloxStrapSDK.SetRichPresence({
            details = GameName .. " | " .. CurrentGameMode,
            state = "Ranked: " .. RankedSystemData.CurrentRank,
            timeStart = TimeStamp,
            timeEnd = TimeStamp + 60,
            largeImage = {
                assetId = GameIcons.DiscordRPC.Away,
                hoverText = GameClientStatus
            },
            smallImage = {
                assetId = GameGroup.EmblemUrl,
                hoverText = "BlueVez Studios"
            }
        })

        Utilities:OutputLog("Cofigured Discord RichPresence to Inactive mode.")
    end)
end

--//Setup game menus.
local function SetupMenus()
    --//Variables
    local StartTime = tick()

    --//Core setup
    InitializeRBLX()
    LoadTopBarIcons()

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

    --//Core Variables
    local GameBDP = ConverBuildDate(BuidDate)
    local GamePublishData = GameName .. " - " .. " Build @" ..GameBDP[1] .. " | " .. GameBDP[2]  .. " - Roblox Client Version: " .. "Error?"

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

    --//Core Roblox UI Setup
    InitializeSoundGroups()

    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    Character.PrimaryPart.Anchored = true

    --//Core setup
    Utilities:OutputLog(GamePublishData)

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
    LoadingBarFrameText.Text = "Waiting on downloaded content... " .. 0
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
    for ContentFetchTime = 0, MaxContentFetchTime do
        local newContent = ContentFolder:GetChildren()

        LoadingBarFrameText.Text = "Waiting on downloaded content... " .. ContentFetchTime

        if ContentFetchTime == MaxContentFetchTime and #newContent == 0 then
            LoadingBarFrameText.Text = "Error loading downloaded content."
            LocalPlayer:Kick("Failed to load downloaded content.")
            LocalPlayer:Destroy()
            break
        elseif #newContent > 0 then
            LoadingBarFrameText.Text = "Content is loading..."
            UnCachedAssets = ContentFolder:GetDescendants()
            ContentFetchTime = 0
            break
        end

        task.wait(1)
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

    --//Checks if the AssetsToLoad are above zero
    if #AssetsToLoad > 0 then
        LoadingBarFrameText.Text = "Loading content - " .. 0 .. "%."
        ContentProvider:PreloadAsync(AssetsToLoad, ContentProviderCallback)
    elseif RunService:IsStudio() == true or #AssetsToLoad == 0 then
        LoadingBarFrameText.Text = "Loading content - " .. 100 .. "%."
        LoadingPercentage = 100
        
        task.wait()

        WaitForUserData(LoadingBarFrameText)
    end

    --//Does whate every loading screen does
    if LoadingPercentage == 100 and PlayerUserData ~= nil and ClientLoaded == true then
        PlayerLoadedEvent:FireServer(true)
        ScreenGui:Destroy()
        
        task.spawn(function()
            InitializeRemoteEvent()
            SetupMenus()

            Utilities:OutputLog({"Loaded Client in:", tick() - ClientStartTime})
        end)

        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

        if Character.PrimaryPart then
            Character.PrimaryPart.Anchored = false

            Character.Humanoid.WalkSpeed = 1.5
            Character.Humanoid.JumpHeight = 5.4
        end
    end
end

--//Runs these functions once when the client script loads.
ReplicatedFirst:RemoveDefaultLoadingScreen()
CreateLoadingScreen()

--//Checks if the client is loaded.
if ClientLoaded == true then
    Utilities:OutputLog({"Loaded core controllers in:", tick() - ClientStartTime})

    --//Prototype punch bindings
    --[[local PunchBind = InputTransulator.new("Punch Action",
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
    end)]]
else
    Utilities:OutputWarn({"Failed to load client in:", tick() - ClientStartTime})
    LocalPlayer:Kick("Failed to load Client.")
    LocalPlayer:Destroy()
end
