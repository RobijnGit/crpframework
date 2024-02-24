local HasPackage = false
local DeliveryVehicle = nil
local DeliveryJob = Data

RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'postop' then return end
    DeliveryJob = Data

    if IsLeader then
        Citizen.CreateThread(function()
            local ShowingInteraction = false
            while true do
                DrawMarker(20, 929.99, -1249.48, 27.5, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 138, 43, 226, 150, true, true, false, false, false, false, false)

                if #(GetEntityCoords(PlayerPedId()) - vector3(929.99, -1249.48, 25.5)) < 1.2 then
                    if not ShowingInteraction then
                        exports['fw-ui']:ShowInteraction("[E] Vraag de werkgever om een voertuig.")
                        ShowingInteraction = true
                    end

                    if IsControlJustReleased(0, 38) then
                        if FW.Functions.IsSpawnPointClear(vector3(929.08, -1227.19, 25.58), 1.85) then
                            exports['fw-ui']:HideInteraction()
                            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
                            TriggerServerEvent('fw-jobmanager:Server:SpawnDeliveryVehicle', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
                            ShowingInteraction = false
                            return
                        else
                            FW.Functions.Notify("De werkgever kan je geen voertuig geven: er staat iets in de weg..", "error")
                        end
                    end
                elseif ShowingInteraction then
                    exports['fw-ui']:HideInteraction()
                end

                Citizen.Wait(4)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'postop' then return end

    if TaskId == 3 then
        SetRouteBlip("Winkel", vector3(DeliveryJob.Store.x, DeliveryJob.Store.y, DeliveryJob.Store.z))

        if IsLeader then
            Citizen.CreateThread(function()
                while CurrentTaskId and CurrentTaskId == 3 do
    
                    if #(GetEntityCoords(PlayerPedId()) - DeliveryJob.Store) < 25.0 then
                        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
                        RemoveRouteBlip()
                        return
                    end
    
                    Citizen.Wait(500)
                end
            end)
        end
    elseif TaskId == 5 then
        SetRouteBlip("24/7 Logistiek", vector3(927.73, -1246.89, 25.5))

        if IsLeader then
            Citizen.CreateThread(function()
                while CurrentTaskId and CurrentTaskId == 5 do
    
                    if #(GetEntityCoords(PlayerPedId()) - vector3(927.73, -1246.89, 25.5)) < 25.0 and GetVehiclePedIsIn(PlayerPedId()) <= 0 then
                        Citizen.SetTimeout(1000, function()
                            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 5, 1)
                            TriggerServerEvent("fw-jobmanager:Server:DeleteDeliveryVehicle", MyJob.CurrentGroup.Activity.Id)
                        end)
                    end
    
                    Citizen.Wait(500)
                end
            end)
        end
    end
end)

RegisterNetEvent("fw-jobmanager:Client:PostOp:GrabGoods")
AddEventHandler("fw-jobmanager:Client:PostOp:GrabGoods", function()
    if HasPackage then return FW.Functions.Notify("Je hebt al een pakketje vast..", "error") end

    HasPackage = true
    exports['fw-assets']:AddProp('Box')

    RequestAnimDict("anim@heists@box_carry@")
    while not HasAnimDictLoaded("anim@heists@box_carry@") do Citizen.Wait(4) end

    Citizen.CreateThread(function()
        while HasPackage do
            if not IsEntityPlayingAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 3) then
                TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 2.0, 2.0, -1, 51, 0, false, false, false)
            end

            Citizen.Wait(100)
        end

        StopAnimTask(PlayerPedId(), "anim@heists@box_carry@", "idle", 1.0)
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:PostOP:DeliverGoods")
AddEventHandler("fw-jobmanager:Client:PostOP:DeliverGoods", function()
    if exports['fw-progressbar']:GetTaskBarStatus() then return end

    if not HasPackage then
        return FW.Functions.Notify("Pak eerst een pakketje uit je busje..", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(math.random(700, 1300), "Pakketje afleveren...", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    if not Finished then return end

    if CurrentTaskId == 4 then
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
    end

    HasPackage = false
    exports['fw-assets']:RemoveProp()
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'postop' then return end

    if HasPackage then
        exports['fw-assets']:RemoveProp()
    end

    RemoveRouteBlip()
    HasPackage = false
end)

RegisterNetEvent('fw-jobmanager:Client:SetDeliveryVehicle')
AddEventHandler('fw-jobmanager:Client:SetDeliveryVehicle', function(NetId)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    local Vehicle = NetToVeh(NetId)

    Citizen.SetTimeout(500, function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
        exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
        DeliveryVehicle = Vehicle
    end)
end)

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    local Model = GetEntityModel(Vehicle)
    if Model ~= GetHashKey("benson") then return end

    if not MyJob.CurrentJob or MyJob.CurrentJob ~= 'postop' then return end

    if CurrentTaskId ~= 2 then return end
    if Vehicle ~= DeliveryVehicle then return end

    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
end)

function IsNearDeliveryStore()
    return #(GetEntityCoords(PlayerPedId()) - DeliveryJob.Store) < 2.5
end
exports("IsNearDeliveryStore", IsNearDeliveryStore)