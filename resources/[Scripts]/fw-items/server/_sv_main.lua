local FW = exports['fw-core']:GetCoreObject()

-- Code
FW.Functions.CreateUsableItem("nightvision", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player ~= nil then 
        TriggerClientEvent("fw-items:client:use:nightvision", Source)
    end 
end)

-- Weed
FW.Functions.CreateUsableItem("scales", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:Scales', Source)
    end
end)

FW.Functions.CreateUsableItem("weed-seed-female", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:SeedsFemale', Source)
    end
end)

-- Shitz

FW.Functions.CreateUsableItem("evidence", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        if not Item.CustomType or Item.CustomType == "" then
            TriggerClientEvent("fw-items:Client:Used:Evidence", Source)
        end
    end
end)

FW.Functions.CreateUsableItem("spikestrip", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-police:Client:Used:Spikestrip", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("security_hacking_device", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:Used:SecurityHackingDevice", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("goldpan", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:Used:GoldPan", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("newscamera", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:Used:NewsCamera", Source)
    end
end)

FW.Functions.CreateUsableItem("newsmic", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:Used:NewsMic", Source)
    end
end)

FW.Functions.CreateUsableItem("burnerphone", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:Used:BurnerPhone", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("lawnchair", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:Used:Lawnchair", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("metaldetector", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-misc:Client:UsedMetaldetector", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("trowel", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-misc:Client:UsedTrowel", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("panicbutton", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        if not Player.PlayerData.job.onduty then
            return
        end

        if Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'storesecurity' and Player.PlayerData.job.name ~= 'ems' and Player.PlayerData.job.name ~= 'doc' then
            return
        end

        TriggerClientEvent("fw-menu:client:send:panic:button", Source)
    end
end)

-- Chains
FW.Functions.CreateUsableItem("gang-chain", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:SetPlayerChain", Source, Item.CustomType)
    end
end)

-- Badge
FW.Functions.CreateUsableItem("identification-badge", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-ui:Client:BadgeAnim", Source)

        Citizen.Wait(4500)

        local MyCoords = GetEntityCoords(GetPlayerPed(Source))
        for k, v in pairs(FW.GetPlayers()) do
            if #(MyCoords - v.Coords) <= 3.0 then
                TriggerClientEvent('fw-ui:Client:ShowBadge', v.ServerId, Item.CustomType, Item.Info)
            end
        end
    end
end)

-- Heists
FW.Functions.CreateUsableItem("heist-loot", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil and Item.CustomType == 'tracked' then
        TriggerClientEvent('fw-items:Client:HeistLootTracker', Source, Item)
    end
end)

FW.Functions.CreateUsableItem("inkedmoneybag", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        if os.time() >= Item.Info.InkedBagExpiration then
            if Player.Functions.RemoveItem('inkedmoneybag', 1, Item.Slot, true) then
                Player.Functions.AddMoney("cash", 60000, 'Money from Inked Money Bag.')
            end
        else
            Player.Functions.Notify("De tas is te recentelijk gestolen, misschien nog even wachten?", "error")
        end
    end
end)

-- Farming
FW.Functions.CreateUsableItem("farming-seed", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-misc:Client:Farming:UsedSeed", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("farming-seedbag", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:OpenBag', Source, Item.Info.BagId, 'SeedBag')
    end
end)

FW.Functions.CreateUsableItem("producebasket", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:OpenBag', Source, Item.Info.BagId, 'ProduceBasket')
    end
end)

FW.Functions.CreateUsableItem("farming-pitchfork", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-misc:Client:Farming:UsedPitchfork", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("farming-hoe", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-misc:Client:Farming:UsedHoe", Source, Item)
    end
end)

FW.Functions.CreateUsableItem("farming-wateringcan", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-misc:Client:Farming:UsedWateringcan", Source, Item)
    end
end)

-- Food & Drinks
local AlcoholDrinks = {
    'vodka',
    'bacardi',
    'whiskey',
    'goldstrike',
    'flugel',
    'cocktail-split',
    'cocktail-pinacolada',
    'cocktail-aperolspritz',
    'cocktail-1',
    'cocktail-2',
    'cocktail-3',
    'white-wine',
    'red-wine',
    'beer',
    'beer-heineken',
    'beer-hertogjan',
    'beer-grolsch',
}

for k, v in pairs(AlcoholDrinks) do
    FW.Functions.CreateUsableItem(v, function(Source, Item)
        local Player = FW.Functions.GetPlayer(Source)
        if Player == nil then return end

        if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
            TriggerClientEvent("fw-items:Client:DrinkAlcohol", Source, Item)
        end
    end)
end

-- Jobs
FW.Functions.CreateUsableItem("uwu-mystery-box", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:MysteryBox', Source, Item)
    end
end)
FW.Functions.CreateUsableItem("hunting-bait", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:HuntingBait', Source)
    end
end)
FW.Functions.CreateUsableItem("hunting-knife", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:HuntingKnife', Source)
    end
end)

-- Unsorted
-- // Lockpick \\ --
FW.Functions.CreateUsableItem("advlockpick", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:UseLockpick', Source, true, Item)
    end
end)

FW.Functions.CreateUsableItem("lockpick", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:UseLockpick', Source, false, Item)
    end
end)

FW.Functions.CreateUsableItem("megaphone", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:Megaphone', Source)
    end
end)

FW.Functions.CreateUsableItem("cryptostick", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        local Crypto, Amount = false, 0

        if Item.CustomType == 'GNE5' then
            Crypto, Amount = 'GNE', 5
        elseif Item.CustomType == 'GNE10' then
            Crypto, Amount = 'GNE', 10
        elseif Item.CustomType == 'GNE25' then
            Crypto, Amount = 'GNE', 25
        elseif Item.CustomType == 'GNE50' then
            Crypto, Amount = 'GNE', 50
        elseif Item.CustomType == 'GNE100' then
            Crypto, Amount = 'GNE', 100
        elseif Item.CustomType == 'GNE250' then
            Crypto, Amount = 'GNE', 250
        end

        if Crypto and Amount > 0 then
            if Player.Functions.RemoveItem('cryptostick', 1, Item.Slot, true, Item.CustomType) then
                Player.Functions.AddCrypto(Crypto, Amount)
                Player.Functions.Notify("Je hebt crypto toegevoegd aan je wallet!")
            end
        else
            Player.Functions.Notify("Lijkt erop dat deze crypto stick nep is..", "error")
        end
    end
end)

-- // Eten \\ --

FW.Functions.CreateUsableItem("foodchain-drink-item", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:FoodchainDrink", Source, Item.Item, Item.CustomType, Item.Slot, Item.Info)
    end
end)

FW.Functions.CreateUsableItem("foodchain-alcohol-item", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:FoodchainAlcohol", Source, Item.Item, Item.CustomType, Item.Slot, Item.Info)
    end
end)

FW.Functions.CreateUsableItem("foodchain-food-item", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:FoodchainFood", Source, Item.Item, Item.CustomType, Item.Slot, Item.Info)
    end
end)

FW.Functions.CreateUsableItem("foodchain-side-item", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:FoodchainSide", Source, Item.Item, Item.CustomType, Item.Slot, Item.Info)
    end
end)

FW.Functions.CreateUsableItem("foodchain-dessert-item", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:Client:FoodchainDessert", Source, Item.Item, Item.CustomType, Item.Slot, Item.Info)
    end
end)

FW.Functions.CreateUsableItem("water_bottle", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'water_bottle', 'water')
    end
end)

