--!native
--!strict
-- [[ Standard luau buffer libary ]]
local buffer = buffer

-- [[ Rmv4 Engine Types ]]
type AllocatableBuffer = {
	Buffer: buffer,
	CurrentBit: number,
}

-- [[ Buffer Allocator Engine ]]
local BufferEngine = {}
BufferEngine.__index = BufferEngine

--[=[
	Creates a buffer that initializes with 8bits.
]=]
function BufferEngine.create()
	-- Variables
	local self = setmetatable({
		Buffer = buffer.create(1),
	}, BufferEngine)

	return self
end

--[=[
	Allocate bytes to an buffer.

	**Note**: 
	Each buffer is initialized with 8 bits so if your using more than 8bits there is no need for allocation.

	@param Amount: number
]=]
function BufferEngine:AllocateBytes(Amount: number)
	-- Variables
	local AllocatableBuffer = self :: AllocatableBuffer
	local OldBuffSize = buffer.len(AllocatableBuffer.Buffer)
	local TempBuffer = buffer.create(OldBuffSize + Amount)

	buffer.copy(TempBuffer, 0, AllocatableBuffer.Buffer)

	AllocatableBuffer.Buffer = TempBuffer
end

--[=[
	Make this write bytes better and actually count them]
	Inserts data into a pointer, using a Offset 0 -> (Buffer Length - 1)

	@param StartOffset: number
	@param EndOffset: number
]=]
function BufferEngine:WriteBits(StartOffset: number, EndOffset: number, Value: number)
	-- Variables
	local AllocatableBuffer = self :: AllocatableBuffer
	AllocatableBuffer.CurrentBit = EndOffset

	buffer.writebits(AllocatableBuffer.Buffer, StartOffset, EndOffset, Value)
end

--[=[ Data Type Engine ]=]
local Types = {}
local Reads = {}
local Writes = {}

-- [[ Type data here ]]

--[=[
	This is the u8 Integer type.

	Max length 0 -> 255 (256)
]=]
Types.IntU8 = ("IntU8" :: any) :: number
Writes.IntU8 = function(Value: number)
	local Pointer = BufferEngine.create()
	Pointer:WriteBits(0, 8, Value)
	return Pointer.Buffer
end
Reads.IntU8 = function(Value: buffer)
	return buffer.readbits(Value, 0, 8)
end

--[=[
	Weaphon Fire type.
]=]
Types.WeaphonFire = "WeaphonFire"
Writes.WeaphonFire = function(Value: {}) end
Reads.WeaphonFire = function(Value: buffer) end

return {
	Types = Types,
	Reads = Reads :: { [string]: (...buffer) -> ...any },
	Writes = Writes :: { [string]: (...any) -> buffer },
}
