-- Interactions
local HasBag, FirstZone, SecondZone = false, nil, nil
local InSanitationZone = false

local SingleBagDumpsters = {
    [GetHashKey('prop_cs_rub_binbag_01')] = true,
    [GetHashKey('prop_ld_binbag_01')] = true,
    [GetHashKey('prop_ld_rub_binbag_01')] = true,
    [GetHashKey('prop_rub_binbag_sd_01')] = true,
    [GetHashKey('prop_rub_binbag_sd_02')] = true,
    [GetHashKey('prop_cs_street_binbag_01')] = true,
    [GetHashKey('p_binbag_01_s')] = true,
    [GetHashKey('ng_proc_binbag_01a')] = true,
    [GetHashKey('p_rub_binbag_test')] = true,
    [GetHashKey('prop_rub_binbag_01')] = true,
    [GetHashKey('prop_rub_binbag_04')] = true,
    [GetHashKey('prop_rub_binbag_05')] = true,
    [GetHashKey('bkr_prop_fakeid_binbag_01')] = true,
    [GetHashKey('hei_prop_heist_binbag')] = true,
    [GetHashKey('prop_rub_binbag_01b')] = true,
    [GetHashKey('prop_rub_binbag_03')] = true,
    [GetHashKey('prop_rub_binbag_03b')] = true,
    [GetHashKey('prop_rub_binbag_06')] = true,
    [GetHashKey('prop_rub_binbag_08')] = true,
    [GetHashKey('ch_chint10_binbags_smallroom_01')] = true,
    [GetHashKey('prop_cs_bin_01')] = true,
    [GetHashKey('prop_cs_bin_03')] = true,
    [GetHashKey('prop_bin_08a')] = true,
    [GetHashKey('prop_bin_08open')] = true,
}

local SanitationDumpsters = {
    'prop_dumpster_01a',
    'prop_dumpster_02a',
    'prop_dumpster_02b',
    'prop_dumpster_3a',
    'prop_dumpster_4a',
    'prop_dumpster_4b',
    'prop_cs_bin_01',
    'prop_cs_bin_03',
    'prop_bin_08a',
    'prop_bin_08open',
    -- Bags
    'prop_cs_rub_binbag_01',
    'prop_ld_binbag_01',
    'prop_ld_rub_binbag_01',
    'prop_rub_binbag_sd_01',
    'prop_rub_binbag_sd_02',
    'prop_cs_street_binbag_01',
    'p_binbag_01_s',
    'ng_proc_binbag_01a',
    'p_rub_binbag_test',
    'prop_rub_binbag_01',
    'prop_rub_binbag_04',
    'prop_rub_binbag_05',
    'bkr_prop_fakeid_binbag_01',
    'hei_prop_heist_binbag',
    'prop_rub_binbag_01b',
    'prop_rub_binbag_03',
    'prop_rub_binbag_03b',
    'prop_rub_binbag_06',
    'prop_rub_binbag_08',
    'ch_chint10_binbags_smallroom_01',
}

-- Loops
RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    for k, v in pairs(SanitationDumpsters) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
            Type = 'Model',
            Model = v,
            SpriteDistance = 3.0,
            Options = {
                {
                    Name = 'sanitation_pickup_trash',
                    Icon = 'fas fa-circle',
                    Label = 'Vuilniszak Pakken',
                    EventType = 'Client',
                    EventName = 'fw-jobmanager:Client:Sanitation:PickupTrash',
                    EventParams = '',
                    Enabled = function(Entity)
                        local MyJob = exports['fw-jobmanager']:GetMyJob()
                        if MyJob.CurrentJob ~= 'sanitation' then return false end

                        if exports['fw-jobmanager']:GetCurrentTaskId() ~= 4 and exports['fw-jobmanager']:GetCurrentTaskId() ~= 6 then
                            return false
                        end

                        return true
                    end,
                }
            }
        })
    end

    exports['fw-ui']:AddEyeEntry("sanitation_exchange_recycle", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.5,
        Position = vector4(-355.69, -1556.31, 24.17, 178.6),
        Model = 's_m_y_garbage',
        Options = {
            {
                Name = 'exchange_recyclables',
                Icon = 'fas fa-circle',
                Label = 'Recyclebaar Materiaal Ruilen',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:Sanitation:ExchangeRecyclables',
                EventParams = {},
                Enabled = function(Entity) return true end,
            },
        }
    })
end)

