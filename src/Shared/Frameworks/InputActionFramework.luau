--!strict
-- Exported types
export type CustomInputAction = {
	ActionName: string,
	InputAction: InputAction,
	BindKeyboard: (KeyCode: Enum.KeyCode) -> (),
	BindGamepad: (Button: Enum.KeyCode) -> (),
	SetEnabled: (Enabled: boolean) -> (),
	SetMobileUI: (MobileUI: GuiButton) -> (),
	OnPressed: (Callback: () -> ()) -> (),
	OnRelease: (Callback: () -> ()) -> (),
}

-- Variables
local StartTime = tick()

-- Module constuctor
local InputActionFramework = {}

--[[
	InputActionFramework is a framework for creating and managing input actions in Roblox.
	It allows you to create custom input actions, bind them to keyboard and gamepad inputs,
	and handle their pressed and released events.
]]
function InputActionFramework.new(
	ActionName: string,
	ActionType: Enum.InputActionType,
	InputPrioty: number,
	Tag: string?
): CustomInputAction
	-- Assertions
	assert(ActionName and type(ActionName) == "string", "ActionName must be a non-empty string.")
	assert(ActionType and typeof(ActionType) == "EnumItem", "ActionType must be a valid Enum.InputActionType.")

	-- self
	local self = {}

	-- Variables
	local InputAction = Instance.new("InputAction") :: InputAction
	InputAction.Type = ActionType
	InputAction.Name = ActionName
	InputAction.Parent = script

	local InputContext = Instance.new("InputContext")
	InputContext.Name = ActionName .. "Context"
	InputContext.Priority = InputPrioty

	local KeyboardAction = Instance.new("InputBinding")
	KeyboardAction.Name = ActionName .. "Keyboard"
	KeyboardAction.Parent = InputAction

	local GamepadAction = Instance.new("InputBinding")
	GamepadAction.Name = ActionName .. "Gamepad"
	GamepadAction.Parent = InputAction

	-- Initialzie
	if Tag and script:FindFirstChild(Tag) then
		-- Variables
		local Parent = script:FindFirstChild(Tag) :: Instance

		InputAction:AddTag(Tag)
		InputAction.Parent = Parent
	elseif Tag and not script:FindFirstChild(Tag) then
		--Variables
		local TagFolder = Instance.new("Folder")
		TagFolder.Parent = script
		TagFolder.Name = Tag

		InputAction:AddTag(Tag)
		InputAction.Parent = TagFolder
	end

	-- Methods
	--[[
        sets if the action is enabled or not.
        @param Enabled: boolean - Whether the action is enabled.
    ]]
	function self.SetEnabled(boolean: boolean)
		if type(boolean) ~= "boolean" then
			warn("Enabled must be a boolean value.")
		end
		InputAction.Enabled = boolean
	end

	--[[
        Binds a keyboard key to an action.
        @param KeyCode: Enum.KeyCode - The key to bind.
        @param Callback: function - The function to call when the key is pressed.
    ]]
	function self.BindKeyboard(KeyCode: Enum.KeyCode)
		KeyboardAction.KeyCode = KeyCode
	end

	--[[
        Binds a gamepad button to an action.
        @param Button: Enum.KeyCode - The gamepad button to bind.
    ]]
	function self.BindGamepad(Button: Enum.KeyCode, PressedThreshold: number, ReleasedThreshold: number)
		GamepadAction.KeyCode = Button
		GamepadAction.PressedThreshold = PressedThreshold
		GamepadAction.ReleasedThreshold = ReleasedThreshold
	end

	--[[
        Sets the mobile UI for the action.
        @param MobileUI: GuiButton - The button to use for mobile input.
    ]]
	function self.SetMobileUI(MobileUI: GuiButton)
		if MobileUI:IsA("GuiButton") then
			KeyboardAction.UIButton = MobileUI
		else
			error("MobileUI must be a ScreenGui instance.")
		end
	end

	--[[
        Binds a callback function to the action when the key is pressed.
        @param Callback: function - The function to call when the key is pressed.
    ]]
	function self.OnPressed(Callback: () -> ())
		InputAction.Pressed:Connect(function()
			Callback()
		end)
	end

	--[[
        Binds a callback function to the action when the key is released.
        @param Callback: function - The function to call when the key is pressed.
    ]]
	function self.OnRelease(Callback: () -> ())
		InputAction.Released:Connect(function()
			Callback()
		end)
	end

	--[[
        Gets the Direction 1D state of the action.
        @return number - The current state of the action.
    ]]
	--TODO
	function self.GetDirection1D(): number
		return 0
	end

	-- Propterties
	self.ActionName = ActionName
	self.InputAction = InputAction

	return setmetatable(self, InputActionFramework) :: CustomInputAction
end

--[[
	Clears all input bindings for a specific tag or all bindings if no tag is provided.
	@param Tag: string? - The tag to clear bindings for. If nil, clears all bindings.
]]
function InputActionFramework.ClearBindings(Tag: string?)
	-- Clear all bindings
	if Tag then
		-- Variables
		local TagFolder = script:FindFirstChild(Tag)

		for _, action in script:GetChildren() do
			if action:IsA("InputAction") and action:HasTag(Tag) then
				action:Destroy()
			end
		end

		if TagFolder then
			TagFolder:Destroy()
		end
	else
		script:ClearAllChildren()
	end
end

print("[InputActionFramework] - " .. tostring(tick() - StartTime) .. " seconds")

return InputActionFramework
