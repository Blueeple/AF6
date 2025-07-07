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
local EZ_NetServer = require(ServerScriptService.Modules["EZ-NetServer"])
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

local Test = EZ_NetServer.new("StringRemoteTest", true, {
	"table",
})

Test.OnPacket(function(Player: Player, Args: any)
	print(Player, Args)
end)

Test.FirePacket(Players:WaitForChild("Blueeple"), "Test")