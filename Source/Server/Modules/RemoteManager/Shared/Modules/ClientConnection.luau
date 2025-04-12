--!strict
--strict
local require = require
local SharedTable = SharedTable

-- Remotes
local PingPiority0: RemoteEvent | nil = _G
local PingPiority1: UnreliableRemoteEvent | nil

-- Shared
local SharedRemotes = {}

-- Variables
local Loaded = false

-- Exported types
export type ConnectionType = {
    Fire: (any?),
    Evnet: {}
}

local ConnectionModule = {}
ConnectionModule.__index = ConnectionModule

-- Yeilds initialization until module has loaded propertly
local function YeildUntil(Number: number)
    for i = 1, Number do
        task.wait()
        if not next(SharedRemotes, nil) then
            break
        end
    end
end

-- Initializes the client services and modules.
function ConnectionModule.Init()
    -- self
    local self

    -- Callback
    local ReturnCallBack = function(Remotes: any)
        SharedRemotes = Remotes
        warn(Remotes)
    end

    -- Objects
    local ReplicatorSignal = script:FindFirstChild("ReplicatorSignal") :: RemoteEvent

    -- Temp
    local PingPiority0_Temp  = script:FindFirstChild("PingPiority0") :: RemoteEvent
    local PingPiority1_Temp = script:FindFirstChild("PingPiority1") :: UnreliableRemoteEvent

    -- Global
    _G["PingPiority0"] = PingPiority0_Temp
    _G["PingPiority1"] = PingPiority1_Temp

    -- Event fire
    ReplicatorSignal:FireServer()

    -- Callback trigger
    ReplicatorSignal.OnClientEvent:Once(ReturnCallBack)
end

-- Indexs the remote for a script.
function ConnectionModule.new(Name: string)
    if not next(SharedRemotes, nil) then YeildUntil(100) end

    local Remote = SharedRemotes[Name]

    if Remote then
        -- self
        local self = {}

        self.Piority = "PingPiority" .. tostring(Remote.Piority)

        -- Meta
        local Meta = {}

        -- Meta Functions
        function Meta.Fire(...)
            _G[self.Piority]:FireServer(...)
        end

        return setmetatable(Meta, ConnectionModule) :: ConnectionType
    else
        warn("[RemoteManager][Client] - Failed to register a remote that doesn't exist.")
        return setmetatable({}, ConnectionModule) :: ConnectionType
    end
end

return ConnectionModule