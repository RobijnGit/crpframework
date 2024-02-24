RegisterNetEvent('fw-emotes:Client:StopDance')
AddEventHandler('fw-emotes:Client:StopDance', function()
    if not CurrentDance then
        return
    end

    StopAnimTask(PlayerPedId(), CurrentDance.Dict, CurrentDance.Anim, 1.0)
    CurrentDance = false
end)

RegisterNetEvent('fw-emotes:Client:PlayDance')
AddEventHandler('fw-emotes:Client:PlayDance', function(DanceNumber)
    local TotalAnims = #Config.Dances
    if DanceNumber == -1 then
        DanceNumber = math.random(TotalAnims)
        print('Selected dance: ', DanceNumber)
    end

    if DanceNumber > TotalAnims or DanceNumber <= 0 then
        return
    end

    if Config.Dances[DanceNumber].Disabled then
        return
    end

    if CurrentDance then
        TriggerEvent('fw-emotes:Client:StopDance')
    end

    CurrentDance = Config.Dances[DanceNumber]
    exports['fw-assets']:RequestAnimationDict(CurrentDance.Dict)
    TaskPlayAnim(PlayerPedId(), CurrentDance.Dict, CurrentDance.Anim, 3.0, 3.0, -1, 1, 0, 0, 0, 0)
end)