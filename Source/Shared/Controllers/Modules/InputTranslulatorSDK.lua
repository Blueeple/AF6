--//Services
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

--//Shared folders
local SharedModules = ReplicatedStorage:WaitForChild("SharedModules")

--Local player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui

--//Client modules
local Utilities = require(SharedModules.Utility)

--//Binable Events
local KeySend = Instance.new("BindableEvent")

--//Variables
local ModuleStartTime = tick()

--//Tables
local GamepadTypes = {
	Gamepad1 = true,
	Gamepad2 = true,
	Gamepad3 = true,
	Gamepad4 = true,
	Gamepad5 = true,
	Gamepad6 = true,
	Gamepad7 = true,
	Gamepad8 = true,
}

--//Object Oriented App
local KeyboardTransulator = {Binds = {}}
KeyboardTransulator.__index = KeyboardTransulator

--//Checks if the module is running on a device with a touch screen.
if UserInputService.TouchEnabled then
	local TouchGui = PlayerGui:WaitForChild("TouchGui")
	local TouchControlFrame = TouchGui.TouchControlFrame
	local JumpButton = TouchControlFrame:FindFirstChildOfClass("ImageButton")

	local CustomControlFrame = Instance.new("Frame", TouchGui)

	CustomControlFrame.Size = UDim2.fromScale(1, 1)
	CustomControlFrame.Position = UDim2.fromScale(0, 0)
	CustomControlFrame.BackgroundTransparency = 1
	CustomControlFrame.Interactable = true

	JumpButton.Changed:Connect(function(Property: any)
		if Property == "Visible" then
			CustomControlFrame.Visible = JumpButton.Visible
		end
	end)

	Utilities:OutputLog("Mobile controls initialied.")
end

UserInputService.InputBegan:Connect(function(Input: InputObject, PassThroughEnabled: boolean)
	KeySend:Fire(Input.UserInputType.Name, Input.KeyCode, PassThroughEnabled)
end)

local function CompileToButton()
	
end

--//Return all the binds and thieir properties.
function KeyboardTransulator:GetBind(Argument: string)
	assert(typeof(Argument) == "string", "Did you forget to arg 1? ($All / [BindName])")


end

--//Creates a new Input bind that can emulate a keyboard bind with ease.
function KeyboardTransulator.new(Name: string, Arguments: {PassThroughEnabled: boolean, Enabled: boolean}, ...: {Keyboard: {Major: Enum.KeyCode, Alt: Enum.KeyCode, EnmulateMouse: Enum.UserInputType}, Mobile: {Template: ModuleScript, Properties: {any}}, Console: {Major: Enum.KeyCode, Alt: Enum.KeyCode}})
	--//Variables
	local Args = ...
	local BindName = Name

	local BindArguments = Arguments

	local KeyboardData = Args.Keyboard
	local MobileData = Args.Mobile
	local ConsoleData = Args.Console

	local BypassEnabled = BindArguments.PassThroughEnabled
	local KeyEnabled = BindArguments.Enabled

	local BindSender = Instance.new("BindableEvent")

	local self = {}

	--//Creation checks
	if KeyboardTransulator.Binds[Name] == nil then
		KeyboardTransulator.Binds[Name] = {
			InputData = self.Bindings,
			InputArguments = self.Arguments,
			ActivatedContext = self.Activated,
		}
	else
		Utilities:OutputWarn({"Failed to create bind of Name:", Name , " as another bind has the same name."})
		return setmetatable({}, KeyboardTransulator)
	end

	--//Self bindings
	self.Bindings = {
		Keyboard = {
			MajorBind = KeyboardData.Major,
			AltBind = KeyboardData.Alt,
			EmulateMouse = KeyboardData.EnmulateMouse,
		},
		Touch = {
			MajorBind = "Button",
			TemplateData = MobileData.Template,
			Properties = MobileData.Properties,
		},
		Gamepad = {
			MajorBind = ConsoleData.Major,
			Alt = ConsoleData.Alt,
			AuctuationPoint = 0, --PlaceHolder input type.
		},
	}
	self.Arguments= {
		PassThroughEnabled = BypassEnabled,
	}
	self.Activated = BindSender.Event

	--//Appplications
	MobileData.MajorBind = self.Bindings.Touch.MajorBind

	--//Self functions
	function self:SetSetting(SettingToChange: any, Variable: any)
		assert(typeof(SettingToChange) == "string", "Failed to apply setting " .. tostring(SettingToChange) .. " invalid type.")
		assert(SettingToChange ~= nil, "A variable must be mentioned.")
	
	if self[SettingToChange] ~= nil then
		SettingToChange = Variable
		Utilities:OutputLog("Applied setting.")
	else
		Utilities:OutputWarn("Setting", tostring(SettingToChange) ,"doesn't exist")
		return nil
	end

		print(self)
	end

	function self:Remove()
		BindSender:Destroy()
		self = nil

		Utilities:OutputLog({"Removed Key bind:", BindName})

		return nil
	end

	--//Checks if the KeySend event has been triggered
	KeySend.Event:Connect(function(InputType, InputCode, PassThroughEnabled)
		if InputType == Enum.UserInputType.Keyboard.Name and InputCode == KeyboardData.Major or InputCode == KeyboardData.Alt and PassThroughEnabled == BypassEnabled and KeyEnabled then
			BindSender:Fire(BindName, Args)
		elseif InputType == Enum.UserInputType.Touch.Name and MobileData.MajorBind.GuiState == Enum.GuiState.Press and PassThroughEnabled == BypassEnabled and KeyEnabled then
			BindSender:Fire(BindName, Args)
		elseif GamepadTypes[InputType] == true and InputCode == ConsoleData.Major or InputCode == ConsoleData.Alt and PassThroughEnabled == BypassEnabled and KeyEnabled then
			BindSender:Fire(BindName, Args)
		elseif KeyboardData.EnmulateMouse ~= nil and InputType == KeyboardData.EnmulateMouse.Name and PassThroughEnabled == BypassEnabled and KeyEnabled then
			BindSender:Fire(BindName, Args)
		end
	end)

	return setmetatable(self, KeyboardTransulator)
end

Utilities:OutputLog({"Initialized transulator in:", tick() - ModuleStartTime})

return KeyboardTransulator