local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local SharedModules = ReplicatedStorage:FindFirstChild("SharedModules")

local GameSettings = require(SharedModules.GameSettings)

local ServerSettings = GameSettings.ServerSettings

local CanRun = true

if RunService:IsStudio() == false or RunService:IsClient() and GameSettings.ServerSettings.isUtilityModuleOutputEnabled_Client == false then
    CanRun = false
end

local Utility = {}

local function typeCheck(object : Object, newType : Object , errorMessage : string)
    if type(object) == newType then
        return({true , object})
    else
        warn("[~] - " .. tostring(errorMessage or "no error message provided."))
    end
end

function Utility:GenerateGUIDName(MinNumber: number, MaxNumber: number, useDash: boolean)
    local Remove = "-"

    if useDash then
        Remove = ""
    end

    return string.sub(table.concat(string.split(game.HttpService:GenerateGUID(false), Remove)), MinNumber, MaxNumber)
end

function Utility:DecodeFullNameToObject(FullName: string)
	local segments = FullName:split(".")
	local current = game

	for _,location in pairs(segments) do
		current = current[location]
	end

	return current
end

function Utility:GetTableLength(... : table)
    local maxNum = 0
    local objectType = typeCheck(..., "table", "A frien yah luk?")

    if objectType then
        for _, value in objectType[2] do
            maxNum += 1
        end
    end
    return maxNum
end

function Utility:GetRigOffsetY(Rig: Model)
    local Humanoid = Rig:FindFirstChildOfClass("Humanoid")
    local RigData =  {}
    
    if Humanoid.RigType == Enum.HumanoidRigType.R6 then
        local RootPart = Rig.PrimaryPart
        local Torso = Rig:FindFirstChild("Torso")
        local RightFoot = Rig:FindFirstChild("Right Leg")

        local OffsetSizeY_L = Torso.Size.Y / 2 + RightFoot.Size.Y / 2 - 0.1

        RigData["OffsetSizeY"] = Vector3.new(0, OffsetSizeY_L, 0)
    else   

    end

    return setmetatable(RigData, Utility)
end

function Utility:AnimateRig(Rig: Model, AnimationName: string)
    Utility:OutputLog({"Setting up animations for: ", Rig.Name})

    local Humanoid: Humanoid = Rig:WaitForChild("Humanoid")
    local Animator: Animator = Humanoid:WaitForChild("Animator") or Instance.new("Animator", Humanoid)
    local AnimationsFolder: Folder = Humanoid:WaitForChild("Animations")

    if (Humanoid and Animator and AnimationsFolder) == true then Utility:OutputWarn("[Error]: Failed to load animation.") return end

    local AnimationObject: Animation = AnimationsFolder[AnimationName]

    local AnimationLoaded = Animator:LoadAnimation(AnimationObject)

    return AnimationLoaded
end

function Utility:OutputLog(...: {})
    if ServerSettings.isUtilityModuleOutputEnabled == true and CanRun then
		local ScriptName = Utility:DecodeFullNameToObject(debug.info(2, "s")).Name
        local Information = if type(...) == "table" then table.concat(..., " ") else ...
        print("[" .. ScriptName .. "] - " .. Information)
    end
end

function Utility:OutputWarn(...: {})
    if ServerSettings.isUtilityModuleOutputEnabled == true and CanRun then
		local ScriptName = Utility:DecodeFullNameToObject(debug.info(2, "s")).Name
        local Information = if type(...) == "table" then table.concat(..., " ") else ...
        warn("[" .. ScriptName .. "] - " .. Information)
    end
end

return Utility