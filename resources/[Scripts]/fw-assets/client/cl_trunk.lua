
local TrunkCam = nil

-- Events
RegisterNetEvent('fw-assets:client:getin:trunk', function(Data, Entity)
    if Data.Forced then
        local TargetEntity, EntityType, TargetCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(1.0, 0.2, 2)
        if EntityType == 2 then Entity = TargetEntity end
    end

    if Entity == nil or not DoesEntityExist(Entity) then
        FW.Functions.Notify("Geen voertuig gevonden..", "error")
        return
    end

    local LockStatus = GetVehicleDoorLockStatus(Entity)
    if LockStatus ~= 0 and LockStatus ~= 1 and LockStatus ~= 4 then return FW.Functions.Notify("Voertuig is op slot..", "error") end
    if (not GetIsDoorValid(Entity, 5)) or Config.DisabledTrunk[GetEntityModel(Entity)] then return FW.Functions.Notify("Voertuig heeft geen kofferbak..", "error") end
    if GetVehicleDoorAngleRatio(Entity, 5) == 0 then return FW.Functions.Notify("Kofferbak is dicht..", "error") end

    FW.Functions.TriggerCallback("fw-assets:Server:IsTrunkEmpty", function(IsEmpty)
        if not IsEmpty then return FW.Functions.Notify("Lijkt erop dat er al iemand in de kofferbak ligt..", "error") end
        StartTrunkLoop(Entity)
        TriggerServerEvent('fw-assets:Server:SetTrunkOccupied', GetVehicleNumberPlateText(Entity), true)
    end, GetVehicleNumberPlateText(Entity))
end)

-- Functions
function StartTrunkLoop(Vehicle)
    RequestAnimDict("mp_common_miss")
    while not HasAnimDictLoaded("mp_common_miss") do Citizen.Wait(4) end
    
    local MinDimension, MaxDimension = GetModelDimensions(GetEntityModel(Vehicle))
    local ZOffset = MaxDimension.z
    if ZOffset > 1.4 then ZOffset = 1.4 - (MaxDimension.z - 1.4) end
    
    AttachEntityToEntity(PlayerPedId(), Vehicle, 0, -0.1, (MinDimension.y + 0.85), (ZOffset - 0.87), 0, 0, 40.0, 1, 1, 1, 1, 1, 1)
    ClearPedTasks(PlayerPedId())

    -- Cam
    TrunkCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(TrunkCam, GetEntityCoords(PlayerPedId()))
    SetCamRot(TrunkCam, 0.0, 0.0, 0.0)
    SetCamActive(TrunkCam, true)
    RenderScriptCams(true, false, 0, true, true)
    SetCamCoord(TrunkCam, GetEntityCoords(PlayerPedId()))
    AttachCamToEntity(TrunkCam, PlayerPedId(), 0.0, -2.5, 1.5, true)
    SetCamFov(TrunkCam, 80.0)

    if not FW.Functions.GetPlayerData().metadata['ishandcuffed'] then
        exports['fw-ui']:ShowInteraction("[H] Open/Sluiten, [F] Uit Kofferbak")
    else
        exports['fw-ui']:ShowInteraction("[F] Uit Kofferbak")
    end
    
    Citizen.CreateThread(function()
        local InTrunk = true
        while InTrunk do
            SetCamRot(TrunkCam, -20.0, 0.0, GetEntityHeading(PlayerPedId()) - 15.0)

            if not IsEntityPlayingAnim(PlayerPedId(), "mp_common_miss", "dead_ped_idle", 3) then
                TaskPlayAnim(PlayerPedId(), "mp_common_miss", "dead_ped_idle", 8.0, 8.0, -1, 2, 999.0, 0, 0, 0)
            end

            if IsEntityDead(PlayerPedId()) then InTrunk = false end
            if not DoesEntityExist(Vehicle) then InTrunk = false end
            
            if IsControlJustReleased(0, 74) then
                if not FW.Functions.GetPlayerData().metadata['ishandcuffed'] then
                    if (GetVehicleDoorAngleRatio(Vehicle, 5) == 0) then
                        FW.VSync.SetVehicleDoorOpen(Vehicle, 5, false, true)
                    else
                        FW.VSync.SetVehicleDoorShut(Vehicle, 5, true)
                    end
                end
            end

            if IsDisabledControlJustReleased(0, 23) then
                if GetVehicleDoorAngleRatio(Vehicle, 5) > 0.0 then
                    InTrunk = false
                else
                    FW.Functions.Notify("Kofferbak is dicht..", "error")
                end
            end
            
            Citizen.Wait(4)
        end
        
        exports['fw-ui']:HideInteraction()
        
        if DoesCamExist(TrunkCam) then
            RenderScriptCams(false, false, 0, 1, 0)
            DestroyCam(TrunkCam, false)
        end

        StopAnimTask(PlayerPedId(), "mp_common_miss", "dead_ped_idle", 1.0)

        DetachEntity(PlayerPedId())
        if DoesEntityExist(Vehicle) then
            local DropPosition = GetOffsetFromEntityInWorldCoords(Vehicle, 0.0, MinDimension.y - 0.5, 0.0)
            SetEntityCoords(PlayerPedId(), DropPosition.x, DropPosition.y, DropPosition.z)
            TriggerServerEvent('fw-assets:Server:SetTrunkOccupied', GetVehicleNumberPlateText(Vehicle), false)
        end
    end)
end

function GetTrunkOffset(Entity)
    local MinDimension, MaxDimension = GetModelDimensions(GetEntityModel(Entity))
    return GetOffsetFromEntityInWorldCoords(Entity, 0.0, MinDimension.y - 0.5, 0.0)
end

function GetInTrunkState()
    return DoesCamExist(TrunkCam)
end
exports("GetInTrunkState", GetInTrunkState)