Citizen.CreateThread(function()
    while true do
        Citizen.Wait((1000 * 60) * 10)

        local IncomeTax = 0
        for k, v in pairs(FW.GetPlayers()) do
            local Player = FW.Functions.GetPlayer(v.ServerId)
            if Player ~= nil then
                local Payment, Deduction = FW.Shared.DeductTax("Personal Income", Player.PlayerData.job.payment)
                local NewPaycheck = Player.PlayerData.metadata['paycheck'] + Payment
                Player.Functions.SetMetaData('paycheck', NewPaycheck)
                IncomeTax = Deduction + 1
            end
        end

        exports['fw-financials']:AddMoneyToAccount('1001', "1", "1", IncomeTax, '', '', true)
    end
end)

Citizen.CreateThread(function()
    while not exports['fw-config']:IsConfigReady() do
        Citizen.Wait(1)
    end

    local ServerCode = exports['fw-config']:GetServerCode()
    if ServerCode ~= "wl" then
        return print("^1Disabling double steamid check!^7")
    end

    while true do
        Citizen.Wait(60000 * 2) -- every 2 minutes

        local UsedSteamIds = {}

        for k, v in pairs(FW.GetPlayers()) do
            if UsedSteamIds[v.Steam] ~= nil and UsedSteamIds[v.Steam] > 0 then
                TriggerEvent('fw-logs:Server:Log', 'anticheatDoubleConnection', 'Dupe-Player Kicked', ('%s (%s) was kicked from the server because another client is connected with the same steam id.'):format(v.Name, v.Steam), 'red')
                DropPlayer(v.ServerId, "Je zit al op de server met een andere FiveM-client..")
                DropPlayer(UsedSteamIds[v.Steam], "Je zit al op de server met een andere FiveM-client..")
            end

            UsedSteamIds[v.Steam] = v.ServerId
        end
    end
end)
