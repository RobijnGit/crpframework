local AnchoredBoats, Synced = {}, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
 	Citizen.SetTimeout(1250, function()
        FW.Functions.TriggerCallback('fw-items:server:sync:anchor:config', function(Config) 
            AnchoredBoats = Config
        end)

        -- print(json.encode(AnchoredBoats))
 	end)
end)

RegisterNetEvent('fw-items:use:item:anker')
AddEventHandler('fw-items:use:item:anker', function(Source) 
    local Vehicle = FW.Functions.GetClosestVehicle()
    if GetVehicleClass(Vehicle) == 14 then
        if not exports['fw-progressbar']:GetTaskBarStatus() then
            exports["fw-inventory"]:SetBusyState(true)
            TriggerEvent("fw-misc:Client:PlaySoundEntity", 'vehicle.anchorDrop', NetworkGetNetworkIdFromEntity(Vehicle), true, nil)
            FW.Functions.Progressbar("use_anker", "Anker uitgooien..", 5000, false, true, {}, {}, {}, {}, function() -- Done
                exports["fw-inventory"]:SetBusyState(false)
                TriggerServerEvent('fw-items:server:sync:item:anchor', GetVehicleNumberPlateText(Vehicle), true)
                TaskPlayAnim(PlayerPedId(), 'missfbi4prepp1', '_bag_drop_garbage_man', 8.0, -8, -1, 16, 0, 0, 0, 0);
                FW.Functions.Notify('Het anker is uitgegooid..', 'success')
            end)
        end
    end
end)


RegisterNetEvent('fw-items:client:sync:item:anchor')
AddEventHandler('fw-items:client:sync:item:anchor', function(Plate, Toggle, NewAnchoredBoats)
    AnchoredBoats = NewAnchoredBoats

    local Vehicle = FW.Functions.GetClosestVehicle()
    if Plate == GetVehicleNumberPlateText(Vehicle) then
        Synced = true
        SetBoatAnchor(Vehicle, Toggle)
        SetForcedBoatLocationWhenAnchored(Vehicle, Toggle)
    end
end)

RegisterNetEvent('fw-items:use:item:anker:tilt')
AddEventHandler('fw-items:use:item:anker:tilt', function() 
    local Vehicle = FW.Functions.GetClosestVehicle()

    TriggerEvent("fw-misc:Client:PlaySoundEntity", 'vehicle.anchorRaise', NetworkGetNetworkIdFromEntity(Vehicle), true, nil)
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        exports["fw-inventory"]:SetBusyState(true)
        FW.Functions.Progressbar("use_anker", "Anker ophalen..", 5000, false, true, {}, {}, {}, {}, function() -- Done
            exports["fw-inventory"]:SetBusyState(false)
            TriggerServerEvent('fw-items:server:sync:item:anchor', GetVehicleNumberPlateText(Vehicle), false)
            FW.Functions.Notify('Het anker is opgehaald..', 'success')
        end)
    end
end)

local WasNearVehicle = false
local Count = 0

Citizen.CreateThread(function() 
    while true do
        Wait(0)
        local NearVehicle = false
        local Vehicle = FW.Functions.GetClosestVehicle()
        local VehicleCoords = GetEntityCoords(Vehicle)
    
        if GetVehicleClass(Vehicle) == 14 then
            if AnchoredBoats[GetVehicleNumberPlateText(Vehicle)] and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), VehicleCoords.x, VehicleCoords.y, VehicleCoords.z, false) <= 2.0 then
                WasNearVehicle = true
                NearVehicle = true

                if not Synced then
                    SetBoatAnchor(Vehicle, true)
                    SetForcedBoatLocationWhenAnchored(Vehicle, true)
                    Synced = true
                end

                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    TaskLeaveVehicle(PlayerPedId(), Vehicle, 16)

                    if not IsPedSittingInAnyVehicle(PlayerPedId()) then
                        SetBoatAnchor(Vehicle, true)
                        SetForcedBoatLocationWhenAnchored(Vehicle, true)

                        Count = Count + 1
                        Wait(1300)
                            
                        if not ShowedNotify then 
                            if Count == 2 then
                                FW.Functions.Notify('Je kan pas weer varen als het anker opgehaald is', 'error')
                                ShowedNotify = true
                                Count = 0
                            end
                        end
                    end
                end
            else
                if WasNearVehicle then 
                    exports['fw-ui']:HideInteraction()
                    WasNearVehicle = false
                end
            end
        end

        if not NearVehicle then
            Wait(1000)
        end

        if ShowedNotify then
            Wait(1300)
            ShowedNotify = false
        end
    end
end)

exports('CanDropAnchor', function() 
    local Vehicle = FW.Functions.GetClosestVehicle()
    if GetVehicleClass(Vehicle) == 14 then
        if not AnchoredBoats[GetVehicleNumberPlateText(Vehicle)] then
            return true
        end
    end
end)

exports('CanTiltAnchor', function() 
    local Vehicle = FW.Functions.GetClosestVehicle()
    if GetVehicleClass(Vehicle) == 14 then
        if AnchoredBoats[GetVehicleNumberPlateText(Vehicle)] then
            return true
        end
    end
end)

