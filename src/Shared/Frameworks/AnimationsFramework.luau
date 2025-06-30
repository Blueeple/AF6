--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local CachedFolder = ReplicatedStorage:WaitForChild("Cached")

-- Exported types
export type PlayerAnimations = { [string]: AnimationTrack }

-- Module constructor
local AnimationsFramework = {}

function AnimationsFramework.InitPlayerAnimator()
	-- self
	local self = {}

	-- Variables
	local PlayerAnimations = {} :: PlayerAnimations
	local LocalPlayer = Players.LocalPlayer :: Player
	local Animator: Animator
	local IsRunning = false

	LocalPlayer.CharacterAdded:Connect(function(Character: Model)
		warn("new player")

		-- Variables
		local RobloxAnimationsScript = Character:WaitForChild("Animate") :: Script
		local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid

		-- Initialize
		Animator = Humanoid:WaitForChild("Animator") :: Animator
		RobloxAnimationsScript:Destroy()

		-- Connections
		Humanoid.StateChanged:Connect(
			function(_OldStateType: Enum.HumanoidStateType, _NewStateType: Enum.HumanoidStateType)
				local CurrentAnimation = Animator:GetPlayingAnimationTracks()

				print(CurrentAnimation)
			end
		)

		Humanoid.Running:Connect(function(Speed: number)
			if Speed > 0 and IsRunning == false and next(PlayerAnimations, nil) then
				Animator:GetPlayingAnimationTracks()[1]:Stop(0.3)

				IsRunning = true
				PlayerAnimations["Running"]:Play(0.3, Speed, Speed * 0.15)
			elseif Speed == 0 and next(PlayerAnimations, nil) then
				IsRunning = false
				PlayerAnimations["Running"]:Stop(0.125)
				PlayerAnimations["Idle" .. math.random(1, 3)]:Play(0.2, 1, 1)
			end
		end)
	end)

	-- Methods
	--[[
        Sets the new animations that the player rig should use.
        @param Animations: table - A table containing the new animations.
    ]]
	function self.SetAnimations(Animations: { [string]: string })
		assert(type(Animations) == "table", "Animations must be a table.")

		local TempAnimationsFolder = CachedFolder:FindFirstChild("RigAnimations" .. LocalPlayer.Name)

		if TempAnimationsFolder then
			TempAnimationsFolder:Destroy()
		end

		-- Variables
		local RigAnimations = Instance.new("Folder")
		RigAnimations.Name = "RigAnimations_" .. LocalPlayer.Name
		RigAnimations.Parent = CachedFolder

		for Name, AnimationId in Animations do
			local Animation = Instance.new("Animation")
			Animation.Name = Name
			Animation.AnimationId = AnimationId
			Animation.Parent = RigAnimations

			PlayerAnimations[Name] = Animator:LoadAnimation(Animation) :: AnimationTrack
		end
	end

	return setmetatable(self, AnimationsFramework)
end

return AnimationsFramework
