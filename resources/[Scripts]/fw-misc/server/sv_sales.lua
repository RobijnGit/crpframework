FW.Functions.CreateCallback("fw-misc:Server:GetMaterialsSell", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Retval = { Total = 0, Items = {} }
    local Result = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    for k, v in pairs(Result) do
        if IsThisAMaterial(v.item_name) then
            local Quality = exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate)
            if Quality > 0 then
                if Retval.Items[v.item_name] == nil then Retval.Items[v.item_name] = 0 end
                Retval.Items[v.item_name] = Retval.Items[v.item_name] + 1
                Retval.Total = Retval.Total + 1
            end
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-misc:Server:GetIngredientsSell", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Retval = { Total = 0, Items = {} }
    local Result = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    for k, v in pairs(Result) do
        if IsThisAIngredient(v.item_name, v.custom_type) then
            local Quality = exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate)
            if Quality > 0 then
                if Retval.Items[v.custom_type] == nil then Retval.Items[v.custom_type] = 0 end
                Retval.Items[v.custom_type] = Retval.Items[v.custom_type] + 1
                Retval.Total = Retval.Total + 1
            end
        end
    end

    Cb(Retval)
end)

RegisterNetEvent("fw-misc:Server:SellMaterials")
AddEventHandler("fw-misc:Server:SellMaterials", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if FW.Throttled("sell-materials-" .. Player.PlayerData.citizenid, 5000) then
        return Player.Functions.Notify("Niet zo snel jij.. Ik moet het nog tellen!", "error")
    end

    local TotalReceive, ItemsSold = 0, {}
    local Result = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    for k, v in pairs(Result) do
        if IsThisAMaterial(v.item_name) then
            local Quality = exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate)
            if Quality > 0 then
                ItemsSold[v.item_name] = (ItemsSold[v.item_name] or 0) + 1
                TotalReceive = TotalReceive + 4
            end
        end
    end

    if TotalReceive > 0 then
        for Item, Amount in pairs(ItemsSold) do
            -- TriggerClientEvent('fw-inventory:Client:ShowActionBox', Source, 'Verkocht', Item, Amount, '')
            if not Player.Functions.RemoveItem(Item, Amount, false, false) then
                TotalReceive = TotalReceive - (4 * Amount)
            end
        end

        if TotalReceive > 0 then
            Player.Functions.AddMoney("cash", TotalReceive, "Sells materials")
        end
    end
end)
RegisterNetEvent("fw-misc:Server:SellIngredients")
AddEventHandler("fw-misc:Server:SellIngredients", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if FW.Throttled("sell-ingredients-" .. Player.PlayerData.citizenid, 5000) then
        return Player.Functions.Notify("Niet zo snel jij.. Ik moet het nog tellen!", "error")
    end

    local TotalReceive, ItemsSold = 0, {}
    local Result = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    for k, v in pairs(Result) do
        if IsThisAIngredient(v.item_name, v.custom_type) then
            local Quality = exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate)
            if Quality > 0 then
                ItemsSold[v.custom_type] = (ItemsSold[v.custom_type] or 0) + 1
                TotalReceive = TotalReceive + 12
            end
        end
    end

    if TotalReceive > 0 then
        for CustomType, Amount in pairs(ItemsSold) do
            -- TriggerClientEvent('fw-inventory:Client:ShowActionBox', Source, 'Verkocht', 'ingredient', Amount, CustomType)
            if not Player.Functions.RemoveItem('ingredient', Amount, false, false, CustomType) then
                TotalReceive = TotalReceive - (12 * Amount)
            end
        end

        if TotalReceive > 0 then
            Player.Functions.AddMoney("cash", TotalReceive, "Sells Ingredients")
        end
    end
end)

function IsThisAMaterial(ItemName)
    local Materials = { "plastic", "metalscrap", "copper", "aluminum", "steel", "rubber", "glass", "electronics" }

    for k, v in pairs(Materials) do
        if v == ItemName then
            return true
        end
    end

    return false
end

function IsThisAIngredient(ItemName, CustomType)
    if ItemName ~= 'ingredient' then return end
    local Ingredients = { "Cabbage", "Carrot", "Corn", "Cucumber", "Garlic", "Onion", "Potato", "Pumpkin", "Radish", "RedBeet", "Sunflower", "Tomato", "Watermelon", "Wheat" }

    for k, v in pairs(Ingredients) do
        if v == CustomType then
            return true
        end
    end

    return false
end