FW.Functions.CreateUsableItem("kurkakola", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'kurkakola', 'cola')
    end
end)

FW.Functions.CreateUsableItem("sprunk", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'sprunk', 'cola')
    end
end)

FW.Functions.CreateUsableItem("slushy", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink:slushy', Source)
    end
end)

FW.Functions.CreateUsableItem("sandwich", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'sandwich', 'sandwich')
    end
end)

FW.Functions.CreateUsableItem("worstenbroodje", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'worstenbroodje', 'sandwich')
    end
end)

FW.Functions.CreateUsableItem("frikandel", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'frikandel', 'sandwich')
    end
end)

FW.Functions.CreateUsableItem("bitterbal", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'bitterbal', 'sandwich')
    end
end)

FW.Functions.CreateUsableItem("chocolade", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'chocolade', 'chocolade')
    end
end)

FW.Functions.CreateUsableItem("420-choco", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, '420-choco', 'chocolade')
    end
end)

FW.Functions.CreateUsableItem("coffee", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'coffee', 'coffee')
    end
end)

FW.Functions.CreateUsableItem("chips", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'chips', 'chips')
    end
end)

FW.Functions.CreateUsableItem("jail-food", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'jail-food', 'sandwich')
    end
end)

FW.Functions.CreateUsableItem("macncheese", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:eat', Source, 'macncheese', 'macncheese')
    end
end)

