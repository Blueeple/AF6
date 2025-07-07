--!strict
--!native
return {
    Decode = function(Data: buffer)
        local X, Y, Z = buffer.readf32(Data, 0), buffer.readf32(Data, 4), buffer.readf32(Data, 8)
        return Vector3.new(X, Y, Z)
    end,
    Encode = function(Data: Vector3)
        local VecBuffer = buffer.create(12)
        buffer.writef32(VecBuffer, 0, Data.X)
        buffer.writef32(VecBuffer, 4, Data.Y)
        buffer.writef32(VecBuffer, 8, Data.Z)
        return VecBuffer
    end,
}