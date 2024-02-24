RegisterNetEvent('fw-fx:Client:Thermite')
AddEventHandler('fw-fx:Client:Thermite', function(Coords, Detcord)
    local PlayerCoords = GetEntityCoords(PlayerPedId())
    local Distance = #(PlayerCoords - Coords)
    if Distance < 45.0 then
        RequestNamedPtfxAsset("scr_ornate_heist")
        while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
            Citizen.Wait(1)
        end
    
        SetPtfxAssetNextCall("scr_ornate_heist")
        local Effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        Citizen.Wait(11000)
        if Detcord then 
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.5)
            PlaySoundFromCoord(-1, "MAIN_EXPLOSION_CHEAP", Coords.x, Coords.y, Coords.z, 0, 0, 75.0, 0) 
        end
        StopParticleFxLooped(Effect, 0)
    end
end)

local DrugEffectTime = 0
RegisterNetEvent("fw-fx:Client:DrugEffect")
AddEventHandler("fw-fx:Client:DrugEffect", function(DrugType, Data)
    if DrugEffectTime > 0 then return end
    DrugEffectTime = 40

    if DrugType == "Crack" then
        local Loops = 0

        SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
        SetSwimMultiplierForPlayer(PlayerId(), 1.15)

        while DrugEffectTime > 0 do
            if Loops > 10 then
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.1)
                SetSwimMultiplierForPlayer(PlayerId(), 1.1)
            end
            Loops = Loops + 1
            Citizen.Wait(1000)
            RestorePlayerStamina(PlayerId(), 1.0)
            DrugEffectTime = DrugEffectTime - 1
            if IsPedRagdoll(PlayerPedId()) then
                SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
            end
        end

        DrugEffectTime = 0
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        SetSwimMultiplierForPlayer(PlayerId(), 1.0)

    elseif DrugType == "Meth" then
        DrugEffectTime = 0

        local ArmorMulti, QualityMulti, SprintEffect = GetMethFactors(Data.Purity)
        DrugEffectTime = QualityMulti * 6

        if Data.Purity and Data.Purity < 40 then
            FW.Functions.Notify("Deze kwaliteit is echt net stront.", "error")
        end

        TriggerServerEvent('fw-ui:Server:remove:stress', math.random(15, 100) / 10)

        local Loops = 0
        while DrugEffectTime > 0 do
            Loops = Loops + 1
            if Loops > 20 then
                SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
                SetSwimMultiplierForPlayer(PlayerId(), 1.0)
            end

            if Loops < 20 then
                SetRunSprintMultiplierForPlayer(PlayerId(), SprintEffect)
                SetSwimMultiplierForPlayer(PlayerId(), SprintEffect)
                RestorePlayerStamina(PlayerId(), 1.0)
            end

            Citizen.Wait(1000)

            DrugEffectTime = DrugEffectTime - 1
            if IsPedRagdoll(PlayerPedId()) then
                SetPedToRagdoll(PlayerPedId(), math.random(5), math.random(5), 3, 0, 0, 0)
            end

            if ArmorMulti > 0 then
                SetPedArmour(PlayerPedId(), math.floor(GetPedArmour(PlayerPedId()) + ArmorMulti))
            end
        end
        DrugEffectTime = 0

        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
        SetSwimMultiplierForPlayer(PlayerId(), 1.0)
    end
end)

function GetMethFactors(Purity)
    local ArmorMulti, QualityMulti, SprintEffect = 0.0, 1.0, 1.0
    Purity = Purity and Purity or 20

    if Purity > 25 and Purity <= 50 then
        QualityMulti, SprintEffect = 2.0, 1.05
    elseif Purity > 50 and Purity <= 62.5 then
        QualityMulti, SprintEffect, ArmorMulti = 3.0, 1.1, 1.0
    elseif Purity > 62.5 and Purity <= 75 then
        QualityMulti, SprintEffect, ArmorMulti = 6.0, 1.15, 1.0
    elseif Purity > 75 and Purity <= 90 then
        QualityMulti, ArmorMulti, SprintEffect = 12.0, 1.0, 1.15
    elseif Purity > 90 and Purity <= 99 then
        QualityMulti, ArmorMulti, SprintEffect = 18.0, 2.0, 1.16
    elseif Purity > 99 then
        QualityMulti, ArmorMulti, SprintEffect = 30.0, 3.0, 1.175
    end

    return ArmorMulti, QualityMulti, SprintEffect
end