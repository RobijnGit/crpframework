AttackersCache, ZombiesCache = {}, {}
ZombieWalkstyles = {
    "MOVE_M@DRUNK@MODERATEDRUNK",
    "MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP",
    "MOVE_M@DRUNK@SLIGHTLYDRUNK",
    "MOVE_M@DRUNK@VERYDRUNK"
}

function ConvertPedToZombie(Ped)
    ZombiesCache[Ped] = true

    local Vehicle = GetVehiclePedIsUsing(Ped)

    SetEntityAsMissionEntity(Ped, true, true)

    if Vehicle and DoesEntityExist(Vehicle) then
        TaskLeaveVehicle(Ped, Vehicle, 4160)
        Citizen.Wait(1500)
        SetTimeout(100, function()
            SetPedToRagdoll(Ped, math.random(1000, 2000), math.random(1000, 2000), 0, 0, 0, 0)
        end)
    end

    ClearPedTasks(Ped)
    ClearPedSecondaryTask(Ped)
    ClearPedTasksImmediately(Ped)

    local Clipset = ZombieWalkstyles[math.random(#ZombieWalkstyles)]
    RequestAnimSet(Clipset)
    while not HasAnimSetLoaded(Clipset) do Citizen.Wait(0) end
    SetPedMovementClipset(Ped, Clipset, 1.0)

    SetPedIsDrunk(Ped, true)
    TaskSetBlockingOfNonTemporaryEvents(Ped, true)
    SetPedKeepTask(Ped, false)

    SetPedFleeAttributes(Ped, 0, 0)
    SetPedCombatAttributes(Ped, 16, true)
    SetPedCombatAttributes(Ped, 46, true)
    SetPedCombatAttributes(Ped, 26, true)
    SetAmbientVoiceName(Ped, "ALIENS")
    SetPedEnableWeaponBlocking(Ped, true)
    DisablePedPainAudio(Ped,true)
    ApplyPedDamagePack(Ped, 'BigHitByVehicle', 0.0, 1.0)
    ApplyPedDamagePack(Ped, 'Car_Crash_Heavy', 0.0, 1.0)
    ApplyPedDamagePack(Ped, 'SCR_Torture', 0.0, 1.0)
    ApplyPedDamagePack(Ped, 'SCR_TracySplash', 0.0, 1.0)
    ApplyPedDamagePack(Ped, 'Burnt_Ped_Limbs', 0.0, 1.0)

    SetPedRelationshipGroupHash(Ped, GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("HATES_PLAYER"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("HATES_PLAYER"), GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("HATES_PLAYER"), GetHashKey("ISDEFENDTARGET"))
    SetRelationshipBetweenGroups(0, GetHashKey("TRUENEUTRAL"), GetHashKey("HATES_PLAYER"))
    SetRelationshipBetweenGroups(0, GetHashKey("HATES_PLAYER"), GetHashKey("TRUENEUTRAL"))
    SetPedAccuracy(Ped, math.random(75, 100))
    SetPedFleeAttributes(Ped, 0, 0)
    SetPedCombatAttributes(Ped, 5, true)
    SetPedCombatAttributes(Ped, 16, true)
    SetPedCombatAttributes(Ped, 46, true)
    SetPedCombatAttributes(Ped, 26, true)
    SetPedCombatAttributes(Ped, 3, false)
    SetPedCombatAttributes(Ped, 2, true)
    SetPedCombatAttributes(Ped, 1, false)
    SetPedSeeingRange(Ped, 10000.0)
    SetPedHearingRange(Ped, 10000.0)
    SetPedDiesWhenInjured(Ped, false)
    SetPedAlertness(Ped,3)

    SetPedPathAvoidFire(Ped, true)
    SetPedPathCanUseLadders(Ped, true)
    SetPedPathCanDropFromHeight(Ped, true)
    SetPedPathCanUseClimbovers(Ped, true)

    TaskWanderStandard(Ped, 10.0, 10)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if Config.IsEventActive then
            local Peds = GetGamePool('CPed')
            local FoundPed
            for _, Ped in ipairs(Peds) do
                if not IsPedDeadOrDying(Ped, true) and not IsPedAPlayer(Ped) and not IsPedFleeing(Ped) and IsPedHuman(Ped) and NetworkGetEntityIsNetworked(Ped) and not ZombiesCache[Ped] then
                    ConvertPedToZombie(Ped)
                end
            end

            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if Config.IsEventActive then

            for k, Ped in pairs(AttackersCache) do
                if not DoesEntityExist(Ped) or IsEntityDead(Ped) or not NetworkGetEntityIsNetworked(Ped) then
                    table.remove(AttackersCache, k)
                end
            end

            for Ped, v in pairs(ZombiesCache) do
                if not DoesEntityExist(Ped) or not NetworkGetEntityIsNetworked(Ped) then
                    ZombiesCache[Ped] = nil
                end
            end

            if not IsInfected and #AttackersCache < 10 then
                local ChurchInteriorId = GetInteriorAtCoords(-774.412, -10.381, 41.12)
                if GetInteriorAtCoords(GetEntityCoords(PlayerPedId())) ~= ChurchInteriorId then
                    for Ped, DoesExist in pairs(ZombiesCache) do
                        if DoesExist then
                            if not IsPedInCombat(Ped, PlayerPedId()) and not IsPedDeadOrDying(Ped, true) then
                                RegisterHatedTargetsAroundPed(Ped, 10.0)
                                TaskCombatPed(Ped, PlayerPedId(), 0, 16)
                                table.insert(AttackersCache, Ped)
                            end
                        end
                    end
                end
            end

            Citizen.Wait(5000)
        end
    end
end)

AddEventHandler("onResourceStop", function()
    print("Deleting zombies.")
    for k, v in pairs(ZombiesCache) do
        DeletePed(k)
    end
end)