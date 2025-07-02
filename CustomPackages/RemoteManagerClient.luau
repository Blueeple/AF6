--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local StartTick = tick()
local LocalPlayer = Players.LocalPlayer :: Player

-- Return module contructor
local RemoteManagerClient = {}

function RemoteManagerClient.get() end

return RemoteManagerClient
