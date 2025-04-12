-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

-- Shared folders
local NetworkShared = ReplicatedStorage:FindFirstChild("Network")
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

-- Server folders
local MoveSetsFolder = ServerStorage:FindFirstChild("MoveSets")
local ServerModules = ServerScriptService:FindFirstChild("GameServerModules")

-- Core server folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")
local ServerBindings = ServerScriptService:FindFirstChild("ServerBindings")

-- Shared modules
local Utilities = require(SharedModulesFolder.Utility)

-- Server modules
local PlayerManager = require(ServerModulesFolder.PlayerManager)

local MoveSetManager = {
    AvaliableMoveSets = {}
}

function MoveSetManager:LoadMoveSet(Moveset: string)
    local Moveset_Server = MoveSetsFolder[Moveset]
    local Moveset_Client = MoveSetsFolder[Moveset .. "Client"]

    
end

function MoveSetManager:CreateHitBox(Name: string, ...: {Parent: Instance, Time: number, CFrame: CFrame, Shape: Enum.PartType}) -- summ like that idk
    local args = ...

    local NewHitBox = Instance.new("Part")

    NewHitBox.Name = Name
    NewHitBox.Shape = args["Shape"]
    NewHitBox.CanCollide = false
    NewHitBox.CastShadow = false
    NewHitBox.CFrame = args["CFrame"]
    NewHitBox.Transparency = 0.75
    NewHitBox.Parent = args["Parent"]

    task.wait(args["Time"])

    NewHitBox:Destroy()
end

return MoveSetManager