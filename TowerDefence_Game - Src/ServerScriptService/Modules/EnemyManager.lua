local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local EnemiesFolder:Folder = workspace.Enemies
local EnemyFileFolder = ServerStorage.Enemies
local ReplicatedAssetsFolder = ReplicatedStorage:FindFirstChild("Assets")
local EnemiesCached = ReplicatedAssetsFolder:FindFirstChild("Enemies")
local MapFolder:Folder = workspace.Map
local LobbyFolder = ServerStorage.Assets:FindFirstChild("Lobby")
local NetworkFolder = ReplicatedStorage:FindFirstChild("Network")
local ServerModules = ServerScriptService:FindFirstChild("Modules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Utilities = require(SharedModules.Utility)
local RemoteManager = require(ServerModules.RemoteManager)
local PlayersManager = require(ServerModules.PlayerManager)
local GameSettings = require(SharedModules.GameSettings)
local MapsModule = require(ServerModules.MapConfiguration)

local EnemySpawnDelayThreshold = 0 --Initail spawn delay.

local TempEnemyWalkSpeed = 0.16

local EnemyManager = {EnemyIndex = 0}
EnemyManager.__index = EnemyManager

--Chaches the enemy to a folder for you know what reasons.
local function CacheEnemy(Enemy: Model)
    Utilities:Print({"Caching enemy:", Enemy.Name, "to Cached enemies."})
    if EnemiesCached:FindFirstChild(Enemy.Name) == nil then
        local newCache = Enemy:Clone()
        newCache.Parent = EnemiesCached
        Utilities:Print({"Cached enemy:", Enemy.Name, "."})
    end
end

--Configures the enemy for the clients.
local function SetupEnemyServer(Enemy: Model)
    Utilities:Print("Setting up enemy for server.") -- Talk tuah.

    local Humanoid: Humanoid = Enemy:FindFirstChild("Humanoid") -- You sohuld know this idiot.

    if Humanoid then
        for _, state in Enum.HumanoidStateType:GetEnumItems() do
            if state.Name == "None" then continue end -- Checks for the "None" state has that state can not be disabled.
            Humanoid:SetStateEnabled(Enum.HumanoidStateType[state.Name], false) --Disabes every state of the humanoid for maximum performance.
        end

        for index, BasePart in pairs(Enemy:GetDescendants()) do
            if BasePart:IsA("BasePart") then
                BasePart.CollisionGroup = "Enemy" -- No way sherlock Holmes.
            end
        end
    end
end

--Spawns the enemy to the server with the corect configurations.
local function SpawnEnemiesFromWave(Wave: table, Enemies: table)
    local EnemiesInWave = {} -- Table containing all the enemies in the wave.

    for EnemyId = 1, #Enemies do
        Utilities:Print({"Creating enemy for Id:", EnemyId}) -- Talk tuah with the server.

        local Enemy = Enemies[EnemyId] -- The enemy table?

        local EnemyName = Enemy["Name"] -- The Name of the enemy.
        local EnemyCount = Enemy["Count"] -- The max number of enemies.
        local EnemyThreshold = Enemy["Threshold"] -- Threshold number.
        local EnemySettings = Enemy["Settings"] -- Forced settings for enemy NOTE: You should totally use a dynamic update system for this.

        local EnemyObject = EnemyFileFolder:FindFirstChild(EnemyName) -- The Model with the enemy.
        local EnemySpawns = MapFolder:FindFirstChildOfClass("Folder").EnemySpawns:GetChildren() --The folder containing all the enemy spawns.
        local AdjustedThreshold = math.random(1, math.clamp(EnemyThreshold, 1, math.huge)) -- This is the allow for random enemy counts.

        if not EnemyObject then Utilities:Warn({"[Error]: Failed to load enemy:", EnemyName}) continue end -- Checks if the Enemy exists, else does not spawn the enemy.
        
        for EnemySpawned = 1, math.clamp((EnemyCount - EnemyThreshold), 1, math.huge) do
            Utilities:Print({"Spawning enemy:", EnemyName, " Count:", EnemySpawned})

            local newEnemyObject = EnemyObject:Clone() -- The enemy for the game world.
            local RandomEnemySpawn = EnemySpawns[math.random(1, #EnemySpawns)] -- To allow for multiple paths or select an random path.
            local EnemyOffsetY = Utilities:GetRigOffsetY(newEnemyObject) -- Automatically gets the Y offset NOTE: This may NOT be 100% accurate with other rig types AND WILL YEILD A ERROR!
            local Humanoid = newEnemyObject:FindFirstChild("Humanoid")

            SetupEnemyServer(newEnemyObject)
            CacheEnemy(EnemyObject)

            EnemyManager["EnemyIndex"] += 1

            Humanoid:SetAttribute("EnemyIndex", EnemyManager["EnemyIndex"]) --Easy indexing for developers and clients.
            Humanoid:SetAttribute("SpawnId", RandomEnemySpawn.Name) --Where and what path the enemy should take when moving.
            Humanoid:SetAttribute("EnemyOffsetY", EnemyOffsetY.OffsetSizeY)
            Humanoid:SetAttribute("PathLink", RandomEnemySpawn:GetAttribute("PathLink"))
            Humanoid:SetAttribute("PathEnd", RandomEnemySpawn:GetAttribute("PathEnd"))

            newEnemyObject.PrimaryPart.CFrame = RandomEnemySpawn.CFrame + EnemyOffsetY.OffsetSizeY --Sets the enemies location to the spawn.
            
            task.wait(EnemySpawnDelayThreshold) -- The delay to prevent enemies from spawning in each other, Unless the client has MASSIVE yeah MASSIVE delay.

            newEnemyObject.Parent = EnemiesFolder -- Hawk tuahs the enemy into the game world.
            EnemySpawnDelayThreshold = EnemyObject.PrimaryPart.Size.X / 2 * TempEnemyWalkSpeed * 10 -- The spawn delay for the next enemy.

            print("Spawn threshold:", EnemySpawnDelayThreshold)

            table.insert(EnemiesInWave, newEnemyObject) --This system uses the correct indexing method. Dw pookie
        end
    end

    return EnemiesInWave -- Offloads the data to the RenderWaveToServer function.
end

--Creates a new wave of enemies.
function EnemyManager.RenderWaveToServer(Wave: table)
    Utilities:Print("Rendering wave to server.")

    local WaveName = Wave["Name"]
    local Enemies = Wave["Enemies"]
    local WaveSettings = Wave["Settings"]

    local EnemiesInWave = SpawnEnemiesFromWave(Wave, Enemies)

    return setmetatable({
        WaveEndedEvent = Instance.new("BindableEvent"),
        EnemiesInWave = EnemiesInWave,
    }, EnemyManager)
end

--Cleans up the wave, Despawning and other stuff. NOTE: also can be used as a skip wave function.
function EnemyManager:CleanUp()
    Utilities:Print("Cleaning up last wave.")

    local Wave = self -- The self variable but renamed.

    local EnemiesInWave = Wave["EnemiesInWave"] -- No way Sherlock Holmes
    local WaveEndedEvent = Wave["WaveEndedEvent"] -- No way Sherlock Holmes

    for EnemyIndex = 1, #EnemiesInWave do
        local Enemy = EnemiesInWave[EnemyIndex] -- The enemy?
        Enemy:Destroy() -- Deleting the enemy?
    end

    --WaveEndedEvent:Fire(true) -- Tells GameProvider.lua to Clean up the wave.
end

return EnemyManager