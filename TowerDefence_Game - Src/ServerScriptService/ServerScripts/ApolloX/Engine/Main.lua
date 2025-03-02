--//Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Stats = game:GetService("Stats")

--//Folders
local ApploXModules = script.Parent.Parent.Modules

--//Modules
local Utilities = require(ReplicatedStorage.SharedModules.Utility)

--//Objects
local StartedModuleBind = Instance.new("BindableEvent")

--//Variables
local StartTick = 0

--//Tables

--//AntiCheat Modules
local AntiCheatSettingsChecklist = {
    AllowMultiThreading = {"boolean", "MultiThreader", "$S"},
    LogPlayerMovement = {"boolean", "LogPlayerMovement", "true"},
    LoggedPlayerCharacterPart = {"string", "LoggedPlayerCharacterPart", "true"},
    TickRate = {"number", nil, "false"},
    MaxMemoryUsage = {"number", nil, "false"},
}

local LoadTypes = {
    ["$S"] = "DefaultConfigs"
}

--//Loaded Modules - [Modules that are loaded into the main script]
local LoadedModules = {}

--//Type exports
export type AntiCheatSettings = {
    AllowMultiThreading: boolean,
    LogPlayerMovement: boolean,
    LoggedPlayerCharacterPart: string,
    TickRate: number,
    MaxMemoryUsage: number,
}

local ApploX = {}
ApploX.__index = ApploX

local function InitializeState(Configurations: any, ...: any)
    local Executor = Utilities:DecodeFullNameToObject(...)
    local InstancesGenerated = 0
    local LoadedInstances = 0

    for ConfigName, Properties in pairs(Configurations) do
        InstancesGenerated += 1

        if AntiCheatSettingsChecklist[ConfigName] ~= nil and typeof(ConfigName) == AntiCheatSettingsChecklist[ConfigName][1] then
            Utilities:OutputLog({"Check:", tostring(ConfigName), "has been certified."})
            LoadedInstances += 1
            continue
        elseif AntiCheatSettingsChecklist[ConfigName][1] == nil then
            Utilities:OutputWarn({"Unable to apply setting:", tostring(ConfigName)})
            break
        else
            error("[ApolloX] - Fatal error.")
        end
    end

    if LoadedInstances == InstancesGenerated then
        StartedModuleBind:Fire(true)
    else
        StartedModuleBind:Fire(false)
    end
end

--//Fix this function to remove the type checking errors in studio
local function StartConfigurations(Configurations: AntiCheatSettings)
    if Configurations then
        for ConfigName, Properties in pairs(Configurations) do
            local ModuleName: string = Properties[2]
            local ModuleLoadTypeSolver: string = Properties[3]

            local RawType  = string.split(ModuleLoadTypeSolver, "/")[1]
            local RawTypeFound = LoadTypes[RawType] or nil

            if ModuleName ~= nil and RawTypeFound ~= nil then
                local ModuleToLoad = require(ApploXModules[RawTypeFound][ModuleName])
            end
        end
    end
end

function ApploX:Initialize(...)
    local Args = ...
    local Executor = debug.info(2, "s")

    local self = {}

    coroutine.wrap(InitializeState)(Args, Executor)

    StartedModuleBind.Event:Connect(function(...: boolean)
        
    end)
end

return ApploX