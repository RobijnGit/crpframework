function OnPedAction(Data)
    if CurrentEntityType ~= 'ped' then
        return
    end

    if not DoesEntityExist(FocusingEntity) then
        return
    end

    local Result = Data.Result

    if Data.Id == "BurnEntity" then
        StartEntityFire(FocusingEntity)
    elseif Data.Id == "DamageEntity" then
        SetPedArmour(FocusingEntity, 0)
        SetEntityHealth(FocusingEntity, GetEntityHealth(FocusingEntity) - 50)
    elseif Data.Id == "DeleteEntity" then
        DeleteEntity(FocusingEntity)
    elseif Data.Id == "ExplodeEntity" then
        AddExplosion(GetEntityCoords(FocusingEntity), GRENADE, 4.0, true, false, 1.0)
    elseif Data.Id == "Telekenesis" then
        local ForceVector = vector3(math.random(-30, 30), math.random(-30, 30), math.random(-10, 20))
        ApplyForceToEntity(FocusingEntity, 3, ForceVector.x, ForceVector.y, ForceVector.z, 0.0, 0.0, 0.0, true, true, true, true, true)
    end
end