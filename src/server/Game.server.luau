--!strict
--!native

-- Services
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Folders
local Modules = ServerScriptService.Modules

-- Modules
local ModNet = require(Modules.ModNet)

-- types
type ServerInfo = {
	ip: string,
	city: string,
	region: string,
	country: string,
	org: string,
	timezone: string,
}

-- Variables

-- [[ HTTP Requests ]]
local IPRequestFailures = 0
local MaxIpRetries = 5
local IpInfoURL = "https://ipinfo.io/json"
local _DataBasePassword = "Deadfishxp64$DATABASE"
local ServerInfo = {} :: ServerInfo

--[[  ModNet-Binaries ]]
ModNet.CreatePacket("MoneyGram", true, "Quickr", { ModNet.DataType.RBXUnCompressed, ModNet.DataType.Floatu8 })
local PacketTest = ModNet.GetPacket("MoneyGram")

-- Requests for server data info
repeat
	local success, result = pcall(function()
		local IpInfo = nil

		if not RunService:IsStudio() then
			IpInfo = HttpService:GetAsync(IpInfoURL)
		else
			IpInfo = HttpService:JSONEncode({
				ip = "0.0.0.0",
				city = "Developer-City",
				region = "Developer-Region",
				country = "Developer-Country",
				org = "BlueVez-DeveloperServer",
				timezone = "America/Jamaica",
			})
		end

		return {
			IpInfo = IpInfo,
		}
	end)

	if success and result then
		ServerInfo = HttpService:JSONDecode(result.IpInfo) :: ServerInfo

		-- Variables
		--local TimezoneInfo = HttpService:GetAsync("http://worldtimeapi.org/api/timezone/" .. ServerInfo.timezone)
		--local TimezoneData = HttpService:JSONDecode(TimezoneInfo)

		print(ServerInfo.city, ServerInfo.country, ServerInfo.timezone, ServerInfo.org)
	else
		IPRequestFailures += 1
	end
until ServerInfo or IPRequestFailures >= MaxIpRetries

Players.PlayerAdded:Connect(function(Player: Player)
	PacketTest:Fire(Player, 100, 255.0)
end)
