local Players = game:GetService("Players")

-- Variables
local PlayerGui = Players.LocalPlayer.PlayerGui

return function(Name: string, Properties: any)
	-- Variables
	local ObjectFrame = Instance.new("Frame")
	ObjectFrame.Name = Name
	ObjectFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	ObjectFrame.Position = UDim2.fromScale(0.5, 0.5)
	ObjectFrame.Parent = PlayerGui:FindFirstChild("HudFramework-Gui")

	ObjectFrame.Size = Properties["ObjectFrame"].Size or UDim2.fromScale(0.7, 0.7)
	ObjectFrame.BackgroundColor3 = Properties["ObjectFrame"].Color or Color3.new(0, 0, 0)

	return ObjectFrame
end
