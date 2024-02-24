-- // General Functions \\ --
function CalculateQuality(ItemName, CreateDate)
    local TimeAllowed = 1000 * 60 * 40320 -- 28 days
    local DecayRate = Shared.Items[ItemName].DecayRate
    local TimeExtra = TimeAllowed * DecayRate
    local Quality = 100 - math.ceil((((os.time() * 1000) - CreateDate) / TimeExtra) * 100)

    if DecayRate == 0 then Quality = 100 end
    if Quality < 0 then Quality = 0 end

    return Quality
end
exports("CalculateQuality", CalculateQuality)

function GetItemData(ItemName, CustomType)
    if CustomType and CustomType:len() > 0 then
        local Retval = DeepCopyTable(Shared.Items[ItemName])
        local TypeData = Shared.CustomTypes[ItemName][CustomType]

        if TypeData.Label then Retval.Label = TypeData.Label end
        if TypeData.Image then Retval.Image = TypeData.Image end
        if TypeData.Description then Retval.Description = TypeData.Description end
        if TypeData.IsExternImage then Retval.IsExternImage = TypeData.IsExternImage end
        if TypeData.Price then Retval.Price = TypeData.Price end
        if TypeData.Cract then Retval.Cract = TypeData.Cract end

        return Retval
    else
        return Shared.Items[ItemName]
    end
end
exports("GetItemData", GetItemData)

function GenerateItemInfo(InvName, Item, CustomType)
    local Info = {}

    local SerialPrefix = string.startsWith(InvName, 'ply-') and InvName:sub(5) or FW.Shared.RandomInt(4)
    if string.startsWith(Item, 'weapon_') then
        Info = {
            Serial = SerialPrefix .. '-' .. FW.Shared.RandomStr(4) .. '-' .. FW.Shared.RandomInt(3),
            Ammo = 0
        }
    elseif Item == 'business-bag' then
        Info = {
            BagId = 'bag-' .. os.time() .. FW.Shared.RandomInt(6)
        }
    elseif Item == 'farming-seedbag' then
        Info = {
            BagId = 'seed-bag-' .. os.time() .. FW.Shared.RandomInt(6)
        }
    elseif Item == 'producebasket' then
        Info = {
            BagId = 'produce-basket-' .. os.time() .. FW.Shared.RandomInt(6)
        }
    elseif Item == 'id_card' then
        local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if not Player then return {} end

        Info = {
            citizenid = Player.PlayerData.citizenid,
            firstname = Player.PlayerData.charinfo.firstname,
            lastname = Player.PlayerData.charinfo.lastname,
            birthdate = Player.PlayerData.charinfo.birthdate,
            gender = Player.PlayerData.charinfo.gender,
            nationality = Player.PlayerData.charinfo.nationality,
        }
    elseif Item == 'driver_license' then
        local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if not Player then return {} end

        Info = {
            citizenid = Player.PlayerData.citizenid,
            firstname = Player.PlayerData.charinfo.firstname,
            lastname = Player.PlayerData.charinfo.lastname,
            birthdate = Player.PlayerData.charinfo.birthdate,
            type = "A1-A2-A | AM-B | C1-C-CE",
        }
    elseif Item == 'scuba-gear' then
        Info = {
            air = 100
        }
    elseif Item == 'crackpipe' then
        Info = { Uses = 0 }
    elseif Item == 'methpipe' then
        Info = { Uses = 0, _Purities = {} }
    elseif Item == 'methcured' then
        Info = { _Purity = 100 }
    elseif Item == '1gmeth' then
        Info = { Purity = math.random(1, 100) }
    elseif Item == 'burnerphone' then
        Info = { PhoneNumber = FW.Player.CreatePhoneNumber(true) }
    elseif Item == 'customjoint' and CustomType == 'insideout' then
        Info = { Uses = 1 }
    elseif Item == 'customjoint' and CustomType == 'cone' then
        Info = { Uses = 2 }
    elseif Item == 'customjoint' and CustomType == 'splitter' then
        Info = { Uses = 2 }
    elseif Item == 'customjoint' and CustomType == 'cross' then
        Info = { Uses = 3 }
    elseif Item == 'customjoint' and CustomType == 'tulp' then
        Info = { Uses = 4 }
    elseif Item == 'customjoint' and CustomType == 'windmill' then
        Info = { Uses = 5 }
    elseif Item == 'notepad' then
        Info = { _Uses = 10 }
    end

    return Info