FW.Functions.CreateUsableItem("fristi", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'fristi', 'water')
    end
end)

FW.Functions.CreateUsableItem("chocomelk", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'chocomelk', 'coffee')
    end
end)

FW.Functions.CreateUsableItem("fernandes", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:drink', Source, 'fernandes', 'cola')
    end
end)

FW.Functions.CreateUsableItem("mint", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:mint', Source, 'mint', 'painkiller')
    end
end)

-- // Other \\ --
FW.Functions.CreateUsableItem("armor", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:armor', Source, 'armor')
    end
end)

FW.Functions.CreateUsableItem("heavyarmor", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:armor', Source, 'heavyarmor')
    end
end)

FW.Functions.CreateUsableItem("tirekit", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:client:use:tirekit", Source)
    end
end)

FW.Functions.CreateUsableItem("repairkit", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:repairkit', Source, false)
    end
end)

FW.Functions.CreateUsableItem("big-repair", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:repairkit', Source, true)
    end
end)

FW.Functions.CreateUsableItem("bandage", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedHeal', Source, 'bandage')
    end
end)

FW.Functions.CreateUsableItem("ifak", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedHeal', Source, 'ifak')
    end
end)

-- FW.Functions.CreateUsableItem("health-pack", function(Source, Item)
-- 	local Player = FW.Functions.GetPlayer(Source)
-- 	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
--         TriggerClientEvent('fw-hospital:client:use:health-pack', Source)
--     end
-- end)

FW.Functions.CreateUsableItem("pakjesigaretten", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:pakjesigaretten', Source)
    end
end)

-- FW.Functions.CreateUsableItem("printer-pack-paper", function(Source, Item)
-- 	local Player = FW.Functions.GetPlayer(Source)
-- 	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
--         TriggerClientEvent('fw-items:client:use:pack:paper', Source)
--     end
-- end)

-- FW.Functions.CreateUsableItem("printer", function(Source, Item)
-- 	local Player = FW.Functions.GetPlayer(Source)
-- 	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
--         TriggerClientEvent('fw-printer:gebruiken', Source)
--     end
-- end)

FW.Functions.CreateUsableItem("welcome", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:welcome', Source)
    end
end)

FW.Functions.CreateUsableItem("car-polish", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-vehicle:client:clean:vehicle', Source)
    end
end)

FW.Functions.CreateUsableItem("carwax", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-businesses:Client:AutoCare:ApplyWax', Source)
    end
end)

FW.Functions.CreateUsableItem("sigaret", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:sigaret', Source)
    end
end)

FW.Functions.CreateUsableItem("oxy", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedOxy', Source)
    end
end)

FW.Functions.CreateUsableItem("adrenaline", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedAdrenaline', Source) 
    end
end)

FW.Functions.CreateUsableItem("ibuprofen", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedIbuprofen', Source) 
    end
end)

FW.Functions.CreateUsableItem("ketamine", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedKetamine', Source) 
    end
end)

FW.Functions.CreateUsableItem("melatonin", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedMelatonin', Source) 
    end
end)

FW.Functions.CreateUsableItem("morphine", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedMorphine', Source) 
    end
end)

FW.Functions.CreateUsableItem("painkillers", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-medical:Client:UsedPainkillers', Source) 
    end
end)

FW.Functions.CreateUsableItem("joint", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:joint', Source, Item, "default")
    end
end)

FW.Functions.CreateUsableItem("customjoint", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:joint', Source, Item, Item.CustomType)
    end
end)

FW.Functions.CreateUsableItem("narcose_syringe", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:narcose', Source)
    end
end)

FW.Functions.CreateUsableItem("herion_syringe", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:spuit', Source)
    end
end)

FW.Functions.CreateUsableItem("lsd-strip", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:client:use:lsd", Source)
    end
end)

FW.Functions.CreateUsableItem("coin", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:coinflip', Source)
    end
end)

-- Lighter
FW.Functions.CreateUsableItem("lighter", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:lighter', Source)
        if math.random(1, 100) <= 21 then
            Player.Functions.RemoveItem('lighter', 1)
            TriggerClientEvent('FW:Notify', Source, "Je aansteker brak sukkel..", "error", 3500)
        end
    end
end)

