FW = exports['fw-core']:GetCoreObject()

local lastBananaPluck = GetGameTimer() + (3600 * 1000)
local bananaPool = 0
local isBananaTreeWaterLevel = 100

local AllowedCid = {
    ['2009'] = GetConvar("sv_serverCode") == "dev",
    ['2006'] = true,
    ['3129'] = true,
    ['2033'] = true,
    ['2035'] = true,
    ['2880'] = true,
    ['4068'] = true,
}

-- Code

Citizen.CreateThread(function()
    local timeSinceLastBanana = GetGameTimer()
    while true do

        -- Reduce water level.
        if isBananaTreeWaterLevel - 1 > 0 then
            isBananaTreeWaterLevel = isBananaTreeWaterLevel - 1

            -- every 8 minutes, add 1 banana.
            if GetGameTimer() - timeSinceLastBanana >= 480 then
                bananaPool = bananaPool + 1
            end
        elseif bananaPool - 1 > 0 then
            bananaPool = bananaPool - 1
        end

        Citizen.Wait(30000)
    end
end)

exports("GetSoundTimeout", function(SoundId)
    return Config.Sounds[SoundId].Timeout
end)

local RecentSellers = {}

local IgnoreWeapons = {
    ["weapon_glock"] = true,
    ["weapon_fn57"] = true,
    ["weapon_m4"] = true,
    ["weapon_scar"] = true,
    ["weapon_mpx"] = true,
    ["weapon_mp7"] = true,
    ["weapon_remington"] = true,
}

local WeaponPrices = {}

Citizen.CreateThread(function()
    while true do
        UpdateWeaponPartsPrices()
        Citizen.Wait((1000 * 60) * 10)
    end
end)

FW.Functions.CreateCallback("fw-misc:Server:CanPluckBananas", function(Source, Cb)
    if isBananaTreeWaterLevel <= 25 then
        Cb({Success = false, Msg = "De boom is te droog, geef het wat water.."})
        return
    end

    if GetGameTimer() <= lastBananaPluck then
        Cb({Success = false, Msg = "De bananen zijn nog niet rijp.."})
        return
    end

    if bananaPool <= 0 then
        Cb({Success = false, Msg = "De bananen moeten nog groeien.."})
        return
    end

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-misc:Server:GetBananaTreeWater", function(Source, Cb)
    Cb(isBananaTreeWaterLevel)
end)

FW.Functions.CreateCallback('fw-misc:Server:GetWeaponBodyPrices', function(Source, Cb)
    Cb(WeaponPrices)
end)

FW.Functions.CreateCallback('fw-interactions:server:has:robbery:item', function(source, cb)
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then cb(false) return end

    if Player.Functions.HasEnoughOfItem('stolen-tv', 1) then
        cb('StolenTv')
    elseif Player.Functions.HasEnoughOfItem('stolen-micro', 1) then
        cb('StolenMicro')
    elseif Player.Functions.HasEnoughOfItem('stolen-pc', 1) then
        cb('StolenPc')
    elseif Player.Functions.HasEnoughOfItem('oxy-box', 1) then
        cb('DarkmarketBox')
    elseif Player.Functions.HasEnoughOfItem('business-bag', 1, 'policeduffel') then
        cb('Duffel')
    elseif Player.Functions.HasEnoughOfItem('moneycase', 1) then
        cb('BriefCase')
    elseif Player.Functions.HasEnoughOfItem('atm-blackbox', 1) then
        cb('ATM')
    elseif Player.Functions.GetItemByName('antique-vase') then
        cb('Vase')
    elseif Player.Functions.GetItemByName('painting') then
        cb('Painting')
    else
        cb(false)
    end
end)

FW.Functions.CreateCallback("fw-misc:Server:GetIllegalSellsCoords", function(Source, Cb)
    Cb(Config.IllegalSells)
end)

FW.Functions.CreateCallback("fw-misc:Server:CanSellIllegal", function(Source, Cb)
    Cb(RecentSellers[Source])
end)

FW.RegisterServer("fw-misc:Server:GetTea", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.RemoveItemByName('water_bottle', 1, true) then
        Player.Functions.AddItem('mugoftea', 1, false, false, true, false)
    end
end)

