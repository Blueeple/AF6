local ServerScriptService = game:GetService("ServerScriptService")

local ServerModulesFolder = ServerScriptService:FindFirstChild("ServerModules")

local Management = ServerModulesFolder.Management

local UserDataManager = require(Management.UserDataManager)

local Command = {
    Description = "Allows external scripts to edit the data of users externally."
}

function Command:Tell()
    print(Command.Description)
end

function Command:Run(args)
    print(args)
end

return Command