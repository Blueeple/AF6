--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local _UserSettings = UserSettings():GetService("UserGameSettings")

-- Folders
local FrameworkFolder = ReplicatedStorage.Shared:FindFirstChild("Frameworks")

-- Modules
local InputActionFramework = require(FrameworkFolder:WaitForChild("InputActionFramework"))

-- Variables
local MaxLookUpAngle = 85
local MaxLookDownAngle = -85
local MoveMultiplier = 1.25
local MoveDirection = Vector3.new(0, 0, 0)

local CameraX = 0
local CameraY = 0

return function(Camera: Camera, BindName: string)
	-- Initalize
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	UserInputService.MouseIconEnabled = false
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CFrame.new(0, 10, 0)

	RunService:BindToRenderStep(BindName, 0, function()
		-- Variables
		local MouseDelta = UserInputService:GetMouseDelta()

		local LookVector = Camera.CFrame.LookVector
		local RightVector = Camera.CFrame.RightVector

		CameraX = math.clamp(CameraX - MouseDelta.Y, MaxLookDownAngle, MaxLookUpAngle)
		CameraY = CameraY - MouseDelta.X

		local CameraRotation = CFrame.Angles(0, math.rad(CameraY), 0) * CFrame.Angles(math.rad(CameraX), 0, 0)
		local CameraMovement = (Vector3.new(0, MoveDirection.Y, 0) + (RightVector * MoveDirection.X + LookVector * MoveDirection.Z)) * MoveMultiplier

		-- Logic
		Camera.CFrame = CFrame.new(Camera.CFrame.Position + CameraMovement) * CameraRotation
	end)

	-- Variables
	local MoveForward = InputActionFramework.new("MoveForward", Enum.InputActionType.Bool, 1, "FreeCameraController")
	MoveForward.BindKeyboard(Enum.KeyCode.W)

	local MoveBackward = InputActionFramework.new("MoveBackward", Enum.InputActionType.Bool, 1, "FreeCameraController")
	MoveBackward.BindKeyboard(Enum.KeyCode.S)

	local MoveLeft = InputActionFramework.new("MoveLeft", Enum.InputActionType.Bool, 1, "FreeCameraController")
	MoveLeft.BindKeyboard(Enum.KeyCode.A)

	local MoveRight = InputActionFramework.new("MoveRight", Enum.InputActionType.Bool, 1, "FreeCameraController")
	MoveRight.BindKeyboard(Enum.KeyCode.D)

	local MoveUp = InputActionFramework.new("MoveUp", Enum.InputActionType.Bool, 1, "FreeCameraController")
	MoveUp.BindKeyboard(Enum.KeyCode.E)
	MoveUp.BindAltKeyboard(Enum.KeyCode.Space)

	local MoveDown = InputActionFramework.new("MoveDown", Enum.InputActionType.Bool, 1, "FreeCameraController")
	MoveDown.BindKeyboard(Enum.KeyCode.Q)
	MoveDown.BindAltKeyboard(Enum.KeyCode.LeftShift)

	local SlowDown = InputActionFramework.new("SlowDown", Enum.InputActionType.Bool, 1, "FreeCameraController")
	SlowDown.BindKeyboard(Enum.KeyCode.LeftControl)

	local IncreaseSpeed = InputActionFramework.new("IncreaseSpeed", Enum.InputActionType.Bool, 1, "FreeCameraController")
	IncreaseSpeed.BindKeyboard(Enum.KeyCode.Plus)
	IncreaseSpeed.BindKeyboard(Enum.KeyCode.KeypadPlus)

	local DecreaseSpeed = InputActionFramework.new("DecreaseSpeed", Enum.InputActionType.Bool, 1, "FreeCameraController")
	DecreaseSpeed.BindKeyboard(Enum.KeyCode.Minus)
	DecreaseSpeed.BindKeyboard(Enum.KeyCode.KeypadMinus)

	-- Connections
	MoveForward.OnPressed(function()
		MoveDirection += Vector3.new(0, 0, 1)
	end)

	MoveForward.OnRelease(function()
		MoveDirection -= Vector3.new(0, 0, 1)
	end)

	MoveBackward.OnPressed(function()
		MoveDirection += Vector3.new(0, 0, -1)
	end)

	MoveBackward.OnRelease(function()
		MoveDirection -= Vector3.new(0, 0, -1)
	end)

	MoveLeft.OnPressed(function()
		MoveDirection += Vector3.new(-1, 0, 0)
	end)

	MoveLeft.OnRelease(function()
		MoveDirection -= Vector3.new(-1, 0, 0)
	end)

	MoveRight.OnPressed(function()
		MoveDirection += Vector3.new(1, 0, 0)
	end)

	MoveRight.OnRelease(function()
		MoveDirection -= Vector3.new(1, 0, 0)
	end)

	MoveUp.OnPressed(function()
		MoveDirection += Vector3.new(0, 1, 0)
	end)

	MoveUp.OnRelease(function()
		MoveDirection -= Vector3.new(0, 1, 0)
	end)

	MoveDown.OnPressed(function()
		MoveDirection += Vector3.new(0, -1, 0)
	end)

	MoveDown.OnRelease(function()
		MoveDirection -= Vector3.new(0, -1, 0)
	end)

	SlowDown.OnPressed(function()
		MoveMultiplier = 0.5
	end)

	SlowDown.OnRelease(function()
		MoveMultiplier = 1.25
	end)

	IncreaseSpeed.OnPressed(function()
		MoveMultiplier += 0.25
	end)

	DecreaseSpeed.OnPressed(function()
		MoveMultiplier = math.max(0.25, MoveMultiplier - 0.25)
	end)

	print("[FreeCameraController] - Initialized.")

	return {
		Disconnect = function()
			RunService:UnbindFromRenderStep(BindName)

			UserInputService.MouseIconEnabled = true
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default

			InputActionFramework.ClearBindings("FreeCameraController")
		end,
	} :: { Disconnect: () -> () }
end
