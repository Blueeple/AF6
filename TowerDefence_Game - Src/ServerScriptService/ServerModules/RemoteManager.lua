--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

--//Shared folder
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

--//Shared Modules
local Utilities = require(SharedModules.Utility)

--//Variables
local ModuleStartTime = tick()

--//Object Oriented Module Constructor
local RemoteManager = {Remotes = {}}
RemoteManager.__index = RemoteManager

--//Checks if the module is running on the client.
if RunService:IsServer() == false then
    error("Remote manager is somehow running on the client.")
    return
end

--//Handles all the remote work. NOTE: RemoteFunction option is unfinished, unoptimized, Broken and NOT recommended for live server use~
local function HandleRemote(Player: Player, SerializedName: string, EventBind: BindableEvent, ...: table)
    local Remote = RemoteManager.Remotes[SerializedName]

    local Activation = Remote["Activated"]
    local AllowedTypes = Remote["AllowedTypes"]
    local DebouceTime = Remote["DebouceTime"]
    local FallOffTime = Remote["FallOffTime"]
    local RemoteType = Remote["RemoteType"]

    local RemoteDataPlayers = RemoteManager.Remotes[SerializedName]["Players"]
    local LastReboundPingT = RemoteManager.Remotes[SerializedName]["Ping"]
    
    local LastReboundPing = 0

    Utilities:OutputLog("Proccessing data from remote: ", SerializedName)

    if RemoteDataPlayers[Player] == nil then
        RemoteDataPlayers[Player] = {
            LastPing = 1,
            Violations = 0,
        }
    end

    --//Make this actrually work fr fr
    if RemoteType == "Functional" then
        --[[LastReboundPingT = RunService.Heartbeat:Connect(function(deltaTime)
            if LastReboundPing > FallOffTime then
                Utilities:OutputWarn({"Emergency shutdown protocal in force for Remote: ", SerializedName})
            end
        end)]]

        --print(...)
    end

    local PlayerRemoteData = RemoteDataPlayers[Player]

    if Activation == true and AllowedTypes[tostring(typeof(...))] == true and tick() - PlayerRemoteData.LastPing > DebouceTime and PlayerRemoteData.Violations < FallOffTime then
        LastReboundPing = tick()

        Utilities:OutputLog("The data has passsed the first event check.")

        if typeof(...) == "table" then
            Utilities:OutputLog("Table type detected.")
            for VariableName, Value in pairs(...) do
                if VariableName and AllowedTypes[tostring(typeof(Value))] then
                    Utilities:OutputLog({"Table data:", tostring(VariableName), " of type:", tostring(typeof(Value)), " has passed the check."})
                    continue
                else
                    --//Increment violations and warn the player
                    Utilities:warned({"Table data:", tostring(VariableName), " of type:", tostring(typeof(Value)), " failed the check."})
                    PlayerRemoteData.Violations += 1
                    Utilities:OutputWarn({"Player: ", Player.Name, " has been warned. Violation count: ", PlayerRemoteData.Violations})
                end
            end
        end

        --//Fire the event
        Utilities:OutputLog("Data is verified to be used on the server.")
        EventBind:Fire(Player, ...)

        --//Reset violations and update LastPing
        PlayerRemoteData.Violations = 0
    elseif PlayerRemoteData.Violations >= FallOffTime or AllowedTypes[tostring(typeof(...))] == false then
        --//Kick player for exceeding the violation threshold
        Player:Kick("ApolloX Detected illegal remote event use.")
        Player:Destroy()
    else
        -- Increment violations and warn the player
        PlayerRemoteData.Violations += 1
        Utilities:OutputWarn({"Player: ", Player.Name, " has been warned. Violation count: ", PlayerRemoteData.Violations})
    end

    PlayerRemoteData.LastPing = tick()
end

