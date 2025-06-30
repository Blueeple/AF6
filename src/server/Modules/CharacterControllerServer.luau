--Services
local HttpService = game:GetService("HttpService")
local _ServerScriptService = game:GetService("ServerScriptService")

-- Variables
local CharacterFolder = workspace:FindFirstChild("Characters")

-- Modules

-- Module
local CharacterControllerServer = {}

--[[
    Spawns a base for the character and allows for the main character replication.
]]
function CharacterControllerServer.Spawn(Player: Player)
	-- Variables
	local CharacterBase = Instance.new("Part")
	CharacterBase.Name = HttpService:GenerateGUID(false)
	CharacterBase.Parent = CharacterFolder
	CharacterBase.Size = Vector3.new(1, 7, 1)
	CharacterBase.BrickColor = BrickColor.random()
	CharacterBase:SetNetworkOwner(Player)
end

return CharacterControllerServer
