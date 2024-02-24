FW.Players = {}
FW.Player = {}

FW.Player.Login = function(Source, IsCharNew, CitizenId, newData)
    if Source ~= nil then
        if IsCharNew then
            local PlayerData = {}
            PlayerData.citizenid = FW.Player.CreateCitizenId()
            PlayerData.charinfo = {
                firstname = newData.firstname,
                lastname = newData.lastname,
                birthdate = newData.birthdate,
                gender = newData.gender,
                nationality = newData.nationality,
                account = FW.Player.CreateBankAccount()
            }
            PlayerData.metadata = { islifer = newData.isLifer }
            PlayerData.skin = exports['fw-clothes']:GetDefaultClothes(newData.gender)
            FW.Player.CheckPlayerData(Source, PlayerData)
            exports['fw-financials']:CreateFinancialAccount('Standaard', PlayerData.citizenid, 'Persoonlijke Rekening', 3500, PlayerData.charinfo.account)
            return true
        else
            local Player = FW.Functions.GetPlayerByCitizenId(CitizenId)
            if Player then
                TriggerEvent('fw-logs:Server:Log', 'anticheatDoubleConnection', 'Active Character Selected', ('%s (%s / %s) was kicked from the server because the loaded character is already active.'):format(GetPlayerName(Source), FW.Functions.GetIdentifier(Source, "steam"), CitizenId), 'blue')
                DropPlayer(Source, "Je zit al op de server met een andere FiveM-client..")
                return false
            end

             exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = @Cid", {
                ['@Cid'] = CitizenId,
            }, function(result)
                local PlayerData = result[1]
                if PlayerData ~= nil then
                    PlayerData.money = json.decode(PlayerData.money)
                    PlayerData.position = json.decode(PlayerData.position)
                    PlayerData.job = json.decode(PlayerData.job)
                    PlayerData.metadata = json.decode(PlayerData.metadata)
                    PlayerData.addiction = json.decode(PlayerData.addiction)
                    PlayerData.charinfo = json.decode(PlayerData.charinfo)
                    PlayerData.skin = json.decode(PlayerData.skin)

                    if exports['fw-financials']:GetFinancialAccountById(PlayerData.charinfo.account) == nil then
                        exports['fw-financials']:CreateFinancialAccount('Standaard', PlayerData.citizenid, 'Persoonlijke Rekening', 3500, PlayerData.charinfo.account)
                        print("Financial account did not exist for player, generating a fresh one.")
                    end
                end    
                FW.Player.CheckPlayerData(Source, PlayerData)
            end)
            return true
        end
    end
end

function FW.Player.FormatCrypto(crypto)
    for k, v in pairs(FW.Config.Money.ConfigDefaultCrypto) do
        crypto[k] = crypto[k] ~= nil and crypto[k] or v
    end
    return crypto
end

