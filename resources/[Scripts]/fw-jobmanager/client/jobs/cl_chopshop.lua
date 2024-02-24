local WantedPlate = nil
local ScrapyardBlip = false
local Scrapyard = nil

local VehicleScrapBones = {
    ['wheel_lf'] = { Text = "Band", Index = 0 },
    ['wheel_rf'] = { Text = "Band", Index = 1 },
    ['wheel_lm'] = { Text = "Band", Index = 2 },
    ['wheel_rm'] = { Text = "Band", Index = 3 },
    ['wheel_lr'] = { Text = "Band", Index = 4 },
    ['wheel_rr'] = { Text = "Band", Index = 5 },
    ['wheel_lm1'] = { Text = "Band", Index = 2 },
    ['wheel_rm1'] = { Text = "Band", Index = 3 },
    ['door_dside_f'] = { Text = 'Deur', Index = 0 },
    ['door_pside_f'] = { Text = 'Deur', Index = 1 },
    ['door_dside_r'] = { Text = 'Deur', Index = 2 },
    ['door_pside_r'] = { Text = 'Deur', Index = 3 },
    ['bonnet'] = { Text = 'Deur', Index = 4 },
    ['boot'] = { Text = 'Deur', Index = 5 },
}

function GetValidBones(Vehicle)
    local Retval = {}

    for k, v in pairs(VehicleScrapBones) do
        local BoneIndex = GetEntityBoneIndexByName(Vehicle, k)
        if BoneIndex ~= -1 then
            if v.Text == "Deur" and not IsVehicleDoorDamaged(Vehicle, v.Index) or v.Text == "Band" and not IsVehicleTyreBurst(Vehicle, v.Index, 1) then
                Retval[#Retval + 1] = {
                    Text = v.Text,
                    Index = v.Index,
                    Id = BoneIndex
                }
            end
        end
    end

    return Retval
end

function GetClosestBone(Vehicle, Bones)
    local PedCoords = GetEntityCoords(PlayerPedId())
    local BoneData, BoneIndex, BoneCoords, BoneDistance = {}, nil, nil, nil

    for k, v in pairs(Bones) do
        local Coords = GetWorldPositionOfEntityBone(Vehicle, v.Id)
        local Distance = #(PedCoords - Coords)

        if not BoneCoords then
            BoneData, BoneIndex, BoneCoords, BoneDistance = v, v.Id, Coords, Distance
        elseif BoneDistance > Distance then
            BoneData, BoneIndex, BoneCoords, BoneDistance = v, v.Id, Coords, Distance
        end
    end

    if not BoneIndex then
        BoneIndex = GetEntityBoneIndexByName(Vehicle, "bodyshell")
        BoneCoords = GetWorldPositionOfEntityBone(Vehicle, Bodyshell)
        BoneDistance = #(PedCoords - BoneCoords)
        BoneData = { Text = 'Overblijfselen' }
        BoneData.Id = BoneIndex
    end

    return BoneData, BoneIndex, BoneCoords, BoneDistance
end

RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'chopshop' then return end

    Scrapyard = Data.Scrapyard
    if IsLeader then
        TriggerServerEvent('fw-jobmanager:Server:CreateChopVehicle', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'chopshop' then return end

    if TaskId == 3 then
        if not Scrapyard then return end
        SetRouteBlip("Scrapyard", vector3(Scrapyard.x, Scrapyard.y, Scrapyard.z))

        Citizen.CreateThread(function()
            while true do
                local CurrentTask = FW.SendCallback('fw-jobmanager:Server:GetGroupCurrentTask', MyJob.CurrentJob, MyJob.CurrentGroup.Id)
                if CurrentTask.TaskId ~= 3 then
                    break
                end
    
                if #(GetEntityCoords(PlayerPedId()) - Scrapyard) < 10.0 then
                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
                end
    
                Citizen.Wait(1000)
            end
        end)
    elseif TaskId == 5 then
        Citizen.CreateThread(function()
            while true do
                local CurrentTask = FW.SendCallback('fw-jobmanager:Server:GetGroupCurrentTask', MyJob.CurrentJob, MyJob.CurrentGroup.Id)
                if CurrentTask.TaskId ~= 5 then
                    break
                end
    
                if #(GetEntityCoords(PlayerPedId()) - Scrapyard) > 50.0 then
                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 5, 1)
                end
    
                Citizen.Wait(1000)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'chopshop' then return end

    RemoveRouteBlip()
    TriggerServerEvent('fw-jobmanager:Server:DeleteChopVehicle', MyJob.CurrentGroup.Activity.Id, true)
end)

RegisterNetEvent("fw-vehicles:Client:OnLockpickSuccess")
AddEventHandler("fw-vehicles:Client:OnLockpickSuccess", function(Vehicle, ReceivedKeys)
    if not ReceivedKeys then return end
    if MyJob.CurrentJob ~= 'chopshop' then return end

    if MyJob.CurrentGroup.Activity.Id == nil then return end
    if GetVehicleNumberPlateText(Vehicle) ~= WantedPlate then return end
    
    local CurrentTask = FW.SendCallback('fw-jobmanager:Server:GetGroupCurrentTask', MyJob.CurrentJob, MyJob.CurrentGroup.Id)
    if CurrentTask.TaskId == 2 then
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
    end
end)

