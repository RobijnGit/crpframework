local CurrentFishingSpot = 0

-- Code

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        CurrentFishingSpot = GetNextFishingSpot()
        TriggerClientEvent('fw-jobmanager:Client:Fishing:SetFishingSpot', -1, Config.FishingSpots[CurrentFishingSpot])
        Citizen.Wait((1000 * 60) * 60)
    end
end)

-- Functions
function GetNextFishingSpot()
    local RandomSpot = math.random(1, #Config.FishingSpots)
    while RandomSpot == CurrentFishingSpot do
        Citizen.Wait(4)
        RandomSpot = math.random(1, #Config.FishingSpots)
    end
    return RandomSpot
end

-- Callbacks
FW.Functions.CreateUsableItem("fishingrod", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-jobmanager:Client:Fishing:GrabRod', Source)
    end
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:Fishing:GetLocation", function(Source, Cb)
    Cb(Config.FishingSpots[CurrentFishingSpot])
end)

-- Events
FW.RegisterServer("fw-jobmanager:Server:Fishing:GetFishReward", function(Source, FishType)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if FishType == 'Big' then
        Player.Functions.AddItem("fish", 1, false, nil, true, Config.BigFishTypes[math.random(1, #Config.BigFishTypes)])
    else
        Player.Functions.AddItem("fish", 1, false, nil, true, Config.FishTypes[math.random(1, #Config.FishTypes)])
    end
end)

RegisterNetEvent("fw-jobmanager:Server:FishingSell")
AddEventHandler("fw-jobmanager:Server:FishingSell", function()
    local Source = source
    local TotalReceive = 0

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Salary')
    local MoneyRolls = 0
    for k, v in pairs(Result) do
        if v.item_name == 'fish' and IsThisFish(v.custom_type) then
            if exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate) > 0 then
                if Player.Functions.RemoveItem(v.item_name, 1, v.slot, false, v.custom_type) then
                    TotalReceive = TotalReceive + math.random(1, 3)
                    if HasBuff then TotalReceive = TotalReceive + math.random(2, 5) end
                end
            end
        elseif v.item_name == 'fish' and (v.custom_type == 'Shark' or v.custom_type == 'Whale') then
            local Time = exports['fw-sync']:GetCurrentTime()
            if (Time.Hour >= 20 and Time.Hour <= 23) or (Time.Hour >= 0 and Time.Hour <= 6) then
                if exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate) > 0 then
                    if Player.Functions.RemoveItem(v.item_name, 1, v.Slot, false, v.custom_type) then
                        MoneyRolls = MoneyRolls + 1
                    end
                end
            else
                Player.Functions.Notify('Kom je vannacht even terug? Ik ga dit soort dingen niet overdag aannemen..', 'error')
            end
        end
    end

    if TotalReceive > 0 then
        Player.Functions.Notify('Toegevoegd op bank balans.')
        exports['fw-financials']:AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, TotalReceive, 'SALES', 'Baan: Vis Verkoop')
    end

    if MoneyRolls > 0 then
        Player.Functions.AddItem('money-roll', MoneyRolls, nil, nil, true)
    end
end)

function IsThisFish(ItemName)
    for k, v in pairs(Config.FishTypes) do
        if v == ItemName then
            return true
        end
    end
    return false
end