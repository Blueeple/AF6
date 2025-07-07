--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local _UserSettings = UserSettings():GetService("UserGameSettings")

-- Folders
local FrameworkFolder = ReplicatedStorage:FindFirstChild("Frameworks")
local _CachedFolder = ReplicatedStorage:WaitForChild("Cached")

-- Modules
local _InputActionFramework = require(FrameworkFolder:WaitForChild("InputActionFramework"))

-- Variables
local MaxLookUpAngle = 85
local MaxLookDownAngle = -55
local _MoveMultiplier = 1.25
local _MoveDirection = Vector3.new(0, 0, 0)

local CameraX = 0
local CameraY = 0

-- Functions constuctor
return function(Camera: Camera, BindName: string): { Disconnect: () -> () }
	-- self
	local self = {}

	-- Initalize
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CFrame.new(0, 10, 0)
	Camera.FieldOfView = 85
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	RunService:BindToRenderStep(BindName, 1, function(_delta: number)
		-- Variables
		local MouseDelta = UserInputService:GetMouseDelta()

		CameraX = math.clamp(CameraX - MouseDelta.Y, MaxLookDownAngle, MaxLookUpAngle)
		CameraY = CameraY - MouseDelta.X

		local CameraRotation = CFrame.Angles(0, math.rad(CameraY), 0) * CFrame.Angles(math.rad(CameraX), 0, 0)

		Camera.CFrame = CFrame.new(0, 10, 0) * CameraRotation
	end)

	-- Methods
	--[[
		Disconnects the controller and resets the camera to default.
	]]
	function self.Disconnect()
		RunService:UnbindFromRenderStep(BindName)
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		Camera.CameraType = Enum.CameraType.Custom
	end

	print("[HumanController] - Initialized.")
	return setmetatable(self, nil)
end
