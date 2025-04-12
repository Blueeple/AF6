--!strict
-- Strict
local StartTick = tick()
local require = require

-- Services
local Players = game:GetService("Players")

-- Internal
local Core = script

-- Folders
local Utils = Core.Utils
local Common = Core.common

-- Variables
local RemoteTypeIndex = {}
local LoadedConnections = {}

-- Objects
local ReplicatorRemote = nil :: RemoteEvent | nil

-- Modules
local Register = Common.Register

-- Tables
local PlayersReplicateed = {}

-- Exported types
export type RemoteProperties = {
    Debounce: number,
    MaxPingPerMinite: number,
    Activated: boolean,
}

export type RemoteMetaTable = {
    Event: RBXScriptConnection | nil,
    Triggers: number | nil,
    Properties: RemoteProperties | nil,
    Type: string,
    Piority: number,
    Handler: any?,
    Dependencies: string,
}

-- Module contructor
local RemoteManagerServer = {}
RemoteManagerServer.__index = RemoteManagerServer

RemoteManagerServer.Connections = {}

local function ListenForResponse(Event: RemoteEvent?, Module: {any})

end

local function ReplicateToPlayer(Player: Player)
    print("Replicating player.")

    if ReplicatorRemote then
        print("Replicator found.")
        local Allowed = false
        local Start = tick()

        ReplicatorRemote:FireClient(Player, RemoteManagerServer.Connections)
        
        ReplicatorRemote.OnServerEvent:Once(function(Player: Player, Data: any)
            local Latency = tick() - Start

            print(Latency)

            if not Data and Latency < 10 then
                PlayersReplicateed[Player] = {
                    LastPing = tick(),
                    LastRemote = "null"
                }

                Allowed = true
            else
                Player:Kick("Extreme lag detected.")
            end
        end)

        return Allowed
    else
        return false
    end
end

local function GetRemote(Type: string)
    local RemoteInstance = RemoteTypeIndex[Type]

    if RemoteInstance ~= nil then
        return RemoteInstance
    else
        return nil
    end
end

function RemoteManagerServer:Register(Folder: Instance, Tag: string, ...)
    local Data = require(Register)(Folder, Tag, ...)
    RemoteTypeIndex = Data.Index
    ReplicatorRemote = Data.Replicator

    Players.PlayerAdded:Connect(function(Player: Player)
        coroutine.wrap(ReplicateToPlayer)(Player)
    end)

    Players.PlayerRemoving:Connect(function(Player: Player)
        coroutine.wrap(ReplicateToPlayer)(Player)
    end)
end

-- Creates an remote event that is managed and controlled by you know...
function RemoteManagerServer.new(Name: string, Type: string, Parent: Instance, Properties: RemoteProperties)
    -- Remote instance
    local RemoteInstance = GetRemote(Type) :: RemoteMetaTable

    -- Checks if the remote type exists or is indexed (Better remote type checker soon)
    if RemoteInstance then
        if RemoteManagerServer.Connections[Name] then error("Cannot create multiple remotes with the same name.", 1) end

        -- self
        local self = {}

        -- Basic properties idk
        self.Activation = nil
        self.Meta = RemoteTypeIndex[Type]

        -- Tables
        local RemoteMethods = self.Meta.Methods

        -- Properties Meta
        local Meta = {}
        Meta.Piority = RemoteInstance.Piority
        Meta.Triggers = 0

        -- Index
        RemoteManagerServer.Connections[Name] = Meta

        -- self functions
        -- Sets if the remote can be triggered by players.
        function self:SetActivation(...: boolean)
            self.Activation = ...
        end

        -- Remove the remote from the game instance also works with :Destroy() and the game instance
        function self:Remove()
            self = nil
        end

        warn("Initialized Remote " .. Name, tick() - StartTick, RemoteManagerServer)
        return setmetatable(Meta, RemoteManagerServer) :: RemoteMetaTable
    else
        warn("[RemoteManager] - No remote type of: " .. Type .. " exists or is indexed.")
        return setmetatable({}, RemoteManagerServer) :: RemoteMetaTable
    end
end

print(tick() - StartTick)
return RemoteManagerServer