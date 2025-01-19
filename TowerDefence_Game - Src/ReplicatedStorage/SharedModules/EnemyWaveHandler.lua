local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local MapFolder = workspace:WaitForChild("Map")
local NetworkFolder = ReplicatedStorage:WaitForChild("Network")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
local SoundGroupFolder = SoundService:FindFirstChild("SoundGroups")
local NetworkRemotes = NetworkFolder.Remotes

local Utilities = require(SharedModules.Utility)

local Initialized = false

local Map = nil
local NodesFolder = nil
local PathEnds = nil
local EnemySpawns = nil
local PathLinkRender = nil

local Nodes = {}

local EnemyDataFormat = {
    EnemyObject = "null",
    WalkSpeed = "null",
    RunSpeed = -1,
    JumpHeight = "null",
    AttackDamage = -1,
    AttackDamageThreshold = -1,
    Hidden = false,
    EnemyType = "null",
    EnemyIndex = -1,
    EnemyOffsetY = Vector3.new(0, 0, 0),
    Stunned = false,
    EnemySkillSet = "null",
    Binding = "-NoBind",
    PathLink = "null",
    PathLinkEnd = "null",
}

local SavedAttributes = {
    Hidden = true,
    Stunned = true,
}

local HumanoidDataToPort = {
    AutoRotate = true,
    MaxHealth = true,
    WalkSpeed = true,
    JumpHeight = true
}

local EnemyHandler = {Enemies = {}}
EnemyHandler.__index = EnemyHandler

local function UnloadAttributes(EnemyHumanoid: Humanoid)
    Utilities:Print("Unloading attributes.")

    local Attributes = EnemyHumanoid:GetAttributes()

    for Name, Value in Attributes do
        if SavedAttributes[Name] == nil then
            EnemyHumanoid:SetAttribute(Name, nil)
        end
    end
end

local function EnemySeverSideHandler(EnemyData: table, Humanoid: Humanoid)
    local EnemyId = EnemyData["EnemyIndex"]
    local EnemyAiBind = EnemyData["Binding"]
    local Enemy3D = EnemyData["EnemyObject"]

    Humanoid.Died:Once(function()
        EnemyHandler.Binds[EnemyAiBind][EnemyId] = nil
        Enemy3D:Destroy()
    end)
end

local function ImportNodeData(PathLink: string)
    local Nodes = MapFolder:FindFirstChildOfClass("Folder"):FindFirstChild("Nodes")[PathLink]

    local PathsImported = {}

    for Node = 1, #Nodes:GetChildren() do
        local newNode = Nodes[Node]
        table.insert(PathsImported, newNode)
    end

    return PathsImported
end

local function ImportHumanoidData(Humanoid: Humanoid)
    local Data = {}

    for DataName, Value in HumanoidDataToPort do
        Data[DataName] = Humanoid[DataName]
    end

    return Data
end

function EnemyHandler:Initialize()
    if Initialized == false then
        Utilities:Print("Initializing enemy render client.")

        local LastTick = tick()

        Initialized = true

        Map = MapFolder:FindFirstChildOfClass("Folder")
        NodesFolder = Map:FindFirstChild("Nodes")
        PathEnds = Map:FindFirstChild("PathEnds")

        local Rotation = 0

        PathLinkRender = RunService.PreRender:Connect(function(deltaTimeRender: number)

            for EnemyId = 1, #EnemyHandler.Enemies do
                local EnemyData:table = EnemyHandler.Enemies[EnemyId]

                local EnemyObject:Model = EnemyData["EnemyObject"]
                local Nodes = EnemyData["PathLink"]
                local NodeOffset = EnemyData["EnemyOffsetY"]

                local EnemyWalkSpeed = EnemyData["WalkSpeed"]

                EnemyObject.PrimaryPart.CFrame = CFrame.new(Nodes[1].CFrame.Position + NodeOffset) * CFrame.new(Rotation, 0, 0) * CFrame.Angles(0, Rotation, 0)

                Rotation += deltaTimeRender * EnemyWalkSpeed
            end

            LastTick = tick()
        end)
    else
        Utilities:Warn("Cannot Initialize for a second time.")
    end
end

function EnemyHandler.new(Enemy: Model)
    if Enemy == nil then Utilities:Warn("Failed to create enemy class.") return end

    Utilities:Print({"Instancing new enemy class:", Enemy.Name})

    local Humanoid: Humanoid = Enemy:WaitForChild("Humanoid")
    local ImportedHumanoidData: table = ImportHumanoidData(Humanoid)
    local HumanoidAttributes: table = Humanoid:GetAttributes()

    local EnemyIndex = HumanoidAttributes["EnemyIndex"]
    local PathLink = HumanoidAttributes["PathLink"]

    local EnemyData = {}

    for DataName, Value in pairs(HumanoidAttributes) do
        if EnemyDataFormat[DataName] ~= nil then
            EnemyData[DataName] = Value
        else
            Utilities:Warn({"No entry found for DataName: ", tostring(DataName)})
            continue
        end
    end

    for DataName, Value in pairs(ImportedHumanoidData) do
        EnemyData[DataName] = Value
    end

    EnemyData["EnemyObject"] = Enemy
    EnemyData["PathLink"] = ImportNodeData(PathLink)
    EnemyData["PathEnd"] = HumanoidAttributes["PathEnd"]

    UnloadAttributes(Humanoid)
    EnemySeverSideHandler(EnemyData, Humanoid)

    local newAnimation_walk = Utilities:AnimateRig(Enemy, "Walk")
    newAnimation_walk:Play()

    EnemyHandler.Enemies[EnemyIndex] = EnemyData

    Utilities:Print("Enemy class creation completed.")

    return setmetatable(EnemyData, EnemyHandler)
end

function EnemyHandler:Delete()
    
end

function EnemyHandler:Get()
    local EnemyData = self
    warn(EnemyHandler)
    return EnemyData
end

return EnemyHandler

--[[
* Calculate the magnitude from start to end node then multiply it by 0.01 * WalkSpeed.
* Then when enemy spawns tween the number by the speed from the start to the end.
* use runservice to position the enemy at the repestive area, using advanced math equations.
]]

--[[


    local LastTick = tick()
    local Node = 0

    local Nodes = {}
    ]]