-- Events
RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'sanitation' then return end

    FirstZone, SecondZone = Data.FirstZone, Data.SecondZone

    if IsLeader then
        local ShowingInteraction = false

        Citizen.CreateThread(function()
            while true do
                DrawMarker(20, -353.10, -1546.22, 28.9, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 138, 43, 226, 150, true, true, false, false, false, false, false)

                if #(GetEntityCoords(PlayerPedId()) - vector3(-353.10, -1546.22, 26.8)) < 1.5 then
                    if not ShowingInteraction then
                        ShowingInteraction = true
                        exports['fw-ui']:ShowInteraction("[E] Vraag de werkgever om een voertuig.")
                    end

                    if IsControlJustPressed(0, 38) then
                        if FW.Functions.IsSpawnPointClear(vector3(-335.41, -1564.36, 24.95), 1.85) then
                            exports['fw-ui']:HideInteraction()
                            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
                            TriggerServerEvent('fw-jobmanager:Server:SpawnSanitationVehicle', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
                            ShowingInteraction = false
                            return
                        else
                            FW.Functions.Notify("De werkgever kan je geen voertuig geven: er staat iets in de weg..", "error")
                        end

                    end
                elseif ShowingInteraction then
                    ShowingInteraction = false
                    exports['fw-ui']:HideInteraction()
                end

                Citizen.Wait(4)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'sanitation' then return end

    if TaskId == 3 or TaskId == 5 then
        Citizen.SetTimeout(250, function()
            Citizen.CreateThread(function()
                while CurrentTaskId and CurrentTaskId >= 3 and CurrentTaskId <= 6 do
                    local Coords = GetEntityCoords(PlayerPedId())
                    local Zone = GetLabelText(GetNameOfZone(Coords.x, Coords.y, Coords.z))

                    if TaskId == 3 then
                        if Zone == FirstZone.Label then
                            if CurrentTaskId == 3 then
                                FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
                            end

                            InSanitationZone = true
                        else
                            InSanitationZone = false
                        end
                    else
                        if Zone == SecondZone.Label then
                            if CurrentTaskId == 5 then
                                FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 5, 1)
                            end

                            InSanitationZone = true
                        else
                            InSanitationZone = false
                        end
                    end

                    Citizen.Wait(500)
                end
            end)
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'sanitation' then return end
    
    if HasBag then
        if IsEntityPlayingAnim(PlayerPedId(), 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
            StopAnimTask(PlayerPedId(), 'missfbi4prepp1', '_bag_walk_garbage_man', 1.0)
        end
        
        exports['fw-assets']:RemoveProp()
        HasBag = false
    end
end)

RegisterNetEvent("fw-jobmanager:Client:SetSanitationVehicle")
AddEventHandler("fw-jobmanager:Client:SetSanitationVehicle", function(NetId)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    local Vehicle = NetToVeh(NetId)

    Citizen.SetTimeout(500, function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
        exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:Sanitation:ThrowInTrash")
AddEventHandler("fw-jobmanager:Client:Sanitation:ThrowInTrash", function(Data, Entity)
    if CurrentTaskId ~= 4 and CurrentTaskId ~= 6 then return end
    if HasBag == false then FW.Functions.Notify("Welke vuilniszak wil jij weggooien dan?", "error") return end
    
    HasBag = false
    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, -1)
    RequestAnimDict('missfbi4prepp1')
    while not HasAnimDictLoaded("missfbi4prepp1") do Citizen.Wait(10) end

    TaskPlayAnim(PlayerPedId(), 'missfbi4prepp1', '_bag_throw_garbage_man', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    FreezeEntityPosition(PlayerPedId(), true)
    CanTakeBag = false

    Citizen.SetTimeout(1250, function()
        exports['fw-assets']:RemoveProp()
        TaskPlayAnim(PlayerPedId(), 'missfbi4prepp1', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        FreezeEntityPosition(PlayerPedId(), false)

        if math.random(1, 100) <= 50 then
            TriggerServerEvent('fw-jobmanager:Server:GiveSanitationReward', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
        end

        ClearPedTasks(PlayerPedId())

        if CurrentTaskId == 4 then
            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        elseif CurrentTaskId == 6 then
            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 6, 1)
        end
    end)
end)

RegisterNetEvent('fw-jobmanager:Client:Sanitation:PickupTrash', function(Data, Entity)
    if HasBag then FW.Functions.Notify("Je hebt al een vuilniszak vast..", "error") return end

    local IsEmpty = FW.SendCallback("fw-jobmanager:Server:Sanitation:IsDumpsterEmpty", NetworkGetNetworkIdFromEntity(Entity))
    if IsEmpty then
        if SingleBagDumpsters[GetEntityModel(Entity)] then
            FW.Functions.Notify("Zie jij spook-vuilniszakken?", "error")
        else
            FW.Functions.Notify("Deze container ziet er nogal leeg uit..", "error")
        end
        return
    end

    exports['fw-assets']:AddProp("Trash")
    RequestAnimDict("missfbi4prepp1")
    while not HasAnimDictLoaded("missfbi4prepp1") do Citizen.Wait(4) end
    HasBag = true
    
    Citizen.CreateThread(function()
        while HasBag do
            if not IsEntityPlayingAnim(PlayerPedId(), 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
                TaskPlayAnim(PlayerPedId(), 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            
            Citizen.Wait(500)
        end
    end)

    if SingleBagDumpsters[GetEntityModel(Entity)] then
        TriggerServerEvent('fw-jobmanager:Server:Sanitation:DeleteBinbag', NetworkGetNetworkIdFromEntity(Entity))
    end
end)

RegisterNetEvent("FW:Vehicle:OnThreadChange")
AddEventHandler("FW:Vehicle:OnThreadChange", function()
    if MyJob.CurrentJob ~= 'sanitation' then return end
    if not MyJob.CurrentGroup.Activity then return end

    local Vehicle = GetVehiclePedIsIn(PlayerPedId())

    if (Vehicle == 0 or Vehicle == -1) and CurrentTaskId == 7 and MyJob.CurrentGroup.Members[1].Cid == FW.Functions.GetPlayerData().citizenid then
        Vehicle = GetVehiclePedIsIn(PlayerPedId(), true)

        if #(GetEntityCoords(PlayerPedId()) - vector3(-349.49, -1541.75, 27.72)) <= 25.0 then
            Citizen.SetTimeout(1000, function()
                FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 7, 1)
                TriggerServerEvent("fw-jobmanager:Server:DeleteSanitationVehicle", MyJob.CurrentGroup.Activity.Id)
            end)
        end

        return
    end

    if GetEntityModel(Vehicle) ~= GetHashKey("trash") then return end

    if CurrentTaskId == 2 then
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:Sanitation:ExchangeRecyclables', function(Data, Entity)
    Citizen.SetTimeout(450, function()
        if exports['fw-inventory']:CanOpenInventory() then
            FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'Recycle')
        end
    end)
end)