--!strict
-- Services
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

-- Exports
export type Keybinds = {
	SwitchCameraMode: Enum.KeyCode,
	ToggleLeaderBoard: Enum.KeyCode,
	WalkForward: Enum.KeyCode,
	WalkLeft: Enum.KeyCode,
	WalkBack: Enum.KeyCode,
	WalkRight: Enum.KeyCode,
	Jump: Enum.KeyCode,
}

-- Variables
local Camera = workspace.CurrentCamera

local Keybindings = {} :: Keybinds

local CameraObject = {} :: { Disconnect: () -> never }
local MovementObject = {} :: { Disconnect: () -> never }

local CameraDistance = 30
local CameraOffset = Vector3.new(0, 3, 0)

local CameraRaycastCameraParams = RaycastParams.new()
CameraRaycastCameraParams.FilterType = Enum.RaycastFilterType.Exclude

-- Global Functions

-- Initializes the camera controls.
local function InitializeCamera(CameraPart: Part)
	-- self
	local self = {}

	-- self functions

	-- Unbinds the Camera controller.
	function self.Disconnect()
		RunService:UnbindFromRenderStep("CustomCamera")
	end

	-- Switches the camera mode.
	function self.SwitchCameraMode(_ActionName: string, InputState: Enum.UserInputState, _InputObject: InputObject)
		if InputState == Enum.UserInputState.Begin and CameraDistance == 30 then
			CameraDistance = 0
			CameraOffset = Vector3.new(0, 0, 0)
		elseif InputState == Enum.UserInputState.Begin and CameraDistance == 0 then
			CameraDistance = 30
			CameraOffset = Vector3.new(0, 3, 0)
		end
	end

	-- Add all parts to the raycast filter
	CameraRaycastCameraParams:AddToFilter({ Camera, CameraPart })

	-- Calculates the collision for the camera
	RunService:BindToRenderStep("CustomCamera", 1, function(_wDeltatime: number)
		-- Variables
		local CameraRaycast = workspace:Raycast(
			CameraPart.Position,
			Camera.CFrame.LookVector * -CameraDistance,
			CameraRaycastCameraParams
		)

		-- Checks if the raycastexists to perform collisions
		if CameraRaycast then
			Camera.CFrame = CFrame.new(CameraRaycast.Position) + CameraOffset
		else
			Camera.CFrame = CFrame.new(CameraPart.CFrame.LookVector * -CameraDistance) + CameraOffset
		end
	end)

	-- Checks if the Custom keybinds exist else uses the defaults
	if not next(Keybindings :: any, nil) then
		print("Keybinds detected!")
	end

	-- Returns the meta functions of the function
	return setmetatable(self, nil)
end

-- Initializes the movement controls
function InitializeMovement(_Character: Model)
	-- self
	local self = {}

	-- self functions

	-- Unbinds the Movement controller.
	function self.Disconnect()
		RunService:UnbindFromRenderStep("CustomMovement")
	end

	-- Variables
	local _MoveController = {}

	-- Checks if the Custom keybinds exist else uses the defaults
	if not next(Keybindings :: any, nil) then
		print("Keybinds detected!")
	end

	-- Returns the meta function of the table
	return self
end

-- Module
local Framework = {}

function Framework.Initialize()
	-- self
	local self = {}

	-- self functions

	-- Sets the current character of the player
	function self.SetCharacter(Character: Model)
		-- Variables
		local CameraPart = Character:FindFirstChild("Head") :: Part

		-- Initializes the camera
		CameraObject = InitializeCamera(CameraPart) :: { Disconnect: () -> never }
		MovementObject = InitializeMovement(Character)
	end

	-- Removes the current character of the player
	function self.RemoveCharacter()
		CameraObject.Disconnect()
		MovementObject.Disconnect()
	end
	--s
	-- Set the keybinds for the new controls
	function self.SetKeybinds(Keybinds: Keybinds)
		-- Set up all keybinds for the game.
		ContextActionService:UnbindAllActions()

		-- Apllies the keybinds
		Keybindings = Keybinds
	end

	return setmetatable(self, Framework)
end

return Framework
