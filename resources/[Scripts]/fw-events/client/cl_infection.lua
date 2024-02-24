InfectedPlayers, IsInfected, InfectedHitCount, StopInfection = {}, false, 0, false

RegisterNetEvent("fw-events:Client:SetInfected")
AddEventHandler("fw-events:Client:SetInfected", function(Id, Bool)
    print("Infection: ", Id, "->", Bool)
    InfectedPlayers[Id] = Bool
end)

RegisterNetEvent("fw-events:Client:RespawnAsZombie")
AddEventHandler("fw-events:Client:RespawnAsZombie", function()
    InfectedHitCount, StopInfection = 0, true
    DoScreenFadeOut(1000)
    Citizen.Wait(3000)

    TriggerServerEvent("fw-events:Server:SetInfected")

    local RandomPortal = Config.Portals[math.random(1, #Config.Portals)]
    SetEntityCoords(PlayerPedId(), RandomPortal.x + (math.random(6, 15) / 10), RandomPortal.y + (math.random(6, 15) / 10), RandomPortal.z - 1.0)
    SetEntityHeading(PlayerPedId(), RandomPortal.w)

    Citizen.Wait(1000)

    --Stop all zombies attacking the player
    for Ped, _ in pairs(AttackersCache) do
        ClearPedTasksImmediately(Ped)
        TaskWanderStandard(Ped, 1.0, 10)
    end

    -- Set walkstyle + add blood packs
    ResetPedMovementClipset(PlayerPedId(), 0.25)
    RequestAnimSet("MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP")
    while not HasAnimSetLoaded("MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP") do Citizen.Wait(0) end
    SetPedMovementClipset(PlayerPedId(), "MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP", true)

    ApplyPedDamagePack(PlayerPedId(), "BigHitByVehicle", 0.0, 9.0)
    ApplyPedDamagePack(PlayerPedId(), "SCR_Dumpster", 0.0, 9.0)
    ApplyPedDamagePack(PlayerPedId(), "SCR_Torture", 0.0, 9.0)

    ClearPedTasksImmediately(PlayerPedId())

    DoScreenFadeIn(10000)

    RequestAnimDict("stungun@standing")
    while not HasAnimDictLoaded("stungun@standing") do Citizen.Wait(4) end
    TaskPlayAnim(PlayerPedId(), "stungun@standing", "damage", 1.0, 1.0, -1, 0, 0, 0, 0, 0)
    Citizen.Wait(GetAnimDuration("stungun@standing", "damage") * 1000)
    SetPedToRagdoll(PlayerPedId(), 8000, 8000, 0, 0, 0, 0)

    FW.Functions.Notify("Je bent geïnfecteerd met het zombie virus!", "error", 10000)
end)

RegisterNetEvent("fw-events:Client:GiveAntidote")
AddEventHandler("fw-events:Client:GiveAntidote", function()
    local Player, PlayerDist = FW.Functions.GetClosestPlayer()
    if PlayerDist ~= -1 and PlayerDist < 2 then
        FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
            if not DidRemove then return end

            local Outcome = exports['fw-ui']:StartSkillTest(3, { 10, 15 }, { 950, 1500 }, false)
            if Outcome then
                TriggerServerEvent("fw-events:Server:UsedAntidote", Player)
                FW.Functions.Notify("Je hebt het tegengif gegeven..", "success")
            else
                FW.Functions.Notify("Je faalde het tegengif te geven..", "error")
            end
        end, 'zombie-antidote', 1, false)
    end
end)

RegisterNetEvent("fw-events:Client:RecieveAntidote")
AddEventHandler("fw-events:Client:RecieveAntidote", function()
    InfectedHitCount, IsInfected = 0, false
    ClearPedTasksImmediately(PlayerPedId())
    TriggerEvent('animations:client:set:walkstyle')
    RequestAnimDict("stungun@standing")
    while not HasAnimDictLoaded("stungun@standing") do Citizen.Wait(4) end
    TaskPlayAnim(PlayerPedId(), "stungun@standing", "damage", 1.0, 1.0, -1, 0, 0, 0, 0, 0)
    ClearPedBloodDamage()
    Citizen.Wait(GetAnimDuration("stungun@standing", "damage") * 1000)
    SetPedToRagdoll(PlayerPedId(), 8000, 8000, 0, 0, 0, 0)

    FW.Functions.Notify("Je bent verward en veranderd langzaam weer terug naar jezelf..", "success", 5000)
end)

AddEventHandler('gameEventTriggered', function (Name, Args)
    if Name ~= "CEventNetworkEntityDamage" then return end
    if not Config.IsEventActive then return end

    local VictimType = GetEntityType(Args[1])
    if VictimType ~= 1 then return end

    local Attacker = Args[2]
    local IsInfectedPed = false

    if IsPedAPlayer(Attacker) and Args[1] == PlayerPedId() then
        local ServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(Attacker))
        IsInfectedPed = InfectedPlayers[ServerId]
    end

    if ZombiesCache[Attacker] then
        IsInfectedPed = true
    end

    if not IsInfected and IsInfectedPed then
        InfectedHitCount = InfectedHitCount + 1
        if InfectedHitCount >= math.random(3, 6) then
            SetPlayerInfected()
        end
    end
end)

exports("IsInfected", function()
    return IsInfected
end)

exports("IsEventActive", function()
    return Config.IsEventActive
end)

function SetPlayerInfected()
    IsInfected, StopInfection = true, false
    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId("Infection"), 1.0)

    local InfectedPercentage = 1.0
    Citizen.CreateThread(function()
        while InfectedPercentage < 100.0 do
            Citizen.Wait(math.random(3000, 6000))
            InfectedPercentage = InfectedPercentage + math.random(2, 4)
            exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId("Infection"), InfectedPercentage)

            if StopInfection then break end
        end

        if not StopInfection then
            TriggerEvent('fw-events:Client:RespawnAsZombie')
        end

        StopInfection = false
        exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId("Infection"), 0.0)
    end)
end

RegisterNetEvent("fw-events:Client:SetPlayerInfected")
AddEventHandler("fw-events:Client:SetPlayerInfected", SetPlayerInfected)