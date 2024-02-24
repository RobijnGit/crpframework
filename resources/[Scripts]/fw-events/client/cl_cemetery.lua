function showLoopParticle(dict, particleName, coords, scale, time)
    Citizen.CreateThread(function()
        RequestNamedPtfxAsset(dict)
        while not HasNamedPtfxAssetLoaded(dict) do
            Citizen.Wait(0)
        end
        UseParticleFxAssetNextCall(dict)
        local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords, 0.0, 0.0, 0.0, scale, false, false, false)
        SetParticleFxLoopedColour(particleHandle, 0, 255, 0 ,0)
        Citizen.Wait(time)
        StopParticleFxLooped(particleHandle, false)
    end)
end

-- Smoke in graveside
Citizen.CreateThread(function()
    local Coords = {
        vector3(-1763.55, -264.46, 47.0),
        vector3(-1764.28, -263.98, 47.0),
        vector3(-1762.75, -261.35, 47.0),
        vector3(-1761.89, -261.65, 47.0),
        vector3(-1763.16, -262.81, 47.0),
    }

    while true do
        if #(GetEntityCoords(PlayerPedId()) - vector3(-1763.16, -262.81, 47.5)) < 150.0 then
            for k, v in pairs(Coords) do
                showLoopParticle("core", "exp_grd_grenade_smoke", v, 1.5, 1000)
            end
        else
            Citizen.Wait(5000)
        end

        Citizen.Wait(3000)
    end
end)

