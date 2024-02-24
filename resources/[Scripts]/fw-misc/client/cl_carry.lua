local Carrying, Carried = false, false

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if Carrying or Carried then
                if Carrying then
                    if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 3) then
                        TaskPlayAnim(PlayerPedId(), 'missfinale_c2mcs_1', 'fin_c2_mcs_1_camman', 8.0, -8.0, -1, 49, 0, false, false, false)
                    end
                    if IsControlJustPressed(0, 38) then
                        TriggerServerEvent('fw-misc:Server:Stop:Carry')
                        exports['fw-ui']:HideInteraction()
                        ClearPedTasks(PlayerPedId())
                        Carrying = false
                    end
                end
            else
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-misc:Server:Try:Carry')
AddEventHandler('fw-misc:Server:Try:Carry', function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Distance > 2.0 then return end

    if Carrying or Carried then return end
    if Player == -1 then
        FW.Functions.Notify("Niemand in de buurt..", "error")
        return
    end
    if not IsPedInAnyVehicle(PlayerPedId()) and not IsPedInAnyVehicle(Player) then
        FW.Functions.Notify("Druk E om de persoon op de grond te zetten.", "primary", 10000)
        TriggerServerEvent('fw-misc:Server:Carry:Target', Player)
        exports['fw-ui']:ShowInteraction('[E] Drop')
        RequestCarryAnims(false)
        Carrying = true
    end
end)

RegisterNetEvent('fw-misc:Server:Getting:Carried')
AddEventHandler('fw-misc:Server:Getting:Carried', function(Source)
    local TargetPed = GetPlayerPed(GetPlayerFromServerId(Source))
    AttachEntityToEntity(PlayerPedId(), TargetPed , 1, -0.68, -0.2, 0.94, 180.0, 180.0, 60.0, 1, 1, 0, 1, 0, 1)
    exports['fw-inventory']:SetBusyState(true)
    TaskTurnPedToFaceEntity(PlayerPedId(), TargetPed, 1.0)
    SetPedKeepTask(PlayerPedId(), true)
    RequestCarryAnims(true)
    Carried = true

    if Carrying then
        TriggerServerEvent('fw-misc:Server:Stop:Carry')
        exports['fw-ui']:HideInteraction()
        ClearPedTasks(PlayerPedId())
        Carrying = false
    end
end)

RegisterNetEvent('fw-misc:Client:Stop:Carry')
AddEventHandler('fw-misc:Client:Stop:Carry', function()
    exports['fw-inventory']:SetBusyState(false)
    DetachEntity(PlayerPedId(), true, false)
    ClearPedTasks(PlayerPedId())
    Carried, Carrying = false, false
end)

-- // Functions \\ --

function RequestCarryAnims(PlayCarried)
    exports['fw-assets']:RequestAnimationDict('amb@world_human_bum_slumped@male@laying_on_left_side@base')
    exports['fw-assets']:RequestAnimationDict('missfinale_c2mcs_1')
    exports['fw-assets']:RequestAnimationDict('dead')
    if PlayCarried then
        TaskPlayAnim(PlayerPedId(), "dead", "dead_f", 8.0, 8.0, -1, 1, 0, 0, 0, 0)
        TaskPlayAnim(PlayerPedId(), "amb@world_human_bum_slumped@male@laying_on_left_side@base", "base", 8.0, 8.0, -1, 1, 999.0, 0, 0, 0)
    end
end

exports("IsCarried", function()
    return Carried
end)