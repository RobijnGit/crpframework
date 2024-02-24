FW.OneSync = {}

-- OneSync Player Coords
function FW.OneSync.GetPlayerCoords(PlayerId)
    local Prom = promise.new()

    FW.Functions.TriggerCallback("FW:Server:GetPlayerCoords", function(Coords)
        Prom:resolve(Coords)
    end, PlayerId)

    return Citizen.Await(Prom)
end