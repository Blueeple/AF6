return { --Maybe use the json method and use this has a backup when http service is ddown.
    ServerSettings = {
        isUtilityModuleOutputEnabled = true,
        isUtilityModuleOutputEnabled_Client = true,
    },
    LobbySettings = {
        VoteTime_Normal = 15,
        VoteTime_Veto = 15,
    },
    MapScanParams = {
        Tags_Options = {
            isEventMapEnabled = false,
            isDeveloperMapEnabled = false,
            isExperimentalMapEnabled = false,
            isStandardMapEnabled = true,
        },
        Settings = {
            quarantineInfectedMaps = false, --This does nothing for now.

        }
    },
}