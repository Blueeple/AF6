--!strict
--!native
return {
	Decode = function(Data: buffer)
		local PosX, PosY, PosZ = buffer.readf32(Data, 0), buffer.readf32(Data, 4), buffer.readf32(Data, 8)
		local RVecX, RVecY, RVecZ = buffer.readf32(Data, 12), buffer.readf32(Data, 16), buffer.readf32(Data, 20)
		local UpVecX, UpVecY, UpVecZ = buffer.readf32(Data, 24), buffer.readf32(Data, 28), buffer.readf32(Data, 32)

		return CFrame.fromMatrix(Vector3.new(PosX, PosY, PosZ), Vector3.new(RVecX, RVecY, RVecZ), Vector3.new(UpVecX, UpVecY, UpVecZ))
	end,
	Encode = function(Data: CFrame)
		local CFrameBuffer = buffer.create(36)

		buffer.writef32(CFrameBuffer, 0, Data.Position.X)
		buffer.writef32(CFrameBuffer, 4, Data.Position.Y)
		buffer.writef32(CFrameBuffer, 8, Data.Position.Z)
		buffer.writef32(CFrameBuffer, 12, Data.RightVector.X)
		buffer.writef32(CFrameBuffer, 16, Data.RightVector.Y)
		buffer.writef32(CFrameBuffer, 20, Data.RightVector.Z)
		buffer.writef32(CFrameBuffer, 24, Data.UpVector.X)
		buffer.writef32(CFrameBuffer, 28, Data.UpVector.Y)
		buffer.writef32(CFrameBuffer, 32, Data.UpVector.Z)

		print(buffer.len(CFrameBuffer))

		return CFrameBuffer
	end,
}
