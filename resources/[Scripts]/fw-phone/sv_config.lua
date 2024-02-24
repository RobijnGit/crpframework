Config.MilkRoadProducts = {
    ['milkroad'] = {
        {
            Id = 1,
            Icon = 'fas fa-user-secret',
            Label = 'VPN',
            Costs = {
                Amount = 20,
                CryptoId = 1,
                Label = Config.Crypto[1].Label:upper()
            },
            Reward = { Item = "vpn", CustomType = "" }
        },
        {
            Id = 2,
            Icon = 'fas fa-mask',
            Label = 'USB-apparaat',
            Costs = {
                Amount = 50,
                CryptoId = 2,
                Label = Config.Crypto[2].Label:upper()
            },
            Reward = { Item = "methusb" }
        },
        {
            Id = 3,
            Icon = 'fas fa-road',
            Label = 'Race USB',
            Costs = {
                Amount = 10,
                CryptoId = 2,
                Label = Config.Crypto[2].Label:upper()
            },
            Reward = { Item = "racing-usb" }
        },
    },
}

Config.Networks = {
    {
        Id = "milkroad",
        Name = "Public Hotspot",
        Center = vector3(1099.35, -345.92, 66.18),
        Size = 5.0,
        Password = false,
        Enabled = function(Source)
            return true
        end,
    },
    {
        Id = "bennys",
        Name = "Bennys Motorworks",
        Center = vector3(-211.13, -1326.52, 31.3),
        Size = 50.0,
        Enabled = function(Source)
            return exports['fw-businesses']:HasPlayerBusinessPermission("Bennys Motorworks", Source, 'VehicleSales')
        end,
    },
    {
        Id = "pdm",
        Name = "Premium Deluxe Motorsports",
        Center = vector3(-42.83, -1093.77, 27.27),
        Size = 40.0,
        Enabled = function(Source)
            return exports['fw-businesses']:HasPlayerBusinessPermission("Premium Deluxe Motorsports", Source, 'VehicleSales')
        end,
    },
    {
        Id = "lostmc",
        Name = "The Lost Holland",
        Center = vector3(969.19, -122.23, 74.35),
        Size = 80.0,
        Enabled = function(Source)
            return exports['fw-businesses']:HasPlayerBusinessPermission("The Lost Holland", Source, 'VehicleSales')
        end,
    },
    {
        Id = "losmuertos",
        Name = "Muertos Motorcycle Shop",
        Center = vector3(1232.86, 3593.99, 33.83),
        Size = 80.0,
        Enabled = function(Source)
            return exports['fw-businesses']:HasPlayerBusinessPermission("Muertos Motorcycle Shop", Source, 'VehicleSales')
        end,
    },
    -- {
    --     Id = "bearlymc",
    --     Name = "Bearly Legal MC",
    --     Center = vector3(124.8, 313.41, 112.14),
    --     Size = 80.0,
    --     Enabled = function(Source)
    --         return exports['fw-businesses']:HasPlayerBusinessPermission("Bearly Legal MC", Source, 'VehicleSales')
    --     end,
    -- },
    {
        Id = "darkwolves",
        Name = "Dark Wolves MC",
        Center = vector3(1712.73, 4781.29, 43.67),
        Size = 80.0,
        Enabled = function(Source)
            return exports['fw-businesses']:HasPlayerBusinessPermission("Dark Wolves MC", Source, 'VehicleSales')
        end,
    },
    {
        Id = "flightschool",
        Name = "Los Santos Vliegschool",
        Center = vector3(-954.35, -2986.74, 14.29),
        Size = 100.0,
        Enabled = function(Source)
            return exports['fw-businesses']:HasPlayerBusinessPermission("Los Santos Vliegschool", Source, 'VehicleSales')
        end,
    },
}

Config.Bankbusters = {
    {
        Id = "Bank",
        Data = { Bank = "Great Ocean" },
        Label = "Fleeca: Great Ocean",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bank",
        Data = { Bank = "Harmony" },
        Label = "Fleeca: Harmony",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bank",
        Data = { Bank = "Life Invader" },
        Label = "Fleeca: Life Invader",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bank",
        Data = { Bank = "Legion Square" },
        Label = "Fleeca: Legion Square",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bank",
        Data = { Bank = "Pink Cage" },
        Label = "Fleeca: Pink Cage",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bank",
        Data = { Bank = "Hawick" },
        Label = "Fleeca: Hawick",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bank",
        Data = { Bank = "Bay City" },
        Label = "Bay City Bank",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Paleto",
        Data = {},
        Label = "Blaine County Savings Bank",
        Time = 60 * math.random(60, 120), -- 2 > 3 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Bobcat",
        Data = {},
        Label = "Bobcat Security",
        Time = 60 * math.random(220, 300), -- 4 > 5 hours. 
        Expired = false,
        Claimers = {},
    },
    {
        Id = "Jewelry",
        Data = {},
        Label = "Vangelico Jewelry",
        Time = 60 * math.random(180, 300), -- 3 > 5 hours. 
        Expired = false,
        Claimers = {},
    },
    -- {
    --     Id = "HumaneLabs",
    --     Data = {},
    --     Label = "Humane Labs & Research",
    --     Time = 60 * math.random(120, 240), -- 2 > 4 hours. 
    --     Expired = false,
    --     Claimers = {},
    -- },
    -- {
    --     Id = "Yacht",
    --     Data = {},
    --     Label = "Yacht",
    --     Time = 60 * math.random(180, 300), -- 3 > 5 hours. 
    --     Expired = false,
    --     Claimers = {},
    -- },
}