FW.RegisterServer("fw-misc:Server:PurchaseWeaponBody", function(Source, BodyType, Amount)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if math.floor(Amount) <= 0 then return end
    local Amount = math.min(math.floor(Amount), 100)

    if not Player.Functions.RemoveMoney('cash', WeaponPrices[BodyType] * Amount) then
        return Player.Functions.Notify("Niet genoeg cash..", "error")
    end

    local Item = ""
    if BodyType == "Rifle" then
        Item = "riflebody"
    elseif BodyType == "Smg" then
        Item = "smgbody"
    elseif BodyType == "Pistol" then
        Item = "pistolparts"
    elseif BodyType == "Shotgun" then
        Item = "shotgunparts"
    end

    if Player.Functions.AddItem(Item, Amount, false, nil, true) then
        UpdateWeaponPartsPrices()
    end
end)

FW.RegisterServer("fw-misc:Server:ExploiterAlert", function(Source, ResourceName, Type)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    print(("EXPLOITER ALERT: %s (%s) %s resource %s on CLIENT!"):format(GetPlayerName(Source), Source, Type, ResourceName))

    TriggerEvent("fw-logs:Server:Log", 'anticheat', "Exploiter Alert", ("%s (%s) %s resource **'%s'** on CLIENT, **possible cheater**!"):format(GetPlayerName(Source), Source, Type, ResourceName), "red")
end)

FW.RegisterServer("fw-misc:Server:PluckBananas", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not AllowedCid[Player.PlayerData.citizenid] then
        return
    end

    if isBananaTreeWaterLevel <= 25 then
        return
    end

    if GetGameTimer() <= lastBananaPluck then
        return
    end

    if bananaPool <= 0 then
        return
    end

    for i = 1, bananaPool, 1 do
        Player.Functions.AddItem("weapon_banana", 1, false, false, true)
        Citizen.Wait(1)
    end

    lastBananaPluck = GetGameTimer() + (3600 * 1000)
    bananaPool = 0
    isBananaTreeWaterLevel = isBananaTreeWaterLevel - 10
end)

FW.RegisterServer("fw-misc:Server:CreateSandstone", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local DidFind = math.random() > 0.25
    if not DidFind then
        return Player.Functions.Notify("Lijkt erop dat je niks kon vinden..", "error")
    end

    if Player.PlayerData.job.name ~= 'police' or Player.PlayerData.metadata.department ~= 'BCSO' then
        return
    end

    Player.Functions.AddItem("weapon_brick", 1, false, nil, true)
end)

FW.Functions.CreateUsableItem("mugoftea", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    TriggerClientEvent("fw-misc:Client:UsedTea", Source, Item)
end)

RegisterNetEvent("fw-misc:Server:WaterBananaTree")
AddEventHandler("fw-misc:Server:WaterBananaTree", function()
    isBananaTreeWaterLevel = isBananaTreeWaterLevel + 15
end)

RegisterNetEvent("fw-misc:Server:BananaSwitchFx")
AddEventHandler("fw-misc:Server:BananaSwitchFx", function(Coords)
    local Players = FW.GetPlayers()
    for k, v in pairs(Players) do
        if #(Coords - GetEntityCoords(GetPlayerPed(v.ServerId))) <= 25.0 then
            TriggerClientEvent('fw-misc:Client:BananaSwitchFx', v.ServerId, Coords)
        end
    end
end)

RegisterNetEvent("fw-misc:Server:SellSomething")
AddEventHandler("fw-misc:Server:SellSomething", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if RecentSellers[Source] then return end
    RecentSellers[Source] = true

    local Result = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    local TotalReceive, ItemsTraded = 0, {}

    for k, v in pairs(Result) do
        local Quality = exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate)
        if IsIllegalSellItem(v.item_name) and Quality > 0 then
            if Player.Functions.RemoveItem(v.item_name, 1, v.slot, false, v.custom_type) then
                ItemsTraded[v.item_name] = (ItemsTraded[v.item_name] or 0)
                TotalReceive = TotalReceive + Config.IllegalSelling[v.item_name]
            end
        end
    end

    if TotalReceive > 0 then
        -- for k, v in pairs(ItemsTraded) do
        --     TriggerClientEvent('fw-inventory:Client:ShowActionBox', Source, 'Verkocht', k, v, '')
        -- end

        Player.Functions.Notify("Goederen verkocht.")
        Player.Functions.AddMoney("cash", TotalReceive, "Sells illegal items")
    end

    Citizen.SetTimeout((1000 * 60) * 5, function() -- 5 minutes.
        RecentSellers[Source] = false
    end)
