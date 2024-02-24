Config = Config or {}

Config.Paleto = {
    State = 0,
    Vault = vector3(-100.68, 6464.64, 31.63),
    Doorlocks = { 'PALETO_VAULT_DOOR', 'PALETO_HALL_TO_SECURITY' },
    Door = {
        Hash = GetHashKey("ch_prop_ch_vault_d_door_01a"),
        HeadingOpen = 87.20,
        HeadingClosed = -134.85,
    },
    PowerBox = {
        center = vector3(-109.82, 6483.66, 31.47),
        length = 1.35,
        width = 1.35,
        heading = 225,
        minZ = 30.47,
        maxZ = 32.47
    },
    Loot = {
        {
            Id = 1, State = 0,
            Zone = {
                center = vector3(-96.84, 6463.43, 31.63),
                length = 4.4,
                width = 0.2,
                heading = 45,
                minZ = 30.63,
                maxZ = 33.03,
            }
        },
        {
            Id = 2, State = 0,
            Zone = {
                center = vector3(-100.3, 6459.95, 31.63),
                length = 4.4,
                width = 0.2,
                heading = 45,
                minZ = 30.63,
                maxZ = 33.03,
            }
        },
        {
            Id = 3, State = 0,
            Zone = {
                center = vector3(-96.53, 6459.71, 31.63),
                length = 3.5,
                width = 0.2,
                heading = 315,
                minZ = 30.63,
                maxZ = 33.03,
            }
        },
    },
    USBLocations = {
        vector3(-104.75, 6478.99, 31.43),
        vector3(-106.23, 6474.06, 31.43),
        vector3(-110.76, 6469.20, 31.53),
        vector3(-111.96, 6469.67, 31.53),
        vector3(-104.11, 6460.35, 31.43),
        vector3(-101.45, 6460.34, 31.36),
        vector3(-97.72, 6466.54, 31.43),
        vector3(-95.91, 6466.09, 31.36),
        vector3(-94.30, 6467.66, 31.68),
        vector3(-109.52, 6476.02, 31.68),
        vector3(-105.05, 6468.04, 31.08),
    },
}