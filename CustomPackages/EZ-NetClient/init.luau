--!strict
-- Services
local _ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Exported types
export type Remote = {
	OnPacket: (Callack: () -> any) -> any,
	FirePacket: (Args: any) -> any,
}

-- Variables
local StartTick = tick()
local _LocalPlayer = Players.LocalPlayer :: Player

-- Return module contructor
local EZNet = {
	Index = {} :: { [string]: (Args: any) -> any },
	Queue = {},
}

function EZNet.get(Name: string): Remote
	-- self
	local Contianer = {}

	-- Variables
	Contianer.Connected = false

	-- Methods
	--[=[
        Connects an callback function to the event.

        @param Callback: function
    ]=]
	function Contianer.OnPacket(Callback: (Args: any) -> any)
		-- Assertions
		if Contianer.Connected then
			error("Failed to connect a new function to remote: " .. Name .. ", disconnect the old one.")
		end

		EZNet.Index[Name] = Callback
		Contianer.Connected = true :: any?
	end

	return setmetatable(Contianer, EZNet) :: Remote
end

print("[EZ-Net][Client]: Loaded in " .. tostring(tick() - StartTick) .. " seconds.")

return EZNet
