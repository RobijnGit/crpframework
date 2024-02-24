local InsidePurchase, InsideHeli = false, false

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    exports['PolyZone']:CreateBox({
        center = vector3(463.32, -1019.05, 28.1),
        length = 4.8,
        width = 6.8,
    }, {
        name = "mrpd_purchase_vehicle",
        heading = 0,
        minZ = 27.1, maxZ = 30.5,
    }, function(IsInside, Zone, Point)
        local PlayerJob = FW.Functions.GetPlayerData().job
        if PlayerJob.name ~= 'police' then return end

        InsidePurchase = IsInside
        if InsidePurchase then
            exports['fw-ui']:ShowInteraction("[E] Voertuig Aanschaffen")
        else
            exports['fw-ui']:HideInteraction()
        end

        Citizen.CreateThread(function()
            while InsidePurchase do

                if IsControlJustReleased(0, 38) then
                    local BuyVehicles = {}
                    for k, v in pairs(exports['fw-vehicles']:GetPoliceVehicles()) do
                        local SharedData = FW.Shared.HashVehicles[GetHashKey(v)]
                        BuyVehicles[#BuyVehicles + 1] = {
                            Icon = 'car',
                            Title = SharedData.Name,
                            Desc = exports['fw-businesses']:NumberWithCommas(FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price)),
                            Disabled = not CanUseVehicle(v),
                            SecondMenu = {
                                {
                                    Icon = 'user',
                                    Title = 'Bevestig aankoop',
                                    CloseMenu = true,
                                    Data = { Event = 'fw-police:Server:PurchaseVehicle', Type = 'Server', Vehicle = v }
                                },
                            }
                        }

                        if (FW.Functions.GetPlayerData().metadata.ishighcommand) then
                            BuyVehicles[#BuyVehicles].SecondMenu[2] = {
                                Icon = 'people-arrows',
                                Title = 'Bevestig aankoop (Gezamelijk)',
                                CloseMenu = true,
                                Data = { Event = 'fw-police:Server:PurchaseVehicle', Type = 'Server', Vehicle = v, Shared = true }
                            }
                        end
                    end

                    FW.Functions.OpenMenu({
                        MainMenuItems = BuyVehicles
                    })
                end

                Citizen.Wait(1)
            end
        end)
    end)

    for k,pad in pairs(Config.HeliPads) do
        exports['PolyZone']:CreateBox({
            center = pad.center,
            length = pad.length,
            width = pad.width,
        }, {
            name = pad.name,
            heading = pad.heading,
            minZ = pad.minZ,
            maxZ = pad.maxZ,
        }, function(IsInside, Zone, Point)
            local PlayerJob = FW.Functions.GetPlayerData().job
            if PlayerJob.name ~= 'police' then return end
    
            InsideHeli = IsInside
            if InsideHeli then
                exports['fw-ui']:ShowInteraction(IsPedInAnyHeli(PlayerPedId()) and "[E] Helikopter Verwijderen" or "[E] Politie Helikopters")
            else
                exports['fw-ui']:HideInteraction()
            end
    
            Citizen.CreateThread(function()
                while InsideHeli do
    
                    if IsControlJustReleased(0, 38) then
    
                        if IsPedInAnyHeli(PlayerPedId()) then
                            exports['fw-ui']:EditInteraction("[E] Politie Helikopters")
                            FW.VSync.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                        else
                            FW.Functions.OpenMenu({
                                MainMenuItems = {
                                    {
                                        Icon = "helicopter",
                                        Title = FW.Shared.HashVehicles[GetHashKey('airone')].Name,
                                        Disabled = not CanUseVehicle('airone'),
                                        SecondMenu = {
                                            {
                                                Title = 'Helikopter Pakken',
                                                CloseMenu = true,
                                                Data = { Event = 'fw-police:Client:SpawnHelicopter', Type = 'Client', Helicopter = 'airone', Coords = pad.Coords }
                                            },
                                        }
                                    },
                                }
                            })
                        end
                    end
    
                    Citizen.Wait(1)
                end
            end)
        end)        
    end
end)

function CanUseVehicle(VehicleName)
    local VehicleData = FW.Functions.GetPlayerData().metadata['pd-vehicles']
    if not Config.VehicleCerts[VehicleName] then
        return false
    end

    return VehicleData[Config.VehicleCerts[VehicleName]:upper()]
end

RegisterNetEvent("fw-police:Client:SpawnHelicopter")
AddEventHandler("fw-police:Client:SpawnHelicopter", function(Data)
    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob.name ~= 'police' then return end

    local Model = Data.Helicopter
    if not CanUseVehicle(Model) then return end

    RequestModel(Model)
    while not HasModelLoaded(Model) do
        Citizen.Wait(4)
    end
    
    local Plate = "ZUL" .. FW.Shared.RandomInt(5)
    local Spot = Data.Coords

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Model, { x = Spot.x, y = Spot.y, z = Spot.z, a = Spot.w }, false, Plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    
    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    SetEntityVisible(Vehicle, false)
    NetworkRequestControlOfEntity(Vehicle)

    Citizen.SetTimeout(500, function()
        exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
        exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
        NetworkRegisterEntityAsNetworked(Vehicle)
        SetEntityVisible(Vehicle, true)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)

        local Liveries = {
            ['UPD'] = 0,
            ['LSPD'] = 0,
            ['RANGER'] = 0,
            ['BCSO'] = 1,
            ['PBSO'] = 1,
            ['SDSO'] = 2,
            ['SASP'] = 2,
        }
        SetVehicleLivery(Vehicle, Liveries[FW.Functions.GetPlayerData().metadata.department])
    end)
end)

RegisterNetEvent('fw-police:Client:SpawnBoat')
AddEventHandler('fw-police:Client:SpawnBoat', function()
    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob.name ~= 'police' and PlayerJob.name ~= 'ems' then return end

    if GetVehiclePedIsIn(PlayerPedId()) then
        local Vehicle = GetVehiclePedIsIn(PlayerPedId())

        if GetEntityModel(Vehicle) == GetHashKey("predator") or GetEntityModel(Vehicle) == GetHashKey("dinghy4") then
            FW.VSync.DeleteVehicle(Vehicle)
            return
        end
    end

    local Model = PlayerJob.name == "ems" and "dinghy4" or "predator"
    RequestModel(Model)
    while not HasModelLoaded(Model) do
        Citizen.Wait(4)
    end
    
    local Plate = "PBO" .. FW.Shared.RandomInt(5)
    local Spot = vector4(-796.4, -1502.84, 0.12, 109.14)

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Model, { x = Spot.x, y = Spot.y, z = Spot.z, a = Spot.w }, false, Plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    
    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    SetEntityVisible(Vehicle, false)
    NetworkRequestControlOfEntity(Vehicle)

    Citizen.SetTimeout(500, function()
        exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
        exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
        NetworkRegisterEntityAsNetworked(Vehicle)
        SetEntityVisible(Vehicle, true)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)
        TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
    end)
end)
