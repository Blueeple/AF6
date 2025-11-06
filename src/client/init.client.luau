--!strict

--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Folders
local Frameworks = ReplicatedStorage:WaitForChild("Frameworks")

-- Modules
local ModNet = require(Frameworks["EZNet-V2"])
local _RobloxDiagnosticsTool = require(Frameworks.RobloxDiagnosticsTool)

-- Variables
local TestRemote = ModNet.GetPacket("MoneyGram1")
TestRemote:OnPacket(function(Data1: number, Data2: number)
    print("I got the data and it is", Data1, Data2)

    task.wait(1)
    
    TestRemote:Fire(57, 67)
end)
