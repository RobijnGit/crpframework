function LoadCutscene(cut, flag1, flag2)
    if (not flag1) then
        RequestCutscene(cut, 8)
    else
        RequestCutsceneEx(cut, flag1, flag2)
    end
    while (not HasThisCutsceneLoaded(cut)) do
        Wait(0)
    end
    return
end

function Finish(timer)
    local tripped = false

    repeat
        Wait(0)
        if (timer and (GetCutsceneTime() > timer)) then
            DoScreenFadeOut(250)
            tripped = true
        end

        if (GetCutsceneTotalDuration() - GetCutsceneTime() <= 250) then
            DoScreenFadeOut(250)
            tripped = true
        end
    until not IsCutscenePlaying()
    if (not tripped) then
        DoScreenFadeOut(100)
        Wait(150)
    end
    return
end

function BeginCutsceneWithPlayer()
    local plyrId = PlayerPedId()
    local playerClone = ClonePed_2(plyrId, 0.0, false, true, 1)

    SetBlockingOfNonTemporaryEvents(playerClone, true)
    SetEntityVisible(playerClone, false, false)
    SetEntityInvincible(playerClone, true)
    SetEntityCollision(playerClone, false, false)
    FreezeEntityPosition(playerClone, true)
    SetPedHelmet(playerClone, false)
    RemovePedHelmet(playerClone, true)

    SetCutsceneEntityStreamingFlags('MP_1', 0, 1)
    RegisterEntityForCutscene(plyrId, 'MP_1', 0, GetEntityModel(plyrId), 64)

    Wait(10)
    StartCutscene(0)
    Wait(10)
    ClonePedToTarget(playerClone, plyrId)
    Wait(10)
    DeleteEntity(playerClone)
    Wait(50)
    DoScreenFadeIn(250)

    return playerClone
end
