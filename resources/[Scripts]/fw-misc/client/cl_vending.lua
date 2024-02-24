local VendingMachines = {
    { Prop = "prop_vend_coffe_01", Vending = "Coffee" },
    { Prop = "prop_vend_fridge01", Vending = "Soda" },
    { Prop = "prop_vend_snak_01", Vending = "Candy" },
    { Prop = "prop_vend_soda_02", Vending = "Soda" },
    { Prop = "prop_vend_water_01", Vending = "Water" },
    { Prop = "prop_vend_snak_01_tu", Vending = "Candy" },
    { Prop = "v_68_broeknvend", Vending = "Soda" },
    { Prop = "prop_vend_soda_01", Vending = "Soda" },
    { Prop = "ch_chint10_vending_smallroom_01", Vending = "Soda" },
    { Prop = "sf_prop_sf_vend_drink_01a", Vending = "Soda" },
    { Prop = "prop_watercooler", Vending = "Water" },
    { Prop = "prop_watercooler_dark", Vending = "Water" },
}

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    for k, v in pairs(VendingMachines) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v.Prop), {
            Type = 'Model',
            Model = v.Prop,
            SpriteDistance = 10.0,
            Distance = 1.5,
            Options = {
                {
                    Name = "open_vending",
                    Icon = 'fas fa-shopping-basket',
                    Label = "Automaat",
                    EventType = "Client",
                    EventName = "fw-misc:Client:OpenVending",
                    EventParams = {Vending = v.Vending},
                    Enabled = function(Entity)
                        return true
                    end,
                }
            }
        })
    end
end)

RegisterNetEvent("fw-misc:Client:OpenVending")
AddEventHandler("fw-misc:Client:OpenVending", function(Data)
    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'Vending' .. Data.Vending)
    end
end)