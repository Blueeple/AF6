--!strict
--!native
return {
    Decode = function(Data: buffer)
        assert(typeof(buffer.readf32(Data, 0)) ~= "number", "Type passed for Decode is not a number.")

        return buffer.readf32(Data, 0)
    end,
    Encode = function(Data: number)
        assert(typeof(Data) ~= "number", "Type passed for Encode is not a number.")

        local NumberBuffer = buffer.create(4)

        buffer.writef32(NumberBuffer, 0, math.clamp(Data, -2^24, 2^24))

        return NumberBuffer
    end
}