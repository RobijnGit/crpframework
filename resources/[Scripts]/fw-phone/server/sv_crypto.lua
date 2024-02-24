FW.Functions.CreateCallback("fw-phone:Server:Crypto:BuyCrypto", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then
        Cb({Success = false, Msg = "Ongeldige Koper"})
        return
    end

    if tonumber(Data.Amount) <= 0 then
        Cb({Success = false, Msg = "Ongeldige Aantal"})
        return
    end

    local Crypto = nil
    for k, v in pairs(Config.Crypto) do
        if v.Id == Data.CryptoId then
            Crypto = v
            break
        end
    end

    if Crypto == nil then
        Cb({Success = false, Msg = "Ongeldige Crypto"})
        return
    end

    local Costs = Crypto.Costs * tonumber(Data.Amount)
    if exports['fw-financials']:RemoveMoneyFromAccount("1001", "3", Player.PlayerData.charinfo.account, Costs, 'PURCHASE', 'Bought ' .. Data.Amount .. ' ' .. Crypto.Id) then
        TriggerEvent("fw-logs:Server:Log", 'crypto', "Crypto Purchased [" .. GetInvokingResource() .. "]", ("User: [%s] - %s - %s\nCrypto ID: %s\nAmount: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Crypto.Id, Data.Amount), "purple")
        Player.Functions.AddCrypto(Crypto.Id, tonumber(Data.Amount))
        Cb({Success = true})
    else
        Cb({Success = false, Msg = "Niet Genoeg Balans"})
    end
end)

FW.Functions.CreateCallback("fw-phone:Server:Crypto:TransferCrypto", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then
        Cb({Success = false, Msg = "Ongeldige Speler"})
        return
    end

    local Target = FW.Functions.GetPlayerByPhone(Data.Phone)
    if Target == nil then
        Cb({Success = false, Msg = "Ongeldige Speler"})
        return
    end

    if tonumber(Data.Amount) <= 0 then
        Cb({Success = false, Msg = "Ongeldige Aantal"})
        return
    end

    local Crypto = Config.Crypto[tonumber(Data.Id)]
    if Crypto == nil then
        Cb({Success = false, Msg = "Ongeldige Crypto"})
        return
    end

    if not Player.Functions.RemoveCrypto(Crypto.Id, tonumber(Data.Amount)) then
        Cb({Success = false, Msg = "Onvoldoende in Wallet"})
        return
    end

    Target.Functions.AddCrypto(Crypto.Id, tonumber(Data.Amount))
    TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, "crypto-transfer-"..Source, "fas fa-wallet", { "white", "#121315" }, "Crypto ontvangen", string.format("Er is %d %s overgemaakt naar je wallet.", Data.Amount, Crypto.Id), false, false, nil, nil, nil)
    TriggerEvent("fw-logs:Server:Log", 'crypto', "Crypto Transfered [" .. GetInvokingResource() .. "]", ("User: [%s] - %s - %s\nTarget: [%s] - %s - %s\nCrypto ID: %s\nAmount: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Target.PlayerData.source, Target.PlayerData.citizenid, Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname, Crypto.Id, Data.Amount), "purple")

    Cb({Success = true})
end)
