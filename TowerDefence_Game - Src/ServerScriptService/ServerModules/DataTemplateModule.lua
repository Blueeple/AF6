local Template = {
    Currency = {
        GameCoins = 0,
        RankCoins = 0,
    },
    OwnedMovesets = {
        Ohma_Tokita = true,
        Kure_Raian = true,
    },
    OwnedAccessories = {
        DeveloperCape_BlueVez = true,
    },
    RankData = {
        Rank = 0,
        RankPercentage = 0,
        RankPosition = 0,
        IsRankProtected = true
    },
    Equipped = {
        Moveset = "Ohma_Tokita",
        Badge = "null",
        Banner = "null",
        Accessories = {
            Accessory1 = "null",
            Accessory2 = "null",
            Accessory3 = "null",
            Accessory4 = "null",
            Accessory5 = "null",
            Accessory6 = "null",
            Accessory7 = "null",
            Accessory8 = "null",
        }
    },
    GameSettings = {
        Game = {
            --//Camera
            FieldOfView = 70,

            --//Aim assist
            AimAssistEnabled_Console = true,
            AimAssistEnabled_Touch = true,

            --//Aim assist Strength
            AimAssistStrength_Console = 0.35,
            AimAssistStrength_Touch = 0.4,

            --//Aim Console
            SensitivityMultiplier = 2.5,
            AimInputCurveMethod = Enum.EasingStyle.Exponential.Name,
            AimInputCurveType = Enum.EasingDirection.InOut.Name,
            AimInputCurveAmount = 0.1
        },
        Input = {
            --//Input Fix
            isTachyonModeEnabled = false,
            inputBuffer = 10,
            LockInputMethod = Enum.UserInputType.None.Name,

            --//Keybindings
            KeyBinds = {
                KeyBoard = {
                    PunchButton = {
                        Main = Enum.KeyCode.ButtonR3.Name,
                        Alt = nil,
                        Auctuation = 0.1,
                    },
                    --[[HeavyButton = {
                        Main = Enum.KeyCode.ButtonL3,
                        Alt = nil,
                        Auctuation = 0.1,
                    },]]
                    DashButton = {
                        Main = Enum.KeyCode.ButtonY.Name,
                        Alt = nil,
                    },
                    SpecialButton = {
                        Main = Enum.KeyCode.ButtonB.Name,
                        Alt = nil,
                    },
                    ActionButton_1 = {
                        Main = Enum.KeyCode.ButtonX.Name,
                        Alt = nil,
                    },
                    ActionButton_2 = {
                        Main = Enum.KeyCode.ButtonR1.Name,
                        Alt = nil,
                    },
                    ActionButton_3 = {
                        Main = Enum.KeyCode.ButtonL1.Name,
                        Alt = nil,
                    },
                    ActionButton_4 = {
                        Main = Enum.KeyCode.ButtonR3.Name,
                        Alt = nil,
                    },
                    ActionButton_5 = {
                        Main = Enum.KeyCode.ButtonR2.Name,
                        Alt = nil,
                    },
                },
                Gamepad = {
                    PunchButton = {
                        Main = Enum.UserInputType.MouseButton1.Name,
                        Alt = Enum.KeyCode.J.Name,
                    },
                    --[[HeavyButton = {
                        Main = Enum.UserInputType.MouseButton1,
                        Alt = Enum.KeyCode.J,
                    },]]
                    DashButton = {
                        Main = Enum.KeyCode.Q.Name,
                        Alt = Enum.KeyCode.H.Name,
                    },
                    SpecialButton = {
                        Main = Enum.KeyCode.E.Name,
                        Alt = Enum.KeyCode.J.Name,
                    },
                    ActionButton_1 = {
                        Main = Enum.KeyCode.One.Name,
                        Alt = Enum.KeyCode.One.Name,
                    },
                    ActionButton_2 = {
                        Main = Enum.KeyCode.Two.Name,
                        Alt = Enum.KeyCode.Two.Name,
                    },
                    ActionButton_3 = {
                        Main = Enum.KeyCode.Three.Name,
                        Alt = Enum.KeyCode.Three.Name,
                    },
                    ActionButton_4 = {
                        Main = Enum.KeyCode.Four.Name,
                        Alt = Enum.KeyCode.Four.Name,
                    },
                    ActionButton_5 = {
                        Main = Enum.KeyCode.Five.Name,
                        Alt = Enum.KeyCode.Five.Name,
                    },
                },
                Touch = {
                    PunchButton = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    --[[HeavyButton = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },]]
                    DashButton = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    BlockButton = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    SpecialButton = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    ActionButton_1 = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    ActionButton_2 = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    ActionButton_3 = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    ActionButton_4 = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                    ActionButton_5 = {
                        Position = {
                            X = 0.5,
                            Y = 0.5
                        },
                        Scale = {
                            X = 0.5,
                            Y = 0.5
                        },
                    },
                },
            },


        },
        Graphics = {
            --//Roblox-Engine
            MaximumFrameRate = 240,
            AreShadowsEnabled = true,
            RBLX_GameLightingStyle = "Realistic",
            RBLX_PioritizeLightingQuality = true,
            RBLX_PostProcessingFeaturesEnabled = true,
            RBLX_BloomEnabled = true,
            RBLX_SunRaysEnabled = true,

            --//User-Interface
            UIFrameRateCap = 60,
            UICulling = true,
            ShowFPS = true,

            --//Custom-Rendering-Engine
            MaximumAnimationEngineFPS_NEAR = 60,
            MaximumAnimationEngineFPS_FAR = 15,
            CharacterCulling = false,
            
            --//Animation-Engine
            IsAnimationUpScallingEnabled = true,
            AnimationVFXScallingAmount = 5,
            
            --//

        },
        Networking = {
            ShowPlayerPing = true,
            PingCompensation = true,
        },
        Audio = {
            
        },
    }
}

return Template