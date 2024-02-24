RegisterNetEvent("fw-items:Client:FoodchainDrink")
AddEventHandler("fw-items:Client:FoodchainDrink", function(ItemName, ItemType, ItemSlot, ItemInfo)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    exports['fw-inventory']:SetBusyState(true)

    local PropName = "water"
    if Config.FoodchainProps[ItemType] then PropName = Config.FoodchainProps[ItemType] end

    exports['fw-assets']:AddProp(PropName)

    local Finished = FW.Functions.CompactProgressbar(6000, "Drinken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_drinking@coffee@male@idle_a", anim = "idle_c", flags = 49 }, {}, {}, false)
    exports['fw-assets']:RemoveProp()
    exports['fw-inventory']:SetBusyState(false)

    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", ItemName, 1, ItemSlot, ItemType)
        if not DidRemove then return end

        if ItemInfo.Buff and ItemInfo.BuffPercentage > 0 and math.random() > 0.15 then
            FW.TriggerServer("fw-hud:Server:ApplyBuff", ItemInfo.Buff, ItemInfo.BuffPercentage)
        end

        TriggerServerEvent("FW:Server:SetMetaData", "thirst", FW.Functions.GetPlayerData().metadata.thirst + math.random(30, 60))
    end
end)

RegisterNetEvent("fw-items:Client:FoodchainAlcohol")
AddEventHandler("fw-items:Client:FoodchainAlcohol", function(ItemName, ItemType, ItemSlot, ItemInfo)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    exports['fw-inventory']:SetBusyState(true)

    local PropName = "cocktail"
    if Config.FoodchainProps[ItemType] then PropName = Config.FoodchainProps[ItemType] end

    exports['fw-assets']:AddProp(PropName)

    local Finished = FW.Functions.CompactProgressbar(6000, "Drinken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_drinking@coffee@male@idle_a", anim = "idle_c", flags = 49 }, {}, {}, false)
    exports['fw-assets']:RemoveProp()
    exports['fw-inventory']:SetBusyState(false)

    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", ItemName, 1, ItemSlot, ItemType)
        if not DidRemove then return end

        if ItemInfo.Buff and ItemInfo.BuffPercentage > 0 and math.random() > 0.15 then
            FW.TriggerServer("fw-hud:Server:ApplyBuff", ItemInfo.Buff, ItemInfo.BuffPercentage)
        end

        TriggerServerEvent("FW:Server:SetMetaData", "thirst", FW.Functions.GetPlayerData().metadata.thirst + math.random(30, 60))
    end
end)

RegisterNetEvent("fw-items:Client:FoodchainFood")
AddEventHandler("fw-items:Client:FoodchainFood", function(ItemName, ItemType, ItemSlot, ItemInfo)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    exports['fw-inventory']:SetBusyState(true)

    local PropName = "sandwich"
    if Config.FoodchainProps[ItemType] then PropName = Config.FoodchainProps[ItemType] end

    exports['fw-assets']:AddProp(PropName)

    local Finished = FW.Functions.CompactProgressbar(6000, "Eten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flags = 49 }, {}, {}, false)
    exports['fw-assets']:RemoveProp()
    exports['fw-inventory']:SetBusyState(false)

    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", ItemName, 1, ItemSlot, ItemType)
        if not DidRemove then return end

        if ItemInfo.Buff and ItemInfo.BuffPercentage > 0 and math.random() > 0.15 then
            FW.TriggerServer("fw-hud:Server:ApplyBuff", ItemInfo.Buff, ItemInfo.BuffPercentage)
        end

        TriggerServerEvent("FW:Server:SetMetaData", "hunger", FW.Functions.GetPlayerData().metadata.hunger + math.random(30, 60))
    end
end)

RegisterNetEvent("fw-items:Client:FoodchainSide")
AddEventHandler("fw-items:Client:FoodchainSide", function(ItemName, ItemType, ItemSlot, ItemInfo)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    exports['fw-inventory']:SetBusyState(true)

    local PropName = "taco"
    if Config.FoodchainProps[ItemType] then PropName = Config.FoodchainProps[ItemType] end

    exports['fw-assets']:AddProp(PropName)

    local Finished = FW.Functions.CompactProgressbar(6000, "Eten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flags = 49 }, {}, {}, false)
    exports['fw-assets']:RemoveProp()
    exports['fw-inventory']:SetBusyState(false)

    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", ItemName, 1, ItemSlot, ItemType)
        if not DidRemove then return end

        if ItemInfo.Buff and ItemInfo.BuffPercentage > 0 and math.random() > 0.15 then
            FW.TriggerServer("fw-hud:Server:ApplyBuff", ItemInfo.Buff, ItemInfo.BuffPercentage)
        end

        TriggerServerEvent("FW:Server:SetMetaData", "hunger", FW.Functions.GetPlayerData().metadata.hunger + math.random(20, 40))
    end
end)

RegisterNetEvent("fw-items:Client:FoodchainDessert")
AddEventHandler("fw-items:Client:FoodchainDessert", function(ItemName, ItemType, ItemSlot, ItemInfo)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    exports['fw-inventory']:SetBusyState(true)

    local PropName = "donut"
    if Config.FoodchainProps[ItemType] then PropName = Config.FoodchainProps[ItemType] end

    exports['fw-assets']:AddProp(PropName)

    local Finished = FW.Functions.CompactProgressbar(6000, "Eten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flags = 49 }, {}, {}, false)
    exports['fw-assets']:RemoveProp()
    exports['fw-inventory']:SetBusyState(false)

    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", ItemName, 1, ItemSlot, ItemType)
        if not DidRemove then return end

        if ItemInfo.Buff and ItemInfo.BuffPercentage > 0 and math.random() > 0.15 then
            FW.TriggerServer("fw-hud:Server:ApplyBuff", ItemInfo.Buff, ItemInfo.BuffPercentage)
        end

        TriggerServerEvent("FW:Server:SetMetaData", "hunger", FW.Functions.GetPlayerData().metadata.hunger + math.random(15, 25))
    end
end)

RegisterNetEvent("fw-items:Client:DrinkAlcohol")
AddEventHandler("fw-items:Client:DrinkAlcohol", function(Item)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    exports['fw-inventory']:SetBusyState(true)

    local PropName = "cocktail"
    if Config.FoodchainProps[Item.Item] then PropName = Config.FoodchainProps[Item.Item] end

    exports['fw-assets']:AddProp(PropName)

    local Finished = FW.Functions.CompactProgressbar(6000, "Drinken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_drinking@coffee@male@idle_a", anim = "idle_c", flags = 49 }, {}, {}, false)
    exports['fw-assets']:RemoveProp()
    exports['fw-inventory']:SetBusyState(false)

    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", Item.Item, 1, false)
        if not DidRemove then return end
        TriggerServerEvent("FW:Server:SetMetaData", "thirst", FW.Functions.GetPlayerData().metadata.thirst + math.random(20, 35))
        DrinkEffect()
    end
end)