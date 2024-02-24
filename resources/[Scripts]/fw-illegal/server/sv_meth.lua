local TablesPlaced, TablesPurity, TablesCooked = 0, {}, {}

-- Every 10 minutes go through all raw meth batches, if the time since its been cooked has been more than an hour, turn it into a cured batch.
Citizen.CreateThread(function()
    while true do

        local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `inventory`, `slot`, `info` FROM `player_inventories` WHERE `item_name` = 'methbatch'")
        local CurrentTime = os.time()
        for k, v in pairs(Result) do
            local Info = json.decode(v.info)
            if Info and Info.CookTime + (60 * 60) >= CurrentTime then
                exports['ghmattimysql']:executeSync("UPDATE `player_inventories` SET `item_name` = 'methcured' WHERE `id` = @Id", {
                    ['@Id'] = v.id,
                })

                if v.inventory:sub(1, 4) == 'ply-' then
                    local Cid = v.inventory:sub(5)
                    local Player = FW.Functions.GetPlayerByCitizenId(Cid)
                    if Player then
                        Player.Functions.RefreshInvSlot(tonumber(v.slot))
                        TriggerClientEvent("fw-assets:Client:Attach:Items", Player.PlayerData.source)
                    end
                end
            end
        end

        Citizen.Wait((60 * 1000) * 10)
    end
end)

RegisterNetEvent("fw-illegal:Server:Meth:PurchaseTable")
AddEventHandler("fw-illegal:Server:Meth:PurchaseTable", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.Functions.RemoveItemByName('methusb', 1, true) then
        return Player.Functions.Notify("Je mist een USB..", "error")
    end

    if not Player.Functions.RemoveCrypto('SHUNG', 150) then
        return Player.Functions.Notify("Je hebt niet genoeg SHUNG, arme sloeber.", "error")
    end

    Player.Functions.SetMetaData('lastmethpayment', os.time() + ((3600 * 24) * 7))
    Player.Functions.AddItem('methtable', 1, false, nil, true)
end)

FW.RegisterServer("fw-illegal:Server:PlaceMethTable", function(Source, Coords, Rotation)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemByName('methtable')
    if not Item then return end

    if IsMethTablePlacedWithCid(Player.PlayerData.citizenid) then
        return Player.Functions.Notify("Je hebt al een tafel geplaatst..", "error")
    end
    
    if not Player.Functions.RemoveItemByName('methtable', 1, true) then
        return Player.Functions.Notify("Je mist een tafel.", "error")
    end
    
    local TableId = TablesPlaced + 1
    TablesPlaced = TablesPlaced + 1

    local InsertId = #Config.MethTables + 1
    Config.MethTables[InsertId] = {
        Id = TableId,
        Owner = Player.PlayerData.citizenid,
        Coords = Coords,
        Rotation = Rotation,
        LastCook = Item.Info._LastCook or 0
    }
    TablesCooked[TableId] = Item.Info._LastCook

    TriggerClientEvent("fw-illegal:Client:SetMethTableData", -1, "Set", TableId, Config.MethTables[InsertId])
end)

