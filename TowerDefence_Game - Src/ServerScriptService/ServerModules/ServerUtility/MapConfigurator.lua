local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")

local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local Utilities = require(SharedModules.Utility)

local MapModule = {}
MapModule.__index = MapModule

local function SafeCheckMap(Map)
    for Index, MapFile in ipairs(Map:GetDescendants()) do
        if MapFile.ClassName:match("Script") == true then
            MapFile:Destroy()
            Utilities:Warn("[Error]: Map named: " .. Map.Name .. " has a potential virus destroyed.")
        end
    end
end

local function SearchMap(SearchParams : table)
    local WhitelistedMaps = {}
    local BlacklistedMaps = {}

    for ParamName, Setting in SearchParams do
        if Setting == true then
            local MapsWithTag = CollectionService:GetTagged(tostring(ParamName))

            for index, MapName in pairs(MapsWithTag) do
                table.insert(WhitelistedMaps, MapName)
            end

            Utilities:Print("Tag: " .. tostring(ParamName) .. " is whitelisted, with a total count of: " .. #MapsWithTag .. " maps.")
        else
            local MapsWithTag = CollectionService:GetTagged(tostring(ParamName))

            for index, MapName in pairs(MapsWithTag) do
                table.insert(BlacklistedMaps, MapName)
            end

            if #MapsWithTag > 0 then
                Utilities:Warn("Tag: " .. tostring(ParamName) .. " is blacklisted, with a total count of: " .. #MapsWithTag .. " maps.")
            end
        end
    end

    return {
        Whitelist = WhitelistedMaps,
        Blacklist = BlacklistedMaps
    }
end

function MapModule:ScanForMaps(Configurations : table, MapFolder: Folder)
    local MapData = {}
    local SearchParams = {}

    Utilities:Print("Beggining map scanning.")

    for Index, Map in pairs(MapFolder:GetChildren()) do
        if Map:IsA("Folder") then
            SafeCheckMap(Map)
        end
    end

    for TagName, Setting in pairs(Configurations["Tags_Options"]) do
        local TagName = TagName:sub(1, #TagName - 7)
        SearchParams[TagName] = Setting
    end

    MapData = SearchMap(SearchParams)

   return MapData
end

return MapModule
