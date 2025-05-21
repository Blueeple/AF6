--!strict
-- Service
local _ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folder
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local Controllers = SharedFolder.Controllers

-- Modules
local PlayerFramework = require(Controllers:WaitForChild("PlayerFramework"))

-- Variables
local PlaceName = game.Name
local PlaceVersion = game.PlaceVersion

-- Remotes

-- Global functions

-- Initial
print(PlaceName .. " Version: " .. PlaceVersion)

PlayerFramework.Initialize()