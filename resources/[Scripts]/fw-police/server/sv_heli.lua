RegisterNetEvent('fw-police:Server:Helicam:SyncSpotlightStatus', function(Id, NetId, State, Coords)
    local AllPlayers = FW.GetPlayers()
    for k, v in pairs(AllPlayers) do
        local TargetCoords = GetEntityCoords(GetPlayerPed(v.ServerId))
        local Distance = #(Coords.Coords - TargetCoords)
        if Distance <= 300.0 then
            TriggerClientEvent('fw-police:Client:Helicam:SyncSpotlightState', v.ServerId, Id, NetId, State, Coords)
        else
            TriggerClientEvent('fw-police:Client:Helicam:SyncSpotlightState', v.ServerId, Id, NetId, false, Coords)
        end
    end
end)