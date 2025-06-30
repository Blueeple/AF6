-- Services
local _Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Modules = ServerScriptService.Modules
local ServerPackages = ServerScriptService.ServerPackages
local Cached = ReplicatedStorage.Cached

-- Exports

-- Modules
local _RemoteManagerServer = require(ServerPackages.RemoteManagerServer)
local _CharacterControllerServer = require(Modules.CharacterControllerServer)

-- Variables
local _CharactersLoaded = {}

local SpawnChar = ReplicatedStorage:FindFirstChild("SpawnCharacter")

SpawnChar.OnServerEvent:Connect(function(player: Player, ...: any)
	print("Spawning character for player: " .. player.Name)

	local CharMover = Cached.CharacterMover:Clone()

	CharMover.AlignPosition.Position = workspace.SpawnLocation.Position + Vector3.new(0, 1, 0)
	CharMover.Name = "_" .. game:GetService("HttpService"):GenerateGUID(false)
	CharMover.Parent = workspace.Characters

	print(...)
end)