FW.Functions.CreateUsableItem("binoculars", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    TriggerClientEvent("fw-items:binoculars:toggle", Source)
end)

FW.Functions.CreateUsableItem("pdcamera", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    TriggerClientEvent("fw-items:camera:toggle", Source)
end)

FW.Functions.CreateUsableItem("explosive", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:Explosive', Source)
    end
end)

FW.Functions.CreateUsableItem("black-card", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:use:black-card', Source)
    end
end)

FW.Functions.CreateUsableItem("pickaxe", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-jobmanager:Client:Used:Pickaxe', Source)
    end
end)

FW.Functions.CreateUsableItem("teddy", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    TriggerClientEvent('fw-emotes:Client:PlayEmote', Source, "teddy")
end)

FW.Functions.CreateUsableItem("melissa-teddy", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:OpenBag', Source, 'melissa-teddy', "Teddy")
    end
end)

FW.Functions.CreateUsableItem("umbrella", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    TriggerClientEvent('fw-emotes:Client:PlayEmote', Source, "umbrella")
end)

FW.Functions.CreateUsableItem("heavy-thermite", function(Source, Item)
    TriggerClientEvent("fw-items:Clent:Used:HeavyThermite", Source)
end)

FW.Functions.CreateUsableItem("scuba-gear", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:put:scuba:on', Source, Item.Info.air)
    end
end)

FW.Functions.CreateUsableItem("nitrous", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-vehicles:client:use:nitrous', Source)
    end
end)

FW.Functions.CreateUsableItem("wheelchair", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:Wheelchair', Source)
    end
end)

FW.Functions.CreateUsableItem("scootmobile", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:Used:Scootmobile', Source)
    end
end)

FW.Functions.CreateUsableItem("walkstick", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:walkstick', Source)
    end
end)

FW.Functions.CreateUsableItem("jerry_can", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:client:jerry_can', Source)
    end
end)

FW.Functions.CreateUsableItem("moneybag", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        if Player.PlayerData.job.name ~= 'police' then
            if Player.Functions.RemoveItem('moneybag', 1, Item.Slot, true) then
                Player.Functions.AddMoney('cash', Item.Info.Worth)
            end
        end
    end
end)

