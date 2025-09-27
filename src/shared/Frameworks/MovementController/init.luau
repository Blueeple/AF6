--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local _UserInputService = game:GetService("UserInputService")

-- Types
local Types = require(script.Types)

-- Modules
local InputWrapper = require(ReplicatedStorage:WaitForChild("Frameworks").InputWrapper)
local imgizmo = require(ReplicatedStorage:WaitForChild("Wally").imgizmo)

-- Variables
--[[ Roblox ]]
local _Camera = workspace.CurrentCamera :: Camera

--[[ Runtimes ]]
local CharacterRuntime = nil :: RBXScriptConnection?

--[[ Engine ]]
local LastDirection = "Unknown"
local LastState = "Unknown"

local Animations = {
	Walking = {
		Forward = 17153821474,
		Left = 16371820698,
		Right = 15901878440,
		Backward = 16238051864,
		Idle = 15886689075,
		ForwardLeft = 15901875416,
		ForwardRight = 15901860954,
		BackwardLeft = 15901872707,
		BackwardRight = 15901864797,
	},
} :: { [string]: { [string]: number } }
local WalkSpeedData = {
	Walking = {
		Forward = 18,
		ForwardLeft = 14.25,
		ForwardRight = 14.25,
		Backward = 10,
		BackwardLeft = 8,
		BackwardRight = 8,
		Left = 16,
		Right = 16,
		Idle = 0,
		TweenMultiplier = 1,
	},
	Sprinting = {
		Forward = 27,
		ForwardLeft = 24.25,
		ForwardRight = 24.25,
		Backward = 16,
		BackwardLeft = 13,
		BackwardRight = 13,
		Left = 22,
		Right = 22,
		Idle = 0,
		TweenMultiplier = 1.2,
	},
	Crouching = {
		Forward = 5,
		ForwardLeft = 4,
		ForwardRight = 4,
		Backward = 3,
		BackwardLeft = 2,
		BackwardRight = 2,
		Left = 3.5,
		Right = 3.5,
		Idle = 0,
		TweenMultiplier = 1.25,
	},
} :: { [string]: { [string]: number, TweenMultiplier: number } }

local LoadedAnimations = {} :: { [string]: { [string]: AnimationTrack } }

--[[ IAS Wrapper ]]
local CharacterContext = InputWrapper.CreateContext("Character", 1, true)

local SprintToggleBind = InputWrapper.CreateAction("SprintToggle", CharacterContext, Enum.InputActionType.Bool, {
	Gamepad = Enum.KeyCode.Thumbstick1,
	Keyboard = Enum.KeyCode.LeftShift,
})
local CrouchToggleBind = InputWrapper.CreateAction("CrouchToggle", CharacterContext, Enum.InputActionType.Bool, {
	Gamepad = Enum.KeyCode.ButtonB,
	Keyboard = Enum.KeyCode.LeftControl,
})
local CrouchToggleBind2 = InputWrapper.CreateAction("CrouchToggle1", CharacterContext, Enum.InputActionType.Bool, {
	Gamepad = Enum.KeyCode.ButtonB,
	Keyboard = Enum.KeyCode.F,
})

CrouchToggleBind2.OnPressed:Connect(function()
	print("sure")
end)

--[[ SETTINGS ]]
local ANIMATION_FADE_TIME = 0.25

--[[ STATE ]]
local CurrentAnimationTrack: AnimationTrack | nil
local CurrentWalkSpeedTween: Tween

local IS_SPRINTING = false
local IS_CROUCHING = false
local IS_JUMPING = false

-- Global function
--[[
	Construct a character viewmodel.
]]
local function _ConstructCharacterViewModel(): Types.CharacterViewModel
	return {
		Torso = Instance.new("MeshPart"),
		LeftLeg = Instance.new("MeshPart"),
		RightLeg = Instance.new("MeshPart"),
	}
end

--[[
	Convert CFrame to rotation
]]
function _CFrameToRotation(CFrame: CFrame): Vector3
	local X, Y, Z = CFrame:ToOrientation()
	return Vector3.new(math.deg(X), math.deg(Y), math.deg(Z))
