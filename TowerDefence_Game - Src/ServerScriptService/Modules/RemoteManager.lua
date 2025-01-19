local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Utilities = require(SharedModules.Utility)

local RemoteManager = {}
RemoteManager.__index = RemoteManager
RemoteManager.__Remotes = {}

--Checks if the module is running on the client.
if RunService:IsServer() == false then
    error("Remote manager is somehow running on the client.")
    return
end

--Handles all the remote work. NOTE: RemoteFunction option is unfinished, unoptimized, Broken and NOT recommended for live server use~
local function HandleRemote(Player: Player, SerializedName: string, EventBind: BindableEvent, ...: table)
    local Remote = RemoteManager.__Remotes[SerializedName]

    local Activation = Remote["Activated"]
    local AllowedTypes = Remote["AllowedTypes"]
    local DebouceTime = Remote["DebouceTime"]
    local FallOffTime = Remote["FallOffTime"]
    local RemoteType = Remote["RemoteType"]

    local RemoteDataPlayer = RemoteManager.__Remotes[SerializedName]["Players"]
    local LastReboundPingT = RemoteManager.__Remotes[SerializedName]["Ping"]
    
    local LastReboundPing = 0

    if RemoteDataPlayer[Player] == nil then
        RemoteDataPlayer[Player] = {
            LeaveGame = Player.Destroying:Once(function()
                RemoteDataPlayer[Player] = nil
            end),
            LastPing = 1,
            Violations = 0,
        }
    end

    if RemoteType == "Functional" then
        LastReboundPingT = RunService.Heartbeat:Connect(function(deltaTime)
            if LastReboundPing > FallOffTime then
                Utilities:Warn({"Emergency shutdown protocal in force for Remote: ", SerializedName})
            end
        end)
    end

    local PlayerRemoteData = RemoteDataPlayer[Player]

    if Activation == true and AllowedTypes[tostring(type(...))] == true and tick() - PlayerRemoteData.LastPing > DebouceTime and PlayerRemoteData.Violations < FallOffTime then
        LastReboundPing = tick()

        -- Fire the event
        EventBind:Fire({
            Player = Player,
            Data = ...,
        })

        -- Reset violations and update LastPing
        PlayerRemoteData.Violations = 0
    elseif PlayerRemoteData.Violations >= FallOffTime or AllowedTypes[tostring(type(...))] == false then
        -- Kick player for exceeding the violation threshold
        Player:Kick("ApolloX Detected illegal remote event use.")
        Player:Destroy()
    else
        -- Increment violations and warn the player
        PlayerRemoteData.Violations += 1
        Utilities:Warn({"Player: ", Player.Name, " has been warned. Violation count: ", PlayerRemoteData.Violations})
    end

    PlayerRemoteData.LastPing = tick()
end

