-- // Events \\ --

RegisterNetEvent("fw-events:Client:AddPortal")
AddEventHandler("fw-events:Client:AddPortal", function(Coords)
    local PortalId = #Config.Portals + 1
    Config.Portals[PortalId] = Coords
    TriggerEvent("fw-events:Client:DrawPortal", PortalId + 1, Coords, 0.25)
end)

RegisterNetEvent("fw-events:Client:DrawPortal", function(PortalId, Coords, Radius, IncreaseRadiusSpeed, MaxRadius, OnRadiusDone)
    if ActivePortals[PortalId] then return end
    ActivePortals[PortalId] = true

    if IncreaseRadiusSpeed then
        Citizen.CreateThread(function()
            local InverseRadius = false
            while true do
                if Radius >= MaxRadius then
                    InverseRadius = true
                end

                if InverseRadius then
                    Radius = Radius - 5.0
                else
                    Radius = Radius + 5.0
                end

                if OnRadiusDone and Radius <= 0 then
                    ActivePortals[PortalId] = nil
                    OnRadiusDone()
                    return
                end

                Citizen.Wait(IncreaseRadiusSpeed)
            end
        end)
    end

    Citizen.CreateThread(function()
        while ActivePortals[PortalId] do
            if IncreaseRadiusSpeed or #(GetEntityCoords(PlayerPedId()) - vector3(Coords.x, Coords.y, Coords.z)) < 50.0 then
                local Alpha = 100
                if IncreaseRadiusSpeed then Alpha = 255 end
                DrawMarker(28, Coords.x, Coords.y, Coords.z + (Radius / 2) + 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Radius, Radius, Radius, 0, 0, 0, Alpha, false, false, 2, nil, nil, false)
            end
            Citizen.Wait(4)
        end
    end)

    Citizen.CreateThread(function()
        local PortalCoords = { x = Coords.x, y = Coords.y, z = Coords.z + (Radius / 2) + 0.0 }
        local Scale = 4.0 * Radius
        local X1, Y1, Z1 = 0.0, 0.0, 0.0
        local X2, Y2, Z2 = 180.0, 90.0, 270.0
        local X3, Y3, Z3 = 90.0, 270.0, 180.0

        while ActivePortals[PortalId] do
            if IncreaseRadiusSpeed or #(GetEntityCoords(PlayerPedId()) - vector3(Coords.x, Coords.y, Coords.z)) < 50.0 then
                PortalCoords = { x = Coords.x, y = Coords.y, z = Coords.z + (Radius / 2) + 0.0 }
                Scale = 4.0 * Radius

                StartParticleAtCoord("core", "veh_exhaust_afterburner", true, PortalCoords, { x = X1, y = Y1, z = Z1 }, Scale, 10.0, nil, 4)
                X1, Y1, Z1 = X1 + 1.0 + 0.0, Y1 + 1.0 + 0.0, Z1 + 1.0 + 0.0

                StartParticleAtCoord("core", "veh_exhaust_afterburner", true, PortalCoords, { x = X2, y = Y2, z = Z2 }, Scale, 10.0, nil, 4)
                X2, Y2, Z2 = X2 + 1.0 + 0.0, Y2 + 1.0 + 0.0, Z2 + 1.0 + 0.0

                StartParticleAtCoord("core", "veh_exhaust_afterburner", true, PortalCoords, { x = X3, y = Y3, z = Z3 }, Scale, 10.0, nil, 4)
                X3, Y3, Z3 = X3 + 1.0 + 0.0, Y3 + 1.0 + 0.0, Z3 + 1.0 + 0.0
            end

            Citizen.Wait(4)
        end
    end)
end)

-- // Functions \\ --

function LoadParticleDictionary(Dict)
    if not HasNamedPtfxAssetLoaded(Dict) then
        RequestNamedPtfxAsset(Dict)
        while not HasNamedPtfxAssetLoaded(Dict) do Citizen.Wait(0) end
    end
end

function StartParticleAtCoord(Dict, ParticleName, Looped, Coords, Rotation, Scale, Alpha, Color, Duration)
    LoadParticleDictionary(Dict)
    UseParticleFxAssetNextCall(Dict)
    SetPtfxAssetNextCall(Dict)

    local Particle = nil
    if Looped then
        Particle = StartParticleFxLoopedAtCoord(ParticleName, Coords.x, Coords.y, Coords.z, Rotation.x, Rotation.y, Rotation.z, Scale or 1.0)
        if Color then SetParticleFxLoopedColour(Particle, Color.r, Color.g, Color.b, false) end
        SetParticleFxLoopedAlpha(Particle, Alpha or 10.0)

        if Duration then
            Citizen.Wait(Duration)
            StopParticleFxLooped(Particle, 0)
        end
    else
        SetParticleFxNonLoopedAlpha(Alpha or 10.0)
        if Color then SetParticleFxNonLoopedColour(Color.r, Color.g, Color.b) end
        StartParticleFxNonLoopedAtCoord(ParticleName, Coords.x, Coords.y, Coords.z, Rotation.x, Rotation.y, Rotation.z, Scale or 1.0)
    end

    return Particle
end

function StartPortals()
    for k, v in pairs(Config.Portals) do
        TriggerEvent("fw-events:Client:DrawPortal", k + 1, v, 0.25)
    end

    Citizen.CreateThread(function()
        while Config.IsEventActive do
            Citizen.Wait(500)
            for k, v in pairs(Config.Portals) do
                if #(GetEntityCoords(PlayerPedId()) - vector3(v.x, v.y, v.z)) < 0.5 then
                    local RandomPortal = Config.Portals[math.random(1, #Config.Portals)]
                    SetEntityCoords(PlayerPedId(), RandomPortal.x + (math.random(6, 15) / 10), RandomPortal.y + (math.random(6, 15) / 10), RandomPortal.z)
                    SetEntityHeading(PlayerPedId(), RandomPortal.w)

                    Citizen.Wait(3000)
                end
            end
        end
    end)
end