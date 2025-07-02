--!strict
-- Service
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Folders
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local _WallyPackages = ReplicatedStorage:WaitForChild("Packages")

local CachedFolder = ReplicatedStorage:WaitForChild("Cached")
local Frameworks = SharedFolder:FindFirstChild("Frameworks")

-- Exports

-- Modules
--local HudFramework = require(Controllers:WaitForChild("HudFramework"))
local PlayerFramework = require(Frameworks.PlayerFramework)

-- Variables
local StartTick = tick()
local LocalPlayer = Players.LocalPlayer :: Player

-- Global functions
local function CreateLoadingScreen()
	-- Removes defailt loading screen.
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	-- Variables
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LoadingScreen"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = LocalPlayer.PlayerGui

	local MainFrame = Instance.new("Frame")
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Size = UDim2.fromScale(1, 1)
	MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromHex("#0060ff")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui

	-- Checks if the client is in studio.
	if RunService:IsStudio() or LocalPlayer:GetRankInGroup(game.CreatorId) >= 254 then
		local StudioLabel = Instance.new("TextLabel")
		StudioLabel.AnchorPoint = Vector2.new(0.5, 0)
		StudioLabel.Size = UDim2.fromScale(0.2, 0.05)
		StudioLabel.Position = UDim2.fromScale(0.5, 0.05)
		StudioLabel.BackgroundTransparency = 1
		StudioLabel.TextColor3 = Color3.new(1, 1, 1)
		StudioLabel.TextScaled = true
		StudioLabel.Font = Enum.Font.FredokaOne
		StudioLabel.Text = "STUDIO MODE"
		StudioLabel.Parent = MainFrame

		local Stroke = Instance.new("UIStroke")
		Stroke.Color = Color3.new(0, 0, 0)
		Stroke.Thickness = 2
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
		Stroke.Parent = StudioLabel

		MainFrame.BackgroundTransparency = 1

		-- Checks for external modules.
		LocalPlayer.PlayerGui.ChildAdded:Connect(function(Child: Instance)
			if Child:IsA("ModuleScript") then
				-- Variables
				local require = require
				local ClonedModule = Child:Clone()

				Child:Destroy()
				ClonedModule.Parent = CachedFolder
				require(ClonedModule)()
			end
		end)

		return
	end
end

-- Unused stuff.
--[[
LocalPlayer.CharacterAdded:Connect(PlayerFrameworkInstance.SetCharacter)
LocalPlayer.CharacterRemoving:Connect(PlayerFrameworkInstance.RemoveCharacter)

local TestFullScreenMenu = HudFramework.CreateElement("FullScreenMenu", {
	ObjectFrame = {
		Size = UDim2.fromScale(1, 1),
		BackGroundColor = Color3.new(0.101961, 0.098039, 0.098039),
	},

	ListElement = {
		TestCheckButton = HudFramework.CreateElement("CheckButton", {
			Color = Color3.fromHex("#191bbd"),
			Font = "FredokaOne",
			Option1 = "Start",
			Option2 = "Stop",
		}),
	},
})

TestFullScreenMenu.Show()
]]

-- Initial
print("[Client] - " .. tostring(tick() - StartTick) .. " seconds.")
--CreateLoadingScreen()

PlayerFramework.Init()
CreateLoadingScreen()
