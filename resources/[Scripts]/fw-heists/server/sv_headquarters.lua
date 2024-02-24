FW.Functions.CreateCallback("fw-heists:Server:GetLevelProgression", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = exports['fw-phone']:GetPlayerGroup(Player.PlayerData.citizenid)
    if not Group or Group == nil then
        Player.Functions.Notify("Je hebt geen TierUp! groep..", "error")
        return
    end

    local Retval = GetProgressionByExperience(Group.experience)
    Retval.MaxLevels = #Config.Levels
    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-heists:Server:GetLevelItems", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = exports['fw-phone']:GetPlayerGroup(Player.PlayerData.citizenid)
    if not Group or Group == nil then
        Player.Functions.Notify("Je hebt geen TierUp! groep..", "error")
        return
    end

    local Progression = GetProgressionByExperience(Group.experience)
    local Retval = {}

    for i = 1, Progression.CurrentLevel, 1 do
        Retval = table.merge(Retval, Config.Items[i])
    end

    Cb(Retval)
end)

RegisterNetEvent("fw-heists:Server:PurchaseCryptoshop")
AddEventHandler("fw-heists:Server:PurchaseCryptoshop", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Data.Item or not Data.Crypto then
        return
    end

    if not Player.Functions.RemoveCrypto('EVD', Data.Crypto) then
        TriggerClientEvent('fw-phone:Client:Notification', Source, "heists-crypto" .. math.random(1, 100), "fas fa-home", { "white" , "rgb(38, 50, 56)" }, "Evidentia", "Je hebt niet genoeg crypto.")
        return
    end

    Player.Functions.AddItem(Data.Item[1], 1, nil, nil, true, Data.Item[2] or false)
end)

RegisterNetEvent("fw-heists:Server:TradeLoot")
AddEventHandler("fw-heists:Server:TradeLoot", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if FW.Throttled(Player.PlayerData.citizenid .. '-heists-loot-trade', 7000) then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    local Inventory = exports['fw-inventory']:GetInventoryItemsUnproccessed('ply-' .. Player.PlayerData.citizenid)
    local TradableLoots = 0

    for k, v in pairs(Inventory) do
        if v.item_name == 'heist-loot' and v.custom_type ~= "tracked" then
            TradableLoots = TradableLoots + 1
        end
    end

    -- For every 3 loot you get 1 inked bag.
    if Player.Functions.RemoveItemByName('heist-loot', TradableLoots, true) then
        local InkedMoneyBags = math.floor(TradableLoots / 3)
        if InkedMoneyBags > 0 then
            Player.Functions.AddItem('inkedmoneybag', InkedMoneyBags, false, { InkedBagExpiration = os.time() + (86400 * 7) }, true)
        end

        local MarkedBills = 0
        for i = 1, TradableLoots, 1 do
            MarkedBills = MarkedBills + math.random(8, 25)
        end

        Player.Functions.AddItem('markedbills', MarkedBills, false, nil, true)
    end
end)

RegisterNetEvent("fw-heists:Server:TradeUSBs")
AddEventHandler("fw-heists:Server:TradeUSBs", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if FW.Throttled(Player.PlayerData.citizenid .. '-heists-usb-trade', 7000) then
        return Player.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    local Inventory = exports['fw-inventory']:GetInventoryItemsUnproccessed('ply-' .. Player.PlayerData.citizenid)
    local TradableUsbs = 0

    for k, v in pairs(Inventory) do
        if v.item_name == 'heist-loot-usb' then
            TradableUsbs = TradableUsbs + 1
        end
    end

    if Player.Functions.RemoveItemByName('heist-loot-usb', TradableUsbs, false) then
        TriggerClientEvent('fw-inventory:Client:ShowActionBox', Source, 'Ingeleverd', 'heist-loot-usb', TradableUsbs, '')

        local CryptoAdded = 0
        for i = 1, TradableUsbs, 1 do
            CryptoAdded = CryptoAdded + 2
        end

        Player.Functions.AddCrypto('EVD', CryptoAdded)
        TriggerClientEvent('fw-phone:Client:Notification', Source, "heists-crypto" .. math.random(1, 100), "fas fa-home", { "white" , "rgb(38, 50, 56)" }, "Crypto", CryptoAdded .." Evidentia toegevoegd!")
    end
end)

function GetProgressionByExperience(Experience)
    local Retval = { CurrentLevel = 1, NextLevel = 2, Progress = 0 }

    for i = 1, #Config.Levels, 1 do
        local Level = Config.Levels[i]

        if Experience >= Level.RequiredExp then
            Retval.CurrentLevel = i
            if Config.Levels[i + 1] then
                Retval.NextLevel = i + 1
                Retval.Progress = math.floor((Experience - Level.RequiredExp) / (Config.Levels[i + 1].RequiredExp - Level.RequiredExp) * 100)
            else
                Retval.NextLevel = Retval.CurrentLevel
                Retval.Progress = 100
            end
        end
    end

    return Retval
end
exports("GetProgressionByExperience", GetProgressionByExperience)

function IncreaseProgression(Cid, Increasement)
    local Group = exports['fw-phone']:GetPlayerGroup(Cid)
    if not Group or Group == nil then
        return
    end

    local NewExperience = Group.experience + Increasement
    if NewExperience > Config.Levels[#Config.Levels].RequiredExp then
        NewExperience = Config.Levels[#Config.Levels].RequiredExp
    end

    exports['ghmattimysql']:executeSync("UPDATE `phone_tierup` SET `experience` = ? WHERE `id` = ?", { NewExperience, Group.id })
end
exports("IncreaseProgression", IncreaseProgression)

function DecreaseProgression(Cid, Decreasement)
    local Group = exports['fw-phone']:GetPlayerGroup(Cid)
    if not Group or Group == nil then
        return
    end

    local NewExperience = Group.experience - Decreasement
    if NewExperience < 0 then NewExperience = 0 end

    exports['ghmattimysql']:executeSync("UPDATE `phone_tierup` SET `experience` = ? WHERE `id` = ?", { NewExperience, Group.id })
end
exports("DecreaseProgression", DecreaseProgression)