FW.Player.CheckPlayerData = function(source, PlayerData)
    PlayerData = PlayerData ~= nil and PlayerData or {}
    PlayerData.source = source
    PlayerData.citizenid = tostring(PlayerData.citizenid ~= nil and PlayerData.citizenid or FW.Player.CreateCitizenId())
    PlayerData.email = PlayerData.email ~= nil and PlayerData.email or PlayerData.charinfo.firstname:lower()..''..PlayerData.charinfo.lastname:lower()..'@lossantos.nl'
    PlayerData.steam = PlayerData.steam ~= nil and PlayerData.steam or FW.Functions.GetIdentifier(source, "steam")
    PlayerData.license = PlayerData.license ~= nil and PlayerData.license or FW.Functions.GetIdentifier(source, "license")
    PlayerData.name = GetPlayerName(source)

    -- Inventory
    PlayerData.inventory = exports['fw-inventory']:GetInventoryItems('ply-' .. PlayerData.citizenid)

    -- // Money Shit \\ --
    PlayerData.money = PlayerData.money ~= nil and PlayerData.money or {}
    PlayerData.money['cash'] = PlayerData.money['cash'] ~= nil and PlayerData.money['cash'] or 0
    PlayerData.money['casino'] = PlayerData.money['casino'] ~= nil and PlayerData.money['casino'] or 0
    PlayerData.money['crypto'] = PlayerData.money['crypto'] ~= nil and PlayerData.money['crypto'] ~= 0 and FW.Player.FormatCrypto(PlayerData.money.crypto) or FW.Config.Money.ConfigDefaultCrypto
    -- // Char Info \\ --
    PlayerData.charinfo = PlayerData.charinfo ~= nil and PlayerData.charinfo or {}
    PlayerData.charinfo.firstname = PlayerData.charinfo.firstname ~= nil and PlayerData.charinfo.firstname or "Firstname"
    PlayerData.charinfo.lastname = PlayerData.charinfo.lastname ~= nil and PlayerData.charinfo.lastname or "Lastname"
    PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate ~= nil and PlayerData.charinfo.birthdate or "00-00-0000"
    PlayerData.charinfo.gender = PlayerData.charinfo.gender ~= nil and PlayerData.charinfo.gender or 0
    PlayerData.charinfo.nationality = PlayerData.charinfo.nationality ~= nil and PlayerData.charinfo.nationality or "Los Santos"
    PlayerData.charinfo.phone = PlayerData.charinfo.phone ~= nil and PlayerData.charinfo.phone or FW.Player.CreatePhoneNumber(false)
    PlayerData.charinfo.account = PlayerData.charinfo.account ~= nil and PlayerData.charinfo.account or FW.Player.CreateBankAccount()
    
    -- // Skin \\ --
    PlayerData.skin = PlayerData.skin ~= nil and PlayerData.skin or exports['fw-clothes']:GetDefaultClothes(PlayerData.charinfo.gender)
    
    -- // Health Shit \\ --
    PlayerData.metadata = PlayerData.metadata ~= nil and PlayerData.metadata or {}
    PlayerData.metadata["health"] = PlayerData.metadata["health"]  ~= nil and PlayerData.metadata["health"] or 200
    PlayerData.metadata["armor"] = PlayerData.metadata["armor"]  ~= nil and PlayerData.metadata["armor"] or 0
    PlayerData.metadata["hunger"] = PlayerData.metadata["hunger"] ~= nil and PlayerData.metadata["hunger"] or 100
    PlayerData.metadata["thirst"] = PlayerData.metadata["thirst"] ~= nil and PlayerData.metadata["thirst"] or 100
    PlayerData.metadata["stress"] = PlayerData.metadata["stress"] ~= nil and PlayerData.metadata["stress"] or 0
    PlayerData.metadata["isdead"] = PlayerData.metadata["isdead"] ~= nil and PlayerData.metadata["isdead"] or false
    PlayerData.metadata["lucky"] = PlayerData.metadata["lucky"] ~= nil and PlayerData.metadata["lucky"] or false
    -- // DNA \\ --
    PlayerData.metadata["bloodtype"] = PlayerData.metadata["bloodtype"] ~= nil and PlayerData.metadata["bloodtype"] or FW.Config.Player.Bloodtypes[math.random(1, #FW.Config.Player.Bloodtypes)]
    PlayerData.metadata["fingerprint"] = PlayerData.metadata["fingerprint"] ~= nil and PlayerData.metadata["fingerprint"] or FW.Player.CreateDnaId('finger')
    PlayerData.metadata["slimecode"] = PlayerData.metadata["slimecode"] ~= nil and PlayerData.metadata["slimecode"] or FW.Player.CreateDnaId('slime')
    PlayerData.metadata["haircode"] = PlayerData.metadata["haircode"] ~= nil and PlayerData.metadata["haircode"] or FW.Player.CreateDnaId('hair')
    -- // Reputations \\ --
    PlayerData.metadata["craftingrep"] = PlayerData.metadata["craftingrep"] ~= nil and PlayerData.metadata["craftingrep"] or 0
    -- // Work Shizzle \\ --
    PlayerData.metadata["callsign"] = PlayerData.metadata["callsign"] ~= nil and PlayerData.metadata["callsign"] or "N.T.B"
    PlayerData.metadata["pd-vehicles"] = PlayerData.metadata["pd-vehicles"] ~= nil and PlayerData.metadata["pd-vehicles"] or { STANDAARD = true, INTERCEPTOR = false, MOTORCYCLE = false, UNMARKED = false, AIRONE = false }
    PlayerData.metadata["ems-vehicle"] = PlayerData.metadata["ems-vehicle"] ~= nil and PlayerData.metadata["ems-vehicle"] or { SPEEDO = true, MOTOR = false, FLIGHT = false, WATER = false, COMMANDER = false, TAURUS = false }
    PlayerData.metadata["ishighcommand"] = PlayerData.metadata["ishighcommand"] ~= nil and PlayerData.metadata["ishighcommand"] or false
    PlayerData.metadata["department"] = PlayerData.metadata["department"] ~= nil and PlayerData.metadata["department"] or "UPD"
    PlayerData.metadata["division"] = PlayerData.metadata["division"] ~= nil and PlayerData.metadata["division"] or "UPD"
    -- // Appartment \\ 
    PlayerData.metadata["apartmentid"] = PlayerData.metadata["apartmentid"] ~= nil and PlayerData.metadata["apartmentid"] or FW.Player.CreateAppartmentId()
    PlayerData.metadata["phone"] = PlayerData.metadata["phone"] ~= nil and PlayerData.metadata["phone"] or {}
    -- // Miscs \\ --
    PlayerData.metadata['walkstyle'] = PlayerData.metadata['walkstyle'] ~= nil and PlayerData.metadata['walkstyle'] or nil
    PlayerData.metadata['expression'] = PlayerData.metadata['expression'] ~= nil and PlayerData.metadata['expression'] or nil
    PlayerData.metadata['paycheck'] = PlayerData.metadata['paycheck'] ~= nil and PlayerData.metadata['paycheck'] or 0
    PlayerData.metadata["ishandcuffed"] = PlayerData.metadata["ishandcuffed"] ~= nil and PlayerData.metadata["ishandcuffed"] or false
    PlayerData.metadata["jailtime"] = PlayerData.metadata["jailtime"] ~= nil and PlayerData.metadata["jailtime"] or 0
    PlayerData.metadata["paroletime"] = PlayerData.metadata["paroletime"] ~= nil and PlayerData.metadata["paroletime"] or 0
    PlayerData.metadata["commandbinds"] = PlayerData.metadata["commandbinds"] ~= nil and PlayerData.metadata["commandbinds"] or {}
    PlayerData.metadata["licenses"] = PlayerData.metadata["licenses"] ~= nil and PlayerData.metadata["licenses"] or {["driver"] = true, ['hunting'] = false, ['weapon'] = false, ['fishing'] = false, ['flying'] = false, ['business'] = false}
    PlayerData.metadata["lastmethpayment"] = PlayerData.metadata["lastmethpayment"] ~= nil and PlayerData.metadata["lastmethpayment"] or 0
    PlayerData.metadata["islifer"] = PlayerData.metadata["islifer"] ~= nil and PlayerData.metadata["islifer"] or false
    -- // Addiction \\ --
    PlayerData.addiction = PlayerData.addiction ~= nil and PlayerData.addiction or {}
    PlayerData.addiction["cocaine"] = PlayerData.addiction["cocaine"] ~= nil and PlayerData.addiction["cocaine"] or 0
    PlayerData.addiction["weed"] = PlayerData.addiction["weed"] ~= nil and PlayerData.addiction["weed"] or 0
    PlayerData.addiction["fastfood"] = PlayerData.addiction["fastfood"] ~= nil and PlayerData.addiction["fastfood"] or 0
    -- // Oude Jobs
    PlayerData.job = PlayerData.job ~= nil and PlayerData.job or {}
    if FW.Shared.Jobs[PlayerData.job.name] == nil then
        PlayerData.job.name = "unemployed"
        PlayerData.job.label = FW.Shared.Jobs['unemployed'].label
        PlayerData.job.payment = FW.Shared.Jobs['unemployed'].grades['0'].payment
        PlayerData.job.grade = PlayerData.job.grade or {}
        PlayerData.job.grade.name = FW.Shared.Jobs['unemployed'].grades['0'].name
        PlayerData.job.grade.level = '0'
        PlayerData.job.plate = PlayerData.job.plate ~= nil and PlayerData.job.plate or 'none'
        PlayerData.job.serial = PlayerData.job.serial ~= nil and PlayerData.job.serial or FW.Player.CreateWeaponSerial()
        PlayerData.job.onduty = FW.Shared.Jobs[PlayerData.job.name].defaultDuty
    else
        local Grade = tostring(PlayerData.job.grade.level)
        if FW.Shared.Jobs[PlayerData.job.name].grades[Grade] == nil then Grade = "0" end

        PlayerData.job = PlayerData.job ~= nil and PlayerData.job or {}
        PlayerData.job.name = PlayerData.job.name ~= nil and PlayerData.job.name or "unemployed"
        PlayerData.job.label = FW.Shared.Jobs[PlayerData.job.name].label
        PlayerData.job.grade = PlayerData.job.grade or {}
        PlayerData.job.grade.name = PlayerData.job.grade.name or 'Uitkering'
        PlayerData.job.grade.level = Grade or "0"
        PlayerData.job.payment = FW.Shared.Jobs[PlayerData.job.name].grades[Grade].payment or 10
        PlayerData.job.plate = PlayerData.job.plate ~= nil and PlayerData.job.plate or 'none'
        PlayerData.job.serial = PlayerData.job.serial ~= nil and PlayerData.job.serial or FW.Player.CreateWeaponSerial()
        PlayerData.job.onduty = FW.Shared.Jobs[PlayerData.job.name].defaultDuty
    end

    -- // Position \\ --
    PlayerData.position = PlayerData.position ~= nil and PlayerData.position or {}
    FW.Player.CreatePlayer(PlayerData)
    FW.Commands.Refresh(source)
end

FW.Player.CreatePlayer = function(PlayerData)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData

    self.Functions.UpdatePlayerData = function(Save)
        TriggerClientEvent("FW:Player:SetPlayerData", self.PlayerData.source, self.PlayerData)
        if Save then self.Functions.Save() end
    end

    self.Functions.SetCharData = function(Type, NewValue)
        self.PlayerData.charinfo[Type] = NewValue
        self.Functions.UpdatePlayerData(true)
    end

    self.Functions.SetSkin = function(Skin)
        self.PlayerData.skin = Skin
        self.Functions.UpdatePlayerData(true)
    end

    self.Functions.Notify = function(Message, Type, Timeout)
        TriggerClientEvent('FW:Notify', self.PlayerData.source, Message, Type, Timeout)
    end

    self.Functions.SetJob = function(job, grade)
        local job = job:lower()
        local grade = tostring(grade) or '0'
        if not FW.Shared.Jobs[job] then return false end
        self.PlayerData.job.name = job
        self.PlayerData.job.label = FW.Shared.Jobs[job].label
        self.PlayerData.job.onduty = false
        if FW.Shared.Jobs[job].grades[grade] then
            local jobgrade = FW.Shared.Jobs[job].grades[grade]
            self.PlayerData.job.grade = {}
            self.PlayerData.job.grade.name = jobgrade.name
            self.PlayerData.job.grade.level = tostring(grade)
            self.PlayerData.job.payment = jobgrade.payment or 30
        else
            self.PlayerData.job.grade = {}
            self.PlayerData.job.grade.name = 'Onbekend'
            self.PlayerData.job.grade.level = '0'
            self.PlayerData.job.payment = 30
        end
        self.Functions.UpdatePlayerData(false)
        TriggerEvent('FW:Server:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        TriggerClientEvent('FW:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
        return true
    end

    self.Functions.SetJobDuty = function(onDuty)
        self.PlayerData.job.onduty = onDuty
        self.Functions.UpdatePlayerData(false)
    end

    self.Functions.SetMetaData = function(meta, val)
        local meta = meta:lower()
        if val ~= nil then
            self.PlayerData.metadata[meta] = val
            self.Functions.UpdatePlayerData(false)
            TriggerClientEvent("FW:Client:OnMetaDataUpdate", self.PlayerData.source, false, meta, val)
        end
    end

    self.Functions.SetMetaDataTable = function(tablename, key, val)
        local tablename = tablename:lower()
        if val ~= nil then
            self.PlayerData.metadata[tablename][key] = val
            self.Functions.UpdatePlayerData(false)
            TriggerClientEvent("FW:Client:OnMetaDataUpdate", self.PlayerData.source, tablename, meta, val)
        end
    end

    self.Functions.AddAddiction = function(addiction, val)
        local addiction = addiction:lower()
        if val ~= nil then
            self.PlayerData.addiction[addiction] = self.PlayerData.addiction[addiction] + val
            self.Functions.UpdatePlayerData(false)
        end
    end

    self.Functions.AddMoney = function(moneytype, amount, reason)
        reason = reason ~= nil and reason or "unkown"
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        if amount < 0 then return end
        if self.PlayerData.money[moneytype] ~= nil then
            self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype]+amount
            self.Functions.UpdatePlayerData(false)

            TriggerEvent("fw-logs:Server:Log", 'money', "Added Money [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nType: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, moneytype, amount), "green")

            if moneytype == 'cash' then
                TriggerClientEvent("fw-hud:Client:MoneyChange", self.PlayerData.source, amount, true)
            end
            return true
        end
        return false
    end

    self.Functions.RemoveMoney = function(moneytype, amount, reason)
        reason = reason ~= nil and reason or "unkown"
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        if amount == nil or amount < 0 then return end
        if self.PlayerData.money[moneytype] ~= nil then
            for _, mtype in pairs(FW.Config.Money.DontAllowMinus) do
                if mtype == moneytype then
                    if self.PlayerData.money[moneytype] - amount < 0 then return false end
                end
            end
            self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount
            self.Functions.UpdatePlayerData(false)

            TriggerEvent("fw-logs:Server:Log", 'money', "Removed Money [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nType: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, moneytype, exports['fw-businesses']:NumberWithCommas(amount)), "red")

            if moneytype == 'cash' then
                TriggerClientEvent("fw-hud:Client:MoneyChange", self.PlayerData.source, amount, false)
            end
            return true
        end
        return false
    end

    self.Functions.SetMoney = function(moneytype, amount, reason)
        reason = reason ~= nil and reason or "unkown"
        local moneytype = moneytype:lower()
        local amount = tonumber(amount)
        if amount < 0 then return end
        if self.PlayerData.money[moneytype] ~= nil then
            self.PlayerData.money[moneytype] = amount
            self.Functions.UpdatePlayerData(false)
            TriggerEvent("fw-logs:Server:Log", 'setmoney', "Money Set by [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nAmount: %s\nReason: 5s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, amount, reason))
            return true
        end
        return false
    end

    self.Functions.GetMoney = function(moneytype)
        if moneytype then
            local moneytype = moneytype:lower()
            return self.PlayerData.money[moneytype]
        end
        return false
    end

    self.Functions.AddCrypto = function(CryptoType, Amount)
        local CryptoType = CryptoType ~= nil and CryptoType
        local Amount = tonumber(Amount)
        if Amount > 0 then
            if self.PlayerData.money.crypto[CryptoType] ~= nil then
                self.PlayerData.money.crypto[CryptoType] = self.PlayerData.money.crypto[CryptoType] + Amount
                TriggerEvent("fw-logs:Server:Log", 'crypto-temp', "Crypto Added [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nType: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, CryptoType, Amount), "green")
                self.Functions.UpdatePlayerData(true)
                return true
            else
                return false
            end
        else
            return false
        end
    end

    self.Functions.RemoveCrypto = function(CryptoType, Amount, IgnoreMinus)
        local CryptoType = CryptoType ~= nil and CryptoType
        local Amount = tonumber(Amount)
        if Amount > 0 then
            if self.PlayerData.money.crypto[CryptoType] ~= nil then
                if IgnoreMinus or self.PlayerData.money.crypto[CryptoType] - Amount >= 0 then
                    self.PlayerData.money.crypto[CryptoType] = self.PlayerData.money.crypto[CryptoType] - Amount
                    TriggerEvent("fw-logs:Server:Log", 'crypto-temp', "Crypto Removed [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nType: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, CryptoType, Amount), "red")
                    self.Functions.UpdatePlayerData(true)
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
            return false
        end
    end

    self.Functions.RefreshInventory = function()
        self.PlayerData.inventory = exports['fw-inventory']:GetInventoryItems('ply-' .. self.PlayerData.citizenid)        
        self.Functions.UpdatePlayerData(false)
        TriggerClientEvent("fw-inventory:Client:Cock", self.PlayerData.source)
    end

    self.Functions.RefreshInvSlot = function(Slot)
        self.PlayerData.inventory[Slot] = exports['fw-inventory']:GetInventoryItemBySlot('ply-' .. self.PlayerData.citizenid, Slot)
        self.Functions.UpdatePlayerData(false)
        TriggerClientEvent("fw-inventory:Client:Cock", self.PlayerData.source)
    end

    self.Functions.AddItem = function(Item, Amount, Slot, Info, Show, CustomType)
        local Retval = exports['fw-inventory']:AddItemToInventory('ply-' .. self.PlayerData.citizenid, Item, Amount, Slot, Info, CustomType)
        if Retval then
            TriggerEvent("fw-logs:Server:Log", 'additem', "Item Added [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nItem: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, CustomType and #CustomType > 0 and (Item .. " [" .. CustomType .. "]") or Item, Amount), "green")
            if Show then TriggerClientEvent("fw-inventory:Client:ShowActionBox", self.PlayerData.source, "Ontvangen", Item, Amount, CustomType) end
            TriggerClientEvent("fw-inventory:Client:Cock", self.PlayerData.source)
        end
        return Retval
    end

    self.Functions.DecayItem = function(Item, Slot, Percentage)
        local Retval = exports['fw-inventory']:DecayItemFromInventory('ply-' .. self.PlayerData.citizenid, Item, Percentage, Slot)
        if Slot then
            self.Functions.RefreshInvSlot(Slot)
        else
            self.Functions.RefreshInventory()
        end
        return Retval
    end

    -- Please refrain from using this as much as possible.
    -- You should only use this when you know FOR SURE that the amount of items is the required to delete in the defined slot.
    -- If the slot isn't defined, it will find a random one.
    -- So for example; you want to delete 10 sandwiches, but the player has 5 sandwiches in the first found slot, it remove the 5 in that slot and finish.
    -- `self.Functions.RemoveItemByName` deletes by ItemName, slot won't matter.
    -- You can use this for example deleting a sandwich after its been eaten.
    self.Functions.RemoveItem = function(Item, Amount, Slot, Show, CustomType)
        if not self.Functions.HasEnoughOfItem(Item, Amount, CustomType) then
            return false
        end

        local Retval = exports['fw-inventory']:RemoveItemFromInventory('ply-' .. self.PlayerData.citizenid, Item, Amount, Slot, CustomType)
        if Retval then
            TriggerEvent("fw-logs:Server:Log", 'removeitem', "Item Removed [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nItem: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, CustomType and #CustomType > 0 and (Item .. " [" .. CustomType .. "]") or Item, Amount), "red")

            if Show then
                TriggerClientEvent("fw-inventory:Client:ShowActionBox", self.PlayerData.source, "Verwijderd", Item, Amount, CustomType)
            end

            TriggerClientEvent("fw-inventory:Client:Cock", self.PlayerData.source)
        end

        return Retval
    end

    self.Functions.RemoveItemByName = function(Item, Amount, Show, CustomType)
        local Retval, Slots = exports['fw-inventory']:RemoveItemFromInventoryByName('ply-' .. self.PlayerData.citizenid, Item, Amount, CustomType)
        if Retval then
            TriggerEvent("fw-logs:Server:Log", 'removeitem', "Item Removed [" .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s] - %s - %s\nItem: %s\nAmount: %s"):format(self.PlayerData.source, self.PlayerData.citizenid, self.PlayerData.charinfo.firstname .. " " .. self.PlayerData.charinfo.lastname, CustomType and #CustomType > 0 and (Item .. " [" .. CustomType .. "]") or Item, Amount), "red")

            for k, v in pairs(Slots) do
                self.Functions.RefreshInvSlot(v.slot)
                TriggerClientEvent("fw-inventory:Client:UpdateInvSlot", self.PlayerData.source, v.slot)
            end
    
            if Show then
                TriggerClientEvent("fw-inventory:Client:ShowActionBox", self.PlayerData.source, "Verwijderd", Item, Amount, CustomType)
            end

            TriggerClientEvent("fw-inventory:Client:Cock", self.PlayerData.source)

            if string.sub(Item, 1, 7) == 'weapon_' then TriggerClientEvent('fw-assets:Client:Attach:Items', self.PlayerData.source) end
        end

        return Retval
    end

    self.Functions.RemoveMultiItems = function(Items)
        local AllRemoved = exports['fw-inventory']:RemoveItemsFromInventory('ply-' .. self.PlayerData.citizenid, Items)
        return AllRemoved
    end

    self.Functions.RemoveItemByKV = function(Item, Amount, Value, Show, CustomType)
        if not self.Functions.HasEnoughOfItem(Item, Amount, CustomType) then
            return false
        end

        local Retval = exports['fw-inventory']:RemoveItemFromInventoryByKV('ply-' .. self.PlayerData.citizenid, Item, Amount, Value, CustomType)
        if Retval then
            if string.sub(Item, 1, 7) == 'weapon_' then TriggerClientEvent('fw-assets:Client:Attach:Items', self.PlayerData.source) end
            if Show then TriggerClientEvent('fw-inventory:Client:ShowActionBox', self.PlayerData.source, 'Verwijderd', Item, Amount, CustomType) end
            TriggerClientEvent("fw-inventory:Client:Cock", self.PlayerData.source)
        end
        return true
    end

    self.Functions.SetItemKV = function(Item, Slot, Key, Value, CustomType)
        if not self.Functions.HasEnoughOfItem(Item, 1, CustomType) then
            return false
        end

        local Retval = exports['fw-inventory']:SetInventoryItemKV('ply-' .. self.PlayerData.citizenid, Item, Slot, Key, Value)
        if Retval then
            self.Functions.RefreshInvSlot(Slot)
        end

        return Retval
    end

    self.SetItemMultipleKV = function(Item, Slot, Data)
        local Retval = exports['fw-inventory']:SetInventoryItemMultipleKV('ply-' .. self.PlayerData.CitizenId, Item, Slot, Data)
        if Retval then
            self.Functions.RefreshInvSlot(Slot)
        end

        return Retval
    end

    self.Functions.ClearInventory = function()
        exports['fw-inventory']:ClearInventory('ply-' .. self.PlayerData.citizenid)
        self.Functions.RefreshInventory()
        TriggerClientEvent('fw-assets:Client:Attach:Items', self.PlayerData.source)
        return true
    end

    self.Functions.GetItemBySlot = function(Slot)
        local Retval = exports['fw-inventory']:GetInventoryItemBySlot('ply-' .. self.PlayerData.citizenid, Slot)
        return Retval
    end

    self.Functions.GetItemByName = function(Item)
        for k, v in pairs(self.PlayerData.inventory) do
            if v and v.Item == Item then
                return v
            end
        end

        return false
    end

    self.Functions.HasEnoughOfItem = function(Item, Amount, CustomType, RequiredQuality)
        if not CustomType then CustomType = "" end
        if not Amount then Amount = 1 end
        if not RequiredQuality then RequiredQuality = 1 end

        local TotalItems = 0
        for k, v in pairs(self.PlayerData.inventory) do
            if v and v.Item == Item and v.CustomType == CustomType then
                local ItemQuality = exports['fw-inventory']:CalculateQuality(v.Item, v.CreateDate)
                if ItemQuality >= RequiredQuality then
                    TotalItems = TotalItems + v.Amount

                    if TotalItems >= Amount then
                        return true
                    end
                end
            end
        end

        return false
    end

    self.Functions.Save = function()
        FW.Player.Save(self.PlayerData.source)
    end
    
    FW.Players[self.PlayerData.source] = self
    FW.Player.Save(self.PlayerData.source)
    self.Functions.UpdatePlayerData(false)
end

FW.Player.Save = function(source)
    local PlayerData = FW.Players[source].PlayerData
    if PlayerData ~= nil then
        exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = @Cid", {
            ['@Cid'] = PlayerData.citizenid,
        }, function(result)
            if result[1] == nil then
                exports['ghmattimysql']:execute("INSERT INTO `players` (`citizenid`, `email`, `steam`, `license`, `name`, `money`, `charinfo`, `job`, `position`, `metadata`, `addiction`, `skin`) VALUES (@Citizenid, @Email, @Steam, @License, @Name, @Money, @CharInfo, @Job, @Position, @Metadata, @Addiction, @Skin)", {
                    ["@Citizenid"] = PlayerData.citizenid,
                    ["@Email"] = PlayerData.email,
                    ["@Steam"] = PlayerData.steam,
                    ["@License"] = PlayerData.license,
                    ["@Name"] = PlayerData.name,
                    ["@Money"] = json.encode(PlayerData.money),
                    ["@CharInfo"] = json.encode(PlayerData.charinfo),
                    ["@Job"] = json.encode(PlayerData.job),
                    ["@Position"] = json.encode(PlayerData.position),
                    ["@Metadata"] = json.encode(PlayerData.metadata),
                    ["@Addiction"] = json.encode(PlayerData.addiction),
                    ["@Skin"] = json.encode(PlayerData.skin),
                })
            else
                exports['ghmattimysql']:execute("UPDATE `players` SET `steam` = @Steam, `license` = @License, `name` = @Name, `money` = @Money, `charinfo` = @CharInfo, `job` = @Job, `position` = @Position, `metadata` = @Metadata, `addiction` = @Addiction, `skin` = @Skin WHERE `citizenid` = @Citizenid", {
                    ["@Citizenid"] = PlayerData.citizenid,
                    ["@Steam"] = PlayerData.steam,
                    ["@License"] = PlayerData.license,
                    ["@Name"] = PlayerData.name,
                    ["@Money"] = json.encode(PlayerData.money),
                    ["@CharInfo"] = json.encode(PlayerData.charinfo),
                    ["@Job"] = json.encode(PlayerData.job),
                    ["@Position"] = json.encode(PlayerData.position),
                    ["@Metadata"] = json.encode(PlayerData.metadata),
                    ["@Addiction"] = json.encode(PlayerData.addiction),
                    ["@Skin"] = json.encode(PlayerData.skin),
                })
            end
        end)
    else
        print("^1[CORE]^7: Failed to Save " .. source .. "!")
    end
end


FW.Player.Logout = function(source)
    local Player = FW.Functions.GetPlayer(source)
    TriggerClientEvent('FW:Client:OnPlayerUnload', source)
    Player.PlayerData.position = GetEntityCoords(GetPlayerPed(source))
    Player.Functions.Save()
    Citizen.Wait(200)
    FW.Players[source] = nil
end

FW.Player.DeleteCharacter = function(source, citizenid)
    if not citizenid then return end

    local result = exports['ghmattimysql']:executeSync("SELECT * FROM `players` WHERE `citizenid` = @citizenid", { ['@citizenid'] = citizenid })
    if result[1] ~= nil then
        if result[1].steam == GetPlayerIdentifiers(source)[1] then
            exports['ghmattimysql']:execute("DELETE FROM `phone_contacts` WHERE `citizenid` = @citizenid", { ['@citizenid'] = citizenid })
            exports['ghmattimysql']:execute("DELETE FROM `phone_debt` WHERE `citizenid` = @citizenid", { ['@citizenid'] = citizenid })
            exports['ghmattimysql']:execute("DELETE FROM `player_financials` WHERE `accountid` = @accountid", { ['@accountid'] = json.decode(result[1].charinfo).account })
            exports['ghmattimysql']:execute("DELETE FROM `player_inventories` WHERE `inventory` = @citizenid", { ['@citizenid'] = 'ply-'..citizenid })
            exports['ghmattimysql']:execute("DELETE FROM `player_outfits` WHERE `citizenid` = @citizenid", { ['@citizenid'] = citizenid })
            exports['ghmattimysql']:execute("DELETE FROM `player_vehicles` WHERE `citizenid` = @citizenid", { ['@citizenid'] = citizenid })
            exports['ghmattimysql']:execute("DELETE FROM `players` WHERE `citizenid` = @citizenid", { ['@citizenid'] = citizenid })
            TriggerClientEvent('fw-characters:Client:ShowSelector', source)
            TriggerEvent('fw-logs:Server:Log', 'characters', 'Character Deleted [' .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s]\nDeleted CID#: %s"):format(source, citizenid), 'green')
            return true
        else
            TriggerClientEvent('fw-characters:Client:ShowSelector', source)
            TriggerEvent('fw-logs:Server:Log', 'characters', 'Cheater Tried to Delete Character [' .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s]\nCID#: %s"):format(source, citizenid), 'red', true)
        end
    else
        TriggerClientEvent('fw-characters:Client:ShowSelector', source)
        TriggerEvent('fw-logs:Server:Log', 'characters', 'Cheater Tried to Delete Character [' .. (GetInvokingResource() or "Unknown Resource") .. "]", ("User: [%s]\nCID#: %s"):format(source, citizenid), 'red', true)
    end

    return false
end

FW.Player.CreateCitizenId = function()
    local Result = exports['ghmattimysql']:executeSync("SELECT AUTO_INCREMENT AS `CitizenId` FROM information_schema.TABLES WHERE TABLE_SCHEMA = @Database AND TABLE_NAME = 'players'", {
        ['@Database'] = 'fivem-clarity',
    })
    return Result[1].CitizenId
end

FW.Player.CreateDnaId = function(Type)
    local DnaId = {}
    if Type == 'finger' then
        DnaId = tostring('F'..FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3):upper() .. FW.Shared.RandomStr(1) .. FW.Shared.RandomInt(2) .. FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(4):upper())
    elseif Type == 'slime' then
        DnaId = tostring('S'..FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(2):upper() .. FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(4))
    elseif Type == 'hair' then
        DnaId = tostring('H'..FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(2) .. FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(4):upper())
    end 
    return DnaId
end

FW.Player.CreateWeaponSerial = function()
    local Serial =  FW.Shared.RandomStr(2)..FW.Shared.RandomInt(3):upper()..FW.Shared.RandomStr(3)..FW.Shared.RandomInt(3):upper()..FW.Shared.RandomStr(2)..FW.Shared.RandomInt(3):upper()
    return Serial
end

FW.Player.CreateAppartmentId = function()
    local Number, UniqueFound = tostring(FW.Shared.RandomInt(6)), false
    while not UniqueFound do
        local Result = exports['ghmattimysql']:executeSync("SELECT `id` FROM `players` WHERE `metadata` LIKE @Number", { ['@Number'] = "%" .. Number .. "%" })
        if Result[1] ~= nil then
            Number = tostring(FW.Shared.RandomInt(6))
        else
            UniqueFound = true
        end
        Citizen.Wait(4)
    end

    return Number
end

FW.Player.CreatePhoneNumber = function(IsBurner)
    local Number, UniqueFound = (IsBurner and "03" or "06") .. tostring(FW.Shared.RandomInt(8)), false
    while not UniqueFound do
        local Result = exports['ghmattimysql']:executeSync("SELECT `charinfo` FROM `players` WHERE `charinfo` LIKE @Number", { ['@Number'] = "%" .. Number .. "%" })
        if Result[1] ~= nil then
            Number = "06" .. tostring(FW.Shared.RandomInt(8))
        else
            UniqueFound = true
        end
        Citizen.Wait(4)
    end

    return Number
end

FW.Player.CreateBankAccount = function()
    local Account, UniqueFound = FW.Shared.RandomInt(8), false
    while not UniqueFound do
        local Result = exports['ghmattimysql']:executeSync("SELECT `charinfo` FROM `players` WHERE `charinfo` LIKE @Account", { ['@Account'] = "%" .. Account .. "%" })
        if Result[1] ~= nil then
            Account = FW.Shared.RandomInt(8)
        else
            UniqueFound = true
        end
        Citizen.Wait(4)
    end

    return Account
end

FW.EscapeSqli = function(str)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return str:gsub( "['\"]", replacements)
end

FW.GetPlayers = function()
    local Players, ReturnPlayers = GetPlayers(), {}
    for k, v in pairs(Players) do
        local Ped = GetPlayerPed(v)
        if DoesEntityExist(Ped) then
            local PlayerData = {
                ['Name'] = GetPlayerName(v),
                ['ServerId'] = tonumber(v),
                ['Coords'] = GetEntityCoords(Ped),
                ['Steam'] = GetPlayerIdentifiers(v)[1],
                ['ClientPlayerPed'] = nil,
                ['ServerPlayerPed'] = Ped
            }
            table.insert(ReturnPlayers, PlayerData)
        end
    end
    return ReturnPlayers
end

FW.Functions.CreateCallback("FW:Server:GetCitizenIdByServerId", function(Source, Cb, ServerId)
    local Player = FW.Functions.GetPlayer(tonumber(ServerId))
    if Player == nil then return end

    Cb(Player.PlayerData.citizenid)
end)