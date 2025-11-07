--!strict
type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type Signal = {
	Connect: (self: Signal, callback: (...any) -> ()) -> Connection,
	Once: (self: Signal, callback: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Wait: (self: Signal) -> ...any,
}

export type InternalPacket = {
	Name: string,
	PacketId: number,
	Types: { any },
	Replicator: string,
	Signal: Signal,
}

export type PacketObjectEngine = {
	--[=[
		Fires a Pacekt to the client

		@param Player: Player
		@param ...
	]=]
	Fire: (self: PacketObjectEngine, ...any) -> (),
	--[=[
		Fires a function when ever a packet revices a signal

		@param func: (layer: Player, ...any) -> ()
	]=]
	OnPacket: (self: PacketObjectEngine, func: (...any) -> ()) -> { Disconnect: () -> () },
	PacketInfo: InternalPacket,
	PacketId: number,
}

return {}
