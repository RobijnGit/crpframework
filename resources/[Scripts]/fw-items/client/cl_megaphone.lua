local UsingMegaPhone = false

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and UsingMegaPhone then
            if not IsEntityPlayingAnim(PlayerPedId(), "amb@world_human_mobile_film_shocking@female@base", "base", 3) then
                exports['fw-assets']:RequestAnimationDict('amb@world_human_mobile_film_shocking@female@base')
                TaskPlayAnim(PlayerPedId(), 'amb@world_human_mobile_film_shocking@female@base', 'base', 1.0, 1.0, GetAnimDuration('amb@world_human_mobile_film_shocking@female@base', 'base'), 49, 0, 0, 0, 0)
            end
            Citizen.Wait(1000)
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-items:Client:Used:Megaphone')
AddEventHandler('fw-items:Client:Used:Megaphone', function()
    Citizen.SetTimeout(1000, function()
        if not UsingMegaPhone then
            UsingMegaPhone = true
            exports['fw-assets']:AddProp('Megaphone')
            exports['fw-assets']:RequestAnimationDict('amb@world_human_mobile_film_shocking@female@base')
            TaskPlayAnim(PlayerPedId(), 'amb@world_human_mobile_film_shocking@female@base', 'base', 1.0, 1.0, GetAnimDuration('amb@world_human_mobile_film_shocking@female@base', 'base'), 49, 0, 0, 0, 0)
            TriggerServerEvent("fw-voice:Server:Transmission:State", 'Megaphone', true)
            TriggerEvent('fw-voice:Client:Proximity:Override', "Megaphone", 3, 15.0, 2)
        else
            UsingMegaPhone = false
            exports['fw-assets']:RemoveProp()
            StopAnimTask(PlayerPedId(), 'amb@world_human_mobile_film_shocking@female@base', 'base', 1.0)
            TriggerServerEvent("fw-voice:Server:Transmission:State", 'Megaphone', false)
            TriggerEvent('fw-voice:Client:Proximity:Override', "Megaphone", 3, -1, -1)
        end
    end)
end)