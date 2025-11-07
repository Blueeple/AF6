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

export type TypeSettings = { [string]: any }

export type InternalPacket = {
	Name: string,
	PacketId: number,
	Types: { any },
	Reliable: boolean,
	BlockedPlayers: { [number]: boolean },
	Enabled: boolean,
	Replicator: string,
	Signal: Signal,
}

export type Replicator = {
	StepMode: RBXScriptSignal,
	Reliable: boolean,
	TickPerSecond: number,
	ThrottleEnabled: boolean,
	ThrottleRate: number,
	ThrottleInterval: number,
}

export type PacketObjectEngine = {
	--[=[
		Fires a Pacekt to the client

		@param Player: Player
		@param ...
	]=]
	Fire: (self: PacketObjectEngine, Player: Player, ...any) -> (),

	--[=[
		Fires an packet ot all client connected the rmv4.
	]=]
	FireAll: (...any) -> (),

	--[=[
		Sets the activity of an remote.

		@param ...
	]=]
	SetEnabled: (self: PacketObjectEngine, ...boolean) -> (),

	--[=[
		Fires a function when ever a packet revices a signal

		@param func: (layer: Player, ...any) -> ()
	]=]
	OnPacket: (self: PacketObjectEngine, func: (Player: Player, ...any) -> ()) -> { Disconnect: () -> () },

	--[=[
		Blocks a player from firing a packet.
	]=]
	BlockPlayer: (self: PacketObjectEngine, Player: Player) -> (),

	--[=[
		Allows a re blocked player to recived blocked packet.
	]=]
	UnBlockPlayer: (self: PacketObjectEngine, Player: Player) -> (),
	PacketInfo: InternalPacket,
	PacketId: number,
}

return {}