end
exports("GenerateItemInfo", GenerateItemInfo)

function GetTotalItemsWeight(InvName)
    if string.startsWith(InvName, 'ply-') then
        local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if not Player then return 0.0 end

        local TotalWeight = 0.0
        for k, v in pairs(Player.PlayerData.inventory) do
            if v then
                if v.CustomType and Shared.CustomTypes[v.Item] and Shared.CustomTypes[v.Item][v.CustomType] and Shared.CustomTypes[v.Item][v.CustomType].Weight then
                    TotalWeight = TotalWeight + (Shared.CustomTypes[v.Item][v.CustomType].Weight * v.Amount)
                else
                    TotalWeight = TotalWeight + (Shared.Items[v.Item].Weight * v.Amount)
                end
            end
        end

        return TotalWeight
    end
    return 0.0
end
exports("GetTotalItemsWeight", GetTotalItemsWeight)

function FindSlot(InvName, Item, CustomType, MatchItem)
    local Items = {}

    if string.startsWith(InvName, 'ply-') then
        local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if not Player then return false end
        Items = Player.PlayerData.inventory
    else
        Items = GetInventoryItems(InvName)
    end

    for i = 1, Config.MaxPlayerSlots, 1 do
        local SlotData = Items[i]
        if (not MatchItem and SlotData == nil) or (SlotData ~= nil and SlotData.Item == Item and SlotData.CustomType == CustomType and (MatchItem or not Shared.Items[SlotData.Item].NonStack)) then
            return i
        end
    end
end
exports("FindSlot", FindSlot)

-- // Getters \\ --
function GetInventoryItems(InvName)
    local Promise = promise:new()

    exports['ghmattimysql']:execute("SELECT count(item_name) as amount, item_name, custom_type, id, info, slot, MIN(createdate) as createdate FROM `player_inventories` WHERE `inventory` = @InvName group by slot", {
        ['@InvName'] = InvName
    }, function(Result)
        local Retval = {[0] = false}
        for k, v in pairs(Result) do
            local ItemData = Shared.Items[v.item_name]
            Retval[tonumber(v.slot)] = {
                Item = v.item_name,
                CustomType = v.custom_type,
                Amount = tonumber(v.amount),
                Info = json.decode(v.info),
                CreateDate = tonumber(v.createdate),
                Slot = tonumber(v.slot),
            }
        end

        Promise:resolve(Retval)
    end)

    return Citizen.Await(Promise)
end
exports("GetInventoryItems", GetInventoryItems)

