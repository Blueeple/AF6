-- Fuckass exploiter why are you reviewing this unused module?
--!strict
-- Common
local _Bin = script:FindFirstChild("Bin") :: Folder
local Elements = script.Elements:GetChildren()

-- Variables
local LocalPlayer = game:GetService("Players").LocalPlayer :: Player

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HudFramework-Gui"
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

-- functions
local function SearchForElement(Name: string)
	local Element: ModuleScript

	for i = 1, #Elements do
		if Elements[i].Name == Name then
			Element = Elements[i] :: ModuleScript
			break
		end
	end

	return Element :: ModuleScript
end

-- Framework
local Framework = {}
-- self functions
--[[
    Creates a new custom gui class
]]
function Framework.CreateElement(ElementType: string, Properties: any)
	-- Assertions
	assert(SearchForElement(ElementType), "Attempt to index: " .. ElementType .. ".")

	-- self
	local self = {}

	-- Variables
	local require = require
	local UniqueId = game:GetService("HttpService"):GenerateGUID(false)
	local Element = SearchForElement(ElementType) :: ModuleScript

	-- Object
	local ElementManifest = require(Element)(UniqueId, Properties) :: GuiObject

	-- self functions
	--[[
        Hides the element
    ]]
	function self.Hide()
		ElementManifest.Visible = false
	end

	--[[
        Shows the element
    ]]
	function self.Show()
		ElementManifest.Visible = true
	end

	--[[
        Deletes the element
    ]]
	function self.Delete()
		ElementManifest:Destroy()
	end

	return setmetatable(self, Framework)
end

--[[
    Recalibrates element sizing for proper viewing
]]
function Framework.RecalibrateSizing(ScreenSize: Vector2)
	print(ScreenSize) -- Does nothing for now. (I don't have the formula)
end

return Framework
