RegisterServerEvent("FW:Server:Sync:Request", function(Native, TargetId, NetId, ...)
    if TargetId == nil then return end
    TargetId = tonumber(TargetId)

    local Player = FW.Functions.GetPlayer(TargetId)
    if Player == nil then return print(("^1[FW-VEHICLE-SYNC-ERROR]: Request for native %s couldn't be executed because target [%s] does not exist. ^7"):format(Native, TargetId)) end

    TriggerClientEvent("FW:Client:Sync:Execute", TargetId, Native, NetId, ...)
end)