function OnMoneycaseUse(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        if Item.Info.Worth then
            if Item.Info.Code then
                TriggerClientEvent('fw-Items:Client:OpenMoneyCase', Source, Item.Slot, Item.Item == 'advmoneycase')
            else
                if Player.Functions.RemoveItem('moneycase', 1, Item.Slot, true) then
                    Player.Functions.AddMoney('cash', Item.Info.Worth, 'Geld uit koffer getrokken')
                    TriggerEvent('fw-logs:Server:Log', 'moneycase', 'Money Case Emptied', ("User: [%s] - %s - %s \nData: ```json\n %s ```"):format(Player.PlayerData.Source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, json.encode({
                        Slot = Item.Slot,
                        Worth = Item.Info.Worth,
                        Code = 'Koffer heeft geen code.',
                    }, {indent = 2})), 'orange')
                else
                    Player.Functions.Notify("Waar is je koffer dan?", "error")
                end
            end
        else
            TriggerClientEvent('fw-Items:Client:SetMoneyCase', Source, Item.Slot, Item.Item == 'advmoneycase')
        end
    end
end
FW.Functions.CreateUsableItem("moneycase", OnMoneycaseUse)
FW.Functions.CreateUsableItem("advmoneycase", OnMoneycaseUse)

RegisterNetEvent("fw-items:Server:OpenMoneycase")
AddEventHandler("fw-items:Server:OpenMoneycase", function(Slot, IsAdv, Code)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemBySlot(Slot)
    local ItemName = IsAdv and 'advmoneycase' or 'moneycase'

    if Item == nil or Item.Item ~= ItemName then
        Player.Functions.Notify("Waar wil je het geld uit halen dan?", "error")
        return
    end

    if Item.Info.Code ~= Code then
        Player.Functions.Notify("De koffer doet niks..", "error")
        return
    end

    if Player.Functions.RemoveItem(ItemName, 1, Item.Slot, true) then
        Player.Functions.AddMoney('cash', Item.Info.Worth, 'Geld uit koffer getrokken met code ' .. Code)

        TriggerEvent('fw-logs:Server:Log', 'moneycase', 'Money Case Emptied', ("User: [%s] - %s - %s \nData: ```json\n %s ```"):format(Player.PlayerData.Source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, json.encode({
            Slot = Slot,
            Worth = Item.Info.Worth,
            Code = Code,
        }, {indent = 2})), 'red')
    else
        Player.Functions.Notify("Waar wil je het geld uit halen dan?", "error")
    end
end)

RegisterNetEvent("fw-items:Server:GiveMoneyCase")
AddEventHandler("fw-items:Server:GiveMoneyCase", function(Slot, IsAdv, Worth, Code)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemBySlot(Slot)
    local ItemName = IsAdv and 'advmoneycase' or 'moneycase'

    if Item == nil or Item.Item ~= ItemName then
        Player.Functions.Notify("Waar wil je het geld in stoppen dan?", "error")
        return
    end

    if Item.Info.Worth or Item.Info.Code then
        Player.Functions.Notify("Hier zit al geld in..", "error")
        return
    end

    if Player.Functions.RemoveMoney("cash", tonumber(Worth), "In geld koffer gestopt") then
        Player.Functions.SetItemKV(ItemName, Slot, "worth", tonumber(Worth))
        Player.Functions.SetItemKV(ItemName, Slot, "code", Code ~= "" and Code or false)
        Player.Functions.Notify("Je hebt het geld in de koffer geduwd..", "success")
    
        TriggerEvent('fw-logs:Server:Log', 'moneycase', 'Money Case Filled', ("User: [%s] - %s - %s \nData: ```json\n %s ```"):format(Player.PlayerData.Source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, json.encode({
            Slot = Slot,
            Worth = Worth,
            Code = Code,
        }, {indent = 2})), 'green')
    end
end)

FW.Functions.CreateUsableItem("rentalpapers", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-vehicles:Client:ReceiveRentalKeys', Source, Item.Info.Plate)
    end
end)

FW.Functions.CreateUsableItem("parachute", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:client:use:parachute", Source)
    end
end)

FW.Functions.CreateUsableItem("handcuffs", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-police:Client:Cuff", Source, false)
    end
end)

FW.Functions.CreateUsableItem("hairtie", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent("fw-items:client:use:hairtie", Source)
    end
end)

FW.Functions.CreateUsableItem("id_card", function(Source, Item)
    for k, v in pairs(FW.Functions.GetPlayers()) do
		local PlayerPed = GetPlayerPed(Source)
		local TargetPed = GetPlayerPed(v)
		local dist = #(GetEntityCoords(PlayerPed) - GetEntityCoords(TargetPed))
		if dist < 3.0 then
			local gender = "Man"
			if Item.Info.gender == 1 then
				gender = "Vrouw"
			end
			TriggerClientEvent('chat:addMessage', v,  {
					template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>BSN:</strong> {1} <br><strong>Voornaam:</strong> {2} <br><strong>Achternaam:</strong> {3} <br><strong>Geboortedag:</strong> {4} <br><strong>Geslacht:</strong> {5} <br><strong>Nationaliteit:</strong> {6}</div></div>',
					args = {
						"Identiteitskaart",
						Item.Info.citizenid,
						Item.Info.firstname,
						Item.Info.lastname,
						Item.Info.birthdate,
						Item.Info.gender == 0 and "Man" or "Vrouw",
						Item.Info.nationality
					}
				}
			)
		end
	end
end)

FW.Functions.CreateUsableItem("driver_license", function(Source, Item)
    for k, v in pairs(FW.Functions.GetPlayers()) do
		local PlayerPed = GetPlayerPed(Source)
		local TargetPed = GetPlayerPed(v)
		local dist = #(GetEntityCoords(PlayerPed) - GetEntityCoords(TargetPed))
		if dist < 3.0 then
			TriggerClientEvent('chat:addMessage', v,  {
					template = '<div class="chat-message advert"><div class="chat-message-body"><strong>{0}:</strong><br><br> <strong>BSN:</strong> {1} <br><strong>Voornaam:</strong> {2} <br><strong>Achternaam:</strong> {3} <br><strong>Geboortedag:</strong> {4} <br><strong>Rijbewijzen:</strong> {5}</div></div>',
					args = {
						"Rijbewijs",
						Item.Info.citizenid,
						Item.Info.firstname,
						Item.Info.lastname,
						Item.Info.birthdate,
						Item.Info.type
					}
				}
			)
		end
	end
end)

FW.Commands.Add("dobbel", "Lekker dobbelen", {{name="aantal", help="Aantal dobbelsteentjes"}, {name="zijdes", help="Aantal zijdes van dobbelsteentje"}}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    local DiceItems = Player.Functions.GetItemByName("dice")
    if Args[1] ~= nil and Args[2] ~= nil then 
        local Amount = tonumber(Args[1])
        local Sides = tonumber(Args[2])
        if DiceItems ~= nil then
            if (Sides > 0 and Sides <= 20) and (Amount > 0 and Amount <= 5) then 
                TriggerClientEvent('fw-items:client:dobbel', Source, Amount, Sides)
            else
                TriggerClientEvent('FW:Notify', Source, "Teveel aantal kanten of 0 (max: 5) of teveel aantal dobbelstenen of 0 (max: 20)", "error", 3500)
            end
        else
            TriggerClientEvent('FW:Notify', Source, "Je hebt geen eens dobbelstenen..", "error", 3500)
        end
    end
end)

FW.Functions.CreateUsableItem("goldbanana", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-misc:Client:TransformMonkey', Source)
    end
end)

FW.Commands.Add("duikpakuit", "Doe je duikpak uit", {}, false, function(Source, args)
    TriggerClientEvent('fw-items:client:takeoff:scuba', Source)
end)

RegisterServerEvent('fw-items:Server:ReturnWheelchair')
AddEventHandler('fw-items:Server:ReturnWheelchair', function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    Player.Functions.AddItem('wheelchair', 1, false, false, true)
end)

RegisterServerEvent('fw-items:Server:ReturnScootmobile')
AddEventHandler('fw-items:Server:ReturnScootmobile', function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    Player.Functions.AddItem('scootmobile', 1, false, false, true)
end)

RegisterServerEvent('fw-items:server:add:addiction:weed')
AddEventHandler('fw-items:server:add:addiction:weed', function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    local RandomValue = math.random(1, 100)
    if RandomValue == 25 or RandomValue == 20 or RandomValue == 50 or RandomValue == 70 or RandomValue == 75 or RandomValue == 80 or RandomValue == 100 then
        Player.Functions.AddAddiction('weed', 1)
    end
end)

RegisterNetEvent('fw-items:server:use:narcose', function(PlayerId)
TriggerClientEvent('fw-items:client:use:narcose:effect', PlayerId)
end)

RegisterNetEvent('fw-items:server:use:spuit', function(PlayerId)
    TriggerClientEvent('fw-items:client:use:spuit:effect', PlayerId)
end)


RegisterNetEvent('fw-items:server:sync:item:anchor')
AddEventHandler('fw-items:server:sync:item:anchor', function(Plate, Toggle) 
    Config.AnchorVehicles[Plate] = Toggle
    TriggerClientEvent('fw-items:client:sync:item:anchor', -1, Plate, Toggle, Config.AnchorVehicles)
end)

RegisterNetEvent("fw-items:Server:WelcomeReward")
AddEventHandler("fw-items:Server:WelcomeReward", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Items = { "driver_license", "sandwich", "water_bottle", "fishingrod", "lockpick" }
    for k, v in pairs(Items) do
        Player.Functions.AddItem(v, 1, false, nil, true, false)
    end
end)

FW.Functions.CreateCallback('fw-items:server:sync:anchor:config', function(Source, cb)
    cb(Config.AnchorVehicles)
end)

FW.Functions.CreateCallback('fw-items:Server:RemoveUsesJoint', function(Source, Cb, Item, Type, Slot, NewUses)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(Player.Functions.SetItemKV(Item, Slot, 'Uses', NewUses, Type))
end)

FW.Functions.CreateUsableItem("business-bag", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-items:Client:OpenBag', Source, Item.Info.BagId, Item.CustomType)
    end
end)

FW.Functions.CreateUsableItem("detcord", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-doors:Client:Used:Detcord', Source)
    end
end)

FW.Functions.CreateUsableItem("ingredient", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil and Item.CustomType == 'Honey' then
        TriggerClientEvent("fw-items:Client:FoodchainFood", Source, Item.Item, Item.CustomType, Item.Slot, Item.Info)
    end
end)

FW.RegisterServer("fw-items:Server:Receive:Scuba", function(Source, AirValue)
    local Player = FW.Functions.GetPlayer(Source)
    Player.Functions.AddItem('scuba-gear', 1, false, {air =  AirValue}, true, false)
end)