-- Disable Weapon Drops
local PedIndex = {}

function SetWeaponDrops()
    local handle, ped = FindFirstPed()
    local finished = false
    repeat 
        if not IsEntityDead(ped) then
            PedIndex[ped] = {}
        end
        finished, ped = FindNextPed(handle)
    until not finished
    EndFindPed(handle)

    for peds,_ in pairs(PedIndex) do
        if peds ~= nil then
            SetPedDropsWeaponsWhenDead(peds, false) 
        end
    end
end

-- Disable bunny hopping
local JumpDisabled, ResetCounter = false, 0
Citizen.CreateThread( function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if JumpDisabled and ResetCounter > 0 and IsPedJumping(PlayerPedId()) then
                SetPedToRagdoll(PlayerPedId(), 1000, 1000, 3, 0, 0, 0)
                ResetCounter = 0
            end
            if not JumpDisabled and IsPedJumping(PlayerPedId()) then
                JumpDisabled = true
                ResetCounter = 10
                Citizen.Wait(1200)
            end
            if ResetCounter > 0 then
                ResetCounter = ResetCounter - 1
            else
                if JumpDisabled then
                    ResetCounter = 0
                    JumpDisabled = false
                end
            end
            Citizen.Wait(250)
        else
            Citizen.Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if LoggedIn then
            -- Minimap Zoom
            if not IsPedInAnyVehicle(PlayerPedId()) then
                local EntitySpeed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId())) * 3.6
                if EntitySpeed <= 75 then
                    SetRadarZoom(835)
                elseif EntitySpeed <= 100 then
                    SetRadarZoom(1100)
                end
            end
    
            -- Lock cam viewset
            if --[[GetFollowPedCamViewMode() == 1 or]] GetFollowPedCamViewMode() == 2 or GetFollowPedCamViewMode() == 3 then
                SetFollowPedCamViewMode(4)
            end

            if GetFollowVehicleCamViewMode() == 2 or GetFollowVehicleCamViewMode() == 2 then
                SetFollowVehicleCamViewMode(4)
            end

            -- Disable idle cam
            InvalidateIdleCam()
            InvalidateVehicleIdleCam()

            -- Disable health regen
            local HasBuff = exports['fw-hud']:HasBuff('Health')
            SetPlayerHealthRechargeMultiplier(PlayerId(), HasBuff and 1.0 or 0.0)
            if HasBuff then
                SetPlayerHealthRechargeLimit(PlayerId(), 1.0)
            end

            -- Disable combat walk
            if not GetPedConfigFlag(PlayerPedId(), 78, 1) then
                SetPedUsingActionMode(PlayerPedId(), false, -1, 0)
            end

            -- Disable weapon drops
            SetWeaponDrops()
        else
            Citizen.Wait(2000)
        end

        Citizen.Wait(600)
    end
end)

-- Disable Air Control
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if DoesEntityExist(Vehicle) and not IsEntityDead(Vehicle) then
                local Model = GetEntityModel(Vehicle)
                local Roll = GetEntityRoll(Vehicle)
                if (not IsThisModelABoat(Model) and not IsThisModelAHeli(Model) and not IsThisModelAPlane(Model) and not IsThisModelABike(Model) and IsEntityInAir(Vehicle)) or (Roll > 75.0 or Roll < -75.0) and GetEntitySpeed(Vehicle) < 2 then
                    DisableControlAction(0, 59)
                    DisableControlAction(0, 60)
                end
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)

        -- Weapon Damage Modifiers
        local HasBuff = exports['fw-hud']:HasBuff('Strength')
        SetWeaponDamageModifier(GetHashKey('WEAPON_UNARMED'), 0.2 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_NIGHTSTICK'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_FLASHLIGHT'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_HAMMER'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_KNIFE'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_HATCHET'), 0.5 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_SWITCHBLADE'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_WRENCH'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_MACHETE'), 0.5 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_BOTTLE'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_BAT'), 0.3 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_KNUCKLE'), 0.25 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_KATANA'), 0.5 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_CRUTCH'), 0.2 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_UNICORN'), 0.1 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_SLEDGEHAM'), 0.5 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_CROWBAR'), 0.5 * (HasBuff and 1.8 or 1.0))
        SetWeaponDamageModifier(GetHashKey('WEAPON_SNOWBALL'), 0.0)
        SetPedSuffersCriticalHits(PlayerPedId(), false)

        -- Hud Components
        HideHudComponentThisFrame(1)
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(13)
        HideHudComponentThisFrame(14)
        HideHudComponentThisFrame(17)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        HideHudComponentThisFrame(21)
        HideHudComponentThisFrame(22)
        DisplayAmmoThisFrame(true)

        -- Disable combat peeking
        if IsPedInCover(PlayerPedId(), 0) and not IsPedAimingFromCover(PlayerPedId()) then
            DisablePlayerFiring(PlayerPedId(), true)
        end

        local WeaponHash = GetSelectedPedWeapon(PlayerPedId())

        -- Stop Melee when Weapon Equipped
        if IsPedArmed(PlayerPedId(), 6) and WeaponHash ~= GetHashKey("WEAPON_UNARMED") then
            DisableControlAction(1, 140, true)
            DisableControlAction(1, 141, true)
            DisableControlAction(1, 142, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
        end

        -- Disable some stuff
        DisableControlAction(0, 36, true) -- INPUT_DUCK
        SetPlayerTargetingMode(3) -- Force Free Aim
    end
end)

-- Disable Vehicle Rewards
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            DisablePlayerVehicleRewards(PlayerId())
            RemoveVehiclesFromGeneratorsInArea(441.8465 - 500.0, -987.99 - 500.0, 30.68 -500.0, 441.8465 + 500.0, -987.99 + 500.0, 30.68 + 500.0) -- MRPD
        else
            Citizen.Wait(450)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(20)
        if LoggedIn then
            local Weapon = GetSelectedPedWeapon(PlayerPedId())
            if Weapon ~= GetHashKey('weapon_fireextinguisher') then SetPedInfiniteAmmo(PlayerPedId(), false, Weapon) goto SkipLoop end
            SetPedInfiniteAmmo(PlayerPedId(), true, Weapon)
            ::SkipLoop::
        end
    end
end)

-- Remove Health + Armor Bar
Citizen.CreateThread(function()
    local Minimap = RequestScaleformMovie("minimap")
    while true do
        Citizen.Wait(4)
        BeginScaleformMovieMethod(Minimap, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)