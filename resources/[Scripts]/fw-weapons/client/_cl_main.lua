local WeaponMode, HasFireMode = 'Full-Auto', false

FW = exports['fw-core']:GetCoreObject()
LoggedIn = false

local WeaponValues = {
    ['Full-Auto'] = 100,
    ['Burst'] = 66,
    ['Single'] = 33,
}

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
    FW.AddKeybind("fireMode", "Wapens", "Verander vuurwapen modus", "", function(IsPressed)
        if not LoggedIn then return end
        if not IsPressed or not HasFireMode then return end
    
        if WeaponMode == 'Full-Auto' then
            WeaponMode = 'Burst'
            FW.Functions.Notify("Firemode: Burst")
        elseif WeaponMode == 'Burst' then
            WeaponMode = 'Single'
            FW.Functions.Notify("Firemode: Single")
        elseif WeaponMode == 'Single' then
            WeaponMode = 'Full-Auto'
            FW.Functions.Notify("Firemode: Full-Auto")
        end
        exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('FireMode'), WeaponValues[WeaponMode])
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

IsHoldingWeapon, HasScope, InVehicle = false, false, false

Citizen.CreateThread(function()
    for k, v in pairs(Config.Weapons) do
        if v.AmmoType == 'AMMO_NONE' then
            local WeaponHash = GetHashKey(k)
            SetWeaponDamageModifier(WeaponHash, v.Modifier)
        end
    end
    SetWeaponDamageModifier(GetHashKey('WEAPON_UNARMED'), 0.3)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and IsPedArmed(PlayerPedId(), 6) then
            local Weapon = GetSelectedPedWeapon(PlayerPedId())
            if Config.Weapons[Weapon] ~= nil and Config.Weapons[Weapon]['SelectFire'] then
                if not HasFireMode then
                    HasFireMode = true
                    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('FireMode'), WeaponValues[WeaponMode])
                end
                if WeaponMode == 'Burst' then
                    if IsControlJustPressed(0, 24) then
                        Citizen.Wait(350)
                        while IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) do
                            DisablePlayerFiring(PlayerId(), true)
                            Citizen.Wait(0)
                        end
                    end
                elseif WeaponMode == 'Single' then
                    if IsControlJustPressed(0, 24) then
                        Citizen.Wait(0)
                        while IsControlPressed(0, 24) or IsDisabledControlPressed(0, 24) do
                            DisablePlayerFiring(PlayerId(), true)
                            Citizen.Wait(0)
                        end
                    end
                else
                    Citizen.Wait(450)
                end
            else
                if HasFireMode then
                    HasFireMode = false
                    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('FireMode'), 0)
                end
                Citizen.Wait(450)
            end
        else
            if HasFireMode then
                HasFireMode = false
                exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('FireMode'), 0)
            end
            Citizen.Wait(450)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and IsPedArmed(PlayerPedId(), 6) then
            local Weapon = GetSelectedPedWeapon(PlayerPedId())
            if Config.Weapons[Weapon] ~= nil and Config.Weapons[Weapon]['AmmoType'] ~= 'AMMO_FIRE' and Config.Weapons[Weapon]['AmmoType'] ~= 'AMMO_NONE' then 
                local WeaponBullets = GetAmmoInPedWeapon(PlayerPedId(), Weapon)
                if IsPedShooting(PlayerPedId()) and Config.WeaponData ~= false then
                    TriggerServerEvent("fw-weapons:Server:UpdateQuality", Config.WeaponData)
                    if WeaponBullets == 1 then
                        TriggerServerEvent("fw-weapons:Server:UpdateWeapon", Config.WeaponData, 1)
                    else
                        TriggerServerEvent("fw-weapons:Server:UpdateWeapon", Config.WeaponData, tonumber(WeaponBullets))
                    end
                end
            else
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and IsPedArmed(PlayerPedId(), 6) then
            local Weapon = GetSelectedPedWeapon(PlayerPedId())
            if Config.Weapons[Weapon] ~= nil and Config.Weapons[Weapon]['AmmoType'] ~= 'AMMO_FIRE' and Config.Weapons[Weapon]['AmmoType'] ~= 'AMMO_TASER' and Config.Weapons[Weapon]['AmmoType'] ~= 'AMMO_EMP' and not exports['fw-arcade']:IsInTDM() then
                if IsPedShooting(PlayerPedId()) and Config.WeaponData ~= nil then
                    TriggerServerEvent('fw-police:Server:CreateEvidence', 'Bullet', Config.WeaponData)
                    if not exports['fw-police']:IsStatusAlreadyActive('gunpowder') then
                        TriggerEvent('fw-police:Client:SetStatus', 'gunpowder', 1200)
                    end
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(450)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey('WEAPON_UNARMED') then
            local Weapon = GetSelectedPedWeapon(PlayerPedId())
            if Config.Weapons[Weapon] ~= nil and (Config.Weapons[Weapon]['AmmoType'] == 'AMMO_FIRE' or Config.Weapons[Weapon]['AmmoType'] == 'AMMO_NONE') then
                if (IsPedInAnyVehicle(PlayerPedId()) and IsControlJustPressed(0, 24) and IsPedWeaponReadyToShoot(PlayerPedId())) or IsPedShooting(PlayerPedId()) then
                    Citizen.SetTimeout(400, function()
                        FW.SendCallback("FW:RemoveItem", Config.Weapons[Weapon].WeaponID, 1)
                        TriggerEvent('fw-inventory:Client:ResetWeapon')
                    end)
                end
            else
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

