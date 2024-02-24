FW.Functions.CreateCallback("fw-phone:Server:Wenmo:GetTransactions", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_wenmo` WHERE `from_citizenid` = @Cid OR `to_citizenid` = @Cid ORDER BY `timestamp` DESC", {
        ['@Cid'] = Player.PlayerData.citizenid
    })

    local Retval = {}

    for k, v in pairs(Result) do
        local Id = #Retval + 1
        local IsSender = v.from_citizenid == Player.PlayerData.citizenid

        Retval[Id] = {
            Cid = IsSender and v.to_citizenid or v.from_citizenid,
            Name = IsSender and FW.Functions.GetPlayerCharName(v.to_citizenid) or FW.Functions.GetPlayerCharName(v.from_citizenid),
            Comment = v.comment,
            Amount = v.amount,
            Timestamp = v.timestamp,
            IsSender = IsSender,
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-phone:Server:Wenmo:SendMoney", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then
        Cb({Success = false, Msg = "Ongeldige Speler"})
        return
    end

    
    local Target = FW.Functions.GetPlayerByPhone(tostring(Data.Phone))
    if Target == nil then
        Cb({Success = false, Msg = "Ongeldige Speler"})
        return
    end

    if Player.PlayerData.citizenid == Target.PlayerData.citizenid then
        Cb({Success = false, Msg = "Je kan jezelf geen Wenmo sturen."})
        return
    end

    local Comment = "No Comment"
    if Data.Comment then Comment = Data.Comment end

    if exports['fw-financials']:RemoveMoneyFromAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, Player.PlayerData.charinfo.account, tonumber(Data.Amount), 'WENMO', Comment, false) then
        exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, Target.PlayerData.charinfo.account, tonumber(Data.Amount), "WENMO", Comment)
        TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, 'wenmo-deposit-' .. math.random(111, 999), 'fas fa-home', { 'white', 'rgb(38, 50, 56)' }, "Wenmo", exports['fw-businesses']:NumberWithCommas(Data.Amount) .. " werd in je rekening gestort.")
        TriggerClientEvent("fw-phone:Client:SetAppUnread", Target.PlayerData.source, "wenmo")

        TriggerEvent("fw-logs:Server:Log", 'wenmo', "Wenmo Transaction", ("User: [%s] - %s - %s\nTarget: [%s] - %s - %s\nAmount: %s\nComment: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Target.PlayerData.source, Target.PlayerData.citizenid, Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname, exports['fw-businesses']:NumberWithCommas(tonumber(Data.Amount)), Comment), "blue")

        exports['ghmattimysql']:execute("INSERT INTO `phone_wenmo` (`from_citizenid`, `to_citizenid`, `amount`, `comment`) VALUES (@FromCid, @ToCid, @Amount, @Comment)", {
            ['@FromCid'] = Player.PlayerData.citizenid,
            ['@ToCid'] = Target.PlayerData.citizenid,
            ['@Amount'] = tonumber(Data.Amount),
            ['@Comment'] = Comment,
        })
        Cb({Success = true})
    else
        Cb({Success = false, Msg = "Niet Genoeg Balans"})
    end
end)