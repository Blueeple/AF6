--!native
--!strict

-- Services
local HttpService = game:GetService("HttpService")
local ServerScriptService = game:GetService("ServerScriptService")

-- Folders
local Modules = ServerScriptService.Modules

-- Modules
local EZNet = require(Modules["EZ-Net"])

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
local IPRequestFailures = 0

local MaxIpRetries = 5
local IpInfoURL = "https://ipinfo.io/json"
local _DataBasePassword = "Deadfishxp64$DATABASE"
local ServerInfo = {} :: ServerInfo

-- Requests for server data info
repeat
	local success, result = pcall(function()
		local IpInfo = HttpService:GetAsync(IpInfoURL)
		local _TimezoneInfo = HttpService:GetAsync()

		return {
			IpInfo = IpInfo,
			TimezoneInfo = "",
		}
	end)

	if success and result then
		ServerInfo = HttpService:JSONDecode(result.IpInfo) :: ServerInfo
		print(ServerInfo.city, ServerInfo.country, ServerInfo.timezone, ServerInfo.org)
	else
		IPRequestFailures += 1
	end
until ServerInfo or IPRequestFailures >= MaxIpRetries
