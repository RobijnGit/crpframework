RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("vehicle_rental_vesp", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.5,
        Position = vector4(110.93, -1090.56, 28.30, 27.29),
        Model = 'a_m_m_eastsa_02',
        Options = {
            {
                Name = 'rent_vehicle',
                Icon = 'fas fa-circle',
                Label = 'Voertuigen Huren',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:OpenRental',
                EventParams = { Type = "Cars" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("boat_rental_puerta", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.0,
        Position = vector4(-848.55, -1368.33, 0.61, 288.03),
        Model = 'mp_m_boatstaff_01',
        Options = {
            {
                Name = 'rent_vehicle',
                Icon = 'fas fa-circle',
                Label = 'Boot Huren',
                EventType = 'Client',
                EventName = 'fw-vehicles:Client:OpenRental',
                EventParams = { Type = "Boats" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
end)

RegisterNetEvent("fw-vehicles:Client:OpenRental")
AddEventHandler("fw-vehicles:Client:OpenRental", function(Data)
    local MenuItems = {}
    for k, v in pairs(Config.Rentals[Data.Type]) do
        MenuItems[#MenuItems + 1] = {
            Title = v.Label,
            Desc = exports['fw-businesses']:NumberWithCommas(FW.Shared.CalculateTax('Vehicle Registration Tax', v.Price)),
            SecondMenu = {
                {
                    Title = 'Bevestig aankoop',
                    GoBack = false,
                    CloseMenu = true,
                    DoCloseEvent = false,
                    Data = {
                        Event = 'fw-vehicles:Client:RentalPurchase',
                        Type = "Client",
                        RentalType = Data.Type,
                        Model = v.Model,
                        Price = FW.Shared.CalculateTax('Vehicle Registration Tax', v.Price)
                    }
                }
            }
        }
    end
    FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
end)

RegisterNetEvent("fw-vehicles:Client:RentalPurchase")
AddEventHandler("fw-vehicles:Client:RentalPurchase", function(Data)
    local Plate = ("RN" .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(3)):upper()

    if not FW.Functions.IsSpawnPointClear(vector3(Config.RentalSpawn[Data.RentalType].x, Config.RentalSpawn[Data.RentalType].y, Config.RentalSpawn[Data.RentalType].z), 1.85) then
        return FW.Functions.Notify("Er staat een voertuig in de weg..", "error")
    end

    local StartRent = GetEntityCoords(PlayerPedId())
    local Finished = FW.Functions.CompactProgressbar(15000, "Huren, niet bewegen...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = false}, {}, {}, {}, false)
    if not Finished then return end

    if #(GetEntityCoords(PlayerPedId()) - StartRent) > 2.0 then
        return FW.Functions.Notify("Idioot, je bent te ver weg gegaan..", "error")
    end

    local Paid = FW.SendCallback("FW:RemoveCash", Data.Price)
    if not Paid then
        return FW.Functions.Notify("Niet genoeg cash..", "error")
    end

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Data.Model, { x = Config.RentalSpawn[Data.RentalType].x, y = Config.RentalSpawn[Data.RentalType].y, z = Config.RentalSpawn[Data.RentalType].z - 1.0, a = Config.RentalSpawn[Data.RentalType].w }, false, Plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end

    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    NetworkRequestControlOfEntity(Vehicle)
    TriggerServerEvent('fw-vehicles:Server:ReceiveRentalPapers', Plate)

    exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
    exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
    
    Citizen.SetTimeout(500, function()
        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)
        SetVehicleDirtLevel(Vehicle, 0.0)
    end)
end)

RegisterNetEvent("fw-vehicles:Client:ReceiveRentalKeys")
AddEventHandler("fw-vehicles:Client:ReceiveRentalKeys", function(Plate)
    exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
    FW.Functions.Notify("Je ontving een extra set met sleutels!", "success")
end)