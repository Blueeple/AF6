--!strict
-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Frameworks = ReplicatedStorage:WaitForChild("Frameworks")

-- Modules
local MovementController = require(Frameworks.MovementController)

print("[Animate] - Script started")

-- Variables
local LocalPlayer = Players.LocalPlayer :: Player
local SignalConnection = MovementController.LinkState()

-- Function to hook a character
local function SetupCharacter(Character: Model)
	-- Variables
	local Humanoid = Character:WaitForChild("Humanoid") :: Humanoid
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart") :: Part
	local Animator = Humanoid:WaitForChild("Animator") :: Animator
	local AnimatorConnected = SignalConnection.LinkAnimator(Animator)

	MovementController.Init(Animator)

	if AnimatorConnected then
		print("[Animate] - Animator connected")
		SignalConnection.LinkCharacter(Humanoid, HumanoidRootPart)
	else
		warn("[Animate] - Animator connection failed, retrying...")
		task.wait(0.5)
		if SignalConnection.LinkAnimator(Animator) then
			SignalConnection.LinkCharacter(Humanoid, HumanoidRootPart)
		end
	end

	-- Debug (optional)
	Character.PrimaryPart = HumanoidRootPart
	HumanoidRootPart.Transparency = 0.5

	Humanoid.Died:Once(function()
		print("[Animate] - Player died")
		SignalConnection.Disconnect()
	end)
end

-- Hook current + future characters
if LocalPlayer.Character then
	SetupCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(function(Character)
	print("[Animate] - New character spawned")
	SetupCharacter(Character)
end)
