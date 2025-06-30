--!strict
-- Service
local _ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local _ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _RunService = game:GetService("RunService")

-- Folders
local SharedFolder = ReplicatedStorage:WaitForChild("Shared")
local _WallyPackages = ReplicatedStorage:WaitForChild("Packages")
local CustomPackages = ReplicatedStorage:WaitForChild("CustomPackages")

local Frameworks = SharedFolder:FindFirstChild("Frameworks")

-- Exports
export type Networkers = {
	RequestUserData: { Fire: (Data: any) -> never, Connect: () -> any },
}

-- Modules
--local HudFramework = require(Controllers:WaitForChild("HudFramework"))
local _RemoteManagerClient = require(CustomPackages.RemoteManagerClient)() :: Networkers
local PlayerFramework = require(Frameworks.PlayerFramework)

-- Variables
local StartTick = tick()
local _TempVariables = {}
local LocalPlayer = Players.LocalPlayer :: Player

-- the character sheet is sum like this (Only does this for optimizatin perposes.)
local _CharacterIdSheet = {
	[0] = {
		Name = "Velixie",
		Skins = {
			[0] = "Default",
		},
	},
}

local _UserGameData = {
	Character = {
		Name = 0,
		SkinId = 0,
	},
}

-- Remotes

-- Global functions
local function _CreateLoadingScreen()
	-- Removes defailt loading screen.
	ReplicatedFirst:RemoveDefaultLoadingScreen()

	-- Variables
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LoadingScreen"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = LocalPlayer.PlayerGui

	-- Main frame
	local MainFrame = Instance.new("Frame")
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Size = UDim2.fromScale(1, 1)
	MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromHex("#0060ff")
	MainFrame.Name = "MainFrame"
	MainFrame.Parent = ScreenGui

	print("Waiting on game data.")

	-- Network listeners Connections
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
