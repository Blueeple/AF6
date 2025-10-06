export type InternalPacket = {
	Name: string,
	PacketId: number,
	Types: { string },
	Reliable: boolean,
	BlockedPlayers: { [number]: boolean },
	Enabled: boolean,
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
	Fire: (self: PacketObjectEngine, Player: Player | { number: Player }, ...any) -> (),
	Packet: InternalPacket,
	PacketId: number,
}

return {}
