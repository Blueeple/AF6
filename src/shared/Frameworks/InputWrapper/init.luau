--!strict
-- Services
local ContextActionService = game:GetService("ContextActionService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Frameworks = ReplicatedStorage:WaitForChild("Frameworks")
local Contexts = script:FindFirstChild("Contexts") :: Folder

-- Modules
local GoodSignal = require(Frameworks:WaitForChild("GoodSignal"))

-- [[ Roblox ]]
local Camera = workspace.CurrentCamera :: Camera
local LocalPlayer = Players.LocalPlayer :: Player
local PlayerGui = LocalPlayer.PlayerGui

-- [[ Wrapper ]]
local InputWrapperGui: ScreenGui
local ScreenSizeMultiplier = Camera.ViewportSize.Y / Camera.ViewportSize.X * 1.7

-- [[ CAS Redesign Detection ]]
local IASDetection = Instance.new("InputAction")
IASDetection.Type = Enum.InputActionType.Bool
IASDetection.Parent = script
local IASEnabled = pcall(function()
	IASDetection:Fire(true)
	IASDetection:Destroy()
end)

--[[ Settings ]]
local EMULATORENBALED = false

local Wrapper = {}
Wrapper.StateEngine = {
	IsMenuOpened = GuiService.MenuIsOpen,
}

-- State engine events
GuiService.MenuOpened:Connect(function()
	Wrapper.StateEngine.IsMenuOpened = true
end)

GuiService.MenuClosed:Connect(function()
	Wrapper.StateEngine.IsMenuOpened = false
end)

-- Notices
if EMULATORENBALED and not IASEnabled then
	warn("[InputWrapper] - No CAS redesign detected, IAS Emulator lauched")
else
	print("[InputWrapper] - CAS redesign detected")
end

--[=[
    Creates a context for input action service

    @param Name: string
    @param Piority: number
    @param Sink: boolean
]=]
function Wrapper.CreateContext(Name: string, Piority: number, Sink: boolean)
	-- self
	local self = {}

	-- Variables
	local Context = Instance.new("InputContext")
	Context.Name = Name
	Context.Parent = Contexts
	Context.Priority = Piority or table.maxn(Context)
	Context.Sink = Sink or true

	-- Self params
	self.Context = Context

	-- Self methods
	function self.SetEnabled(...: boolean?)
		Context.Enabled = ... or not Context.Sink
	end

	return setmetatable(self, Wrapper) :: { Context: InputContext }
end

--[=[
    Creates a new button for input.Axes

    @param Name: string
]=]
function Wrapper.CreateButton(Name: string, ImageId: number, Size: number, PositionX: number, PositionY: number): ImageButton
	-- Checks if the button screen gui exists
	if not InputWrapperGui then
		InputWrapperGui = Instance.new("ScreenGui") :: ScreenGui
		InputWrapperGui.Name = "InputWrapperMobile"
		InputWrapperGui.Parent = PlayerGui
	end

	-- Variables
	local GuiButton = Instance.new("ImageButton")
	GuiButton.Name = Name
	GuiButton.AnchorPoint = Vector2.one / 2
	GuiButton.Size = UDim2.fromScale(Size * ScreenSizeMultiplier, Size * ScreenSizeMultiplier * 2.1)
	GuiButton.Position = UDim2.fromScale(PositionX * ScreenSizeMultiplier, PositionY * ScreenSizeMultiplier)
	GuiButton.Transparency = 1
	GuiButton.Image = "rbxassetid://" .. tostring(ImageId)
	GuiButton.Parent = InputWrapperGui
	local CornerEffect = Instance.new("UICorner")
	CornerEffect.CornerRadius = UDim.new(1, 0)
	CornerEffect.Parent = GuiButton

	return GuiButton
end

--[=[
    Creates a binding for input action service.

    @param Name: string
    @param Callback: () -> ()
]=]
function Wrapper.CreateAction(
	Name: string,
	ContextInput: { Context: InputContext },
	ActionType: Enum.InputActionType,
	Bindings: { Keyboard: Enum.KeyCode?, Gamepad: Enum.KeyCode?, TouchButton: GuiButton? }
)
	--Signal
	local OnPressedSignal = GoodSignal.new()
	local OnReleasedSignal = GoodSignal.new()

	-- Methods
	local Methods = {}
	Methods.OnPressed = OnPressedSignal
	Methods.OnRelease = OnReleasedSignal

	-- Variables
	local InputAction = Instance.new("InputAction")
	InputAction.Name = Name
	InputAction.Type = ActionType
	InputAction.Parent = ContextInput.Context or script

	local KeyboardBinds = Instance.new("InputBinding")
	KeyboardBinds.Name = "Keyboard"
	KeyboardBinds.KeyCode = Bindings.Keyboard :: Enum.KeyCode
	KeyboardBinds.UIButton = Bindings.TouchButton or nil :: any
	KeyboardBinds.Parent = InputAction

	local GamepadBinds = Instance.new("InputBinding")
	GamepadBinds.Name = "Gamepad"
	GamepadBinds.KeyCode = Bindings.Gamepad or Enum.KeyCode.Unknown :: any
	GamepadBinds.Parent = InputAction

	if EMULATORENBALED and not IASEnabled and not Wrapper.StateEngine.IsMenuOpened then
		-- Internal functions
		local function HandleInputAction(_Name: string, UserInputState: Enum.UserInputState, _InputObject: InputObject)
			if UserInputState == Enum.UserInputState.Begin then
				OnPressedSignal:Fire()
			else
				OnReleasedSignal:Fire()
			end
		end
		
		ContextActionService:BindAction(Name, HandleInputAction :: (Name: string, UserInputState: Enum.UserInputState, InputObject: InputObject) -> Enum.ContextActionResult, false)
	elseif not Wrapper.StateEngine.IsMenuOpened then
		InputAction.Pressed:Connect(function()
			OnPressedSignal:Fire()
		end)

		InputAction.Released:Connect(function()
			OnReleasedSignal:Fire()
		end)
	end

	return Methods
end

return Wrapper
