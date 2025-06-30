--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local FrameworkFolder = ReplicatedStorage.Shared:FindFirstChild("Frameworks")
local BaseControllers = script:FindFirstChild("BaseControllers")

-- Types
export type CameraControllers = {
	HumanController: (Head: BasePart, Camera: Camera) -> { any },
}

-- Modules
local InputActionFramework = require(script.Parent.InputActionFramework)
local _InputActionFramework = require(FrameworkFolder:WaitForChild("InputActionFramework"))

-- Variables
local StatTick = tick()
local LocalPLayer = Players.LocalPlayer :: Player
local Camera: Camera
local RenderStepBindName = "CustomControllers"
local MoveControllerMode = {} :: { Disconnect: () -> () }
local _CameraMode = {}

-- Global functions
local function YeildUntilReady()
	-- Variables
	local Success: boolean

	repeat
		Success = pcall(function()
			-- Variables
			local PlayerScriptsLoader = LocalPLayer.PlayerScripts:FindFirstChild("PlayerScriptsLoader") :: LocalScript
			Camera = workspace.CurrentCamera :: Camera

			if Camera and PlayerScriptsLoader then
				PlayerScriptsLoader.Enabled = false
			end

			task.wait()
		end)

	until Success
end

-- Module contructor
local PlayerFramework = {}

function PlayerFramework.Init()
	-- self
	local self = {}

	-- Variables
	local SwitchToHumanController = InputActionFramework.new("SwitchToHumanController", Enum.InputActionType.Bool, 1)
	SwitchToHumanController.BindKeyboard(Enum.KeyCode.V)

	-- Initialize
	YeildUntilReady()
	MoveControllerMode = require(BaseControllers.FreeCameraController)(Camera, RenderStepBindName)

	-- Connections
	SwitchToHumanController.OnPressed(function()
		MoveControllerMode.Disconnect()
		MoveControllerMode =
			require(BaseControllers.HumanController)(Camera, RenderStepBindName) :: { Disconnect: () -> () }
	end)

	print("[PlayerFramework] - " .. tostring(tick() - StatTick) .. " seconds.")

	return self
end

return PlayerFramework