--Creates a new Remote event.
function RemoteManager.new(...: {Parent: any, Activated: boolean, RemoteType: string, DebouceTime: string, FallOffTime: number, AllowedTypes: {}})
    local args = ...

    --Fixed variables
    local RemoteType = args["RemoteType"]
    local AllowedTypes = args["AllowedTypes"]
    local DebouceTime = args["DebouceTime"]
    local FallOffTime = args["FallOffTime"]
    local Parent = args["Parent"]

    local SerializedName = Utilities:GenerateGUIDName(0, 30, true)
    local EventBind = Instance.new("BindableEvent")

    --Dynamic variables
    local Activated = args["Activated"]
    local Configuration = {}
    local MetaConfiguration = {}

    --Null variables
    local newRemote
    local newRemoteConnection

    --Types checks for the varriables.
    if type(DebouceTime) ~= "number" or type(FallOffTime) ~= "number" or type(Activated) ~= "boolean" or Parent == nil and Utilities:GetTableLength(AllowedTypes) > 0 then
        Utilities:Warn("[Error - 003]: Invalid type or missing variable.")
        return
    end

    Utilities:Print({"Creating new safe remote for: ", SerializedName})

    EventBind.Name = Utilities:GenerateGUIDName(0, 50, true)

    if RemoteType == "Event" then
        newRemote = Instance.new("RemoteEvent", Parent)
        newRemote.Name = SerializedName
    elseif RemoteType == "Functional" then
        newRemote = Instance.new("RemoteFunction", Parent)
        newRemote.Name = SerializedName
    else
        Utilities:Warn({"Failed to create safe remote for :", SerializedName})
        return setmetatable(nil, RemoteManager)
    end

    Configuration = {
        SerializedName = SerializedName,
        Activated = Activated,
        newRemoteConnection = newRemoteConnection,
        AllowedTypes = AllowedTypes,
        FallOffTime = FallOffTime,
        DebouceTime = DebouceTime,
    }

    RemoteManager.__Remotes[SerializedName] = Configuration
    RemoteManager.__Remotes[SerializedName]["Players"] = {}

    if RemoteType == "Event" then
        newRemoteConnection = newRemote.OnServerEvent:Connect(function(Player: Player, ...:{})
            HandleRemote(Player, SerializedName, EventBind, ...)
        end)
    elseif RemoteType == "Functional" then
        newRemoteConnection = newRemote
        
        newRemoteConnection.OnServerInvoke = function(Player: Player, ...: {})
            HandleRemote(Player, SerializedName, EventBind, ...)
        end
    end
    
    MetaConfiguration = {
        SerializedName = SerializedName,
        Configuration = Configuration,
        Event = EventBind.Event,
        Event_nofilter = newRemote,
        RemoteType = RemoteType,
        newRemoteConnection = newRemoteConnection,
    }

    return setmetatable(MetaConfiguration, RemoteManager)
end

--Sets if the remote can be activated.
function RemoteManager:SetActivation(...: boolean)
    Utilities:Print("Setting the activation on remote, " .. self["SerializedName"])
    local Remote = self
    RemoteManager.__Remotes[Remote.SerializedName]["Activated"] = ...
end

--Returns every player connected to the server.
function RemoteManager:AllPlayers()
    return Players:GetChildren()
end

--Fires the remote to a player or group of players.
function RemoteManager:Fire(Player: Player, ...: any)
    local Remote = self["Event_nofilter"]
    local RemoteType = self["RemoteType"]

    if RemoteType == "Event" then
        if type(Player) == "table" then
            Utilities:Print("Firing remote to all players.")
            Remote:FireAllClients(...)
        elseif Player ~= nil and Player:IsA("Player") then
            Utilities:Print({"Firing remote to player, ", Player.Name})
            Remote:FireClient(Player, ...)
        else
            Utilities:Warn({"[Error - 004]: Failed to fire event: " , Remote.Name})
        end
    elseif RemoteType == "Functional" then
        if type(Player) == "table" then
            Utilities:Print("Firing remote to all players.")
            local Info = ...
            
            for Id, _Player in Player do
                local success, response = pcall(function()
                    Remote:InvokeClient(_Player, Info)
                end)

                print(success, response)
            end

        elseif Player ~= nil and Player:IsA("Player") then
            Utilities:Print({"Firing remote to player, ", Player.Name})
            local Info = ...

            local success, response = pcall(function()
                Remote:InvokeClient(Player, Info)
            end)

            print(success, response)
        else
            Utilities:Warn({"[Error - 004]: Failed to fire event: " , Remote.Name})
        end
    end
end

--Unbinds the remote from the remote management system.
function RemoteManager:Shutdown()
    local args = self

    local SerializedName = args["SerializedName"]

    local Connection = args["newRemoteConnection"]
    local Event = args["Event"]
    local Event_nofiler = args["Event_nofilter"]

    Utilities:Print({"Shuting down remote:", SerializedName, "."})

    self:SetActivation(false)

    Event_nofiler:Destroy()

    if typeof(Connection) == "RBXScriptConnection" then
        Connection:Disconnect()
    else
        Connection:Destroy()
    end

    Connection = nil
    Event = nil
    Event_nofiler = nil

    RemoteManager.__Remotes[SerializedName] = nil

    Utilities:Print({SerializedName, "has shutted down."})

    return setmetatable({nil}, RemoteManager)
end

--Returns the information from the remote.
function RemoteManager:GetInfo()
    return self
end

return RemoteManager