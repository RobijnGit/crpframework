FW = exports['fw-core']:GetCoreObject()

-- Code

FW.Commands.Add("staatsmelding", "Verzend een melding als de Staat.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'judge' and Player.PlayerData.job.name ~= 'mayor' then
        return Player.Functions.Notify("Je kan geen melding maken..", "error")
    end

    TriggerClientEvent("fw-cityhall:Client:SendAnnouncement", Source)
end)

FW.RegisterServer("fw-cityhall:Server:SendAnnouncement", function(Source, Label, Text)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'judge' and Player.PlayerData.job.name ~= 'mayor' then
        return Player.Functions.Notify("Je kan geen melding maken..", "error")
    end

    TriggerClientEvent('chatMessage', -1, "[" .. Label .. "]", "warning", Text)
    TriggerEvent("fw-logs:Server:Log", 'mayor', "State Announcement [" .. Label .. "]", ("User: [%s] - %s - %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Text), "cyan")
end)

FW.RegisterServer("fw-cityhall:Server:RequestBankaccount", function(Source, Cid)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'judge' or not Player.PlayerData.metadata.ishighcommand then
        return Player.Functions.Notify("Geen toegang..", "error")
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT `charinfo` FROM `players` WHERE `citizenid` = ?", {Cid})
    if Result[1] == nil then
        return Player.Functions.Notify("Geen bankaccount gevonden met het gegeven BSN..", "error")
    end

    local CharInfo = json.decode(Result[1].charinfo)
    TriggerClientEvent('chatMessage', Source, "Resultaat", "warning", CharInfo.account)
end)

RegisterNetEvent('fw-cityhall:Server:PurchaseId')
AddEventHandler('fw-cityhall:Server:PurchaseId', function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Data.Type == "Driver" and not Player.PlayerData.metadata.licenses.driver then
        return Player.Functions.Notify("Je hebt geen rijbewijs..", "error")
    end

    if Player.Functions.RemoveMoney('cash', Config.IdPrice) then
        local CardInfo = {}
        if Data.Type == "Identity" then
            Player.Functions.AddItem('id_card', 1, false, nil, true)
        elseif Data.Type == "Driver" then
            Player.Functions.AddItem('driver_license', 1, false, nil, true)
        end
    else
        Player.Functions.Notify('Niet genoeg cash..', 'error')
    end
end)

RegisterNetEvent("fw-cityhall:Server:SetLicense")
AddEventHandler("fw-cityhall:Server:SetLicense", function(Cid, License)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "judge" and Player.PlayerData.job.name ~= "mayor" then
        return
    end

    local Target = FW.Functions.GetPlayerByCitizenId(Cid)
    if Target == nil then return end

    local NewLicenses = Target.PlayerData.metadata.licenses
    NewLicenses[License] = not NewLicenses[License]

    if NewLicenses[License] then
        Player.Functions.Notify("Vergunning [" .. License .. "] gegeven", "success")
    
        local Date = os.date("*t", os.time())
        TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
            Type = 1,
            Title = Config.LicensesLocales[License] .. ' - ' .. Target.PlayerData.citizenid,
            Content = Config.LicenseTemplate:format((Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname), Target.PlayerData.citizenid, (Player.PlayerData.charinfo.gender == 0 and "Man" or "Vrouw"), (Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min),
            Signatures = {
                { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
            },
            Sharees = { Target.PlayerData.citizenid },
            Finalized = 1,
        })
    else
        Player.Functions.Notify("Vergunning [" .. License .. "] ontnomen", "error")
        exports['ghmattimysql']:execute("DELETE FROM `phone_documents` WHERE `type` = 1 AND `title` = @Title AND `sharees` LIKE @Cid", {
            ['@Title'] = Config.LicensesLocales[License] .. ' - ' .. Target.PlayerData.citizenid,
            ['@Cid'] = '%' .. Target.PlayerData.citizenid .. '%',
        })
    end

    Target.Functions.SetMetaDataTable('licenses', License, NewLicenses[License])
end)

RegisterNetEvent("fw-cityhall:Server:CreateFinancial")
AddEventHandler("fw-cityhall:Server:CreateFinancial", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "judge" and Player.PlayerData.job.name ~= "mayor" then
        return
    end

    exports['fw-financials']:CreateFinancialAccount(Data.Type, Data.Cid, Data.Name, 0)
    Player.Functions.Notify("Rekening [" .. Data.Type .. "] aangemaakt")
end)

RegisterNetEvent("fw-cityhall:Server:SetFinancialState")
AddEventHandler("fw-cityhall:Server:SetFinancialState", function(AccountId, Active)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "judge" and Player.PlayerData.job.name ~= "mayor" then
        return
    end

    local Account = exports['fw-financials']:GetFinancialAccountById(AccountId)
    if Account == nil then return Player.Functions.Notify("Rekening bestaat niet..", "error") end

    exports['ghmattimysql']:executeSync("UPDATE `player_financials` SET `active` = @Active WHERE `accountid` = @AccountId", {
        ['@Active'] = Active and 1 or 0,
        ['@AccountId'] = AccountId,
    })

    if Active then
        Player.Functions.Notify("Bankrekening [" .. AccountId .. "] geactiveerd", "success")
    else
        Player.Functions.Notify("Bankrekening [" .. AccountId .. "] gedeactiveerd", "error")
    end
end)

RegisterNetEvent("fw-cityhall:Server:SetFinancialMonitorState")
AddEventHandler("fw-cityhall:Server:SetFinancialMonitorState", function(AccountId, Active)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "judge" and Player.PlayerData.job.name ~= "mayor" then
        return
    end

    local Account = exports['fw-financials']:GetFinancialAccountById(AccountId)
    if Account == nil then return Player.Functions.Notify("Rekening bestaat niet..", "error") end

    exports['ghmattimysql']:executeSync("UPDATE `player_financials` SET `monitored` = @Monitored WHERE `accountid` = @AccountId", {
        ['@Monitored'] = Active and 1 or 0,
        ['@AccountId'] = AccountId,
    })

    if Active then
        Player.Functions.Notify("Bankrekening accountactiviteit monitoring [" .. AccountId .. "] geactiveerd", "success")
    else
        Player.Functions.Notify("Bankrekening accountactiviteit monitoring [" .. AccountId .. "] gedeactiveerd", "error")
    end
end)

RegisterServerEvent('fw-cityhall:lawyer:add')
AddEventHandler('fw-cityhall:lawyer:add', function(TagetId)
    local SelfPlayer = FW.Functions.GetPlayer(source)
    local TagetPlayer = FW.Functions.GetPlayer(TagetId)
    if TagetPlayer ~= nil and SelfPlayer ~= nil then
        TagetPlayer.Functions.SetJob('lawyer', '0')
        TriggerClientEvent('FW:Notify', SelfPlayer.PlayerData.source, 'Je hebt '..TagetPlayer.PlayerData.charinfo.firstname..' '..TagetPlayer.PlayerData.charinfo.lastname..' aangenomen!')
        TriggerClientEvent('FW:Notify', TagetPlayer.PlayerData.source, 'Gefeliciteerd je bent aangenomen als advocaat')
    end
end)

RegisterNetEvent('fw-cityhall:server:hamer', function()
    local src = source
    local Player = FW.Functions.GetPlayer(src)
    local PlayerCoords = GetEntityCoords(GetPlayerPed(src))

    if #(PlayerCoords - vector3(-522.81, -177.99, 38.66)) >= 10.0 then return end
    if Player.PlayerData.job.name ~= 'judge' then return end

    TriggerClientEvent('fw-cityhall:client:hamer', src)
end)

FW.Functions.CreateUsableItem("lawyerpass", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        local MyCoords = GetEntityCoords(GetPlayerPed(Source))
        for k, v in pairs(FW.GetPlayers()) do
            if #(v.Coords - MyCoords) <= 2.0 then
                TriggerClientEvent("fw-cityhall:client:show:pass", v.ServerId, Item.info)
            end
        end
    end
end)

RegisterNetEvent("fw-cityhall:Server:SubpoenaRecords")
AddEventHandler("fw-cityhall:Server:SubpoenaRecords", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'judge' then return end
    
    local Target = exports['ghmattimysql']:executeSync("SELECT `charinfo` FROM `players` WHERE `charinfo` LIKE @Phone", {
        ['@Phone'] = '%' .. Data.Phone .. '%',
    })

    if Target[1] == nil then
        Player.Functions.Notify("Telefoonnummer bestaat niet..", "error")
        return
    end

    local PhoneRecords = {}
    local TargetPhone = json.decode(Target[1].charinfo).phone

    local url = 'http://localhost:3000/messages?targetPhone=' .. TargetPhone
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local Data = json.decode(response)
            if Data.Url then
                Player.Functions.Notify(Data.Message .. " Url gekopieerd naar plakbord.", "success")
                TriggerClientEvent("fw-admin:Client:CopyToClipboard", Source, Data.Url)
            else
                Player.Functions.Notify(Data.Message, "error")
            end
        else
            Player.Functions.Notify("Fout opgetreden tijdens het exporteren. (" .. statusCode .. ")", "error")
        end
    end, 'GET', '', {})
end)

RegisterNetEvent("fw-cityhall:Server:SubpoenaFinancials")
AddEventHandler("fw-cityhall:Server:SubpoenaFinancials", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'judge' then return end

    local Account = exports['fw-financials']:GetFinancialAccountById(Data.AccountId)
    if Account == nil then return Player.Functions.Notify("Rekening bestaat niet..", "error") end

    local url = 'http://localhost:3000/financials?accountId=' .. Data.AccountId
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local Data = json.decode(response)
            if Data.Url then
                Player.Functions.Notify(Data.Message .. " Url gekopieerd naar plakbord.", "success")
                TriggerClientEvent("fw-admin:Client:CopyToClipboard", Source, Data.Url)
            else
                Player.Functions.Notify(Data.Message, "error")
            end
        else
            Player.Functions.Notify("Fout opgetreden tijdens het exporteren. (" .. statusCode .. ")", "error")
        end
    end, 'GET', '', {})
end)