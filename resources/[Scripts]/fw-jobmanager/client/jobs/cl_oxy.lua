local TransportVehicle, OxyData, CurrentOxy, OxyVehicle = nil, nil, nil, nil

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("oxy-supplier", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 5.0,
        Position = vector4(-459.21, -64.0, 43.51, 41.49),
        Model = 'u_m_m_streetart_01',
        Anim = {},
        Props = {},
        Options = {
            {
                Name = 'oxy_collect',
                Icon = 'fas fa-box',
                Label = 'Goederen Pakken',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:Oxy:CollectPackage',
                EventParams = '',
                Enabled = function(Entity)
                    local MyJob = exports['fw-jobmanager']:GetMyJob()
                    if MyJob.CurrentJob ~= 'oxy' then return false end

                    local TaskId = exports['fw-jobmanager']:GetCurrentTaskId()
                    if TaskId ~= 2 then return false end

                    return (exports['fw-inventory']:HasEnoughOfItem('vpn', 1) or exports['fw-inventory']:HasEnoughOfItem('darkmarketdeliveries', 1))
                end,
            },
        }
    })
end)

RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'oxy' then return end

    OxyData = Data
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'oxy' then return end

    if TaskId == 3 then
        SetRouteBlip("Aflever Locatie", OxyData.FirstOxy.Coords)

        if IsLeader then
            SetupOxyLocation(TaskId, OxyData.FirstOxy)
        else
            CurrentOxy = OxyData.FirstOxy
        end
    elseif TaskId == 5 then
        SetRouteBlip("Aflever Locatie", OxyData.SecondOxy.Coords)

        if IsLeader then
            SetupOxyLocation(TaskId, OxyData.SecondOxy)
        else
            CurrentOxy = OxyData.SecondOxy
        end
    end
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'oxy' then return end
    TransportVehicle = nil
end)

RegisterNetEvent("fw-vehicles:Client:OnLockpickSuccess")
AddEventHandler("fw-vehicles:Client:OnLockpickSuccess", function(Vehicle, ReceivedKeys)
    if not ReceivedKeys then return end
    if MyJob.CurrentJob ~= 'oxy' then return end
    if MyJob.CurrentGroup == nil or MyJob.CurrentGroup.Activity == nil then return end

    if MyJob.CurrentGroup.Activity.Id == nil then return end

    TransportVehicle = Vehicle
    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)

    SetRouteBlip("", { GetEntityCoords(PlayerPedId()), vector3(-459.21, -64.0, 43.51) }, true)

    Citizen.CreateThread(function()
        local NearSupplier = false
        while not NearSupplier do
            if #(GetEntityCoords(PlayerPedId()) - vector3(-459.21, -64.0, 43.51)) <= 5.0 then
                NearSupplier = true
            end
            Citizen.Wait(500)
        end

        RemoveRouteBlip()
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:Oxy:CollectPackage")
AddEventHandler("fw-jobmanager:Client:Oxy:CollectPackage", function()
    if CurrentTaskId ~= 2 then return FW.Functions.Notify("Wat moet je?", "error") end
    if exports['fw-inventory']:HasEnoughOfItem('oxy-box', 1) then return FW.Functions.Notify("Je hebt al een doos, leg die maar eerst weg.", "error") end
    
    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
    TriggerServerEvent("fw-jobmanager:Server:Oxy:CollectPackage")
end)

RegisterNetEvent("fw-jobmanager:Client:Oxy:SetOxyVehicle")
AddEventHandler("fw-jobmanager:Client:Oxy:SetOxyVehicle", function(Clear, PedNetId, VehicleNetId)
    if Clear then
        OxyVehicle = nil
        return
    end

    while not NetworkDoesEntityExistWithNetworkId(VehicleNetId) do Citizen.Wait(100) end
    local Vehicle = NetToVeh(VehicleNetId)

    while not NetworkDoesEntityExistWithNetworkId(PedNetId) do Citizen.Wait(100) end
    local Ped = NetToVeh(PedNetId)

    SetPedDefaultComponentVariation(Ped)
    SetBlockingOfNonTemporaryEvents(Ped, true)

    Citizen.SetTimeout(500, function()
        OxyVehicle = Vehicle
        TaskVehicleDriveToCoord(Ped, Vehicle, CurrentOxy.Coords.x, CurrentOxy.Coords.y, CurrentOxy.Coords.z, 15.0, 1, GetEntityModel(Vehicle), 786603, 5.0, true)
    end)

    Citizen.SetTimeout(30000, function()
        if OxyVehicle == Vehicle then
            FW.Functions.Notify("Dud, honderd jaren plan met jou of wat?", "error")
            TaskVehicleDriveWander(Ped, Vehicle, 30.0, 786603)

            Citizen.SetTimeout(15000, function()
                TriggerServerEvent('fw-jobmanager:Server:DeleteOxyVehicle', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
            end)
        end
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:Oxy:DeliverGoods")
AddEventHandler("fw-jobmanager:Client:Oxy:DeliverGoods", function(Data, Entity)
    if Entity ~= OxyVehicle then
        return
    end

    if math.random() < 0.4 then
        TriggerServerEvent("fw-mdw:Server:SendAlert:Oxy", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())
    end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Removed = FW.SendCallback("fw-jobmanager:Server:Oxy:DeliverGoods", MyJob.CurrentGroup.Id)
    if Removed then
        TaskVehicleDriveWander(GetPedInVehicleSeat(Entity, -1), Entity, 30.0, 786603)
        Citizen.SetTimeout(15000, function()
            TriggerServerEvent('fw-jobmanager:Server:DeleteOxyVehicle', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
        end)

        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, CurrentTaskId, 1)
    end
end)

function SetupOxyLocation(TaskId, Data)
    CurrentOxy = Data
    Citizen.CreateThread(function()
        while CurrentTaskId == TaskId do
            local Vehicle = GetVehiclePedIsIn(PlayerPedId())
            if #(GetEntityCoords(PlayerPedId()) - vector3(Data.Coords.x, Data.Coords.y, Data.Coords.z)) <= 25 then
                RemoveRouteBlip()
                FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, TaskId, 1)
                break
            end

            Citizen.Wait(500)
        end

        Citizen.Wait(1000)

        local WaitMS, Notified = 50, false
        while CurrentTaskId == TaskId + 1 do
            if #(GetEntityCoords(PlayerPedId()) - vector3(Data.Coords.x, Data.Coords.y, Data.Coords.z)) <= 20 then
                if not Notified then
                    WaitMS, Notified = 60000, true
                    FW.Functions.Notify("Blijf hier, wees niet verdacht..", "error")
                    exports['fw-assets']:SetDensity('Vehicle', 0.8)
                end

                if not OxyVehicle then
                    TriggerServerEvent("fw-jobmanager:Server:CreateOxyVehicle", Data.Spawner, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
                end
            elseif Notified then
                WaitMS, Notified = 50, false
                FW.Functions.Notify("Je bent te ver weg, ga terug..", "error")
                exports['fw-assets']:SetDensity('Vehicle', 0.55)
            end

            Citizen.Wait(WaitMS)
        end
    end)
end

exports("IsOxyVehicle", function(Entity)
    return Entity == OxyVehicle
end)

-- RegisterCommand("skip", function()
--     FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, CurrentTaskId, 1)
-- end)