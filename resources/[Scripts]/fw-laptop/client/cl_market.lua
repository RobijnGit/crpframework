RegisterNetEvent("fw-laptop:Client:Market:SellItemsMenu")
AddEventHandler("fw-laptop:Client:Market:SellItemsMenu", function()
    local Items = FW.SendCallback("fw-laptop:Server:Market:GetItems")

    local MenuItems = {
        {
            Icon = 'store',
            Title = "Holle Bolle Markt",
            Desc = "De plek om makkelijk en anoniem je spullen te verkopen!"
        }
    }

    for k, v in pairs(Items) do
        local ItemData = exports['fw-inventory']:GetItemData(v.Item, v.CustomType)

        MenuItems[#MenuItems + 1] = {
            Title = ItemData.Label,
            Desc = "Slot " .. v.Slot .. "; Aantal: " .. v.Amount,
            SecondMenu = {
                {
                    Icon = "coins",
                    Title = "Verkopen op de Markt",
                    Data = {
                        Event = "fw-laptop:Client:Market:SellItemToMarket",
                        ItemData = v,
                        Label = ItemData.Label,
                    }
                }
            }
        }
    end

    FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
end)

RegisterNetEvent("fw-laptop:Client:Market:SellItemToMarket")
AddEventHandler("fw-laptop:Client:Market:SellItemToMarket", function(Data)
    local InputItems = {
        {
            Label = 'Prijs',
            Icon = 'horse-head',
            Name = 'Price',
            Type = "number",
        }
    }

    Citizen.SetTimeout(350, function()
        local Result = exports['fw-ui']:CreateInput(InputItems)

        if Result.Price then
            FW.TriggerServer("fw-laptop:Server:Market:SellItem", Data.Label, Data.ItemData, Result.Price)
        end
    end)
end)

RegisterNUICallback("Market/GetProducts", function(Data, Cb)
    local Result = FW.SendCallback('fw-laptop:Server:Market:GetProducts')
    Cb(Result)
end)

RegisterNUICallback("Market/PurchaseProducts", function(Data, Cb)
    local Result = FW.SendCallback('fw-laptop:Server:Market:PurchaseProducts', Data)
    Cb(Result)
end)

function IsBlacklistedItem(ItemName)
    return Config.BlacklistedSaleItems[ItemName]
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    local MarketCoords = FW.SendCallback("fw-heists:Server:GetPedCoords", "MarketSale")
    exports['fw-ui']:AddEyeEntry("market-sale", {
        Type = "Zone",
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = MarketCoords,
            Length = 1.6,
            Width = 0.4,
            Data = {
                heading = 0,
                minZ = 6.1,
                maxZ = 8.65
            },
        },
        Options = {
            {
                Name = "sell",
                Icon = "fas fa-laptop",
                Label = "Items Verkopen",
                EventType = "Client",
                EventName = "fw-laptop:Client:Market:SellItemsMenu",
                EventParams = {},
                Enabled = function(entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("market-pickup", {
        Type = "Zone",
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(1184.01, -3322.08, 6.19),
            Length = 1.4,
            Width = 0.4,
            Data = {
                heading = 0,
                minZ = 4.99,
                maxZ = 7.49
            },
        },
        Options = {
            {
                Name = "sell",
                Icon = "fas fa-boxes",
                Label = "Items Ophalen",
                EventType = "Server",
                EventName = "fw-laptop:Server:Market:PickupItems",
                EventParams = {},
                Enabled = function(entity)
                    return true
                end,
            },
        }
    })
end)