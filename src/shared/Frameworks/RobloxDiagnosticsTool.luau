--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats") :: { Network: { ServerStatsItem: { ["Data Ping"]: { GetValue: (self: any) -> number } } } } & Stats

local Player = Players.LocalPlayer :: Player
local Diagnostics = {}

local FrameCount = 0
local AccumulatedDelta = 0
local PingSamples = {}
local FPSSamples = {}
local MaxSamples = 100 -- number of samples for averages

-- helper
local function Average(tbl: { number }): number
	if #tbl == 0 then
		return 0
	end
	local sum = 0
	for _, v in ipairs(tbl) do
		sum += v
	end
	return sum / #tbl
end

-- GUI Setup
local function CreateGui()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "DiagnosticsGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = Player:WaitForChild("PlayerGui")

	local label = Instance.new("TextLabel")
	label.Name = "StatsLabel"
	label.Size = UDim2.new(1, 0, 0, 25) -- full width, 25px height
	label.Position = UDim2.new(0, 0, 0, 0) -- top of screen
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Font = Enum.Font.Code
	label.TextSize = 18
	label.Text = "FPS: 0 | AVG FPS: 0 | PING: 0 | AVG PING: 0"
	label.Parent = screenGui

	return label
end

local statsLabel = CreateGui()

-- Updates FPS samples
RunService.RenderStepped:Connect(function(deltaTime)
	FrameCount += 1
	AccumulatedDelta += deltaTime

	if FrameCount >= 1 then
		local fps = math.floor(1 / deltaTime)
		table.insert(FPSSamples, fps)
		if #FPSSamples > MaxSamples then
			table.remove(FPSSamples, 1)
		end
		FrameCount = 0
		AccumulatedDelta = 0
	end
end)

-- Updates Ping samples
task.spawn(function()
	while task.wait(1) do
		local pingValue = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
		if pingValue then
			table.insert(PingSamples, pingValue)
			if #PingSamples > MaxSamples then
				table.remove(PingSamples, 1)
			end
		end
	end
end)

-- Public function
function Diagnostics:GetStats()
	local currentFPS = FPSSamples[#FPSSamples] or 0
	local avgFPS = math.floor(Average(FPSSamples))
	local currentPing = PingSamples[#PingSamples] or 0
	local avgPing = math.floor(Average(PingSamples))

	return currentFPS, avgFPS, currentPing, avgPing
end

-- Live updater for GUI
RunService.RenderStepped:Connect(function()
	local fps, avgFPS, ping, avgPing = Diagnostics:GetStats()
	statsLabel.Text = string.format("FPS: %d | AVG FPS: %d | PING: %d | AVG PING: %d", fps, avgFPS, ping, avgPing)
end)

return Diagnostics
