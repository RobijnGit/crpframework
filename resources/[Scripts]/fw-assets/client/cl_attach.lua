local GunProps, ItemProps, HandProp, ChestProp, KatanaProp, CurrentHandData = {}, {}, nil, nil, nil, nil
local GunLimit, ItemLimit, HandLimit = 4, 5, 1
local PropsDisabled = false

Citizen.CreateThread(function()
    while true do
        if LoggedIn and HandProp ~= nil and CurrentHandData ~= nil then
            if not IsEntityPlayingAnim(PlayerPedId(), CurrentHandData.PropExtra.Dict, CurrentHandData.PropExtra.Anim, 3) then
                RequestAnimationDict(CurrentHandData.PropExtra.Dict)
                TaskPlayAnim(PlayerPedId(), CurrentHandData.PropExtra.Dict, CurrentHandData.PropExtra.Anim, 8.0, 8.0, -1, 50, 0, false, false, false)
            end
        end

        Citizen.Wait(1500)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and HandProp ~= nil and CurrentHandData ~= nil and CurrentHandData.PropExtra.DisableRun then 
            DisableControlAction(0, 21, true) DisableControlAction(0, 22, true) DisableControlAction(0, 23, true) DisableControlAction(0, 75, true) 
            DisableControlAction(27, 23, true) DisableControlAction(27, 22, true) DisableControlAction(27, 75, true)
        else
            Citizen.Wait(1000)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent("fw-assets:Client:Toggle:Items")
AddEventHandler("fw-assets:Client:Toggle:Items", function(Bool, FirstTime)
    local FirstTime = FirstTime or false

    PropsDisabled = Bool
    if PropsDisabled then
        DeleteAttached()
    else
        if FirstTime then return end
        TriggerEvent("fw-assets:Client:Attach:Items")
    end
end)

RegisterNetEvent("fw-assets:Client:Attach:Items")
AddEventHandler("fw-assets:Client:Attach:Items", function()
    if PropsDisabled then return end 

    FW.SendCallback("fw-inventory:Server:RefreshInventory")

    DeleteAttached()
    local Num, CurrentWeapon = GetCurrentPedWeapon(PlayerPedId(), false)
    for k, v in pairs(Config.AttachBackProps) do
        if exports['fw-inventory']:HasEnoughOfItem(v.Id, 1) and not IsPropOnBack(v.Model) then
            local Model = GetHashKey(v.Model)
            exports['fw-assets']:RequestModelHash(Model)
            if v.Type == 1 and #GunProps < GunLimit and CurrentWeapon ~= tonumber(GetHashKey(v.Id)) then
                local NewProp = CreateObject(Model, 0, 0, 0, true, true, false)
                SetEntityCollision(NewProp, false, false)
                AttachEntityToEntity(NewProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24818), v.PropCoords.Z, -0.155, 0.11 - (#GunProps / 10), v.PropCoords.RX, v.PropCoords.RY, v.PropCoords.RZ, false, true, false, true, false, true)
                table.insert(GunProps, NewProp)
            elseif v.Type == 2 and #ItemProps < ItemLimit then
                local NewProp = CreateObject(Model, 0, 0, 0, true, true, false)
                SetEntityCollision(NewProp, false, false)
                AttachEntityToEntity(NewProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24817), v.PropCoords.Z -0.1, -0.11, 0.24 - (#ItemProps / 10), v.PropCoords.RX, v.PropCoords.RY, v.PropCoords.RZ, false, true, false, true, false, true)
                table.insert(ItemProps, NewProp)
            elseif v.Type == 3 and HandProp == nil then
                local NewProp = CreateObject(Model, 0, 0, 0, true, true, false)
                SetEntityCollision(NewProp, false, false)
                AttachEntityToEntity(NewProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), v.PropCoords.X, v.PropCoords.Y, v.PropCoords.Z, v.PropCoords.RX, v.PropCoords.RY, v.PropCoords.RZ, false, true, false, true, false, true)
                CurrentHandData, HandProp = v, NewProp
            elseif v.Type == 4 and ChestProp == nil and CurrentWeapon ~= tonumber(GetHashKey(v.Id)) then
                local NewProp = CreateObject(Model, 0, 0, 0, true, true, false)
                SetEntityCollision(NewProp, false, false)
                AttachEntityToEntity(NewProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24818), v.PropCoords.X, v.PropCoords.Y, v.PropCoords.Z, v.PropCoords.RX, v.PropCoords.RY, v.PropCoords.RZ, false, true, false, true, false, true)
                ChestProp = NewProp
            elseif v.Type == 5 and KatanaProp == nil and CurrentWeapon ~= tonumber(GetHashKey(v.Id)) then
                local OverridePropModel = exports['fw-inventory']:HasEnoughOfItem('weapon_katana', 1) and 'katana_sheath' or nil
                local NewProp = CreateObject((OverridePropModel ~= nil and OverridePropModel or Model), 0, 0, 0, true, true, false)
                SetEntityCollision(NewProp, false, false)
                AttachEntityToEntity(NewProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24817), v.PropCoords.Z - 0.4, (v.PropCoords.X or 0.0) - 0.135, (v.PropCoords.Y or 0.0) - 0.0, v.PropCoords.RX, v.PropCoords.RY, v.PropCoords.RZ, false, true, false, true, false, true)
                KatanaProp = NewProp
            end
        end
    end
end)

-- // Functions \\ --

function IsPropOnBack(Model)
    for k, v in pairs(GunProps) do
        if GetEntityModel(v) == GetHashKey(Model) then
            return true
        end
    end
    for k, v in pairs(ItemProps) do
        if GetEntityModel(v) == GetHashKey(Model) then
            return true
        end
    end
    if GetEntityModel(HandProp) == Model then
        return true
    end
    if GetEntityModel(KatanaProp) == Model then
        return true
    end
    if GetEntityModel(ChestProp) == Model then
        return true
    end

    return false
end

function DeleteAttached()
    for k, v in pairs(GunProps) do DeleteEntity(v) end
    for k, v in pairs(ItemProps) do DeleteEntity(v) end
    if HandProp ~= nil then DeleteEntity(HandProp) ClearPedTasks(PlayerPedId()) end
    if KatanaProp ~= nil then DeleteEntity(KatanaProp) end
    if ChestProp ~= nil then SetEntityCollision(v, true, true) DeleteEntity(ChestProp) end

    GunProps, ItemProps = {}, {}
    HandProp, CurrentHandData, KatanaProp, ChestProp = nil, nil, nil, nil
end

AddEventHandler('onResourceStop', function(Resource)
    if Resource ~= GetCurrentResourceName() then return end

    for k, v in pairs(GunProps) do DeleteEntity(v) end
    for k, v in pairs(ItemProps) do DeleteEntity(v) end
    if HandProp ~= nil then DeleteEntity(HandProp) end
    if KatanaProp ~= nil then DeleteEntity(KatanaProp) end
    if ChestProp ~= nil then SetEntityCollision(v, true, true) DeleteEntity(ChestProp) end

    GunProps, ItemProps = {}, {}
    HandProp, CurrentHandData, KatanaProp, ChestProp = nil, nil, nil, nil
end)