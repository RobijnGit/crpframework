function OnVehicleAction(Data)
    if CurrentEntityType ~= 'vehicle' then
        return
    end

    if not DoesEntityExist(FocusingEntity) then
        return
    end

    local Result = Data.Result

    if Data.Id == "EnterVehicle" then
        if tonumber(Result.SeatIndex) and tonumber(Result.SeatIndex) > -1 then
            TaskWarpPedIntoVehicle(PlayerPedId(), FocusingEntity, tonumber(Result.SeatIndex))
        end
    elseif Data.Id == "FixVehicle" then
        FW.VSync.SetVehicleFixed(FocusingEntity)
    elseif Data.Id == "CleanVehicle" then
        SetVehicleDirtLevel(FocusingEntity, 0.0)
    elseif Data.Id == "GetKeys" then
        exports['fw-vehicles']:SetVehicleKeys(GetVehicleNumberPlateText(FocusingEntity), true)
    elseif Data.Id == "RefuelVehicle" then
        exports['fw-vehicles']:SetFuelLevel(FocusingEntity, 100)
    elseif Data.Id == "BurnEntity" then
        SetVehiclePetrolTankHealth(FocusingEntity, 1.0)
        SetVehicleEngineOn(FocusingEntity, false, true, true)
        SetVehicleUndriveable(FocusingEntity, true)

        local VehiclePos = GetEntityCoords(FocusingEntity)
        StartScriptFire(VehiclePos.x, VehiclePos.y, VehiclePos.z, 25, true)
    elseif Data.Id == "DamageEntity" then
        for i = 0, 7 do
            SetVehicleDoorBroken(FocusingEntity, i, false)
        end
        for i = 0, 5 do
            SetVehicleTyreBurst(FocusingEntity, i, true, 1000.0)
        end
        for i = 0, 7, 1 do
            SmashVehicleWindow(FocusingEntity, i)
        end
        SetVehiclePetrolTankHealth(FocusingEntity, 500.0)
        SetVehicleBodyHealth(FocusingEntity, 500.0)
        SetVehicleEngineHealth(FocusingEntity, 500.0)
    elseif Data.Id == "DeleteEntity" then
        FW.VSync.DeleteVehicle(FocusingEntity)
    elseif Data.Id == "ExplodeEntity" then
        AddExplosion(GetEntityCoords(FocusingEntity), EXPLOSION_CAR, 4.0, true, false, 1.0)
    elseif Data.Id == "PopTires" then
        for i = 0, 5, 1 do
            FW.VSync.SetVehicleTyreBurst(FocusingEntity, i, true, 1000.0)
        end
    elseif Data.Id == "BreakOffWheels" then
        for i = 0, math.random(1, 5), 1 do
            FW.VSync.BreakOffVehicleWheel(FocusingEntity, i, true, false, true, false)
        end
    elseif Data.Id == "Telekenesis" then
        local ForceVector = vector3(math.random(-30, 30), math.random(-30, 30), math.random(-10, 20))
        ApplyForceToEntity(FocusingEntity, 3, ForceVector.x, ForceVector.y, ForceVector.z, 0.0, 0.0, 0.0, true, true, true, true, true)
    elseif Data.Id == "ToggleEngine" then
        local IsEngineRunning = GetIsVehicleEngineRunning(FocusingEntity)
        SetVehicleEngineOn(FocusingEntity, not IsEngineRunning, true, true)
    end
end