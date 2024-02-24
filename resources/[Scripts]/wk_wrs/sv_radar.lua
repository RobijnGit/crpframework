FW = exports['fw-core']:GetCoreObject()

FW.Commands.Add("radar", "Toggle ANPR", {}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name == 'police' then
        TriggerClientEvent('wk:toggleRadar', Source)
    end
end)