AddEventHandler('baseevents:enteredVehicle', function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = true
    SetVehicleAiming()
end)

AddEventHandler('baseevents:leftVehicle', function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = false
end)

RegisterNetEvent("fw-weapons:Client:SetWeaponData")
AddEventHandler("fw-weapons:Client:SetWeaponData", function(Data)
    Config.WeaponData = Data
    IsHoldingWeapon = Data and Data.Item

    if not IsHoldingWeapon then return end

    if Data.Item == 'weapon_snowball' then
        SetAmmoInClip(PlayerPedId(), 'weapon_snowball', 1)
        SetPedAmmo(PlayerPedId(), 'weapon_snowball', 2)
    end

    Citizen.CreateThread(function()
        local Weapon, Type = GetHashKey(Data.Item), 'Normal'
        if Config.Weapons[Weapon] ~= nil and Config.Weapons[Weapon].WeaponId == 'weapon_huntingrifle' then
            Type = 'Hunting'
        end

        while IsHoldingWeapon do
            if IsControlJustPressed(0, 25) then
                HasScope = true
                if Type == 'Hunting' then
                    exports['fw-ui']:ToggleScope(true)
                elseif exports['fw-hud']:GetPreferenceById('Crosshair.Show') then
                    exports['fw-ui']:ToggleCrosshair(true)
                end
            end

            if IsControlJustReleased(0, 25) then
                HasScope = false
                if Type == 'Hunting' then
                    exports['fw-ui']:ToggleScope(false)
                else
                    exports['fw-ui']:ToggleCrosshair(false)
                end
            end

            Citizen.Wait(4)
        end

        if HasScope then
            HasScope = false
            exports['fw-ui']:ToggleScope(false)
            exports['fw-ui']:ToggleCrosshair(false)
        end
    end)
end)

RegisterNetEvent("fw-weapons:Client:SetAmmo")
AddEventHandler("fw-weapons:Client:SetAmmo", function(Ammo)
    local Weapon = GetSelectedPedWeapon(PlayerPedId())
    local WeaponBullets = GetAmmoInPedWeapon(PlayerPedId(), Weapon)

    if Weapon == GetHashKey("weapon_unarmed") then return end

    SetAmmoInClip(PlayerPedId(), Weapon, 0)
    SetPedAmmo(PlayerPedId(), Weapon, Ammo)
    TriggerServerEvent("fw-weapons:Server:UpdateWeapon", Config.WeaponData, Ammo)
end)

RegisterNetEvent("fw-weapons:Client:AddAmmo")
AddEventHandler("fw-weapons:Client:AddAmmo", function(AmmoType, AmmoName)
    local Weapon = GetSelectedPedWeapon(PlayerPedId())
    local WeaponBullets = GetAmmoInPedWeapon(PlayerPedId(), Weapon)

    if Config.Weapons[Weapon] == nil or Config.Weapons[Weapon].AmmoType == nil then return end
    if Config.Weapons[Weapon].AmmoType ~= AmmoType then return end
    if WeaponBullets == Config.Weapons[Weapon].MaxAmmo then return end

    exports['fw-inventory']:SetBusyState(true)
    local Finished = FW.Functions.CompactProgressbar(3000, "Herladen...", false, true, {}, {}, {}, {}, false)

    exports['fw-inventory']:SetBusyState(false)
    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", "ammo", 1, false, AmmoName)
        if not DidRemove then
            return FW.Functions.Notify("Volgensmij mis je een item daap..", "error")
        end

        local NewAmmo = (WeaponBullets + Config.Weapons[Weapon].AddAmmo)
        if NewAmmo >= Config.Weapons[Weapon].MaxAmmo then NewAmmo = Config.Weapons[Weapon].MaxAmmo end
        SetAmmoInClip(PlayerPedId(), Weapon, 0)
        SetPedAmmo(PlayerPedId(), Weapon, NewAmmo)
        TriggerServerEvent("fw-weapons:Server:UpdateWeapon", Config.WeaponData, tonumber(NewAmmo))
    end
end)

RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    local Weapon = GetSelectedPedWeapon(PlayerPedId())
    if Weapon == GetHashKey("WEAPON_UNARMED") then return end

    Citizen.SetTimeout(100, function()
        if not Config.Weapons[Weapon] then return end

        local Item = Config.Weapons[Weapon].WeaponID
        if not exports['fw-inventory']:HasEnoughOfItem(Item, 1) then
            TriggerEvent('fw-inventory:Client:ResetWeapon')
            FW.Functions.Notify("Je wapen is kapot..", "error")
        end
    end)
end)

function ShowPepegaAimDot(Visible)
    HasScope = Visible
    -- if Visible and  then return print("NO ALLOW CROSSHAIR") end

    SendNUIMessage({
        Action = 'ToggleDot',
        Visible = Visible
    })
end

function GetWeaponList(Weapon)
    return Config.Weapons[Weapon]
end

function GetAmmoType(Weapon)
    return Config.Weapons[Weapon].AmmoType
end

exports("GetWeaponList", GetWeaponList)
exports("GetAmmoType", GetAmmoType)
exports("GetAllWeaponList", function()
    return Config.Weapons
end)
exports("IsFreeAiming", function()
    return HasScope
end)