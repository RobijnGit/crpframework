FW, LoggedIn = exports['fw-core']:GetCoreObject(), false
ActivePortals, FreezeCoords = {}, vector3(0.0, 0.0, 0.0)

-- Code

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true

    Citizen.SetTimeout(1250, function()
        LoggedIn = true

        Config.Portals = FW.SendCallback("fw-events:Server:GetPortals")
        Config.IsEventActive = FW.SendCallback("fw-events:Server:Is:Event:Active")
        FreezeCoords = FW.SendCallback("fw-events:Server:GetFreezeCoords")
        InfectedPlayers = FW.SendCallback("fw-events:Server:GetInfectedPlayers")

        if Config.IsEventActive then
            StartEvent()
        end
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- // Evemts \\ --

RegisterNetEvent('fw-events:Client:Start:Event')
AddEventHandler('fw-events:Client:Start:Event', function()
    StartEvent()
end)

RegisterNetEvent('fw-events:Client:End:Event')
AddEventHandler('fw-events:Client:End:Event', function()
    TriggerEvent("fw-events:Server:OnEventStop")
    local Timer = GetGameTimer()
    local GoodbyeStage = 1

    local ParticleData = { Dict = "scr_xs_dr",  Name = "scr_xs_dr_emp" }
    local WaitTime = 1000

    Citizen.CreateThread(function()
        local Radius = 2.0
        local Coords = vector3(-1889.23, -1272.43, 0.49)
        while GoodbyeStage == 1 do
            DrawSphere(Coords.x, Coords.y, Coords.z + (Radius / 2), Radius, 255, 255, 255, 1.0)
            Citizen.Wait(4)
        end

        TriggerEvent("fw-events:Client:DrawPortal", 1, Coords, 1.5, 10, 150.0, function()
            Citizen.CreateThread(function()
                Radius = 1.0
                local HasEffect = false
                while not HasEffect do
                    if Radius > 9471.0 then print(GetGameTimer() - Timer) return end
                    Radius = Radius + 10.0

                    DrawSphere(Coords.x, Coords.y, Coords.z + (Radius / 2), Radius, 255, 255, 255, 1.0)

                    if (not HasEffect) and #(GetEntityCoords(PlayerPedId()) - vector3(Coords.x, Coords.y, Coords.z + (Radius / 2))) < Radius then
                        HasEffect = true
                        AnimpostfxStopAll()
                        AnimpostfxPlay("DrugsMichaelAliensFight", 9999.0, true)
                    end

                    Citizen.Wait(0)
                end
            end)
        end)
    end)

    for i = 1, 30, 1 do
        local Scale = 7.0
        WaitTime = WaitTime - 50
        Citizen.Wait(WaitTime)

        if i == 30 then
            Scale = 300.0
            GoodbyeStage = 2
        end

        StartParticleAtCoord(ParticleData.Dict, ParticleData.Name, true, vector3(-2025.28, -1446.2, 136.02), vector3(0.0, 0.0, 0.0), Scale, false, false, WaitTime)
    end
end)

-- // Functions \\ --

function StartEvent()
    Config.IsEventActive, IsInfected = true, false
    TriggerEvent("fw-events:Client:OnEventStart")

    Citizen.CreateThread(function()
        StopStream()
        LoadStream("outbreaksiren", "DLC_NIKEZ_MISC")
        while Config.IsEventActive do
            if not IsStreamPlaying() and LoadStream("outbreaksiren", "DLC_NIKEZ_MISC") then
                PlayStreamFromPosition(-75.24, -818.96, 27.94)
            end
            Citizen.Wait(500)
        end
        StopStream() PlayStreamFromPosition(0.0, 0.0, 0.0)
    end)

    -- NPC Zombies
    exports['fw-assets']:SetDensity('Peds', 1.0)
    exports['fw-assets']:SetDensity('Vehicle', 1.0)

    StartPortals()
    EventThread()
end

exports("IsOutbreakActive", function()
    return Config.IsEventActive
end)

RegisterNetEvent("fw-events:Client:SetEventFreezeCoords")
AddEventHandler("fw-events:Client:SetEventFreezeCoords", function(Data)
    FreezeCoords = Data
end)