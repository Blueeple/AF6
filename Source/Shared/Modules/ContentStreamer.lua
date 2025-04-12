-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Network folder
local Network = ReplicatedStorage:WaitForChild("Network")

-- Exported types
export type ClientConnectionType = {
    new: (Name: string) -> {Fire: (any?), Event: (any?)},
}

-- Modules
local ClientConnection: ClientConnectionType = nil

-- Events
local StreamerEvent = nil

-- Variables
local Event = Instance.new("BindableEvent")

local ContentStreamer = {}

function ContentStreamer.Init()
    ClientConnection = require(Network:WaitForChild("ClientConnection"))
    ClientConnection.Init()

    StreamerEvent = ClientConnection.new("Streamer")
end

function ContentStreamer:GetStartAssetsAsync()
    StreamerEvent.Fire({
        "Get",
        "Setup1"
    })
end

function ContentStreamer:StreamToClient()
    
end

return ContentStreamer