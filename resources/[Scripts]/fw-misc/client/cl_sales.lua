-- Ingredient and Material sales.
Citizen.CreateThread(function()
    -- exports['fw-ui']:AddEyeEntry("misc-sales-materials", {
    --     Type = 'Entity',
    --     EntityType = 'Ped',
    --     SpriteDistance = 10.0,
    --     Distance = 1.5,
    --     Position = vector4(-229.76, -1377.1, 30.26, 208.63),
    --     Model = 's_m_y_dockwork_01',
    --     Options = {
    --         {
    --             Name = "sell",
    --             Icon = "fas fa-dollar-sign",
    --             Label = "Verkoop Materialen",
    --             EventType = "Client",
    --             EventName = "fw-misc:Client:SellMaterials",
    --             EventParams = {},
    --             Enabled = function()
    --                 return true
    --             end,
    --         }
    --     }
    -- })

    -- exports['fw-ui']:AddEyeEntry("misc-sales-ingredients", {
    --     Type = 'Entity',
    --     EntityType = 'Ped',
    --     SpriteDistance = 10.0,
    --     Distance = 1.5,
    --     Position = vector4(95.21, -1810.32, 26.08, 240.83),
    --     Model = 's_m_m_linecook',
    --     Options = {
    --         {
    --             Name = "sell",
    --             Icon = "fas fa-dollar-sign",
    --             Label = "Verkoop Ingredienten",
    --             EventType = "Client",
    --             EventName = "fw-misc:Client:SellIngredients",
    --             EventParams = {},
    --             Enabled = function()
    --                 return true
    --             end,
    --         }
    --     }
    -- })
end)

RegisterNetEvent("fw-misc:Client:SellMaterials")
AddEventHandler("fw-misc:Client:SellMaterials", function()
    local Result = FW.SendCallback("fw-misc:Server:GetMaterialsSell")

    local MenuItems = {}

    for k, v in pairs(Result.Items) do
        local ItemData = exports['fw-inventory']:GetItemData(k)

        MenuItems[#MenuItems + 1] = {
            Icon = 'info-circle',
            Title = exports['fw-businesses']:NumberWithCommas(v * 4),
            Desc = "voor " .. v .. "x " .. ItemData.Label:lower(),
            Data = { Event = '', Type = 'Client'},
        }
    end

    MenuItems[#MenuItems + 1] = {
        Icon = 'dollar-sign',
        Title = "Verkopen",
        Desc = "Totaal: " .. exports['fw-businesses']:NumberWithCommas(Result.Total * 4),
        Data = { Event = 'fw-misc:Server:SellMaterials', Type = 'Server' },
        Disabled = Result.Total == 0
    }

    Citizen.SetTimeout(450, function()
        FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
    end)
end)


RegisterNetEvent("fw-misc:Client:SellIngredients")
AddEventHandler("fw-misc:Client:SellIngredients", function()
    local Result = FW.SendCallback("fw-misc:Server:GetIngredientsSell")

    local MenuItems = {}

    for k, v in pairs(Result.Items) do
        local ItemData = Shared.CustomTypes['ingredient'][k]

        MenuItems[#MenuItems + 1] = {
            Icon = 'info-circle',
            Title = exports['fw-businesses']:NumberWithCommas(v * 12),
            Desc = "voor " .. v .. "x " .. ItemData.Label:lower(),
            Data = { Event = '', Type = 'Client'},
        }
    end

    MenuItems[#MenuItems + 1] = {
        Icon = 'dollar-sign',
        Title = "Verkopen",
        Desc = "Totaal: " .. exports['fw-businesses']:NumberWithCommas(Result.Total * 12),
        Data = { Event = 'fw-misc:Server:SellIngredients', Type = 'Server' },
        Disabled = Result.Total == 0
    }

    Citizen.SetTimeout(450, function()
        FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
    end)
end)