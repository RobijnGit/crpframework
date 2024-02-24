function GenerateUniqueAccountId()
    local Account, UniqueFound = FW.Shared.RandomInt(8), false
	while not UniqueFound do
		local Result = exports['ghmattimysql']:executeSync("SELECT `accountid` FROM `player_financials` WHERE `accountid` LIKE @Account", { ['@Account'] = "%" .. Account .. "%" })
		if Result[1] ~= nil then
			Account = FW.Shared.RandomInt(8)
		else
			UniqueFound = true
		end
		Citizen.Wait(4)
	end

	return Account
end

function CreateFinancialAccount(Type, Owner, Name, Balance, AccountId)
    exports['ghmattimysql']:executeSync("INSERT INTO `player_financials` (`citizenid`, `name`, `accountid`, `balance`, `type`, `authorized`, `active`) VALUES (@Cid, @Name, @AccountId, @Balance, @Type, '[]',  1)", {
        ['@Cid'] = Owner,
        ['@Name'] = Name,
        ['@AccountId'] = AccountId or GenerateUniqueAccountId(),
        ['@Balance'] = Balance or 0,
        ['@Type'] = Type,
    })
end
exports("CreateFinancialAccount", CreateFinancialAccount)

function GetFinancialAccountById(AccountId)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_financials` WHERE `accountid` = @AccountId", {
        ['@AccountId'] = AccountId
    })
    return Result[1] and Result[1] or nil
end
exports("GetFinancialAccountById", GetFinancialAccountById)

function IsAccountMonitored(AccountId)
    local Account = GetFinancialAccountById(AccountId)
    return Account ~= nil and Account.monitored == 1
end

function GetAccountBalance(AccountId)
    local Account = GetFinancialAccountById(AccountId)
    return Account == nil and 0 or Account.balance
end
exports("GetAccountBalance", GetAccountBalance)

function SetAccountBalance(AccountId, Balance)
    exports['ghmattimysql']:execute("UPDATE `player_financials` SET `balance` = @Balance WHERE `accountid` = @AccountId", {
        ['@Balance'] = Balance,
        ['@AccountId'] = AccountId,
    })
end
exports("SetAccountBalance", SetAccountBalance)

function AddMoneyToAccount(FromCid, FromAccountId, AccountId, Amount, Type, Comment, IgnoreTransaction)
    Amount = tonumber(Amount)
    if Amount <= 0 then return true end

    local Account = GetFinancialAccountById(AccountId)
    if Account == nil then return false end
    if Account.active == 0 then return false end

    if not IgnoreTransaction then
        CreateTransactionCard(FromCid, FromAccountId, AccountId, Amount, false, Type or 'Deposit', Comment)
    end

    SetAccountBalance(AccountId, Account.balance + Amount)

    return true
end
exports("AddMoneyToAccount", AddMoneyToAccount)

function RemoveMoneyFromAccount(FromCid, FromAccountId, AccountId, Amount, Type, Comment, Forced, IgnoreTransaction)
    Amount = tonumber(Amount)
    if Amount <= 0 then return true end

    local Account = GetFinancialAccountById(AccountId)
    if Account == nil then return false end
    if Account.active == 0 then return false end
    
    if not Forced and Account.balance - Amount < 0 then
        return false
    end

    if not IgnoreTransaction then
        CreateTransactionCard(FromCid, FromAccountId, AccountId, Amount, true, Type or 'Withdraw', Comment)
    end

    SetAccountBalance(AccountId, Account.balance - Amount)

    return true
end
exports("RemoveMoneyFromAccount", RemoveMoneyFromAccount)

function GetAccountTransactions(AccountId)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `financials_transactions` WHERE account_id = ? ORDER BY `timestamp` DESC", {AccountId})
    local Retval = {}

    for k, v in pairs(Result) do
        Retval[#Retval + 1] = {
            Id = v.id,
            AccountName = v.trans_accountname,
            AccountId = v.trans_accountid,
            TransactionType = v.type,
            TransactionUUID = v.uuid,
            Amount = tonumber(v.amount),
            IsNegative = v.negative == 1,
            Timestamp = v.timestamp,
            Receiver = v.receiver,
            Sender = v.sender,
            Message = v.comment,
        }
    end

    return Retval
end
exports("GetAccountTransactions", GetAccountTransactions)

function CreateTransactionCard(FromCid, FromAccountId, AccountId, Amount, Negative, Type, Comment)
    local FromAccount = GetFinancialAccountById(FromAccountId)
    local Account = GetFinancialAccountById(AccountId)

    local TransactionData = {
        AccountName = FromAccountId and FromAccount.name or "The Unknown",
        AccountId = FromAccountId and FromAccount.accountid or "0",
        TransactionType = Type:upper(),
        TransactionUUID = GenerateUUID(),
        Amount = Amount,
        IsNegative = Negative,
        Timestamp = os.time() * 1000,
        Receiver = FromCid and FW.Functions.GetPlayerCharName(Account.citizenid) or "",
        Sender = FromCid and FW.Functions.GetPlayerCharName(FromCid) or FW.Functions.GetPlayerCharName(Account.citizenid),
        Message = Comment or false,
    }

    exports['ghmattimysql']:execute("INSERT INTO financials_transactions (account_id, trans_accountname, trans_accountid, type, uuid, amount, negative, receiver, sender, comment) VALUES (?, ?, ?, ?, ?, ?, ? ,?, ?, ?)", {
        AccountId,
        TransactionData.AccountName,
        TransactionData.AccountId,
        TransactionData.TransactionType,
        TransactionData.TransactionUUID,
        TransactionData.Amount,
        TransactionData.IsNegative,
        TransactionData.Receiver,
        TransactionData.Sender,
        TransactionData.Message,
    });
end
exports("CreateTransactionCard", CreateTransactionCard)