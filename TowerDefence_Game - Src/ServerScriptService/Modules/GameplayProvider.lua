local AnalyticsService = game:GetService("AnalyticsService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")

local LobbyFolder = ServerStorage.Assets:FindFirstChild("Lobby")
local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local ServerModules = ServerScriptService:FindFirstChild("Modules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local EnemyManager = require(ServerModules.EnemyManager)
local Utilities = require(SharedModules.Utility)
local RemoteManager = require(ServerModules.RemoteManager)
local PlayersManager = require(ServerModules.PlayerManager)
local GameSettings = require(SharedModules.GameSettings)
local MapsModule = require(ServerModules.MapConfiguration)

local SkipEvent = {Bind = ServerModules.Hooks:FindFirstChild("Skip"), Connection = nil}

local CurrentWave = nil
local isPlayerVotingAllowed = false

local MapsAvailable = {}
local PlayerVotes = {}

local GameplayProvider = {
    ElaspedTime = 0,
    SkippedVotes = false,
    MapToLoad = nil,
}
GameplayProvider.__index = GameplayProvider

local function StartWaves(...: table)
    local Waves = ...

    for i = 1, 3 do
        Utilities:Print({"Starting wave in:", 4 - i})
        task.wait(1)
    end

    for WaveId = 1, #Waves do
        Utilities:Print({"Initializing wave:", WaveId})

        local WaveSheet: table = Waves[WaveId]
        
        CurrentWave = EnemyManager.RenderWaveToServer(WaveSheet)
        --task.wait(5)
        --Test:CleanUp()
        
        CurrentWave.WaveEndedEvent.Event:Wait()
    end
end

local function TallyVotes(Votes: {}, DefaultVote: string)
    local ItemVotes = Votes
    local SameVotes = {}
    local HighestVoteCount = 0
    local HighestVoteName = nil
    local VetoCount = 0

    Utilities:Print("Tallying votes.")

     for Name, VoteName in PlayerVotes do
        if VoteName ~= "Veto" then
            table.insert(ItemVotes[VoteName], Name)
        else
             VetoCount += 1
        end
    end

    for VoteName, Votes in pairs(ItemVotes) do
        local VoteCount = #Votes
         if VoteCount > HighestVoteCount then
            HighestVoteName = VoteName
            HighestVoteCount = VoteCount
        elseif VoteCount == HighestVoteCount then
            table.insert(SameVotes, HighestVoteName)
            table.insert(SameVotes, VoteName)
            HighestVoteName = nil
        end
    end

    Utilities:Print("Processing tally.")

    if #SameVotes >= 2 and HighestVoteName == nil and VetoCount == 0 then
        local randomIndex = math.random(1, #SameVotes)
        return tostring(SameVotes[randomIndex])
    elseif VetoCount == Utilities:GetTableLength(PlayerVotes) then
        return "Veto"
    elseif HighestVoteName then
        return HighestVoteName
    elseif DefaultVote ~= nil then
        return DefaultVote
    else
        for index, Player in Players:GetPlayers() do
            if Player then
                Utilities:Warn("[Error - 002]: Failed to process votes.")
                PlayersManager:Kick(PlayersManager:AllPlayers(), "Voting system failure.")
            end
        end
    end
end

local function LoadMap(MapName : string, Location: Folder, MapConfiguration: {}) --Add lighting loading.
    local Maps = {}

    local MapToLoad = nil
    local MapSettings = nil

    Location = Location or workspace.Map

    workspace.Map:ClearAllChildren()
    workspace.Enemies:ClearAllChildren()
    workspace.Towers:ClearAllChildren()

    if CurrentWave then
        CurrentWave:CleanUp()
    end

    if type(MapConfiguration) == "table" then
        for Index, Map in MapConfiguration do
            Maps[Map.Name] = ServerStorage.Maps:FindFirstChild(Map.Name) or nil
        end
    end
 
    Utilities:Print("Loading map: " .. MapName)

    if type(MapConfiguration) == "table" and Maps[MapName] ~= nil then
        Utilities:Print("Map detected.")

        Location:ClearAllChildren()

        MapToLoad = Maps[MapName]:Clone()
        MapToLoad.Parent = workspace.Map
        MapSettings = MapToLoad:FindFirstChild("MapSettings")
    elseif type(MapConfiguration) == "userdata" then
        Utilities:Print("Map detected.")

        MapToLoad = MapConfiguration[MapName]:Clone()
        MapToLoad.Parent = workspace.Map
        MapSettings = MapToLoad:FindFirstChild("MapSettings")
    else
        Utilities:Warn("Failed to load map:" .. MapName .. ".")
        PlayersManager:Kick(PlayersManager:AllPlayers(), "There was an error loading map:" .. MapName .. " please report this bug to the developer.")
    end
    
    task.wait(0.5)

    if Location == workspace.Map then
        Utilities:Print("Gameplay map detected.")

        local DifficultyTable = require(MapSettings:FindFirstChild("DifficultyTable"))
        local Difficulties = MapToLoad:FindFirstChild("Difficulties")

        local VoteTimeMax = 16
        local Votes = {}
        
        GameplayProvider.SkippedVotes = false

        for Index, DiffName in DifficultyTable do
            Votes[DiffName] = {}
        end

        PlayersManager:Reload(PlayersManager:AllPlayers())
        
        local ClientContact = RemoteManager.new({
            Parent = NetworkFolder.Remotes,
            Activated = false,
            RemoteType = "Event",
            DebouceTime = 0.3,
            FallOffTime = 5,
            AllowedTypes = {
                string = true,
            }
        })

        task.wait(1)

        ClientContact:Fire(Players:GetChildren(), {
            Intructions = "Difficulty",
            DifficultyVotes = DifficultyTable
        })

        ClientContact:SetActivation(true)

        ClientContact.Event:Connect(function(...: {Player: Player, Data: any})
            local args = ...

            local Player = args["Player"]
            local Message = args["Data"]

            if typeof(Message) == "string" and Votes[Message] ~= nil then
                PlayerVotes[Player.Name] = Message
                return PlayerVotes
            else
                Player:Kick("Illegal opperations detected form user.")
            end
        end)

        for TimeCount = 0, VoteTimeMax do
            if TimeCount == VoteTimeMax or GameplayProvider.SkippedVotes == true then
                local SelectedDifficulty = TallyVotes(Votes, DifficultyTable[1])
                local WaveSheetModule = require(Difficulties[tostring(SelectedDifficulty)])
                Utilities:Print({"Loading difficulty:", SelectedDifficulty})

                ClientContact:Fire(Players:GetChildren(), {
                    Intructions = "Enemy",
                    WaveSheet = WaveSheetModule,
                })

                ClientContact:Shutdown()

                task.wait()

                StartWaves(WaveSheetModule)

                break
            end

            task.wait(1)
        end
    else
        Utilities:Print("Map is not an gameplay map.")
    end

   return MapToLoad
end

local function CreateVoteIndicator(Player : Player, VoteStation : Part, OffsetY : number)
    if VoteStation:FindFirstChild(Player.Name) then
        VoteStation[Player.Name]:Destroy()
    end

    local NewIndicator = Instance.new("Part")
    NewIndicator.Anchored = true
    NewIndicator.Name = Player.UserId .. "_Tile"
    NewIndicator.CanCollide = false
    NewIndicator.Size = Vector3.new(1, 1, 1)
    NewIndicator.Transparency = 0.5
    NewIndicator.CFrame = VoteStation.VoteArea.CFrame + Vector3.new(0, OffsetY, 0)

    NewIndicator.Parent = VoteStation.Parent.Parent.Main.Tiles

    task.wait(0.2)

    NewIndicator:Destroy()
end

local function CreateProximityPrompts(newLobby: Model, LoadVeto: boolean)
    local VotePromptsFolder = newLobby:FindFirstChild("VoteStations")

    local Prompts = {}

    Utilities:Print("Creating prompts for option voting.")

    if #MapsAvailable["Whitelist"] <= #VotePromptsFolder:GetChildren() * 2 - 2 then Utilities:Warn("Not enough maps to start vote system.") return nil end

    Utilities:Print("There is enough maps to start vote system.")

    for index, Prompt in pairs(VotePromptsFolder:GetChildren()) do
        local PromptAttachment = Prompt.PrimaryPart:FindFirstChildOfClass("Attachment")
        local NewProximityPrompt = Instance.new("ProximityPrompt")

        NewProximityPrompt.HoldDuration = 0.1
        --NewProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
        NewProximityPrompt.ObjectText = "Missing_Map"
        NewProximityPrompt.ActionText = "Vote displayed map."

        NewProximityPrompt.Triggered:Connect(function(Player: Player)
            if isPlayerVotingAllowed then
                local MapToVote = NewProximityPrompt.ObjectText

                Utilities:Print("Player:" .. Player.Name .. "Voted for option:".. MapToVote)

                PlayerVotes[Player.Name] = MapToVote

                coroutine.wrap(CreateVoteIndicator)(Player, Prompt, 3)
            else
                Utilities:Warn("Atempted exploiting from user:" .. Player.Name)
                PlayersManager:Kick(Player.Name, "Dude what the hell man :(")
            end
        end)

        if index ~= #VotePromptsFolder:GetChildren() or LoadVeto == false then
            local RandomMapIndex = math.random(1, #MapsAvailable["Whitelist"])
            local MapToVote = MapsAvailable["Whitelist"][RandomMapIndex]

            table.remove(MapsAvailable["Whitelist"], RandomMapIndex)

            NewProximityPrompt.ObjectText = tostring(MapToVote.Name) or "Loading failure"
            NewProximityPrompt.Parent = PromptAttachment

            Prompts[index] = NewProximityPrompt
        elseif LoadVeto == true and index == #VotePromptsFolder:GetChildren() then
            local MapToVote = "Veto"

            NewProximityPrompt.ObjectText = MapToVote
            NewProximityPrompt.Parent = PromptAttachment
            
            Prompts[index] = NewProximityPrompt
        elseif LoadVeto == false and index == #VotePromptsFolder:GetChildren() then
            warn("No.")
            break
        end
    end

    return Prompts
end

local function StartCountDown(Prompts: {}, LobbyTimer: TextLabel)
    local VotingTime = GameSettings.LobbySettings.VoteTime_Normal
    local ElaspedTime = GameplayProvider.ElaspedTime

    Utilities:Print("Starting count down.")

    for TimeCount = 0, VotingTime do
        ElaspedTime = VotingTime - TimeCount
        LobbyTimer.Text = ElaspedTime

        if ElaspedTime == 0 or GameplayProvider.SkippedVotes == true and GameplayProvider.MapToLoad == nil then
            Utilities:Print("Cleaning up prompts.")
            local Votes = {}

            for index, Prompt in Prompts do
                Prompt:Destroy()
            end

            for Index, Prompt in Prompts do
                if Prompt.ObjectText ~= "Veto" then
                    Votes[Prompt.ObjectText] = {}
                end
            end

            local Tally = TallyVotes(Votes)

            if Tally ~= "Veto" then
                PlayerVotes = {}
                LoadMap(Tally, nil, ServerStorage.Maps:GetChildren())
            else
                local newPrompts
                local ProximityPromptConnection

                GameplayProvider.SkippedVotes = false
                GameplayProvider.MapToLoad = nil

                PlayerVotes = {}

                for Timer = 1, 5 do
                    ElaspedTime = 5 - Timer
                    LobbyTimer.Text = ElaspedTime
                    task.wait(1)
                end

                newPrompts = CreateProximityPrompts(workspace.Map:FindFirstChildOfClass("Folder"), false)

                ProximityPromptConnection = ProximityPromptService.PromptTriggered:Once(function(prompt, playerWhoTriggered)
                    StartCountDown(newPrompts, LobbyTimer)
                end)
                    
            end

            break
        elseif GameplayProvider.MapToLoad ~= nil and GameplayProvider.SkippedVotes == true then
            PlayerVotes = {}
            LoadMap(GameplayProvider.MapToLoad, nil, ServerStorage.Maps:GetChildren())
            break
        end

        task.wait(1)
    end
end

function GameplayProvider.newLobby(...: {})
    local args = ...
    local VoteTime = GameSettings["LobbySettings"].VoteTime_Normal

    Utilities:Print({"Creating game lobby."})

    MapsAvailable = MapsModule:ScanForMaps(GameSettings["MapScanParams"]) --Will still be in used but this module requires a rework.

    local LobbyMap  = LoadMap("Lobby", workspace, ServerStorage.Assets)
    local VotePrompts = CreateProximityPrompts(LobbyMap, true)

    isPlayerVotingAllowed = true
    workspace:FindFirstChildOfClass("Part"):Destroy()

    ProximityPromptService.PromptTriggered:Once(function(Prompt: ProximityPrompt, Player: Player)
        StartCountDown(VotePrompts, LobbyMap.Main.Base.Display.DisplayUX.Label)
    end)

    SkipEvent.Connection = SkipEvent.Bind.Event:Connect(function(...: string)
        Utilities:Print("Detected")
        if ... ~= "-n" then
            GameplayProvider.MapToLoad = ...
            LoadMap(GameplayProvider.MapToLoad, nil, ServerStorage.Maps:GetChildren())
        else
            GameplayProvider.SkippedVotes = true
        end
    end)

    return setmetatable({
        Placeholder = 0,
    }, GameplayProvider)
end

function GameplayProvider:ForceMap(...: string)
    GameplayProvider.MapToLoad = ...
end

return GameplayProvider