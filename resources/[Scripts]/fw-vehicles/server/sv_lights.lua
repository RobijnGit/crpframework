RegisterNetEvent('fw-emergencylights:Server:MuteSirens')
AddEventHandler('fw-emergencylights:Server:MuteSirens', function(NetVeh)
    TriggerClientEvent('fw-emergencylights:Client:MuteSirens', -1, NetVeh)
end)