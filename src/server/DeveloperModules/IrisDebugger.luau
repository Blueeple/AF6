--!strict
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local WallyPackages = ReplicatedStorage:FindFirstChild("Packages")

-- Modules
local iris = require(WallyPackages:WaitForChild("iris")).Init()

-- Variables
local Camera = workspace.CurrentCamera :: Camera

-- Return module constructor
return function()
	--stylua: ignore start
	iris:Connect(function() 
        -- Variables
        local CameraDebuggerWindowProperties = {
            size = Vector2.new(600, 400),
            position = vector.zero
        } :: any
        local X, Y, Z = Camera.CFrame.Rotation:ToEulerAnglesXYZ()

        iris.Window({"Camera Debugger"}, CameraDebuggerWindowProperties)
            -- Description
            iris.Text({"This is the camera debugger window. It will show you information on the camera."})
        
            --CameraCframe tree
            iris.Text({"Camera CFrame:"})

            iris.Text({"Rotation: " .. tostring(Vector3.new(X, Y, Z))})
            iris.Text({"Position: " .. tostring(Camera.CFrame.Position)})

            -- Camera properties
            iris.Text({"Camera Properties:"})

            local FOVSlider = iris.SliderNum({"Field of View", 0.1, 40, 120}, {number = 70} :: any).state.number.value
            Camera.FieldOfView = FOVSlider

        iris.End()
    end)
	--stylua: ignore end

	print("[IrisDebugger] - Initialized.")
end
--stylua ignore start
