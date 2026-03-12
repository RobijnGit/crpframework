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
        return print("^1Disabling double license check!^7")
    end

    while true do
        Citizen.Wait(60000 * 2) -- every 2 minutes

        local connectedLicenses = {}

        for k, v in pairs(FW.GetPlayers()) do
            if connectedLicenses[v.License] ~= nil and connectedLicenses[v.License] > 0 then
                TriggerEvent('fw-logs:Server:Log', 'anticheatDoubleConnection', 'Dupe-Player Kicked', ('%s (%s) was kicked from the server because another client is connected with the same Rockstar License.'):format(v.Name, v.License), 'red')
                DropPlayer(v.ServerId, "You can not play with the same Rockstar-account twice.")
                DropPlayer(connectedLicenses[v.License], "You can not play with the same Rockstar-account twice.")
            end

            connectedLicenses[v.License] = v.ServerId
        end
    end
end)
