RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    local Result = FW.SendCallback("fw-misc:Server:GetPlayerVehicles")
    local ContextItems = {
        {
            Icon = "info-circle",
            Title = "Voertuig Swap",
            Desc = "Swap je voertuigen bij de Vapid Dealership naast appartementen."
        }
    }

    for k, v in pairs(Result) do
        local SharedData = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        if not IsModelValid(v.vehicle) and SharedData then
            ContextItems[#ContextItems + 1] = {
                Icon = "car",
                Title = ("Model: %s | Name: %s"):format(v.vehicle, SharedData.Name),
                Desc = ("VIN: %s"):format(v.vinnumber)
            }
        end
    end

    if #ContextItems > 1 then
        FW.Functions.OpenMenu({
            MainMenuItems = ContextItems
        })
    end
end)

-- vector4(-218.53, -1162.37, 23.02, 94.68)
RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("vapid_vehicle_swap", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.5,
        Position = vector4(-218.53, -1162.37, 22.02, 94.68),
        Model = 'a_m_y_business_02',
        Scenario = "WORLD_HUMAN_CLIPBOARD",
        Options = {
            {
                Name = 'pdm-job-store',
                Icon = 'fas fa-car',
                Label = 'Verwijderde Voertuig Swappen',
                EventType = 'Client',
                EventName = 'fw-misc:Client:OpenVehicleSwap',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })
end)

RegisterNetEvent("fw-misc:Client:OpenVehicleSwap")
AddEventHandler("fw-misc:Client:OpenVehicleSwap", function()
    local ContextItems = {
        -- {
        --     Icon = "info-circle",
        --     Title = "Geruilde voertuigen",
        --     SecondMenu = {}
        -- },
        {
            Icon = "info-circle",
            Title = "Ruil voertuig",
            SecondMenu = {}
        }
    }

    local Result = FW.SendCallback("fw-misc:Server:GetPlayerVehicles")
    for k, v in pairs(Result) do
        local SharedData = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        if not IsModelValid(v.vehicle) and SharedData then
            ContextItems[1].SecondMenu[#ContextItems[1].SecondMenu + 1] = {
                Icon = "car",
                Title = ("Model: %s | Name: %s"):format(v.vehicle, SharedData.Name),
                Desc = ("VIN: %s"):format(v.vinnumber),
                Data = {
                    Event = "fw-misc:Client:OpenSwapCatalog",
                    Plate = v.plate,
                    VIN = v.vinnumber,
                    Vehicle = v.vehicle,
                    IsVIN = v.vinscratched == 1
                }
            }
        end
    end

    Citizen.SetTimeout(200, function()
        FW.Functions.OpenMenu({
            MainMenuItems = ContextItems
        })
    end)
end)

RegisterNetEvent("fw-misc:Client:OpenSwapCatalog")
AddEventHandler("fw-misc:Client:OpenSwapCatalog", function(Data)
    local SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Vehicle)]
    if SharedData == nil then return end

    local ContextItems = {
        {
            Icon = "info-circle",
            Title = "Swap Catalogus",
            Desc = ("Model: %s | Name: %s"):format(Data.Vehicle, SharedData.Name)
        }
    }

    local BannedCategories = {
        ["Motorcycles"] = true,
        ["Emergency"] = true,
        ["Helicopter"] = true,
        ["Bicycles"] = true,
        ["Utility"] = true,
    }

    local IsMotorcycle = SharedData.Category == "Motorcycles"
    local VehicleClasses = {}
    for k, v in pairs(FW.Shared.HashVehicles) do
        if IsModelValid(v.Vehicle) and ((IsMotorcycle and v.Category == "Motorcyles") or (not IsMotorcycle and not BannedCategories[v.Category])) then
            if SharedData.Class == v.Class and math.abs(SharedData.Price - v.Price) <= 50000 then
                if VehicleClasses[v.Category] == nil then
                    VehicleClasses[v.Category] = {
                        Icon = "folder",
                        Title = v.Category,
                        SecondMenu = {}
                    }
                end

                table.insert(VehicleClasses[v.Category].SecondMenu, {
                    Icon = "car",
                    Title = ("Name: %s"):format(v.Name),
                    Desc = ("Model: %s | Price: %s"):format(v.Vehicle, exports['fw-businesses']:NumberWithCommas(v.Price)),
                    Data = {
                        Event = "fw-misc:Client:ConfirmVehicleSwap",
                        Plate = Data.Plate,
                        VIN = Data.VIN,
                        Vehicle = Data.Vehicle,
                        Swap = v.Vehicle
                    }
                })
            end
        end
    end

    for k, v in pairs(VehicleClasses) do
        table.insert(ContextItems, v)
    end

    if #ContextItems == 1 then
        table.insert(ContextItems, {
            Icon = "folder-times",
            Title = "Refund",
            Desc = ("Kon geen voertuigen vinden binnen prijsklasse, klik om %s te ontvangen."):format(exports['fw-businesses']:NumberWithCommas(SharedData.Price)),
            Data = {
                Event = "fw-misc:Client:ConfirmVehicleSwap",
                Plate = Data.Plate,
                VIN = Data.VIN,
                Vehicle = Data.Vehicle,
                Swap = "Refund"
            }
        })
    else
        if Data.IsVIN then
            table.insert(ContextItems, {
                Icon = "money-bill-wave",
                Title = "Refund",
                Desc = "Lever je voertuig in, voor GNE refund maak een ticket aan.",
                Data = {
                    Event = "fw-misc:Client:ConfirmVehicleSwap",
                    Plate = Data.Plate,
                    VIN = Data.VIN,
                    Vehicle = Data.Vehicle,
                    Swap = "Refund"
                }
            })
        else
            table.insert(ContextItems, {
                Icon = "money-bill-wave",
                Title = "Refund",
                Desc = ("Ruil je voertuig in voor %s op je bank."):format(exports['fw-businesses']:NumberWithCommas(SharedData.Price)),
                Data = {
                    Event = "fw-misc:Client:ConfirmVehicleSwap",
                    Plate = Data.Plate,
                    VIN = Data.VIN,
                    Vehicle = Data.Vehicle,
                    Swap = "Refund"
                }
            })
        end
    end


    Citizen.SetTimeout(200, function()
        FW.Functions.OpenMenu({
            MainMenuItems = ContextItems
        })
    end)
end)

RegisterNetEvent("fw-misc:Client:ConfirmVehicleSwap")
AddEventHandler("fw-misc:Client:ConfirmVehicleSwap", function(Data)
    Citizen.SetTimeout(200, function()
        FW.Functions.OpenMenu({
            MainMenuItems = {
                {
                    Title = ("Voertuig Ruilen (%s)"):format(Data.VIN),
                    Desc = Data.Swap == "Refund " and "Weet je zeker dat je het voertuig wilt refunden?" or ("Weet je zeker dat je %s wilt omruilen voor een %s?"):format(Data.Vehicle, Data.Swap)
                },
                {
                    Title = "Bevestigen",
                    Data = {
                        Event = "fw-misc:Server:SetVehicleSwap",
                        Plate = Data.Plate,
                        VIN = Data.VIN,
                        Vehicle = Data.Vehicle,
                        Swap = Data.Swap
                    }
                },
                {
                    Title = "Annuleren",
                    Data = { Event = "" }
                },
            },
            Width = "40vh"
        })
    end)
end)

-- RegisterCommand("getInvalidModels", function()
--     for k, v in pairs(FW.Shared.HashVehicles) do
--         if not IsModelValid(v.Vehicle) then
--             print(v.Vehicle)
--         end
--     end
-- end)