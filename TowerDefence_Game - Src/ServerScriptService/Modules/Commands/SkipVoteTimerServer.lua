local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModules = ServerScriptService:FindFirstChild("Modules")
local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local SkipEvent = ServerModules.Hooks:FindFirstChild("Skip")

local Utilities = require(SharedModules.Utility)

return function (context, MapName)
    Utilities:Print("Skipping timer.")
    SkipEvent:Fire(MapName)
end