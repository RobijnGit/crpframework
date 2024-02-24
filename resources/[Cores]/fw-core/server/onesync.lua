-- Get Players
FW.Functions.CreateCallback("FW:Server:GetPlayers", function(Source, Cb)
    Cb(FW.GetPlayers())
end)

FW.Functions.CreateCallback("FW:Server:GetPlayerCoords", function(Source, Cb, PlayerId)
    Cb(GetEntityCoords(GetPlayerPed(tonumber(PlayerId))))
end)