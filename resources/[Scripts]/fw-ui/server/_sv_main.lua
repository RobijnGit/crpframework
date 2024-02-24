local FW = exports['fw-core']:GetCoreObject()

-- Code

RegisterNetEvent("fw-ui:Server:CreateBadge")
AddEventHandler("fw-ui:Server:CreateBadge", function(Data, Badge)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Data.Job then goto SkipJob end
    if Player.PlayerData.job.name ~= Data.Job then return end
    if not Player.PlayerData.metadata.ishighcommand then return end

    ::SkipJob::

    local ItemInfo = {
        Name = Badge.Name,
        Rank = Badge.Rank,
        Callsign = #Badge.Callsign > 0 and Badge.Callsign or nil,
        Image = Badge.Image,
        Department = Badge.Department or Data.Department,
    }

    Player.Functions.AddItem("identification-badge", 1, false, ItemInfo, true, Data.Badge)
end)

FW.Commands.Add("ui-r", "Restart het ui script", {}, false, function(source, args)
    TriggerClientEvent('fw-ui:Client:refresh', source)
    TriggerClientEvent('FW:Client:CloseNui', source)
    TriggerClientEvent('fw-phone:Client:ClosePhone', source)
    TriggerClientEvent('fw-menu:client:force:close', source)
    TriggerClientEvent('fw-inventory:Client:CloseInventory', source)
end)

FW.Commands.Add("players", "Kijk hoeveel spelers er online zijn", {}, false, function(Source, args)
    TriggerClientEvent('chatMessage', Source, "SYSTEM", "normal", "Online Spelers: "..#GetPlayers().." / "..GetConvarInt('sv_maxclients', 64))
end)

RegisterServerEvent('fw-ui:Server:gain:stress')
AddEventHandler('fw-ui:Server:gain:stress', function(Amount)
    local Player = FW.Functions.GetPlayer(source)
	if Player ~= nil then
        if exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Stress') then
            Amount = math.floor(Amount * 0.7)
        end

        local NewStress = Player.PlayerData.metadata["stress"] + Amount
        if NewStress <= 0 then NewStress = 0 end
        if NewStress > 105 then NewStress = 100 end
        Player.Functions.SetMetaData("stress", NewStress)
        TriggerClientEvent("fw-hud:Client:UpdateStress", Player.PlayerData.source, NewStress)
	end
end)

RegisterServerEvent('fw-ui:Server:remove:stress')
AddEventHandler('fw-ui:Server:remove:stress', function(Amount)
    local Player = FW.Functions.GetPlayer(source)
	if Player ~= nil then
        local NewStress = Player.PlayerData.metadata["stress"] - Amount
        if NewStress <= 0 then NewStress = 0 end
        if NewStress > 105 then NewStress = 100 end
        Player.Functions.SetMetaData("stress", NewStress)
        TriggerClientEvent("fw-hud:Client:UpdateStress", Player.PlayerData.source, NewStress)
	end
end)

RegisterServerEvent('fw-sound:server:play:distance')
AddEventHandler('fw-sound:server:play:distance', function(maxDistance, soundFile, soundVolume)
    if maxDistance > 150 then maxDistance = 150 end
    local MyCoords = GetEntityCoords(GetPlayerPed(source))
    for k, v in pairs(FW.GetPlayers()) do
        if #(MyCoords - v.Coords) <= maxDistance then
            TriggerClientEvent('fw-sound:client:play:distance', v.ServerId, soundFile, soundVolume)
        end
    end
end)

RegisterCommand("+jumpscarePlayer", function(source, args)
    if source ~= 0 then return end

    TriggerClientEvent("fw-ui:Client:DoJumpscare", tonumber(args[1]))
end)