FW.RegisterServer("fw-illegal:Server:DestroyMethTable", function(Source, TableId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    TriggerClientEvent("fw-illegal:Client:SetMethTableData", -1, "Remove", TableId)
    local removedTable = false
    for k, v in pairs(Config.MethTables) do
        if v.Id == TableId then
            removedTable = true
            table.remove(Config.MethTables, k)
        end
    end

    if removedTable then
        Player.Functions.AddItem('methtable', 1, false, {
            _LastCook = TablesCooked[TableId] or 0
        }, true)
    end

    TablesCooked[TableId] = false
end)

FW.RegisterServer("fw-illegal:Server:RewardMethTable", function(Source, TableId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local TableKey = GetMethTableKeyById(TableId)
    if not TableKey then return end

    if not TablesPurity[TableId] then return end
    Player.Functions.AddItem("methbatch", 1, false, {_Purity = TablesPurity[TableId], CookTime = os.time()}, true)
    TablesPurity[TableId] = false
    TablesCooked[TableId] = os.time()

    Config.MethTables[TableKey].LastCook = TablesCooked[TableId]
    TriggerClientEvent("fw-illegal:Client:SetMethTableData", -1, "Set", TableId, Config.MethTables[TableKey])
end)

FW.RegisterServer("fw-illegal:Server:CutMethReward", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.Functions.HasEnoughOfItem("methcured") then
        return
    end

    if not Player.Functions.HasEnoughOfItem("emptybaggies") then
        return
    end

    if not Player.Functions.HasEnoughOfItem("scales") then
        return
    end
    
    local Item = Player.Functions.GetItemBySlot(Item.Slot)
    if Item.Item ~= 'methcured' then
        return
    end

    if not Player.Functions.RemoveItemByName('methcured', 1, true) or not Player.Functions.RemoveItemByName('emptybaggies', 1, true) then
        return 
    end

    Player.Functions.AddItem('1gmeth', 32, false, { Purity = Item.Info._Purity }, true)
end)

FW.RegisterServer("fw-illegal:Server:LoadMethpipe", function(Source, Quantity, FromItem, ToItem)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Quantity or Quantity > 1 then return print("too much nerd") end
    if Player.Functions.RemoveItemByName(FromItem.Item, Quantity, true) then
        local Purities = ToItem.Info._Purities
        table.insert(Purities, { Purity = FromItem.Info.Purity })

        Player.Functions.SetItemKV("methpipe", ToItem.Slot, 'Uses', ToItem.Info.Uses + Quantity)
        Player.Functions.SetItemKV("methpipe", ToItem.Slot, '_Purities', Purities)
    end
end)

FW.Functions.CreateCallback("fw-illegal:Server:StartCookingMeth", function(Source, Cb, TableId, Result)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local TableKey = GetMethTableKeyById(TableId)
    if not TableKey then return end

    local PlayerSeeds = {
        tonumber(string.sub(Player.PlayerData.metadata["haircode"], 10, 11)),
        tonumber(string.sub(Player.PlayerData.metadata["haircode"], 15, 16)),
        tonumber(string.sub(Player.PlayerData.metadata["haircode"], 17, 18))
    }

    TablesPurity[TableId] = 100 - (1/3) * (math.abs(Result[1] - PlayerSeeds[1]) + math.abs(Result[2] - PlayerSeeds[2]) + math.abs(Result[3] - PlayerSeeds[3]))

    Cb(true)
end)

FW.Functions.CreateCallback("fw-illegal:Server:SetMethpipeUses", function(Source, Cb, Slot)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemBySlot(Slot)
    if Item.Item ~= 'methpipe' then return end

    Player.Functions.SetItemKV("methpipe", Slot, 'Uses', Item.Info.Uses - 1 or 0)
    Citizen.Wait(100)

    local Purities = Item.Info._Purities
    local Purity = Purities[#Purities].Purity
    table.remove(Purities, #Purities)

    Player.Functions.SetItemKV("methpipe", Slot, '_Purities', Purities)
    Cb(Purity)
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetMethTables", function(Source, Cb)
    Cb(Config.MethTables)
end)

function GetMethTableKeyById(TableId)
    for k, v in pairs(Config.MethTables) do
        if v.Id == TableId then
            return k
        end
    end
    return false
end

function IsMethTablePlacedWithCid(Cid)
    for k, v in pairs(Config.MethTables) do
        if v.Owner == Cid then
            return true
        end
    end
    return false
end

FW.Functions.CreateUsableItem("methtable", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    local LastTablePayment = Player.PlayerData.metadata['lastmethpayment']
    if os.time() > LastTablePayment then -- 7 days
        if not Player.Functions.RemoveCrypto('SHUNG', 50) then
            return Player.Functions.Notify("Je hebt niet genoeg Shungite om de ingredienten aan te vullen..", "error")
        end

        Player.Functions.SetMetaData('lastmethpayment', os.time() + ((3600 * 24) * 7))
        TriggerEvent('fw-phone:Server:Mails:AddMail', "Dark Market", "#M-1001", "We hebben de ingredienten aangevuld voor je.. ijskraam. Er is 50 SHUNG van je wallet afgehaald.", Source)
    end

    TriggerClientEvent("fw-illegal:Client:Meth:PlaceTable", Source, Item)
end)

FW.Functions.CreateUsableItem("methcured", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    if Player.Functions.GetItemByName('emptybaggies') == nil then
        return FW.Functions.Notify("In welke zakjes wil je het stoppen dan?", "error")
    end

    if Player.Functions.GetItemByName('scales') == nil then
        return FW.Functions.Notify("Je hebt een weegschaal nodig.", "error")
    end

    TriggerClientEvent("fw-illegal:Client:CutMeth", Source, Item)
end)

FW.Functions.CreateUsableItem("methpipe", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    TriggerClientEvent("fw-illegal:Client:UseMethpipe", Source, Item)
end)