end

--[[
	Loads an animation from a given ID and stores it in the LoadedAnimations table.
]]
local function LoadAnimations(Animator: Animator)
	-- Iterates through the Animations table and loads each animation
	for StateName, StateAnimations in Animations do
		LoadedAnimations[StateName] = {}

		for StateAnimationName, AnimationId in StateAnimations do
			-- Variables
			local Animation = Instance.new("Animation")

			Animation.AnimationId = "rbxassetid://" .. AnimationId
			LoadedAnimations[StateName][StateAnimationName] = Animator:LoadAnimation(Animation)
		end
	end
end

--[[
	Gets the direction name based on the X and Y values.
]]
local function GetDirectionName(DirectionX: number, DirectionY: number): string
	local DirectionName = "Unknown"

	if DirectionY >= 0.5 then
		if DirectionX <= -0.5 then
			DirectionName = "ForwardLeft"
		elseif DirectionX >= 0.5 then
			DirectionName = "ForwardRight"
		else
			DirectionName = "Forward"
		end
	elseif DirectionY <= -0.5 then
		if DirectionX <= -0.5 then
			DirectionName = "BackwardLeft"
		elseif DirectionX >= 0.5 then
			DirectionName = "BackwardRight"
		else
			DirectionName = "Backward"
		end
	else
		if DirectionX <= -0.5 then
			DirectionName = "Left"
		elseif DirectionX >= 0.5 then
			DirectionName = "Right"
		else
			DirectionName = "Idle"
		end
	end

	return DirectionName
end

--[[
	Gets the movement state of the character.
]]
local function GetMovementState(Humanoid: Humanoid): string
	if Humanoid.MoveDirection.Magnitude > 0 and not IS_SPRINTING and not IS_CROUCHING then
		return "Walking"
	elseif IS_SPRINTING then
		return "Sprinting"
	elseif IS_CROUCHING then
		return "Crouching"
	elseif IS_JUMPING then
		return "Jumping"
	else
		return "Idle"
	end
end

--[[
	Plays the animation for the given direction.
]]
local function HandlePlayerStates(Direction: string, Humanoid: Humanoid, State: string)
	if not Direction:match("Idle") and not State:match("Idle") then
		-- Checks if there is an walk direction tween.
		if CurrentWalkSpeedTween then
			CurrentWalkSpeedTween:Cancel()
			CurrentWalkSpeedTween = nil :: any
		end

		if CurrentAnimationTrack then
			CurrentAnimationTrack:Stop(ANIMATION_FADE_TIME * 3.75)

			CurrentAnimationTrack = nil :: any
		end

		-- Variables
		local MoveSpeedData = WalkSpeedData[State]
		local AnimationTrack = LoadedAnimations[State][Direction]
		local CurrentWalkSpeed = MoveSpeedData[Direction] :: number
		local TweenSpeed = (CurrentWalkSpeed * 0.0425) * MoveSpeedData.TweenMultiplier

		CurrentWalkSpeedTween = TweenService:Create(Humanoid, TweenInfo.new(TweenSpeed, Enum.EasingStyle.Quad), { WalkSpeed = CurrentWalkSpeed })
		CurrentAnimationTrack = AnimationTrack :: AnimationTrack

		if CurrentAnimationTrack then
			CurrentAnimationTrack.Priority = Enum.AnimationPriority.Movement
			CurrentAnimationTrack:Play(TweenSpeed / 3, 1, TweenSpeed)
		end

		CurrentWalkSpeedTween:Play()
	end
end

