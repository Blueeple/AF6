local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Signal = Instance.new("BindableEvent")

local PlayerGui = Players.LocalPlayer.PlayerGui

local MobileKeyboardTransulationEnabled = nil
local MobileScreenGui = nil

local ButtonScaling = nil
local ButtonPositioning = nil

local DynamicPropertiesMobile = {
	Position = true,
	Size = true,
	Visible = true
}

local EasyKeyMappings = {
	M1 = Enum.KeyCode.MouseLeftButton
}

local KeyboardTransulator = {}
KeyboardTransulator.__index = KeyboardTransulator
KeyboardTransulator.Binds = {}

--Creates a new mobile button input by compiling the the button compentents from a table.
local function CreateMobileButton(KeyName: string, Template: Instance)
	local GuiFolder = Template:FindFirstChild("Gui") or nil
	local ConfigFolder = Template:FindFirstChild("Config") or nil

	local GuiMain:GuiObject = GuiFolder:FindFirstChild("Main")
	local ConfigModule = require(ConfigFolder:FindFirstChildOfClass("ModuleScript"))

	local Default = nil

	if GuiFolder ~= nil and ConfigFolder ~= nil then
		Default = GuiMain:Clone()
		ConfigModule:Apply(Default)
		ConfigModule:Idle(Default)
	else
		error("Failed to create mobile button, Did you forget to implement the correct directories?", 1)
	end

	return {Button = Default, Settings = ConfigModule}
end

--Add mouse input detection and the missing controller input detection (Triggers and joysticks) Also make it so it stops mobile inputs when roblox menu opens.
local function InputSignal(KeyName: string, ...: {Keyboard: Enum.KeyCode, Console: Enum.KeyCode, MobileButton: ImageButton, MobileModule: ModuleScript})
	local args = ...

	local MobileButton = args["MobileButton"]
	local MobileModule = args["MobileModule"]

	UserInputService.InputBegan:Connect(function(Input: InputObject, AllowInputPassThrough: boolean)
		if Input.KeyCode == Enum.KeyCode[args["Keyboard"]] or Input.KeyCode == Enum.KeyCode[args["Console"]] and not AllowInputPassThrough then
			Signal:Fire(KeyName)
		end
	end)
	
	if MobileButton ~= nil then
		MobileButton.InputBegan:Connect(function(Input: InputObject)
			if Input.UserInputType == Enum.UserInputType.Touch and Input.UserInputState == Enum.UserInputState.Begin and GuiService.TouchControlsEnabled == true then
				MobileModule:Active(MobileButton)
				Signal:Fire(KeyName)
			end
		end)

		MobileButton.InputEnded:Connect(function(Input: InputObject)
			MobileModule:Idle(MobileButton)
		end)
	end
end

function KeyboardTransulator:InitializeMobileDetection(...: boolean)
	if UserInputService.TouchEnabled == true and ... == true then
		local MobileTouchFrame = PlayerGui:WaitForChild("TouchGui")
		local CustomMobileFrame = Instance.new("Frame")

		local JumpButton = MobileTouchFrame:WaitForChild("TouchControlFrame").JumpButton
		ButtonScaling = JumpButton.Size
		ButtonPositioning = JumpButton.Position
		
		if ... == true then
			MobileKeyboardTransulationEnabled = true
		end

		CustomMobileFrame.Name = "CustomTouchFrame"
		CustomMobileFrame.Size = UDim2.fromScale(1, 1)
		CustomMobileFrame.LayoutOrder = 1 
		CustomMobileFrame.Active = false
		CustomMobileFrame.Interactable = true
		CustomMobileFrame.BackgroundTransparency = 1
		CustomMobileFrame.Visible = true
		CustomMobileFrame.Parent = MobileTouchFrame

		MobileScreenGui = CustomMobileFrame

		JumpButton.Changed:Connect(function(Property)
			if DynamicPropertiesMobile[Property] ~= nil then
				MobileScreenGui.Visible = JumpButton.Visible
			end
		end)
	else
		return
	end
end

function KeyboardTransulator.new(KeyName: string, ...: {MappedInputKey: Enum.KeyCode, ConsoleKeyMapping: Enum.KeyCode, MobileTemplate: Folder})
	local args = ...
	local Self = {}

	local MobileTemplate = args["MobileTemplate"]
	local ActivatedBind = Instance.new("BindableEvent")
	local ProcessedKeyName = nil
	local MobileButton = nil
	
	if MobileKeyboardTransulationEnabled == true then
		MobileButton = CreateMobileButton(KeyName, MobileTemplate)
		MobileButton["Button"].Parent = MobileScreenGui
	end

	if KeyboardTransulator.Binds[KeyName] == nil then
		ProcessedKeyName = KeyName
		KeyboardTransulator.Binds[ProcessedKeyName] = Self
	else
		warn("[InputTransulator]: Binding: " .. KeyName .. " already exists, using new bind: " .. KeyName .. 1 .. ".")
		ProcessedKeyName = KeyName .. 1
		KeyboardTransulator.Binds[ProcessedKeyName] = Self
	end

	Self.Button = MobileButton
	Self.Activated = ActivatedBind.Event
	Self.InputTriggerBind = ActivatedBind

	local NewInput = InputSignal(ProcessedKeyName, {
		Keyboard = args["MappedInputKey"],
		Console = args["ConsoleKeyMapping"],
		MobileButton = if MobileButton then MobileButton.Button else nil,
		MobileModule = if MobileButton then MobileButton.Settings else nil
	})

	Signal.Event:Connect(function(KeyNameTriggered: string)
		if KeyNameTriggered == ProcessedKeyName then
			ActivatedBind:Fire({
				KeyboardKey = args["MappedInputKey"],
				ConsoleKey = args["ConsoleKeyMapping"],
				MobileButton = if MobileButton then MobileButton else nil
			})
		end
	end)

	return setmetatable(Self, KeyboardTransulator)
end

return KeyboardTransulator