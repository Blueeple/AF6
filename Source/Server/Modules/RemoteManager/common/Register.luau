--!strict
-- strict
local require = require

-- Core
local ModuleSpace = script.Parent.Parent

-- Folders
local UtilsFolder = ModuleSpace:FindFirstChild("Utils")
local Shared = ModuleSpace:FindFirstChild("Shared")
local Dependencies = Shared.Dependencies

-- Objects
local ClientModule = Shared.Modules:FindFirstChild("ClientConnection")

-- Ingnore configurations
local Ignore = require(UtilsFolder.FunctionsIgnore)

-- Exported types
export type RemoteBasicOutput = {
    Type: string,
    Piority: number,
    Handler: any?,
    Dependencies: string,
    Properties: {any?}
}

-- Loads the neccecary dependencies for the event type to work, custom depndencies maybe supported at a later date.
local function LoadedDependencies(Name: string | {any}, Destination: Instance)
    if typeof(Name) == "string" then
        local Dependency = Dependencies:FindFirstChild(Name)
        if Dependency then
            Dependency.Parent = Destination -- This can be customized.
        end
    elseif typeof(Name) == "table" then
        for index, DName in Name do
            local Dependency = Dependencies:FindFirstChild(DName)
            if Dependency then
                Dependency.Parent = Destination -- This can be customized.
            end
        end
    end
end

-- Imports all the functions from the remote to the table.
local function ImportFunctions(Module: ModuleScript | {any})
    local FunctionsIndexed = {}

    for FunctionName: string, Function in Module do
        if not FunctionsIndexed[FunctionName] then
            FunctionsIndexed[FunctionName] = Function -- We dont load sub functions here.
        elseif FunctionName:match("Init") then
            FunctionsIndexed[FunctionName]()
        else
            warn("[RemoteManager] - Error importing functions.")
        end
    end

    for FunctionName, null in FunctionsIndexed do
        if table.find(Ignore, FunctionName) then
            FunctionsIndexed[FunctionName] = nil
        end
    end

    return {
        Loaded = next(FunctionsIndexed) ~= nil,
        Index = FunctionsIndexed
    }
end

-- Registers all the external remote types
return function (Folder: Folder, Tag: string, ...)
    -- self
    local self = {}

    -- Tables
    local Children = Folder:GetChildren()
    local Index = {}

    -- Engine objects
    local PingPiority0 = Instance.new("UnreliableRemoteEvent")
    local PingPiority1 = Instance.new("RemoteEvent")
    local ReplicatorSignal = Instance.new("RemoteEvent")

    -- Engine object properties
    PingPiority0.Parent = ClientModule
    PingPiority1.Parent = ClientModule
    ReplicatorSignal.Parent = ClientModule

    -- Properties Engine
    PingPiority0.Name = "PingPiority0"
    PingPiority1.Name = "PingPiority1"
    ReplicatorSignal.Name = "ReplicatorSignal"

    -- Gets all the methods involed with the modules.
    for i, Child: Instance in Children do
        if Child:HasTag(Tag) and Child:IsA("ModuleScript") then
            local Module = require(Child)
            local Info = Module["Get"]() :: RemoteBasicOutput
            local ImportedFunctions = ImportFunctions(Module)
            
            if Info and ImportedFunctions.Loaded then
                local Type = Info["Type"]
                local Dependencies = Info["Dependencies"]

                if Dependencies then
                    LoadedDependencies(Dependencies, game:GetService("ReplicatedStorage")) -- The second argument can be customized.
                end

                Index[Type] = {
                    Methods = ImportedFunctions.Index,
                    Piority = Info.Piority
                }
            else
                warn("[RemoteManager] - Can't loaded module, did you forget to add logic to the modue?")
            end
        end
    end

    ClientModule.Parent = ...

    return setmetatable({
        Index = Index,
        Replicator = ReplicatorSignal
    }, nil)-- This would be stored in memory later on.
end