RegisterNetEvent("fw-jobmanager:Client:Chopshop:CreateBlip")
AddEventHandler("fw-jobmanager:Client:Chopshop:CreateBlip", function(Coords, NetId)
    SetRouteBlip("Voertuig", vector3(Coords.x, Coords.y, Coords.z))

    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    local Vehicle = NetToVeh(NetId)

    Citizen.SetTimeout(500, function()
        WantedPlate = GetVehicleNumberPlateText(Vehicle)
    
        Citizen.CreateThread(function()
            while true do
                local CurrentTask = FW.SendCallback('fw-jobmanager:Server:GetGroupCurrentTask', MyJob.CurrentJob, MyJob.CurrentGroup.Id)
                if CurrentTask.TaskId ~= 1 then
                    RemoveRouteBlip()
                    break
                end
    
                if #(GetEntityCoords(PlayerPedId()) - vector3(Coords.x, Coords.y, Coords.z)) < 50.0 then
                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
                end
    
                Citizen.Wait(1000)
            end
        end)
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:StartChopProcess")
AddEventHandler("fw-jobmanager:Client:StartChopProcess", function(Data, Entity)
    Citizen.CreateThread(function()
        local BoneData, BoneIndex, BoneCoords, BoneDistance = nil, nil, nil, nil

        local LastTaskCheck = 0
        local LastBoneCheck = 0
        local ShowingInteraction = false

        RequestStreamedTextureDict("shared")

        RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
        while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do Citizen.Wait(4) end

        RequestAnimDict("mp_car_bomb")
        while not HasAnimDictLoaded("mp_car_bomb") do Citizen.Wait(4) end

        while CurrentTaskId == 4 do
            if GetGameTimer() - LastBoneCheck > 200 then
                LastBoneCheck = GetGameTimer()
                BoneData, BoneIndex, BoneCoords, BoneDistance = GetClosestBone(Entity, GetValidBones(Entity))
            end

            if BoneCoords then
                if (BoneData.Text == "Band" and BoneDistance < 1.2) or (BoneData.Text == "Deur" and BoneDistance < 1.6) or (BoneData.Text == "Overblijfselen" and BoneDistance < 1.8) then
                    if not ShowingInteraction then
                        ShowingInteraction = true
                        exports['fw-ui']:ShowInteraction("[E] Scrap Voertuig " .. BoneData.Text)
                    end
                    
                    if IsControlJustPressed(0, 38) then
                        if BoneData.Text == "Band" and not IsVehicleTyreBurst(Entity, BoneData.Index, 1) then
                            ShowingInteraction = false
                            exports['fw-ui']:HideInteraction()
                            TaskTurnPedToFaceCoord(PlayerPedId(), BoneCoords.x, BoneCoords.y, BoneCoords.z)
                            TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 2.0, 2.0, -1, 1, 0, false, false, false)
                            local Outcome = StartProgress(10000, "Band scrappen...", true)
                            StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                            if Outcome then
                                if not IsVehicleTyreBurst(Entity, BoneData.Index, true) then
                                    FW.TriggerServer("fw-jobmanager:Server:ReceiveChopReward", MyJob.CurrentGroup.Activity.Id, VehToNet(Entity))
                                    FW.VSync.SetVehicleTyreBurst(Entity, BoneData.Index, true, 1000.0)
                                end
                            end
                            ShowingInteraction = false
                            exports['fw-ui']:HideInteraction()
                        elseif BoneData.Text == "Deur" and not IsVehicleDoorDamaged(Entity, BoneData.Index) then
                            TaskTurnPedToFaceCoord(PlayerPedId(), BoneCoords.x, BoneCoords.y, BoneCoords.z)
                            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_WELDING", 0, true)
                            local Outcome = StartProgress(14000, "Deur scrappen...", true)
                            ClearPedTasks(PlayerPedId())
                            if Outcome then
                                if not IsVehicleDoorDamaged(Entity, BoneData.Index) then
                                    FW.TriggerServer("fw-jobmanager:Server:ReceiveChopReward", MyJob.CurrentGroup.Activity.Id, VehToNet(Entity))
                                    FW.VSync.SetVehicleDoorBroken(Entity, BoneData.Index, true)
                                end
                            end
                        elseif BoneData.Text == "Overblijfselen" then
                            ShowingInteraction = false
                            exports['fw-ui']:HideInteraction()
                            TaskTurnPedToFaceCoord(PlayerPedId(), BoneCoords.x, BoneCoords.y, BoneCoords.z)
                            TaskPlayAnim(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 2.0, 2.0, -1, 1, 0, false, false, false)
                            local Outcome = StartProgress(25000, "Auto scrappen...", true)
                            StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
                            if Outcome then
                                if DoesEntityExist(Entity) then
                                    TriggerServerEvent('fw-jobmanager:Server:DeleteChopVehicle', MyJob.CurrentGroup.Activity.Id, false)
                                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
                                end
                                break
                            end
                        end
                    end
                else
                    if ShowingInteraction then
                        ShowingInteraction = false
                        exports['fw-ui']:HideInteraction()
                    end

                    SetDrawOrigin(BoneCoords.x, BoneCoords.y, BoneCoords.z, 0)
                    DrawSprite("shared", "emptydot_32", 0, 0, 0.02, 0.035, 0, 255, 255, 255, 255)
                    ClearDrawOrigin()
                end
            end

            Citizen.Wait(1)
        end
    end)
end)

exports("IsScrappingVehicle", function(Entity)
    if not Scrapyard then return false end

    if #(GetEntityCoords(PlayerPedId()) - Scrapyard) < 10.0 and GetVehicleNumberPlateText(Entity) == WantedPlate then
        return true
    end

    return false
end)