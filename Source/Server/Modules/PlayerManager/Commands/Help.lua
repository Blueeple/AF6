local Command = {
    Description = "Returns and table of commmands back to the server."
}

function Command:Tell()
    print(Command.Description)
end

function Command:Run()
    local CommandsFolder = script.Parent:GetChildren()
    local CommandsRead = {}

    for i = 1, #CommandsFolder do
        local Cmd = CommandsFolder[i]
        CommandsRead[Cmd.Name] = require(Cmd).Description
    end

    print(CommandsRead)

    return(CommandsRead)
end

return Command