-- Spawn zombies around cemetery island
function EventThread()
    local Center = vector3(-1724.87, -190.04, 58.52)
    local Zombies = {}

    local ZombieSpawns = {
        Cemetery = {
            vector3(-1711.0699462891, -180.00999450684, 57.590000152588),
            vector3(-1703.0699462891, -177.00999450684, 57.590000152588),
            vector3(-1712.0699462891, -184.00999450684, 57.590000152588),
            vector3(-1717.0699462891, -180.00999450684, 57.590000152588),
            vector3(-1717.0699462891, -174.00999450684, 57.590000152588),
            vector3(-1718.0699462891, -190.00999450684, 57.590000152588),
            vector3(-1704.0699462891, -176.00999450684, 57.590000152588),
            vector3(-1708.0699462891, -184.00999450684, 57.590000152588),
            vector3(-1707.0699462891, -174.00999450684, 57.590000152588),
            vector3(-1713.0699462891, -187.00999450684, 57.590000152588),
            vector3(-1705.0699462891, -185.00999450684, 57.590000152588),
            vector3(-1717.0699462891, -174.00999450684, 57.590000152588),
            vector3(-1704.0699462891, -192.00999450684, 57.590000152588),
            vector3(-1714.0699462891, -189.00999450684, 57.590000152588),
            vector3(-1714.0699462891, -175.00999450684, 57.590000152588),
            vector3(-1720.0699462891, -190.00999450684, 57.590000152588),
            vector3(-1703.0699462891, -175.00999450684, 57.590000152588),
            vector3(-1704.0699462891, -189.00999450684, 57.590000152588),
            vector3(-1715.0699462891, -179.00999450684, 57.590000152588),
            vector3(-1708.0699462891, -189.00999450684, 57.590000152588),

            vector3(-1743.3199462891, -193.71000671387, 57.569999694824),
            vector3(-1729.3199462891, -203.71000671387, 57.569999694824),
            vector3(-1738.3199462891, -197.71000671387, 57.569999694824),
            vector3(-1725.3199462891, -197.71000671387, 57.569999694824),
            vector3(-1737.3199462891, -203.71000671387, 57.569999694824),
            vector3(-1741.3199462891, -188.71000671387, 57.569999694824),
            vector3(-1745.3199462891, -190.71000671387, 57.569999694824),
            vector3(-1734.3199462891, -199.71000671387, 57.569999694824),
            vector3(-1726.3199462891, -203.71000671387, 57.569999694824),
            vector3(-1733.3199462891, -194.71000671387, 57.569999694824),
            vector3(-1738.3199462891, -194.71000671387, 57.569999694824),
            vector3(-1728.3199462891, -206.71000671387, 57.569999694824),
            vector3(-1745.3199462891, -190.71000671387, 57.569999694824),
            vector3(-1731.3199462891, -201.71000671387, 57.569999694824),
            vector3(-1732.3199462891, -204.71000671387, 57.569999694824),
            vector3(-1738.3199462891, -192.71000671387, 57.569999694824),
            vector3(-1745.3199462891, -195.71000671387, 57.569999694824),
            vector3(-1743.3199462891, -187.71000671387, 57.569999694824),
            vector3(-1735.3199462891, -188.71000671387, 57.569999694824),
            vector3(-1737.3199462891, -206.71000671387, 57.569999694824),

            vector3(-1732.2399902344, -177.50999450684, 58.330001831055),
            vector3(-1738.2399902344, -189.50999450684, 58.330001831055),
            vector3(-1720.2399902344, -176.50999450684, 58.330001831055),
            vector3(-1736.2399902344, -188.50999450684, 58.330001831055),
            vector3(-1724.2399902344, -194.50999450684, 58.330001831055),
            vector3(-1724.2399902344, -185.50999450684, 58.330001831055),
            vector3(-1733.2399902344, -178.50999450684, 58.330001831055),
            vector3(-1739.2399902344, -177.50999450684, 58.330001831055),
            vector3(-1732.2399902344, -193.50999450684, 58.330001831055),
            vector3(-1722.2399902344, -178.50999450684, 58.330001831055),
            vector3(-1726.2399902344, -180.50999450684, 58.330001831055),
            vector3(-1719.2399902344, -192.50999450684, 58.330001831055),
            vector3(-1732.2399902344, -179.50999450684, 58.330001831055),
            vector3(-1737.2399902344, -187.50999450684, 58.330001831055),
            vector3(-1727.2399902344, -177.50999450684, 58.330001831055),
            vector3(-1720.2399902344, -192.50999450684, 58.330001831055),
            vector3(-1738.2399902344, -194.50999450684, 58.330001831055),
            vector3(-1730.2399902344, -181.50999450684, 58.330001831055),
            vector3(-1720.2399902344, -181.50999450684, 58.330001831055),
            vector3(-1719.2399902344, -180.50999450684, 58.330001831055),
        }
    }

    local IsFrozen = false
    Citizen.CreateThread(function()
        while true do
            local Coords = GetEntityCoords(PlayerPedId())

            -- Spawn Zombies near Cemetery
            if #(Coords - Center) < 100.0 then
                if not ZombiesSpawned then
                    ZombiesSpawned = true

                    exports['fw-assets']:RequestModelHash("u_m_y_zombie_01")
                    for k, v in pairs(ZombieSpawns.Cemetery) do
                        local Ped = CreatePed(-1, "u_m_y_zombie_01", v.x, v.y, v.z, math.random(1, 360), false, true)
                        local Clipset = ZombieWalkstyles[math.random(#ZombieWalkstyles)]
                        RequestAnimSet(Clipset)
                        while not HasAnimSetLoaded(Clipset) do Citizen.Wait(0) end
                        SetPedMovementClipset(Ped, Clipset, 1.0)

                        PlaceObjectOnGroundProperly(Ped)

                        SetPedIsDrunk(Ped, true)
                        TaskSetBlockingOfNonTemporaryEvents(Ped, true)
                        SetPedKeepTask(Ped, false)
                        SetEntityInvincible(Ped, true)
                        SetPedEnableWeaponBlocking(Ped, true)
                        DisablePedPainAudio(Ped,true)
                        ApplyPedDamagePack(Ped, 'BigHitByVehicle', 0.0, 1.0)
                        ApplyPedDamagePack(Ped, 'Car_Crash_Heavy', 0.0, 1.0)
                        ApplyPedDamagePack(Ped, 'SCR_Torture', 0.0, 1.0)
                        ApplyPedDamagePack(Ped, 'SCR_TracySplash', 0.0, 1.0)
                        ApplyPedDamagePack(Ped, 'Burnt_Ped_Limbs', 0.0, 1.0)
                        SetEntityHeading(Ped, math.random(1, 360))

                        Zombies[#Zombies + 1] = Ped
                    end
                end
            elseif ZombiesSpawned then
                ZombiesSpawned = false

                for k, v in pairs(Zombies) do
                    DeletePed(v)
                end
                Zombies = {}
            end

            if FreezeCoords.x ~= 0.0 and FreezeCoords.y ~= 0.0 and FreezeCoords.z ~= 0.0 and #(Coords - FreezeCoords) < 15.0 and not IsFrozen then
                FreezeEntityPosition(PlayerPedId(), true)
                IsFrozen = true
            elseif #(Coords - FreezeCoords) > 15.0 and IsFrozen then
                FreezeEntityPosition(PlayerPedId(), false)
                IsFrozen = false
                StopAnimTask(PlayerPedId(), "stungun@standing", "damage", 1.0)
            end

            if IsFrozen then
                if not IsEntityPlayingAnim(PlayerPedId(), "stungun@standing", "damage", 3) then
                    exports['fw-assets']:RequestAnimationDict("stungun@standing")
                    TaskPlayAnim(PlayerPedId(), "stungun@standing", "damage", 8.0, 8.0, 1470, 0, 0, 0, 0, 0)
                end
            end

            Citizen.Wait(1500)
        end
    end)
end