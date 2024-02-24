Config = Config or {}

function GetVaultPrefix()
    return "vault-"
end

Config.Vault = {
    DoorIds = {
        "PACIFIC_ROOF_ENTRANCE_LEFT",
        "PACIFIC_ROOF_ENTRANCE_RIGHT",
        "PACIFIC_SIDE_ENTRANCE_STAFF",
        "PACIFIC_SIDE_ENTRANCE_STAFF_2ND_FLOOR",
        "PACIFIC_ROOF_ENTRANCE_TO_COUNTER",
        "PACIFIC_ROOF_ENTRANCE_TO_2ND_FLOOR",
        "PACIFIC_COUNTER_LEFT",
        "PACIFIC_COUNTER_RIGHT",
        "PACIFIC_COUNTER_LEFT_FRONT",
        "PACIFIC_COUNTER_RIGHT_FRONT",
        "PACIFIC_MAIN_OFFICE_LEFT",
        "PACIFIC_MAIN_OFFICE_RIGHT",
        "PACIFIC_OFFICE_01",
        "PACIFIC_OFFICE_02",
        "PACIFIC_OFFICE_03",
        "PACIFIC_OFFICE_04",
        "PACIFIC_OFFICE_05",
        "PACIFIC_OFFICE_06",
        "PACIFIC_OFFICE_07",
        "PACIFIC_OFFICE_08",
        "PACIFIC_STAIRS_TO_VAULT_UPPER",
        "PACIFIC_STAIRS_TO_VAULT_LEFT",
        "PACIFIC_STAIRS_TO_VAULT_RIGHT",
        "PACIFIC_VAULT_1",
        "PACIFIC_VAULT_2",
        "PACIFIC_VAULT_SAFE_LEFT",
        "PACIFIC_VAULT_SAFE_RIGHT",
        "PACIFIC_STAIRS_UPPER_LEFT",
        "PACIFIC_STAIRS_UPPER_RIGHT",
        "PACIFIC_VAULT_INNER_GATE_LEFT",
        "PACIFIC_VAULT_INNER_GATE_RIGHT",
    },
    Laptops = {
        {
            center = vector3(251.83, 208.61, 106.28),
            length = 0.4,
            width = 0.6,
            heading = 351,
            minZ = 106.18,
            maxZ = 106.48
        },
        {
            center = vector3(260.52, 205.45, 106.28),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 106.18,
            maxZ = 106.48
        },
        {
            center = vector3(270.39, 231.67, 106.28),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 106.18,
            maxZ = 106.48
        },
        {
            center = vector3(261.7, 234.83, 106.28),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 106.18,
            maxZ = 106.48
        },
        {
            center = vector3(260.5, 205.44, 110.17),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 110.07,
            maxZ = 110.37
        },
        {
            center = vector3(251.85, 208.6, 110.17),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 110.07,
            maxZ = 110.37
        },
        {
            center = vector3(261.7, 234.85, 110.17),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 110.07,
            maxZ = 110.37
        },
        {
            center = vector3(270.38, 231.63, 110.17),
            length = 0.4,
            width = 0.6,
            heading = 350,
            minZ = 110.07,
            maxZ = 110.37
        }
    },
    Loot = {
        -- Left
        {
            Center = vector3(240.88, 215.44, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(239.72, 213.03, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(241.3, 209.82, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 250,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(244.35, 211.41, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(245.27, 213.97, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },

        -- Right
        {
            Center = vector3(253.18, 235.18, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.27
        },
        {
            Center = vector3(254.13, 237.6, 97.12),
            Length = 2.4,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.37
        },
        {
            Center = vector3(252.65, 241.02, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 250,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(249.47, 239.28, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(248.59, 236.77, 97.12),
            Length = 2.4,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },

        -- The Vault
        {
            Center = vector3(225.69, 230.97, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },
        {
            Center = vector3(227.26, 234.64, 97.12),
            Length = 2.6,
            Width = 0.4,
            Heading = 340,
            MinZ = 96.72,
            MaxZ = 99.32
        },
    }
}