-- Services
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
--local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Modules = ServerScriptService.Modules
local _ServerPackages = ServerScriptService.ServerPackages
local DeveloperModules = ServerScriptService.DeveloperModules

-- Exports

-- Modules
local RemoteManagerServer = require(ServerScriptService.Modules.RemoteManagerServer).Init()
local CharacterControllerServer = require(Modules.CharacterControllerServer)

-- Variables
local CharactersLoaded = {}

Players.PlayerAdded:Connect(function(Player: Player)
	if not CharactersLoaded[Player.UserId] then
		CharacterControllerServer.Spawn(Player)
	end

	if Player:GetRankInGroup(game.CreatorId) >= 254 then
		-- Load the Iris Debugger for developers.
		local IrisDebugger = DeveloperModules.IrisDebugger

		IrisDebugger.Parent = Player.PlayerGui
	end
end)

Players.PlayerRemoving:Connect(function(Player: Player)
	CharactersLoaded[Player.UserId] = nil
end)

local Test = RemoteManagerServer.new("Test", true)

Test.OnEvent(function(Player: Player, Args: any)
	print("Hello")
end)

Test.OnEvent(function(Player: Player, Args: any)
	print("World!")
end)
