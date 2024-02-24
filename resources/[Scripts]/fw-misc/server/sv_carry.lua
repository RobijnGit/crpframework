local Carrying, Carried = {}, {}

FW.Commands.Add("carry", "Meeslepen die handel", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    if Player.PlayerData.metadata.isdead or Player.PlayerData.metadata.ishandcuffed then return end

    TriggerClientEvent('fw-misc:Server:Try:Carry', Source)
end)

RegisterServerEvent('fw-misc:Server:Carry:Target')
AddEventHandler('fw-misc:Server:Carry:Target', function(Target)
    local TPlayer = FW.Functions.GetPlayer(Target)
    if TPlayer ~= nil then
        TriggerClientEvent('fw-misc:Server:Getting:Carried', Target, source)
        Carrying[source], Carried[Target] = Target, source
    end
end)

RegisterServerEvent('fw-misc:Server:Stop:Carry')
AddEventHandler('fw-misc:Server:Stop:Carry', function()
    if Carrying[source] then
        local Target = Carrying[source]
        TriggerClientEvent('fw-misc:Client:Stop:Carry', Target)
        Carrying[source], Carried[Target] = nil, nil
        return 
    end
    if Carried[source] then
        local Target = Carried[source]
        TriggerClientEvent('fw-misc:Client:Stop:Carry', Target)
        Carrying[Target], Carried[source] = nil, nil
        return 
    end
end)

AddEventHandler('playerDropped', function(Reason)
	local Source = source
    if Carrying[source] then
        local Target = Carrying[source]
        TriggerClientEvent('fw-misc:Client:Stop:Carry', Target)
        Carrying[source], Carried[Target] = nil, nil
    end
    if Carried[source] then
        local Target = Carried[source]
        TriggerClientEvent('fw-misc:Client:Stop:Carry', Target)
        Carrying[Target], Carried[source] = nil, nil
    end
end)