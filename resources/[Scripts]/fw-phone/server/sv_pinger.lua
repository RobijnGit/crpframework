local Pings = {}

RegisterNetEvent("fw-phone:Server:Pinger:SendPing")
AddEventHandler("fw-phone:Server:Pinger:SendPing", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(tostring(Data.Id))
    if Target == nil then return end

    local PingId = math.random(1, 99999)
    Pings[PingId] = true

    TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, 'ping-request-' .. PingId, 'fas fa-map-pin', { 'white', '#FA8A6A' }, Data.IsAnon and 'Anoniem' or (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname), "Ping Verzoek", false, true, "fw-phone:Server:Pinger:AcceptPing", "fw-phone:Server:Pinger:DeclinePing", { HideOnAction = true, Coords = GetEntityCoords(GetPlayerPed(Source)), PingId = PingId })
end)

RegisterNetEvent("fw-phone:Server:Pinger:AcceptPing")
AddEventHandler("fw-phone:Server:Pinger:AcceptPing", function(Data)
    local Source = source

    if Pings[Data.PingId] then
        Pings[Data.PingId] = false
        TriggerClientEvent('fw-phone:Client:Pinger:SetBlip', Source, Data.Coords)
    end
end)

RegisterNetEvent("fw-phone:Server:Pinger:DeclinePing")
AddEventHandler("fw-phone:Server:Pinger:DeclinePing", function(Data)
    local Source = source

    if Pings[Data.PingId] then
        Pings[Data.PingId] = false
    end
end)