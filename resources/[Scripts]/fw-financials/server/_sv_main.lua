FW = exports['fw-core']:GetCoreObject()

FW.Commands.Add("geefcontant", "Geef iemand cash", {
    { name = "id", help = "Speler ID" },
    { name = "aantal", help = "Hoeveel munnies" },
}, true, function(Source, Args)
    local CashAmount = tonumber(Args[2])
    if type(CashAmount) ~= 'number' then return end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end
    
    local MyCoords, TCoords = GetEntityCoords(GetPlayerPed(Source)), GetEntityCoords(GetPlayerPed(tonumber(Args[1])))
    local Distance = #(MyCoords - TCoords)
    if Distance < 3.0 and tonumber(CashAmount) > 0 then
        local Amount = math.floor(CashAmount)
        if Player.Functions.RemoveMoney('cash', Amount) then
            Target.Functions.AddMoney('cash', Amount)
            TriggerClientEvent('fw-financials:Client:Give:Cash:Animation', Source)
        else
            Player.Functions.Notify('Niet genoeg cash..', 'error')
        end
    else
        Player.Functions.Notify('Lange armen wel man..', 'error')
    end
end)

FW.Functions.CreateCallback("fw-financials:Server:GetPlayerAccounts", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local PlayerAccount = GetFinancialAccountById(Player.PlayerData.charinfo.account)
    if PlayerAccount == nil then return end

    local Retval = {
        {
            Name = PlayerAccount.name,
            AccountId = PlayerAccount.accountid,
            Type = PlayerAccount.type,
            Owner = FW.Functions.GetPlayerCharName(PlayerAccount.citizenid),
            Balance = PlayerAccount.balance,
            Active = PlayerAccount.active,
            Permissions = { Deposit = true, Withdraw = true, Transfer = true, Transactions = true }
        }
    }

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_financials` WHERE (`citizenid` = @Cid OR `authorized` LIKE @LikeCid) AND NOT `type` = 'Standaard'", {
        ['@Cid'] = Player.PlayerData.citizenid,
        ['@LikeCid'] = '%' .. Player.PlayerData.citizenid .. '%',
    })

    for k, v in pairs(Result) do
        local Permissions = { Deposit = true, Withdraw = true, Transfer = true, Transactions = true }
        if v.citizenid ~= Player.PlayerData.citizenid then
            for i, j in pairs(json.decode(v.authorized)) do
                if j.Cid == Player.PlayerData.citizenid then
                    Permissions = j.Permissions
                end
            end
        end

        Retval[#Retval + 1] = {
            Name = v.name,
            AccountId = v.accountid,
            Type = v.type,
            Owner = FW.Functions.GetPlayerCharName(v.citizenid),
            Balance = v.balance,
            Active = v.active,
            Permissions = Permissions,
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-financials:Server:GetAccountTransactions", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(GetAccountTransactions(Data.AccountId))
end)

FW.Functions.CreateCallback("fw-financials:Server:GetFinancialAccess", function(Source, Cb, AccountId, Cid)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then
        Cb({ Balance = false, Deposit = false, Withdraw = false, Transfer = false, Transactions = false })
        return
    end

    local Account = GetFinancialAccountById(AccountId)
    if Account == nil then
        Cb({ Balance = false, Deposit = false, Withdraw = false, Transfer = false, Transactions = false })
        return
    end
    
    if Account.citizenid == Cid then
        Cb({ Balance = true, Deposit = true, Withdraw = true, Transfer = true, Transactions = true })
        return
    end

    for k, v in pairs(json.decode(Account.authorized)) do
        if v.Cid == Cid then
            Cb(v.Permissions)
            return
        end
    end

    Cb({ Balance = false, Deposit = false, Withdraw = false, Transfer = false, Transactions = false })
end)

FW.Functions.CreateCallback("fw-financials:Server:SetFinancialAccess", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb({Success = false, Msg = "Ongeldige Speler"}) end

    local Account = GetFinancialAccountById(Data.AccountId)
    if Account == nil then return Cb({Success = false, Msg = "Ongeldige Bankrekening"}) end

    local Authorized = json.decode(Account.authorized)

    if not Data.Permissions.Balance then
        for k, v in pairs(Authorized) do
            if v.Cid == Data.Employee then
                table.remove(Authorized, k)
                break
            end
        end
    else
        local IsAlreadyAuthorized = false
        for k, v in pairs(Authorized) do
            if v.Cid == Data.Employee then
                v.Permissions = Data.Permissions
                IsAlreadyAuthorized = true
                break
            end
        end
    
        if not IsAlreadyAuthorized then
            Authorized[#Authorized + 1] = {
                Cid = Data.Employee,
                Permissions = Data.Permissions,
            }
        end
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `player_financials` SET `authorized` = @Authorized WHERE `accountid` = @AccountId", {
        ['@Authorized'] = json.encode(Authorized),
        ['@AccountId'] = Data.AccountId,
    })

    Cb({ Success = Result.affectedRows > 0, Msg = "Data was niet opgeslagen!" })
end)

FW.Functions.CreateCallback("fw-financials:Server:Deposit", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.RemoveMoney('cash', Data.Amount, Data.Comment) then
        TriggerEvent("fw-logs:Server:Log", 'money', "Added Money [" .. GetInvokingResource() .. "]", ("User: [%s] - %s - %s\nType: %s\nAmount: %s\nAccount ID: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, 'bank', exports['fw-businesses']:NumberWithCommas(Data.Amount), Data.AccountId), "green")
        AddMoneyToAccount(Player.PlayerData.citizenid, Data.AccountId, Data.AccountId, Data.Amount, 'Deposit', Data.Comment)

        if IsAccountMonitored(Data.AccountId) then
            TriggerClientEvent("fw-financials:Client:SendMonitoredAccount", Source, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname)
        end

        Cb({Cash = Player.PlayerData.money.cash - Data.Amount})
    else
        Cb({Cash = Player.PlayerData.money.cash})
    end

    TriggerClientEvent('fw-financials:Client:RefreshFinancials', Source)
end)

FW.Functions.CreateCallback("fw-financials:Server:Withdraw", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if RemoveMoneyFromAccount(Player.PlayerData.citizenid, Data.AccountId, Data.AccountId, Data.Amount, 'Withdraw', Data.Comment, false) then
        TriggerEvent("fw-logs:Server:Log", 'money', "Remove Money [" .. GetInvokingResource() .. "]", ("User: [%s] - %s - %s\nType: %s\nAmount: %s\nAccount ID: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, 'bank', exports['fw-businesses']:NumberWithCommas(Data.Amount), Data.AccountId), "red")

        if IsAccountMonitored(Data.AccountId) then
            TriggerClientEvent("fw-financials:Client:SendMonitoredAccount", Source, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname)
        end

        Player.Functions.AddMoney('cash', Data.Amount, Data.Comment)
        Cb({Cash = Player.PlayerData.money.cash + Data.Amount})
    else
        Cb({Cash = Player.PlayerData.money.cash})
    end
    
    TriggerClientEvent('fw-financials:Client:RefreshFinancials', Source)
end)

FW.Functions.CreateCallback("fw-financials:Server:Transfer", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Target)
    local TargetAccount = Target == nil and Data.Target or Target.PlayerData.charinfo.account

    if Data.AccountId == TargetAccount then
        return Cb(false)
    end

    if GetFinancialAccountById(TargetAccount) == nil then
        return Cb(false)
    end

    if RemoveMoneyFromAccount(Player.PlayerData.citizenid, Data.AccountId, Data.AccountId, Data.Amount, 'Transfer', Data.Comment, false) then
        TriggerEvent("fw-logs:Server:Log", 'transfermoney', "Money Transferred [" .. GetInvokingResource() .. "]", ("User: [%s] - %s - %s\nTarget: %s\nType: %s\nAmount: %s\nAccount ID: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, TargetAccount, 'bank', exports['fw-businesses']:NumberWithCommas(Data.Amount), Data.AccountId), "blue")
        AddMoneyToAccount(Player.PlayerData.citizenid, Data.AccountId, TargetAccount, Data.Amount, 'Transfer', Data.Comment)
        if IsAccountMonitored(Data.AccountId) then
            TriggerClientEvent("fw-financials:Client:SendMonitoredAccount", Source, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname)
        end
    end

    TriggerClientEvent('fw-financials:Client:RefreshFinancials', Source)
    if type(Target) == 'table' and Target.PlayerData then
        TriggerClientEvent('fw-financials:Client:RefreshFinancials', Target.PlayerData.source)
    end

    Cb(true)
end)

FW.Functions.CreateCallback("fw-financials:Server:ExportData", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Account = GetFinancialAccountById(Data.AccountId)
    if Account == nil then return end

    local url = 'http://localhost:3000/financials?accountId=' .. Data.AccountId
    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            local Data = json.decode(response)
            Cb({Msg = Data.Message, Url = Data.Url})
        else
            Cb({Msg = "Fout opgetreden tijdens exporteren (" .. statusCode .. ")"})
        end
    end, 'GET', json.encode({ pStartDate = Data.StartDate, pEndDate = Data.EndDate }), {['Content-Type'] = 'application/json'})
end)

FW.Functions.CreateCallback("fw-financials:Server:GetAccountBalance", function(Source, Cb, AccountId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Balance = GetAccountBalance(AccountId)
    Cb(Balance)
end)

RegisterNetEvent("fw-financials:Server:ReceivePaycheck")
AddEventHandler("fw-financials:Server:ReceivePaycheck", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local ReceiveMoney = Player.PlayerData.metadata['paycheck']
    if ReceiveMoney <= 0 then
        return Player.Functions.Notify('Hij kijkt je aan en zegt dat je geen salaris hebt om op te halen..', 'error')
    end

    if AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, ReceiveMoney, 'DEPOSIT', 'Salaris ontvangen') then
        Player.Functions.Notify("Je salaris van " .. exports['fw-businesses']:NumberWithCommas(ReceiveMoney) .. ' is overgemaakt naar je bankrekening.', 'success')
        Player.Functions.SetMetaData('paycheck', 0)
    end
end)