--//Creates a new Remote event.
function RemoteManager.new(...: {Name: string, Parent: any, Activated: boolean, RemoteType: string, DebouceTime: string, FallOffTime: number, AllowedTypes: {}})
    local args = ...

    --//Fixed variables
    local Name = args["Name"]
    local RemoteType = args["RemoteType"]
    local AllowedTypes = args["AllowedTypes"]
    local DebouceTime = args["DebouceTime"]
    local FallOffTime = args["FallOffTime"]
    local Parent = args["Parent"]

    local SerializedName = Name or Utilities:GenerateGUIDName(0, 30, true)
    local EventBind = Instance.new("BindableEvent")

    --//Dynamic variables
    local Activated = args["Activated"]
    local Configuration = {}
    local MetaConfiguration = {}

    --//Null variables
    local newRemote
    local newRemoteConnection

    --//Types checks for the varriables.
    if type(DebouceTime) ~= "number" or type(FallOffTime) ~= "number" or type(Activated) ~= "boolean" or Parent == nil and Utilities:GetTableLength(AllowedTypes) > 0 then
        Utilities:OutputWarn("[Error - 003]: Invalid type or missing variable.")
        return
    end

    Utilities:OutputLog({"Creating new safe remote for: ", SerializedName})

    EventBind.Name = SerializedName

    if RemoteType == "Event" then
        newRemote = Instance.new("RemoteEvent", Parent)
        newRemote.Name = SerializedName
    elseif RemoteType == "Functional" then
        newRemote = Instance.new("RemoteFunction", Parent)
        newRemote.Name = SerializedName
    else
        Utilities:OutputWarn({"Failed to create safe remote for :", SerializedName})
        return setmetatable(nil, RemoteManager)
    end

    Configuration = {}

    for Name, Value in pairs(args) do
        Configuration[Name] = Value
    end

    RemoteManager.Remotes[SerializedName] = Configuration
    RemoteManager.Remotes[SerializedName]["Players"] = {}

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

--//Sets if the remote can be activated.
function RemoteManager:SetActivation(...: boolean)
    Utilities:OutputLog("Setting the activation on remote, " .. self["SerializedName"])
    local Remote = self
    RemoteManager.Remotes[Remote.SerializedName]["Activated"] = ...
end

--//Returns every player connected to the server.
function RemoteManager:AllPlayers()
    return Players:GetChildren()
end

--//Fires the remote to a player or group of players.
function RemoteManager:Fire(Player: Player, ...: any)
    local Remote = self["Event_nofilter"]
    local RemoteType = self["RemoteType"]

    if RemoteType == "Event" then
        if type(Player) == "table" then
            Utilities:OutputLog("Firing remote to all players.")
            Remote:FireAllClients(...)
        elseif Player ~= nil and Player:IsA("Player") then
            Utilities:OutputLog({"Firing remote to player, ", Player.Name})
            Remote:FireClient(Player, ...)
        else
            Utilities:OutputWarn({"[Error - 004]: Failed to fire event: " , Remote.Name})
        end
    elseif RemoteType == "Functional" then
        if type(Player) == "table" then
            Utilities:OutputLog("Firing remote to all players.")
            local Info = ...
            
            for Id, _Player in Player do
                local success, response = pcall(function()
                    Remote:InvokeClient(_Player, Info)
                end)

                print(success, response)
            end

        elseif Player ~= nil and Player:IsA("Player") then
            Utilities:OutputLog({"Firing remote to player, ", Player.Name})
            local Info = ...

            local success, response = pcall(function()
                Remote:InvokeClient(Player, Info)
            end)

            print(success, response)
        else
            Utilities:OutputWarn({"[Error - 004]: Failed to fire event: " , Remote.Name})
        end
    end
end

--//Unbinds the remote from the remote management system.
function RemoteManager:Shutdown()
    local args = self

    local SerializedName = args["SerializedName"]

    local Connection = args["newRemoteConnection"]
    local Event = args["Event"]
    local Event_nofiler = args["Event_nofilter"]

    Utilities:OutputLog({"Shuting down remote:", SerializedName, "."})

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

    RemoteManager.Remotes[SerializedName] = nil

    Utilities:OutputLog({SerializedName, "has shutted down."})

    return setmetatable({nil}, RemoteManager)
end

--//Returns the information from the remote.
function RemoteManager:GetInfo()
    return self
end

--/Removes a player from an safe remote.
function RemoteManager:RemovePlayerFrom(Player: Player, Remote: RemoteEvent)
    if Remote == nil then Remote = self end

    Utilities:OutputLog({"Removing player:", tostring(Player), "from remotes."})
    if Remote == "$Active" then
        Utilities:OutputLog({"Removing player:", tostring(Player), "from all remotes."})
        for RemoteName, Data in pairs(RemoteManager.Remotes) do
            if Data["Players"][Player] ~= nil then
                Data["Players"][Player] = nil
            end
        end
    elseif Remote ~= nil and RemoteManager.Remotes[Remote.Name] ~= nil then
        Utilities:OutputLog({"Removing player:", tostring(Player), "from remote:", Remote, "."})
        RemoteManager.Remotes[Remote.Name]["Players"][Player] = nil
    else
        Utilities:OutputWarn({"Failed to remove:", tostring(Player), "from remote:", Remote, "did you trigger this event when the remote doesn't exist?"})
        return
    end

    Utilities:OutputLog({"Removal of player:", tostring(Player), "completed."})
end

Utilities:OutputLog({"Initialized in:", tick() - ModuleStartTime})

return RemoteManager