end)

function IsIllegalSellItem(Item)
    return Config.IllegalSelling[Item] ~= nil
end

FW.RegisterServer("fw-misc:Server:AFKKick", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    DropPlayer(Player.PlayerData.source, 'Je werd gekickt van de server, reden:\nJe was geflagged als AFK.\n\n🔸 Indien je vragen hebt maak een ticket aan in onze discord: discord.gg/clarityrp')
end)

function UpdateWeaponPartsPrices()
    local WeaponsList = exports['fw-weapons']:GetWeapons()
    local Rifles, Smgs, Pistols, Shotguns = '\'riflebody\',', '\'smgbody\',', '\'pistolparts\',', '\'shotgunbody\','

    for k, v in pairs(WeaponsList) do
        if not IgnoreWeapons[v.WeaponID] then
            if v.AmmoType == "AMMO_PISTOL" then
                Pistols = Pistols .. '\'' .. v.WeaponID .. '\','
            -- elseif v.AmmoType == "AMMO_RIFLE" then
            --     Rifles = Rifles .. '\'' .. v.WeaponID .. '\','
            -- elseif v.AmmoType == "AMMO_SMG" then
            --     Smgs = Smgs .. '\'' .. v.WeaponID .. '\','
            elseif v.AmmoType == "AMMO_SHOTGUN" then
                Shotguns = Shotguns .. '\'' .. v.WeaponID .. '\','
            end
        end
    end

    -- Rifles = Rifles:sub(1, -2)
    -- Smgs = Smgs:sub(1, -2)
    Pistols = Pistols:sub(1, -2)
    Shotguns = Shotguns:sub(1, -2)

    local TwentyEightDays = 1000 * 60 * 40320
    -- local RiflesResult = exports['ghmattimysql']:executeSync("SELECT COUNT(item_name) AS `amount` FROM `player_inventories` WHERE `item_name` IN (" .. Rifles .. ") AND `createdate` > ?", { (os.time() * 1000) - TwentyEightDays })
    -- local SmgsResult = exports['ghmattimysql']:executeSync("SELECT COUNT(item_name) AS `amount` FROM `player_inventories` WHERE `item_name` IN (" .. Smgs .. ") AND `createdate` > ?", { (os.time() * 1000) - TwentyEightDays })
    local PistolsResult = exports['ghmattimysql']:executeSync("SELECT COUNT(item_name) AS `amount` FROM `player_inventories` WHERE `item_name` IN (" .. Pistols .. ") AND `createdate` > ?", { (os.time() * 1000) - TwentyEightDays })
    local ShotgunsResult = exports['ghmattimysql']:executeSync("SELECT COUNT(item_name) AS `amount` FROM `player_inventories` WHERE `item_name` IN (" .. Shotguns .. ") AND `createdate` > ?", { (os.time() * 1000) - TwentyEightDays })

    WeaponPrices = {
        -- Rifle = math.min(2500 * math.max(RiflesResult[1].amount + 1, 1), 80000),
        -- Smg = math.min(1500 * math.max(SmgsResult[1].amount + 1, 1), 60000),
        Rifle = 75000,
        Smg = 55000,
        Pistol = math.min(250 * math.max(PistolsResult[1].amount + 1, 1), 20000),
        Shotgun = math.min(1000 * math.max(ShotgunsResult[1].amount + 1, 1), 50000),
    }
end

RegisterNetEvent("fw-misc:Server:SetBinDecor")
AddEventHandler("fw-misc:Server:SetBinDecor", function(Data)
    TriggerClientEvent("fw-misc:Client:SetBinDecor", -1, Data.DecorId)
end)