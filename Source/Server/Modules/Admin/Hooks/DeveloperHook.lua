return function (registry)
	registry:RegisterHook("BeforeRun", function(context)
		if context.Executor:GetRankInGroup(15561950) < 250 then
			return "You don't have permission to run this command."
		end
	end)
end