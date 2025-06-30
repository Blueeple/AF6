--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local StartTick = tick()
local LocalPlayer = Players.LocalPlayer :: Player

-- Return module contructor
return function()
	-- self
	local self = { Remotes = {} }

	-- Variables
	local NetworkConfigReciever = ReplicatedStorage:WaitForChild("NetworkConfigReciever") :: RemoteEvent

	if NetworkConfigReciever then
		NetworkConfigReciever.OnClientEvent:Connect(function(RemoteInformation: { any })
			self.Remotes = RemoteInformation
			--print(RemoteInformation)
		end)

		NetworkConfigReciever:FireServer()

		print("[RemoteManager V3][Client] - " .. tostring(tick() - StartTick) .. " seconds.")
		return self.Remotes
	else
		warn("NetworkConfigReciever not found.")
		LocalPlayer:Kick("Networker failed to load.")
		return {}
	end
end
