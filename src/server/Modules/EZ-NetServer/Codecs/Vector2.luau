--!strict
--!native
return {
    Decode = function(Data: buffer)
		assert(typeof(buffer.readf32(Data, 0)) ~= "number", "Type passed for Decode is not number")
		assert(typeof(buffer.readf32(Data, 4)) ~= "number", "Type passed for Decode is not number")
		
		return Vector2.new(buffer.readf32(Data, 0), buffer.readf32(Data, 4))
    end,
	Encode = function(Data: Vector2)
		assert(typeof(Data) ~= "Vector2", "Type passed for Encode is not Vector2")
		
		local Vector2Buffer = buffer.create(8)
		
		buffer.writef32(Vector2Buffer, 0, math.clamp(Data.X, -2^24, 2^24))
		buffer.writef32(Vector2Buffer, 4, math.clamp(Data.Y, -2^24, 2^24))
		
		return Vector2Buffer
    end
}