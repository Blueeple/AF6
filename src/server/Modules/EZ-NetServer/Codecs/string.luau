--!strict
--!native

-- Modules
local Configurations = require(script.Parent.Parent.Configurations)

return {
    Decode = function(Data: buffer)
        return buffer.readstring(Data, 0, buffer.len(Data))
    end,
    Encode = function(Data: string)
        local StringBuffer = buffer.fromstring(Data)

        if buffer.len(StringBuffer) > Configurations.StringMaxByteSize then
            error("[EZ-Net][Shared]: Your string is too large")
        end

        return StringBuffer
    end
}