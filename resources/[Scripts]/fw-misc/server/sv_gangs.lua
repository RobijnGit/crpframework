local AuthCode = 'HBWH7378KL'

FW.Functions.CreateCallback("fw-misc:Server:Gangs:IsAuthCodeCorrect", function(Source, Cb, Code, GangId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    if Player.PlayerData.job.name ~= 'police' then
        return
    end

    if Code == AuthCode then
        TriggerEvent("fw-logs:Server:Log", 'police-raids', "Stash Opened with Auth Code [" .. GetInvokingResource() .. "]", ("User: [%s] - %s - %s\nCallsign: %s\nGang Id: %s"):format(Source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Player.PlayerData.metadata.callsign, GangId), "red")
    end

    Cb(Code == AuthCode)
end)