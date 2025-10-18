--!strict
type Connection = {
	Disconnect: (self: Connection) -> (),
}

type Signal = {
	Connect: (self: Signal, callback: (...any) -> ()) -> Connection,
	Once: (self: Signal, callback: (...any) -> ()) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Wait: (self: Signal) -> ...any,
}

export type TypeSettings = { [string]: any }

export type InternalPacket = {
	Name: string,
	PacketId: number,
	Types: { string },
	Reliable: boolean,
	BlockedPlayers: { [number]: boolean },
	Enabled: boolean,
	Replicator: string,
	Signal: Signal,
}

export type EZNet = {
	Disconnect: (self: InternalPacket) -> (),
}

export type Replicator = {
	StepMode: RBXScriptSignal,
	Reliable: boolean,
	TickPerSecond: number,
	ThrottleEnabled: boolean,
	ThrottleRate: number,
	ThrottleInterval: number,
}

export type MN_Type = {
	Read: (...any) -> ...any,
	Write: (...any) -> ...any,
}

export type PacketObjectEngine = {
	--[=[
		Fires a Pacekt to the client

		@param Player: Player
		@param ...
	]=]
	Fire: (self: PacketObjectEngine, Player: Player, ...any) -> (),

	--[=[
		Sets the activity of an remote.

		@param ...
	]=]
	SetEnabled: (self: PacketObjectEngine, ...boolean) -> (),

	--[=[
		Fires a function when ever a packet revices a signal

		@param func: (layer: Player, ...any) -> ()
	]=]
	OnPacket: (self: PacketObjectEngine, func: (Player: Player, ...any) -> ()) -> (),
	PacketInfo: InternalPacket,
	PacketId: number,
}

return {}
