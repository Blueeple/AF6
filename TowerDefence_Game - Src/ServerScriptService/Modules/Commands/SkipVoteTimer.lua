return {
	Name = "SkipVoteTimer";
	Aliases = {"SVT"};
	Description = "Skips the timer for the voting system.";
	Group = "Debug";
	Args = {
		{
			Type = "string";
			Name = "Maps";
			Description = "The map that you want to load instead.";
		},
	};
}