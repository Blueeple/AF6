--Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

--unkown folder
local ReplicatedAssetsFolder = ReplicatedStorage:WaitForChild("ReplicatedAssets")
local MoveSetsFolder = ServerStorage:FindFirstChild("MoveSets")
local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local ServerModules = ServerScriptService:FindFirstChild("GameServerModules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

--Core server folders
local SharedModulesFolder = ReplicatedStorage:FindFirstChild("SharedModules")
local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")
local ServerBindings = ServerScriptService:FindFirstChild("ServerBindings")

--Server module folders
local Admin = ServerModulesFolder.Admin
local Cmdr = ServerModulesFolder.Cmdr
local Core = ServerModulesFolder.Core
local Management = ServerModulesFolder.Management
local Network = ServerModulesFolder.Network
local ServerUtility = ServerModulesFolder.ServerUtility

--Shared folders
local NetworkShared = ReplicatedStorage:FindFirstChild("Network")

--Shared modules
local Utilities = require(SharedModulesFolder.Utility)

--Server modules
local PlayerManager = require(Management.PlayerManager)

local MoveSetManager = {}

--Creates a new MoveSet manager for a player.
function MoveSetManager:InitializeMoveSets(...: table) --Chaneg this to make use the player's actrual moveset.
    Utilities:Print("Initializing movesets.")

    for MoveSetName, Bool in pairs(...) do
        local MoveSet = MoveSetsFolder[MoveSetName] or nil

        if MoveSetName ~= nil then
            local Client = MoveSetsFolder[MoveSetName .. "Client"]:Clone()
            Client.Parent = ReplicatedAssetsFolder.MoveSets
        end
    end

    Utilities:Print("Initializing completed.")
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

function MoveSetManager:ProccessMove(Player: Player, Data: table)
    local PlayerData = PlayerManager:ReadPlayer(Player)
    print(PlayerData)
    print(Data)
end

return MoveSetManager