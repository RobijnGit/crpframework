Config = Config or {}

function GetFleecaPrefix(FleecaId)
    return "fleeca-" .. FleecaId .. "-"
end

function GetFleecaOption(Id, Data)
    local Retval = DeepCopyTable(Config.FleecaOptions[Id])

    for k, v in pairs(Retval) do
        v.EventParams = Data
    end

    return Retval
end

Config.FleecaOptions = {
    Gate = {
        {
            Name = 'open',
            Icon = 'fas fa-project-diagram',
            Label = 'Open',
            EventType = 'Client',
            EventName = 'fw-heists:Client:Fleeca:HackGate',
            EventParams = {},
            Enabled = function(Entity)
                return true
            end,
        }
    },
    Loot = {
        {
            Name = 'rob',
            Icon = 'fas fa-th',
            Label = 'Overvallen',
            EventType = 'Client',
            EventName = 'fw-heists:Client:Fleeca:Loot',
            EventParams = {},
            Enabled = function(Entity)
                return true
            end,
        }
    }
}

Config.Fleeca = {
    -- Legion Square
    {
        Center = vector3(149.46, -1040.57, 29.37),
        Vault = vector3(147.41, -1044.96, 29.37),
        PowerBox = { vector3(138.72, -1056.53, 29.19), 1.8, 1.6, 340, 28.19, 32.19 },
        StaffDoor = vector3(144.36, -1043.19, 29.53),
        VaultDoor = {
            Open = 160.0,
            Closed = 250.0,
        },
        DoorIds = {
            "FLEECA_LEGIONSQUARE_SERVICE",
            "FLEECA_LEGIONSQUARE_TO_VAULT",
            "FLEECA_LEGIONSQUARE_VAULT_GATE"
        },
        Zones = {
            -- Gate Hack
            {
                Center = vector3(148.45, -1046.66, 29.37),
                Length = 0.15,
                Width = 0.45,
                Heading = 340,
                MinZ = 29.27,
                MaxZ = 29.87,
                Options = Config.FleecaOptions.Gate
            },

            -- Loot
            {
                Center = vector3(149.86, -1044.68, 29.37),
                Length = 0.2,
                Width = 2.95,
                Heading = 340,
                MinZ = 28.37,
                MaxZ = 30.67,
                Options = GetFleecaOption("Loot", { SafeId = 1 }),
            },
            {
                Center = vector3(151.42, -1046.7, 29.37),
                Length = 2.0,
                Width = 0.2,
                Heading = 340,
                MinZ = 28.37,
                MaxZ = 30.67,
                Options = GetFleecaOption("Loot", { SafeId = 2 }),
            },
            {
                Center = vector3(146.62, -1048.45, 29.37),
                Length = 3.0,
                Width = 0.25,
                Heading = 340,
                MinZ = 28.37,
                MaxZ = 30.67,
                Options = GetFleecaOption("Loot", { SafeId = 3 }),
            },
            {
                Center = vector3(148.04, -1051.0, 29.37),
                Length = 0.2,
                Width = 3.9,
                Heading = 340,
                MinZ = 28.37,
                MaxZ = 30.67,
                Options = GetFleecaOption("Loot", { SafeId = 4 }),
            },
            {
                Center = vector3(150.77, -1049.99, 29.37),
                Length = 3.0,
                Width = 0.5,
                Heading = 340,
                MinZ = 28.37,
                MaxZ = 30.67,
                Options = GetFleecaOption("Loot", { SafeId = 5 }),
            },
        }
    },

    -- Pink Cage
    {
        Center = vector3(313.47, -278.82, 54.17),
        Vault = vector3(311.54, -283.4, 54.16),
        PowerBox = { vector3(320.04, -316.0, 51.13), 1.8, 1.6, 252, 50.13, 54.13 },
        StaffDoor = vector3(308.69, -281.56, 54.33),
        VaultDoor = {
            Open = 160.0,
            Closed = 250.0
        },
        DoorIds = {
            "FLEECA_PINKCAGE_SERVICE",
            "FLEECA_PINKCAGE_TO_VAULT",
            "FLEECA_PINKCAGE_VAULT_GATE"
        },
        Zones = {
            -- Gate Hack
            {
                Center = vector3(312.8, -285.01, 54.16),
                Length = 0.15,
                Width = 0.45,
                Heading = 340,
                MinZ = 54.06,
                MaxZ = 54.66,
                Options = Config.FleecaOptions.Gate
            },

            -- Loot
            {
                Center = vector3(314.19, -283.07, 54.16),
                Length = 0.2,
                Width = 2.95,
                Heading = 340,
                MinZ = 53.16,
                MaxZ = 55.46,
                Options = GetFleecaOption("Loot", { SafeId = 1 }),
            },
            {
                Center = vector3(315.71, -285.05, 54.16),
                Length = 2.0,
                Width = 0.2,
                Heading = 339,
                MinZ = 53.16,
                MaxZ = 55.46,
                Options = GetFleecaOption("Loot", { SafeId = 2 }),
            },
            {
                Center = vector3(311.0, -286.83, 54.16),
                Length = 3.0,
                Width = 0.35,
                Heading = 340,
                MinZ = 53.16,
                MaxZ = 55.46,
                Options = GetFleecaOption("Loot", { SafeId = 3 }),
            },
            {
                Center = vector3(312.41, -289.26, 54.16),
                Length = 0.3,
                Width = 3.9,
                Heading = 340,
                MinZ = 53.16,
                MaxZ = 55.46,
                Options = GetFleecaOption("Loot", { SafeId = 4 }),
            },
            {
                Center = vector3(315.1, -288.35, 54.16),
                Length = 3.0,
                Width = 0.5,
                Heading = 340,
                MinZ = 53.16,
                MaxZ = 55.46,
                Options = GetFleecaOption("Loot", { SafeId = 5 }),
            },
        }
    },

    -- Burton (Hawick Ave. / Gallery Bank)
    {
        Center = vector3(-351.25, -49.79, 49.04),
        Vault = vector3(-353.3, -54.12, 49.04),
        PowerBox = { vector3(-352.33, -45.49, 54.42), 1.8, 1.6, 341, 53.42, 57.42 },
        StaffDoor = vector3(-356.42, -52.46, 49.20),
        VaultDoor = {
            Open = 160.0,
            Closed = 250.0
        },
        DoorIds = {
            "FLEECA_BURTON_SERVICE",
            "FLEECA_BURTON_TO_VAULT",
            "FLEECA_BURTON_VAULT_GATE"
        },
        Zones = {
            -- Gate Hack
            {
                Center = vector3(-352.26, -55.83, 49.03),
                Length = 0.15,
                Width = 0.45,
                Heading = 341,
                MinZ = 48.98,
                MaxZ = 49.53,
                Options = Config.FleecaOptions.Gate
            },

            -- Loot
            {
                Center = vector3(-350.9, -53.86, 49.04),
                Length = 0.2,
                Width = 2.95,
                Heading = 340,
                MinZ = 48.04,
                MaxZ = 50.34,
                Options = GetFleecaOption("Loot", { SafeId = 1 }),
            },
            {
                Center = vector3(-349.35, -55.82, 49.04),
                Length = 2.0,
                Width = 0.2,
                Heading = 341,
                MinZ = 48.04,
                MaxZ = 50.34,
                Options = GetFleecaOption("Loot", { SafeId = 2 }),
            },
            {
                Center = vector3(-354.09, -57.68, 49.04),
                Length = 3.0,
                Width = 0.35,
                Heading = 341,
                MinZ = 48.04,
                MaxZ = 50.34,
                Options = GetFleecaOption("Loot", { SafeId = 3 }),
            },
            {
                Center = vector3(-352.58, -60.13, 49.04),
                Length = 0.3,
                Width = 3.9,
                Heading = 341,
                MinZ = 48.04,
                MaxZ = 50.34,
                Options = GetFleecaOption("Loot", { SafeId = 4 }),
            },
            {
                Center = vector3(-349.95, -59.11, 49.04),
                Length = 3.0,
                Width = 0.5,
                Heading = 341,
                MinZ = 48.04,
                MaxZ = 50.34,
                Options = GetFleecaOption("Loot", { SafeId = 5 }),
            },
        }
    },

    -- Life Invader
    {
        Center = vector3(-1212.39, -330.39, 37.78),
        Vault = vector3(-1211.24, -335.39, 37.78),
        PowerBox = { vector3(-1217.13, -333.02, 42.12), 1.8, 1.6, 297, 41.12, 45.12 },
        StaffDoor = vector3(-1214.62, -336.44, 37.94),
        VaultDoor = {
            Open = 205.0,
            Closed = 295.0
        },
        DoorIds = {
            "FLEECA_LIFEINVADER_SERVICE",
            "FLEECA_LIFEINVADER_TO_VAULT",
            "FLEECA_LIFEINVADER_VAULT_GATE"
        },
        Zones = {
            -- Gate Hack
            {
                Center = vector3(-1209.29, -335.8, 37.79),
                Length = 0.15,
                Width = 0.45,
                Heading = 27,
                MinZ = 37.69,
                MaxZ = 38.29,
                Options = Config.FleecaOptions.Gate
            },

            -- Loot
            {
                Center = vector3(-1209.76, -333.43, 37.78),
                Length = 0.2,
                Width = 2.95,
                Heading = 27,
                MinZ = 36.78,
                MaxZ = 39.08,
                Options = GetFleecaOption("Loot", { SafeId = 1 }),
            },
            {
                Center = vector3(-1207.25, -333.69, 37.78),
                Length = 2.0,
                Width = 0.2,
                Heading = 27,
                MinZ = 36.78,
                MaxZ = 39.08,
                Options = GetFleecaOption("Loot", { SafeId = 2 }),
            },
            {
                Center = vector3(-1209.16, -338.36, 37.78),
                Length = 3.0,
                Width = 0.35,
                Heading = 27,
                MinZ = 36.78,
                MaxZ = 39.08,
                Options = GetFleecaOption("Loot", { SafeId = 3 }),
            },
            {
                Center = vector3(-1206.44, -338.99, 37.78),
                Length = 0.3,
                Width = 3.9,
                Heading = 27,
                MinZ = 36.78,
                MaxZ = 39.08,
                Options = GetFleecaOption("Loot", { SafeId = 4 }),
            },
            {
                Center = vector3(-1205.35, -336.42, 37.78),
                Length = 3.0,
                Width = 0.5,
                Heading = 27,
                MinZ = 36.78,
                MaxZ = 39.08,
                Options = GetFleecaOption("Loot", { SafeId = 5 }),
            },
        }
    },

    -- Harmony
    {
        Center = vector3(1176.26, 2706.8, 38.09),
        Vault = vector3(1175.95, 2711.74, 38.09),
        PowerBox = { vector3(1173.85, 2722.68, 38.0), 1.8, 1.6, 0, 37.0, 41.0 },
        StaffDoor = vector3(1179.72, 2711.7, 38.09),
        VaultDoor = {
            Open = 356.0,
            Closed = 90.0
        },
        DoorIds = {
            "FLEECA_HARMONY_SERVICE",
            "FLEECA_HARMONY_TO_VAULT",
            "FLEECA_HARMONY_VAULT_GATE"
        },
        Zones = {
            -- Gate Hack
            {
                Center = vector3(1174.35, 2712.85, 38.09),
                Length = 0.15,
                Width = 0.45,
                Heading = 0,
                MinZ = 37.99,
                MaxZ = 38.59,
                Options = Config.FleecaOptions.Gate
            },

            -- Loot
            {
                Center = vector3(1173.7, 2710.5, 38.09),
                Length = 0.2,
                Width = 2.95,
                Heading = 0,
                MinZ = 37.09,
                MaxZ = 39.39,
                Options = GetFleecaOption("Loot", { SafeId = 1 }),
            },
            {
                Center = vector3(1171.55, 2711.89, 38.09),
                Length = 2.0,
                Width = 0.2,
                Heading = 0,
                MinZ = 37.09,
                MaxZ = 39.39,
                Options = GetFleecaOption("Loot", { SafeId = 2 }),
            },
            {
                Center = vector3(1175.42, 2715.19, 38.09),
                Length = 3.0,
                Width = 0.35,
                Heading = 0,
                MinZ = 37.09,
                MaxZ = 39.39,
                Options = GetFleecaOption("Loot", { SafeId = 3 }),
            },
            {
                Center = vector3(1173.26, 2717.04, 38.09),
                Length = 0.3,
                Width = 3.9,
                Heading = 0,
                MinZ = 37.09,
                MaxZ = 39.39,
                Options = GetFleecaOption("Loot", { SafeId = 4 }),
            },
            {
                Center = vector3(1171.08, 2715.16, 38.09),
                Length = 3.0,
                Width = 0.5,
                Heading = 0,
                MinZ = 37.09,
                MaxZ = 39.39,
                Options = GetFleecaOption("Loot", { SafeId = 5 }),
            },
        }
    },

    -- Great Ocean Hwy
    {
        Center = vector3(-2962.67, 482.96, 15.7),
        Vault = vector3(-2957.63, 481.65, 15.7),
        PowerBox = { vector3(-2949.69, 487.69, 15.3), 1.8, 1.6, 357, 14.3, 18.3 },
        StaffDoor = vector3(-2958.00, 478.00, 15.85),
        VaultDoor = {
            Open = -92.0,
            Closed = -2.0
        },
        DoorIds = {
            "FLEECA_GREATOCEANHWY_SERVICE",
            "FLEECA_GREATOCEANHWY_TO_VAULT",
            "FLEECA_GREATOCEANHWY_VAULT_GATE"
        },
        Zones = {
            -- Gate Hack
            {
                Center = vector3(-2956.48, 483.36, 15.7),
                Length = 0.15,
                Width = 0.45,
                Heading = 267,
                MinZ = 15.6,
                MaxZ = 16.2,
                Options = Config.FleecaOptions.Gate
            },

            -- Loot
            {
                Center = vector3(-2958.82, 484.1, 15.7),
                Length = 0.2,
                Width = 2.95,
                Heading = 87,
                MinZ = 14.7,
                MaxZ = 17.0,
                Options = GetFleecaOption("Loot", { SafeId = 1 }),
            },
            {
                Center = vector3(-2957.35, 486.25, 15.7),
                Length = 2.0,
                Width = 0.2,
                Heading = 87,
                MinZ = 14.7,
                MaxZ = 17.0,
                Options = GetFleecaOption("Loot", { SafeId = 2 }),
            },
            {
                Center = vector3(-2954.21, 482.13, 15.7),
                Length = 3.0,
                Width = 0.35,
                Heading = 87,
                MinZ = 14.7,
                MaxZ = 17.0,
                Options = GetFleecaOption("Loot", { SafeId = 3 }),
            },
            {
                Center = vector3(-2952.3, 484.31, 15.7),
                Length = 0.3,
                Width = 3.9,
                Heading = 88,
                MinZ = 14.7,
                MaxZ = 17.0,
                Options = GetFleecaOption("Loot", { SafeId = 4 }),
            },
            {
                Center = vector3(-2954.01, 486.6, 15.7),
                Length = 3.0,
                Width = 0.5,
                Heading = 87,
                MinZ = 14.7,
                MaxZ = 17.0,
                Options = GetFleecaOption("Loot", { SafeId = 5 }),
            },
        }
    },
}