function GetInventoryItemsUnproccessed(InvName)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_inventories` WHERE `inventory` = @InvName", {
        ['@InvName'] = InvName
    })

    return Result
end
exports("GetInventoryItemsUnproccessed", GetInventoryItemsUnproccessed)

function GetInventoryItemBySlot(InvName, Slot)
    local Result = exports['ghmattimysql']:executeSync("SELECT count(item_name) as amount, item_name, custom_type, id, info, slot, MIN(createdate) as createdate FROM `player_inventories` WHERE `inventory` = @InvName AND `slot` = @Slot", {
        ['@InvName'] = InvName,
        ['@Slot'] = Slot
    })

    if Result[1] == nil or Result[1].item_name == nil then
        return nil
    end

    local ItemData = Shared.Items[Result[1].item_name]
    return {
        Item = Result[1].item_name,
        CustomType = Result[1].custom_type,
        Amount = tonumber(Result[1].amount),
        Info = json.decode(Result[1].info),
        CreateDate = tonumber(Result[1].createdate),
        Slot = tonumber(Result[1].slot),
    }
end
exports("GetInventoryItemBySlot", GetInventoryItemBySlot)

-- // Setters \\ --
function SetInventoryItemKV(InvName, Item, Slot, Key, Value)
    if not Shared.Items[Item] then return end
    if not Slot then return end

    if not string.startsWith(InvName, 'ply-') then
        print("^1[INVENTORY/SetInventoryItemKV]: NOT COMPATIBLE WITH NON-PLAYER INVENTORIES!")
        return false
    end

    local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
    if not Player then return false end

    local ItemData = Player.PlayerData.inventory[Slot]
    if not ItemData then return false end

    ItemData.Info[Key] = Value
    local Result = exports['ghmattimysql']:executeSync("UPDATE player_inventories SET info = @Info WHERE `inventory` = @Inv AND `item_name` = @Item AND `slot` = @Slot LIMIT 1", {
        ['@Info'] = json.encode(ItemData.Info),
        ['@Inv'] = InvName,
        ['@Item'] = Item,
        ['@Slot'] = Slot,
    })

    return Result.affectedRows > 0
end
exports("SetInventoryItemKV", SetInventoryItemKV)

function SetInventoryItemMultipleKV(InvName, Item, Slot, Data)
    for k, v in pairs(Data) do
        local IsDone = SetInventoryItemKV(InvName, Item, Slot, k, v)
        Citizen.Wait(100) -- Wait a little bit, else it might overwrite old data.
    end

    return true
end
exports("SetInventoryItemMultipleKV", SetInventoryItemMultipleKV)

-- // Add Items \\ --
function AddItemToInventory(InvName, Item, Amount, Slot, Info, CustomType)
    if Shared.Items[Item] == nil then return end
    if CustomType and #CustomType > 0 and (Shared.CustomTypes[Item] == nil or Shared.CustomTypes[Item][CustomType] == nil) then return end
    if not CustomType then CustomType = "" end
    if not Amount or Amount <= 0 then Amount = 1 end
    if not Slot then Slot = FindSlot(InvName, Item, CustomType) end
    if not Info then Info = GenerateItemInfo(InvName, Item, CustomType) end

    if not Slot then return end

    local TotalWeight = GetTotalItemsWeight(InvName)
    if string.startsWith(InvName, 'ply-') and TotalWeight + (Shared.Items[Item].Weight * Amount) > Config.MaxPlayerWeight then
        
        local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if Player then
            local ClosestDropId, ClosestDrop = false, false
            local PlyCoords = GetEntityCoords(GetPlayerPed(Player.PlayerData.source))
            for k, v in pairs(Config.Drops) do
                if not ClosestDropId then
                    ClosestDropId, ClosestDrop = k, #(v.Coords - PlyCoords)
                end
                
                if #(v.Coords - PlyCoords) < ClosestDrop then
                    ClosestDropId, ClosestDrop = k, #(v.Coords - PlyCoords)
                end
            end
            
            if not ClosestDropId or ClosestDrop > 1.5 then
                ClosestDropId = #Config.Drops + 1
                CreateNewDrop(ClosestDropId, PlyCoords)
            end

            InvName = 'Drop-' .. ClosestDropId
            Slot = FindSlot(InvName, Item, CustomType, MatchItem)
            if not Slot then
                return false
            end

            Config.Drops[ClosestDropId].ItemCount = Config.Drops[ClosestDropId].ItemCount + 1
            TriggerClientEvent("fw-inventory:Client:SetDropItemCount", -1, tonumber(InvName:sub(6)), Config.Drops[tonumber(InvName:sub(6))].ItemCount)

            Player.Functions.Notify("Items zijn op de grond gevallen..", "error")
        else
            return false
        end
    end

    local Items = "(@Inventory, @Item, @CustomType, @Slot, @Info, @CreateDate)"
    if Amount > 1 then
        for i = 2, Amount, 1 do
            Items = Items .. ', (@Inventory, @Item, @CustomType, @Slot, @Info, @CreateDate)'
        end
    end

    local Result = exports['ghmattimysql']:executeSync('INSERT INTO player_inventories (inventory, item_name, custom_type, slot, info, createdate) VALUES ' .. Items, {
        ['@Inventory'] = InvName,
        ['@Item'] = Item,
        ['@CustomType'] = CustomType,
        ['@Amount'] = Amount,
        ['@Slot'] = Slot,
        ['@Info'] = json.encode(Info),
        ['@CreateDate'] = os.time() * 1000,
    })

    if string.startsWith(InvName, 'ply-') then
        local Player = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if not Player then return Result.affectedRows > 0 end

        Player.Functions.RefreshInvSlot(Slot)
        TriggerClientEvent("fw-inventory:Client:UpdateInvSlot", Player.PlayerData.source, Slot)

        if Shared.Items[Item].HasProp then
            TriggerClientEvent("fw-assets:Client:Attach:Items", Player.PlayerData.source)
        end
    end

    return Result.affectedRows > 0
end
exports("AddItemToInventory", AddItemToInventory)

-- // Remove Items \\ --
function RemoveItemFromInventory(InvName, Item, Amount, Slot, CustomType)
    if not Shared.Items[Item] then return end
    if CustomType and #CustomType > 0 and (Shared.CustomTypes[Item] == nil or Shared.CustomTypes[Item][CustomType] == nil) then return end
    if not CustomType then CustomType = "" end
    if not Amount or Amount <= 0 then Amount = 1 end
    if not Slot then Slot = FindSlot(InvName, Item, CustomType, true) end
    if not Slot then return end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM player_inventories WHERE inventory = @Inventory AND item_name = @Item AND custom_type = @CustomType AND slot = @Slot LIMIT " .. Amount, {
        ['@Inventory'] = InvName,
        ['@Item'] = Item,
        ['@CustomType'] = CustomType,
        ['@Slot'] = Slot,
    })

    if string.startsWith(InvName, 'ply-') then
        local Target = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if Target then
            Target.Functions.RefreshInvSlot(Slot)

            if Shared.Items[Item].HasProp then
                TriggerClientEvent("fw-assets:Client:Attach:Items", Target.PlayerData.source)
            end
        end
    end

    return Result.affectedRows > 0
end
exports("RemoveItemFromInventory", RemoveItemFromInventory)

function RemoveItemFromInventoryByName(InvName, Item, Amount, CustomType)
    if not CustomType then CustomType = "" end
    if not Amount then Amount = 1 end

    local Slots = {}
    if string.startsWith(InvName, 'ply-') then
        Slots = exports['ghmattimysql']:executeSync("SELECT `slot` FROM player_inventories WHERE inventory = @Inventory AND item_name = @Item AND custom_type = @CustomType GROUP BY `slot` LIMIT " .. Amount, {
            ['@Inventory'] = InvName,
            ['@Item'] = Item,
            ['@CustomType'] = CustomType,
        })
    end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM player_inventories WHERE inventory = @Inventory AND item_name = @Item AND custom_type = @CustomType LIMIT " .. Amount, {
        ['@Inventory'] = InvName,
        ['@Item'] = Item,
        ['@CustomType'] = CustomType,
    })

    if string.startsWith(InvName, 'ply-') then
        local Target = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if Target then
            if Shared.Items[Item].HasProp then
                TriggerClientEvent("fw-assets:Client:Attach:Items", Target.PlayerData.source)
            end
        end
    end

    return Result.affectedRows > 0, Slots
end
exports("RemoveItemFromInventoryByName", RemoveItemFromInventoryByName)

function RemoveItemFromInventoryByKV(InvName, Item, Amount, Value, CustomType)
    if not Shared.Items[Item] then return end
    if CustomType and #CustomType > 0 and (Shared.CustomTypes[Item] == nil or Shared.CustomTypes[Item][CustomType] == nil) then return end
    if not CustomType then CustomType = "" end
    if not Amount or Amount <= 0 then Amount = 1 end
    if not Slot then Slot = FindSlot(InvName, Item, CustomType, true) end
    if not Slot then return end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM player_inventories WHERE inventory = @Inventory AND item_name = @Item AND custom_type = @CustomType AND info LIKE @Value LIMIT " .. Amount, {
        ['@Inventory'] = InvName,
        ['@Item'] = Item,
        ['@CustomType'] = CustomType,
        ['@Value'] = "%" .. Value .. "%",
    })

    if string.startsWith(InvName, 'ply-') then
        local Target = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if Shared.Items[Item].HasProp then
            TriggerClientEvent("fw-assets:Client:Attach:Items", Target.PlayerData.source)
        end
    end

    return Result.affectedRows > 0
end
exports("RemoveItemFromInventoryByKV", RemoveItemFromInventoryByKV)

-- // Item Decay \\ --
function DecayItemFromInventory(InvName, Item, Percentage, Slot)
    if not InvName then return end
    if not Item then return end
    if not Slot then Slot = FindSlot(InvName, Item, '', true) end
    if not Slot then return end

    if Shared.Items[Item].DecayRate <= 0.0 then return end

    local SlotData = nil
    if string.startsWith(InvName, 'ply-') then
        local Target = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if Target then
            SlotData = Target.PlayerData.inventory[Slot]
        end
    end

    if not SlotData then SlotData = GetInventoryItemBySlot(InvName, Slot) end
    
    local MaxTime = (((1000 * 60) * 60) * 24) * 28
    local OnePercent = MaxTime * (Shared.Items[Item].DecayRate / 100 * 1);
    local Result = exports['ghmattimysql']:executeSync("UPDATE player_inventories SET createdate = createdate - @CreateDate WHERE `inventory` = @Inv AND `item_name` = @Item AND `slot` = @Slot LIMIT 1", {
        ['@Inv'] = InvName,
        ['@Item'] = Item,
        ['@Slot'] = Slot,
        ['@CreateDate'] = (OnePercent * Percentage),
    })
    
    if not SlotData then return end
    return (SlotData.CreateDate - (OnePercent * Percentage))
end
exports("DecayItemFromInventory", DecayItemFromInventory)

function IncreaseQualityItemFromInventory(InvName, Item, Percentage, Slot)
    if not InvName then return end
    if not Item then return end
    if not Slot then Slot = FindSlot(InvName, Item, CustomType, true) end
    if not Slot then return end

    if Shared.Items[Item].DecayRate <= 0.0 then return end

    local SlotData = nil
    if string.startsWith(InvName, 'ply-') then
        local Target = FW.Functions.GetPlayerByCitizenId(InvName:sub(5))
        if Target then
            SlotData = Target.PlayerData.inventory[Slot]
        end
    end

    if not SlotData then SlotData = GetInventoryItemBySlot(InvName, Slot) end
    
    local MaxTime = (((1000 * 60) * 60) * 24) * 28
    local OnePercent = MaxTime * (Shared.Items[Item].DecayRate / 100 * 1);
    local Result = exports['ghmattimysql']:executeSync("UPDATE player_inventories SET createdate = createdate + @CreateDate WHERE `inventory` = @Inv AND `item_name` = @Item AND `slot` = @Slot LIMIT 1", {
        ['@Inv'] = InvName,
        ['@Item'] = Item,
        ['@Slot'] = Slot,
        ['@CreateDate'] = (OnePercent * Percentage),
    })
    
    if not SlotData then return end
    return (SlotData.CreateDate + (OnePercent * Percentage))
end
exports("IncreaseQualityItemFromInventory", IncreaseQualityItemFromInventory)

-- // Others \\ --
function ClearInventory(InvName)
    exports['ghmattimysql']:executeSync("DELETE FROM player_inventories WHERE inventory = @Inventory", {
        ['@Inventory'] = InvName
    })
    return true
end
exports("ClearInventory", ClearInventory)

function ClearInventoryItemSlot(InvName, Slot)
    local Result = exports['ghmattimysql']:executeSync("DELETE FROM player_inventories WHERE inventory = @InvName AND slot = @Slot", {
        ['@InvName'] = InvName,
        ['@Slot'] = Slot,
    })

    return Result.affectedRows > 0
end
exports("ClearInventoryItemSlot", ClearInventoryItemSlot)

function SetInventoryItemSlot(InvName, Item, Amount, Slot, Info, CustomType)
    local Result = ClearInventoryItemSlot(InvName, Slot)
    return AddItemToInventory(InvName, Item, Amount, Slot, Info, CustomType)
end
exports("SetInventoryItemSlot", SetInventoryItemSlot)

function SetInventoryName(FromInv, ToInv)
    local Result = exports['ghmattimysql']:executeSync("UPDATE player_inventories SET `inventory` = @ToInv WHERE `inventory` = @FromInv", {
        ['@FromInv'] = FromInv,
        ['@ToInv'] = ToInv,
    })
    return Result.affectedRows > 0
end
exports("SetInventoryName", SetInventoryName)