--[[
	Calculates the characters movement direction for omni-movement.
]]
local function CalculateMoveDirection(Humanoid: Humanoid, HumanoidRootPart: Part): Types.MovementDirectionInfo
	-- Variables
	local ForwardDirection = HumanoidRootPart.CFrame.LookVector
	local RightDirection = HumanoidRootPart.CFrame.RightVector

	local MoveDirection = ForwardDirection * Humanoid.MoveDirection.Z + RightDirection * Humanoid.MoveDirection.X

	local DirectionX = math.clamp(MoveDirection.X, -1, 1)
	local DirectionY = math.clamp(MoveDirection.Z, -1, 1)

	return {
		Direction = Vector2.new(math.round(DirectionX), math.round(DirectionY)),
		DirectionRaw = MoveDirection,
		DirectionName = GetDirectionName(DirectionX, DirectionY),
	}
end

-- Modules
local MovementController = {}

--[[
	Initializes the MovementController module.
]]
function MovementController.Init(Animator: Animator)
	LoadAnimations(Animator)
end

--[[
	Connects the MovementController module to the main module.
]]
function MovementController.LinkState()
	print("[MovementController] - Connected to animate link state")

	-- Variables
	local self = {}

	-- Methods
	--[[
		Links the animator to the main module.
	]]
	self.LinkAnimator = function(Animator: Animator): boolean
		if Animator then
			print("[MovementController] - Animator linked")
			return true
		else
			warn("[MovementController] - No animator found")
			return false
		end
	end

	--[[
		Links the Humanoid and RootPart for animation direction.
	]]
	self.LinkCharacter = function(Humanoid: Humanoid, HumanoidRootPart: Part)
		if Humanoid and HumanoidRootPart then
			print("[MovementController] - Humanoid and RootPart linked")

			-- Variables
			local RootAttachment = HumanoidRootPart:WaitForChild("RootAttachment") :: Attachment
			RootAttachment.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(90), 0)

			Humanoid.WalkSpeed = 0

			-- Add the roblox state handler here.

			-- toggles the sprinting and crouching states
			SprintToggleBind.OnPressed:Connect(function()
				if Humanoid.MoveDirection.Magnitude > 0 then
					IS_SPRINTING = true
					IS_CROUCHING = false
				end
			end)

			SprintToggleBind.OnRelease:Connect(function()
				IS_SPRINTING = false
			end)

			CrouchToggleBind.OnPressed:Connect(function()
				IS_CROUCHING = true
				IS_SPRINTING = false
			end)

			CrouchToggleBind.OnRelease:Connect(function()
				IS_CROUCHING = false
			end)

			-- Connects to the character runtime.
			CharacterRuntime = RunService.RenderStepped:Connect(function()
				-- Variables
				local MoveDirection = CalculateMoveDirection(Humanoid, HumanoidRootPart)
				local MovementState = GetMovementState(Humanoid)

				if MovementState ~= LastState or MoveDirection.DirectionName ~= LastDirection then
					HandlePlayerStates(MoveDirection.DirectionName, Humanoid, MovementState)
				elseif CurrentWalkSpeedTween and CurrentAnimationTrack and Humanoid.MoveDirection.Magnitude == 0 and MovementState:match("Idle") then
					CurrentWalkSpeedTween = TweenService:Create(Humanoid, TweenInfo.new(0.125, Enum.EasingStyle.Quad), { WalkSpeed = 0 })

					CurrentWalkSpeedTween:Play()

					CurrentWalkSpeedTween = nil :: any

					if CurrentAnimationTrack then
						CurrentAnimationTrack:Stop(ANIMATION_FADE_TIME)
						CurrentAnimationTrack = nil :: any
					end
				end

				LastState = MovementState
				LastDirection = MoveDirection.DirectionName

				-- Gizmo Drawing
				imgizmo.PushProperty("Color3", Color3.new(0, 1, 0))
				imgizmo.Box:Draw(HumanoidRootPart.CFrame - Vector3.new(0, 2.25, 0), Vector3.new(2.5, 1.75, 2), false)
			end)
		end
	end

	--[[
		Disconnects the character framework from the animations script.
	]]
	self.Disconnect = function()
		print("[MovementController] - Disconnected")

		if CharacterRuntime then
			CharacterRuntime:Disconnect()
			CharacterRuntime = nil
		end
	end

	return self
end

return MovementController
