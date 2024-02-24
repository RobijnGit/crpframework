-- Code

RegisterNetEvent("fw-core:Server:Player:Spawned")
AddEventHandler('fw-core:Server:Player:Spawned', function()
    Citizen.SetTimeout(2500, function()
        TriggerServerEvent('fw-queue:Server:Activate:Player')
    end)
end)