FW.Functions.CreateCallback("fw-jobmanager:Server:Taxi:CreatePed", function(Source, Cb)
    local Model = Config.TaxiPeds[math.random(#Config.TaxiPeds)]
    local Pickup = Config.TaxiTravelers[math.random(#Config.TaxiTravelers)]
    local Destination = Config.TaxiDestinations[math.random(#Config.TaxiDestinations)]

    local Ped = CreatePed(-1, GetHashKey(Model), Pickup.x, Pickup.y, Pickup.z, Pickup.w, true, true)
    while not DoesEntityExist(Ped) do Citizen.Wait(1) end

    SetEntityHeading(Ped, Pickup.w)

    Cb({NetworkGetNetworkIdFromEntity(Ped), Pickup, Destination})
end)

FW.RegisterServer("fw-jobmanager:Server:Taxi:DeletePed", function(Source, NetId, Distance)
    DeleteEntity(NetworkGetEntityFromNetworkId(NetId))

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- €0.1 per 1 meter at daytime, €0.15 per 1 meter at nighttime.
    local Payout = 0.1
    local Time = exports['fw-sync']:GetCurrentTime()
    if Time.Hour > 21 and Time.Hour < 6 then
        Payout = 0.15
    end

    -- increase with €0.05 per 1 meter
    if exports['fw-hud']:DoesPlayerHaveBuff(Source, "Salary") then
        Payout = Payout + 0.05
    end

    local Earnings = math.ceil(Payout * Distance)
    TriggerClientEvent('fw-phone:Client:Notification', Player.PlayerData.source, "jobcenter-paycheck", "fas fa-home", {"white", "rgb(38, 50, 56)"}, "Werkopdracht", exports['fw-businesses']:NumberWithCommas(Earnings) .. ' is overgemaakt naar je bankrekening.')
    exports['fw-financials']:AddMoneyToAccount("1001", "1", Player.PlayerData.charinfo.account, Earnings, 'PAYMENT', 'Taxirit: ' .. string.format("%.2f", Distance / 1000) .. " km")
end)