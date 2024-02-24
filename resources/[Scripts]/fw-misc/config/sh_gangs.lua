Config.GangHouses = {
    -- {
    --     GangId = 'loz_eztecas',
    --     Price = 280000,
    --     Adress = 'Grove Street Housing Projects',
    -- },
    -- {
    --     GangId = 'bumpergang',
    --     Price = 275000,
    --     Adress = 'Abattoir Ave Warehouse',
    -- },
}

Config.GangsStashes = {
    -- Loz Aztecas
    {
        center = vector3(101.74, -1930.55, 16.56),
        length = 1.8,
        width = 1.4,
        heading = 35,
        minZ = 15.56,
        maxZ = 17.16,
        Gang = "los_aztecas",
    },

    -- BumperGang
    {
        center = vector3(526.41, -2769.85, 6.64),
        length = 1.6,
        width = 0.6,
        heading = 59,
        minZ = 5.64,
        maxZ = 6.64,
        Gang = "bumpergang",
    },

    -- The Nameless
    -- {
    --     center = vector3(553.72, -2064.35, 1.9),
    --     length = 1.6,
    --     width = 0.6,
    --     heading = 358,
    --     minZ = 0.9,
    --     maxZ = 2.7,
    --     Gang = "nameless",
    -- },

    -- Kings
    {
        center = vector3(-1313.05, -1244.74, 4.59),
        length = 1.6,
        width = 0.4,
        heading = 20,
        minZ = 3.59,
        maxZ = 5.59,
        Gang = "kings",
    },
    
    -- Vatos Locos
    {
        center = vector3(758.83, -761.35, 16.99),
        length = 1.0,
        width = 2.8,
        heading = 50,
        minZ = 15.99,
        maxZ = 17.39,
        Gang = "vatoslocos",
    },
    
    -- DWMC
    {
        center = vector3(1708.51, 4765.4, 41.99),
        length = 2.4,
        width = 0.35,
        heading = 0,
        minZ = 40.99,
        maxZ = 42.59,
        Gang = "dark_wolves",
    },
}

Config.GangGarages = {
    { Coords = vector4(102.42, -1964.02, 20.84, 356.03), Gang = "los_aztecas" },
    { Coords = vector4(571.67, -2800.65, 5.48, 239.36), Gang = "bumpergang" },
    -- { Coords = vector4(476.61, -2138.93, 5.31, 222.59), Gang = "nameless" },
    { Coords = vector4(-1307.69, -1261.28, 4.54, 20.3), Gang = "kings" },
    { Coords = vector4(734.45, -743.22, 14.32, 176.39), Gang = "vatoslocos" },
    { Coords = vector4(-1579.46, -244.71, 48.87, 239.73), Gang = "s2n" },
}