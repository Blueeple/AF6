local ContentProvider = game:GetService("ContentProvider")
local LocalizationService = game:GetService("LocalizationService")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local EnemiesFolder = workspace:WaitForChild("Enemies")
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("Assets")
local ControlsFolder = ReplicatedStorage:WaitForChild("Controls")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local ControlTemplates = ControlsFolder:WaitForChild("Templates")
local ControlInterfaces = ControlsFolder:WaitForChild("Interfaces")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
local SoundGroupFolder = SoundService:FindFirstChild("SoundGroups")
local NetworkRemotes = NetworkFolder.Remotes

local Cmdr = require(ControlsFolder.Modules:WaitForChild("CmdrClient"))
local Utilities = require(SharedModules.Utility)
local EnemyHandler = require(SharedModules.EnemyWaveHandler)

local PlayerGui = Players.LocalPlayer.PlayerGui

local test = Instance.new("BindableEvent")

local PlayerTileConnection
local EnemyConnection
local NetworkRemotesConnection

Cmdr:SetActivationKeys({Enum.KeyCode.F2})

local function StartMap()
    
end

local function FadeOutSounds(...: boolean)
    if ... then
        --Utilities:Print("Fading out all sounds.")
        for index, SoundGroup in SoundGroupFolder:GetChildren() do
            TweenService:Create(SoundGroup, TweenInfo.new(2.3), {Volume = 0.1}):Play()
        end
    else
        --Utilities:Print("Fading in all sounds.")
        for index, SoundGroup in SoundGroupFolder:GetChildren() do
            TweenService:Create(SoundGroup, TweenInfo.new(2.3), {Volume = 1}):Play()
        end
    end
end

--User expirence [Beta]
UserInputService.WindowFocusReleased:Connect(function()
    --Utilities:Print("Window focus left.")
    FadeOutSounds(true)
end)

UserInputService.WindowFocused:Connect(function()
    --Utilities:Print("Window focus back.")
    FadeOutSounds(false)
end)

EnemyConnection = EnemiesFolder.ChildAdded:Connect(function(Enemy: Model)
    if Enemy.PrimaryPart and Enemy:FindFirstChildOfClass("Humanoid") then -- Checks if the enemy has the required items to work.
        local newEnemyClass = EnemyHandler.new(Enemy)

        local EnemyData = newEnemyClass:Get()
    else
        Enemy:Destroy()
        Utilities:Warn({"Failed to process enemy:" , Enemy.Name or "Unknown!"})
    end
end)

EnemiesFolder.ChildAdded:Once(function()
    EnemyHandler:Initialize()
end)

--Networking [Beta]
NetworkRemotes.ChildAdded:Connect(function(Remote: RemoteEvent)
    local RemoteConnection = Remote.OnClientEvent:Connect(function(Message: any)
        local Instructions: string = Message["Intructions"]

        if Instructions == "Difficulty" then
            local DifficultyMenu = ControlInterfaces.Voting_Diff_Center:Clone()
            local Template = ControlTemplates:FindFirstChild("VoteFrameTemplate")

            local Difficulties = Message["DifficultyVotes"]
            
            DifficultyMenu.Parent = PlayerGui.z 

            for DifficultyIndex, DifficultyName in pairs(Difficulties) do
                local newTemplateFrame:Frame = Template:Clone()
                local InteractionButton:TextButton = newTemplateFrame.Interact
                local MapImage:string = DifficultyName["ImageId"]
                local VoteDebouce = true
                
                newTemplateFrame.Name = tostring(DifficultyName)
                --newTemplateFrame.MapImage.Image = MapImage
                newTemplateFrame.MapLabel.Text = tostring(DifficultyName)
                newTemplateFrame.LayoutOrder = DifficultyIndex

                newTemplateFrame.Parent = DifficultyMenu.Votes
                newTemplateFrame.Visible = true

                InteractionButton.Activated:Connect(function()
                    Utilities:Print("Voting for difficulty: ", DifficultyName)
                    if VoteDebouce == true then
                        VoteDebouce = false
                        Remote:FireServer(DifficultyName)
                        task.wait(0.5)
                        VoteDebouce = true
                    end
                end)
            end

            for Timer = 1, 16 do
                local Ticker = 16 - Timer
                if DifficultyMenu:FindFirstChild("Timer") then
                    DifficultyMenu.Timer.Text = "Time left to vote: " .. Ticker
                end
                task.wait(1)
                if Ticker == 0 then
                    DifficultyMenu:Destroy()
                end
            end
        elseif Instructions == "Enemy" then

            if PlayerGui.z:FindFirstChild("Voting_Diff_Center") then
                PlayerGui.z:FindFirstChild("Voting_Diff_Center"):Destroy()
            end
        end
    end)

    Remote.Destroying:Once(function()
        RemoteConnection:Disconnect()
    end)
end)