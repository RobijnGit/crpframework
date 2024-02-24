Config = Config or {}

Config.Levels = {
    [1] = { RequiredExp = 0, Label = "Level 1" }, -- Fleeca
    [2] = { RequiredExp = 50, Label = "Level 2" }, -- Paleto
    [3] = { RequiredExp = 350, Label = "Level 3" }, -- Pacific Bank
    [4] = { RequiredExp = 700, Label = "Level 4" }, -- Big Vault
    -- [5] = { RequiredExp = 800, Label = "Level 5" },
}

Config.Items = {
    [1] = { -- Fleeca
        { 
            Title = 'Basic Decrypter',
            Crypto = 2,
            Icon = 'project-diagram',
            Item = { "heist-decrypter-basic" }
        },
        { 
            Title = 'Basic Drill',
            Crypto = 5,
            Icon = 'th',
            Item = { "heist-drill-basic" }
        },
        { 
            Title = 'Groene Laptop',
            Crypto = 8,
            Icon = 'laptop',
            Item = { "heist-laptop", "green" }
        },
    },

    [2] = { -- Paleto
        { 
            Title = 'Advanced Decrypter',
            Crypto = 10,
            Icon = 'project-diagram',
            Item = { "heist-decrypter-adv" }
        },
        { 
            Title = 'Advanced Drill',
            Crypto = 25,
            Icon = 'th',
            Item = { "heist-drill-adv" }
        },
        { 
            Title = 'Advanced Electronic Kit',
            Crypto = 10,
            Icon = 'keyboard',
            Item = { "heist-electronic-kit-adv" }
        },
        { 
            Title = 'Blauwe Laptop',
            Crypto = 40,
            Icon = 'laptop',
            Item = { "heist-laptop", "blue"}
        },
    },

    [3] = { -- Vault
        { 
            Title = 'Hardened Decrypter',
            Crypto = 50,
            Icon = 'project-diagram',
            Item = { "heist-decrypter-hard" }
        },
        { 
            Title = 'Hardened Drill',
            Crypto = 50,
            Icon = 'th',
            Item = { "heist-drill-hard" }
        },
        { 
            Title = 'Hardened Electronic Kit',
            Crypto = 20,
            Icon = 'keyboard',
            Item = { "heist-electronic-kit-hard" }
        },
        -- { 
        --     Title = 'Jamming Device',
        --     Crypto = 15,
        --     Icon = 'broadcast-tower',
        --     Item = { "jammingdevice" }
        -- },
        { 
            Title = 'Rode Laptop',
            Crypto = 200,
            Icon = 'laptop',
            Item = { "heist-laptop", "red" }
        },
    },

    [4] = {
        { 
            Title = 'Entry Keycard',
            Crypto = 1000,
            Icon = 'laptop',
            Item = { "heist-entrykeycard" }
        },
    },

    -- [5] = {

    -- }
}