local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
--[[
Guide to making mobile guis.

Important notes:
* "%L" this prefix is a indicator for alerting the module that it should a local variable. (Variable must be in the local variables table.)
* Using from a 0 to [any number] method to indicate the order of prioritoy. Note "0" is always the default button that the players press.

]]
local Default = {}

function Default:Active(Gui: ImageButton)
    local Main:ImageButton = Gui
    local Icon:ImageLabel = Gui.Icon

    Default:Apply(Gui)

    Main.Visible = true
    Main.ImageRectOffset = Vector2.new(146, 146)

    Icon.ImageColor3 = Color3.new(0, 0, 0)
    Icon.ImageTransparency = 0.75
end

function Default:Idle(Gui: ImageButton)
    local Main:ImageButton = Gui
    local Icon:ImageLabel = Gui.Icon

    Default:Apply(Gui)

    Main.Visible = true
    Main.ImageRectOffset = Vector2.new(1, 146)

    Icon.ImageColor3 = Color3.new(1, 1, 1)
    Icon.ImageTransparency = 0.4
end

function Default:Move()
    
end

function Default:Apply(Gui: ImageButton)
    local JumpButton:ImageButton = Players.LocalPlayer.PlayerGui:WaitForChild("TouchGui").TouchControlFrame.JumpButton
    local Factor = ((JumpButton.Size.X.Offset * (workspace.CurrentCamera.ViewportSize.Magnitude / 2048)) / 2) * 0.8

    Gui.Position = JumpButton.Position - (UDim2.new(0, 0 + Factor, 0, 90 + Factor))
    Gui.Size = JumpButton.Size
end

return Default