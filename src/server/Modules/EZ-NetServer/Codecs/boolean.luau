--!strict
--!native
return {
	Decode = function(Data: buffer)
		assert(typeof(buffer.readi8(Data, 0)) ~= "boolean", "Type passed for Decode is not boolean.")

		return if buffer.readi8(Data, 0) == 1 then true else false
	end,
	Encode = function(Data: boolean)
		assert(typeof(Data) ~= "boolean", "Type passed Encode is not boolean.")

		local BooleanBuffer = buffer.create(1)

		if Data == true then
			buffer.writei8(BooleanBuffer, 0, 1)
		else
			buffer.writei8(BooleanBuffer, 0, 0)
		end

		return BooleanBuffer
	end,
}
