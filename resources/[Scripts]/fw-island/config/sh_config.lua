Config = Config or {}

Config.ActiveIslandPayments = {
    ['island'] = {},
}

Config.IslandItems = {
    {
        Type = 'Tray',
        center = vector3(4902.45, -4942.27, 4.4),
        length = 2,
        width = 1,
        name = "island_foodtray_1",
        heading = 35.0,
        entityHeading = 38.0,
        minZ = 3,
        maxZ = 4,
        options = {
            {
                Name = 'tray',
                Icon = 'fas fa-hand-holding',
                Label = 'Dienblad',
                EventType = 'Client',
                EventName = 'fw-businesses:Client:Foodchain:OpenFoodtray',
                EventParams = { Business = 'island', TrayId = 1 },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    },
    {
        Type = 'Tray',
        center = vector3(4904.78, -4940.74, 4.4),
        length = 2,
        width = 1,
        name = "island_foodtray_2",
        heading = 25.0,
        entityHeading = 27.0,
        minZ = 3,
        maxZ = 4,
        options = {
            {
                Name = 'tray',
                Icon = 'fas fa-hand-holding',
                Label = 'Dienblad',
                EventType = 'Client',
                EventName = 'fw-businesses:Client:Foodchain:OpenFoodtray',
                EventParams = { Business = 'island', TrayId = 2 },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    },
    {
        Type = 'Tray',
        center = vector3(4906.88, -4939.88, 4.4),
        length = 2,
        width = 1,
        name = "island_foodtray_3",
        heading = 20.0,
        entityHeading = 18.0,
        minZ = 3,
        maxZ = 4,
        options = {
            {
                Name = 'tray',
                Icon = 'fas fa-hand-holding',
                Label = 'Dienblad',
                EventType = 'Client',
                EventName = 'fw-businesses:Client:Foodchain:OpenFoodtray',
                EventParams = { Business = 'island', TrayId = 3 },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    },
    {
        Type = 'Register',
        center = vector3(4901.64, -4942.75, 4.4),
        length = 2,
        width = 1,
        name = "island_register_1",
        heading = 35.0,
        entityHeading = 40.0,
        minZ = 3,
        maxZ = 4,
        options = {
            {
                Name = 'pay_payment',
                Icon = 'fas fa-hand-holding-usd',
                Label = 'Betalen',
                EventType = 'Client',
                EventName = 'fw-island:Client:Foodchain:GetPayments',
                EventParams = { Foodchain = "island", RegisterId = 1 },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'setup_payment',
                Icon = 'fas fa-cash-register',
                Label = 'Bestelling Openen',
                EventType = 'Client',
                EventName = 'fw-island:Client:Foodchain:SetupPayment',
                EventParams = { RegisterId = 1 },
                Enabled = function(Entity)
                    if exports['fw-island']:canPlayerUseRegister() then
                        return true
                    end
                    return false
                end,
            },
        },
    },
    {
        Type = 'Register',
        center = vector3(4903.86, -4941.05, 4.4),
        length = 2,
        width = 1,
        name = "island_register_2",
        heading = 25.0,
        entityHeading = 30.0,
        minZ = 3,
        maxZ = 4,
        options = {
            {
                Name = 'pay_payment',
                Icon = 'fas fa-hand-holding-usd',
                Label = 'Betalen',
                EventType = 'Client',
                EventName = 'fw-island:Client:Foodchain:GetPayments',
                EventParams = { Foodchain = "island", RegisterId = 2 },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'setup_payment',
                Icon = 'fas fa-cash-register',
                Label = 'Bestelling Openen',
                EventType = 'Client',
                EventName = 'fw-island:Client:Foodchain:SetupPayment',
                EventParams = { RegisterId = 2 },
                Enabled = function(Entity)
                    if exports['fw-island']:canPlayerUseRegister() then
                        return true
                    end
                    return false
                end,
            },
        },
    },
    {
        Type = 'Register',
        center = vector3(4907.72, -4939.57, 4.4),
        length = 2,
        width = 1,
        name = "island_register_3",
        heading = 20.0,
        entityHeading = 15.0,
        minZ = 3,
        maxZ = 4,
        options = {
            {
                Name = 'pay_payment',
                Icon = 'fas fa-hand-holding-usd',
                Label = 'Betalen',
                EventType = 'Client',
                EventName = 'fw-island:Client:Foodchain:GetPayments',
                EventParams = { Foodchain = "island", RegisterId = 3 },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'setup_payment',
                Icon = 'fas fa-cash-register',
                Label = 'Bestelling Openen',
                EventType = 'Client',
                EventName = 'fw-island:Client:Foodchain:SetupPayment',
                EventParams = { RegisterId = 3 },
                Enabled = function(Entity)
                    if exports['fw-island']:canPlayerUseRegister() then
                        return true
                    end
                    return false
                end,
            },
        },
    },
}