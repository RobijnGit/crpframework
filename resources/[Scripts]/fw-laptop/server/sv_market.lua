local Pickups = {}

FW.Functions.CreateCallback("fw-laptop:Server:Market:GetItems", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Items = exports['fw-inventory']:GetInventoryItems('ply-' .. Player.PlayerData.citizenid)
    local Retval = {}

    for k, SlotData in pairs(Items) do
        if not SlotData then goto Skip end

        local ItemQuality = exports['fw-inventory']:CalculateQuality(SlotData.Item, SlotData.CreateDate)
        if ItemQuality <= 5 then goto Skip end
        Retval[#Retval + 1] = SlotData
    
        ::Skip::
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-laptop:Server:Market:GetProducts", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `laptop_market` ORDER BY `date` DESC")

    for k, v in pairs(Result) do
        v.item_data = json.decode(v.item_data)
        v.SharedData = exports['fw-inventory']:GetItemData(v.item_data.Item, v.item_data.CustomType)
        if not v.SharedData.IsExternImage then
            v.SharedData.Image = 'https://cfx-nui-fw-inventory/html/img/items/' .. v.SharedData.Image
        end
    end

    Cb(Result)
end)

FW.Functions.CreateCallback("fw-laptop:Server:Market:PurchaseProducts", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Query = "SELECT `id`, `item_data`, `price`, `cid` FROM `laptop_market` WHERE `id` = ?"
    for k, v in pairs(Data.Cart) do
        if k ~= 1 then
            Query = Query .. " OR `id` = ?"
        end
    end

    local Result = exports['ghmattimysql']:executeSync(Query, Data.Cart)

    local TotalGNE = 0

    for k, v in pairs(Result) do
        if v.cid ~= Player.PlayerData.citizenid then
            TotalGNE = TotalGNE + v.price
        end
    end

    if TotalGNE > 0 then
        if not Player.Functions.RemoveCrypto("GNE", TotalGNE) then
            return Cb({Msg = "Je hebt niet genoeg GNE balans.."})
        end
    end

    for k, v in pairs(Data.Cart) do
        exports['ghmattimysql']:execute("DELETE FROM `laptop_market` WHERE `id` = ?", {v})
    end

    local Listing = ""

    for k, v in pairs(Result) do
        v.item_data = json.decode(v.item_data)
        v.SharedData = exports['fw-inventory']:GetItemData(v.item_data.Item, v.item_data.CustomType)

        Listing = Listing .. "<br/>" .. v.SharedData.Label .. " voor <i class='fas fa-horse-head'></i> " .. v.price
    end

    Listing = Listing .. "<br/> Totaal: <i class='fas fa-horse-head'></i> " .. TotalGNE

    Citizen.SetTimeout(10000, function()
        TriggerEvent(
            "fw-phone:Server:Mails:AddMail",
            "#U-4310",
            "Je bestelling is gereed.",
            "Je hebt recent een bestelling geplaatst op de Holle Bolle Market, deze bestelling is gereed om opgehaald te worden. Ga naar de Post Op om je bestelling op te halen.<br/><br/> Informatie over je bestelling:"..Listing,
            Source
        )

        TriggerClientEvent("fw-heists:Client:MarkPickupGPS", Source, vector3(1184.01, -3322.08, 6.19))
    end)

    if Pickups[Player.PlayerData.citizenid] == nil then
        Pickups[Player.PlayerData.citizenid] = {}
    end

    for k, v in pairs(Result) do
        table.insert(Pickups[Player.PlayerData.citizenid], v)

        if v.cid ~= Player.PlayerData.citizenid then
            PaySeller(v)
        end
    end

    TriggerEvent('fw-logs:Server:Log', 'market', 'Product Purchased', ("User: [%s] - %s - %s %s\nData: ```json\n%s```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, json.encode(Result, {indent=4})), 'green')

    Cb({Msg = "Je bestelling is afgerond."})
end)

FW.RegisterServer("fw-laptop:Server:Market:SellItem", function(Source, ItemLabel, ItemData, Price)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- Only allow a player to have 1 item for sale so the market won't be full of trash
    -- and people won't sell broken stuff and shit
    local ItemsOnCid = exports['ghmattimysql']:executeSync("SELECT `id` FROM `laptop_market` WHERE `cid` = ? LIMIT 1", { Player.PlayerData.citizenid })
    if ItemsOnCid[1] ~= nil then
        return Player.Functions.Notify("Je kan maximaal maar 1 item te koop hebben staan..", "error")
    end

    Price = math.ceil(tonumber(Price))
    if Price < 1 then
        return Player.Functions.Notify("GNE kosten moet minstens 1 zijn.")
    end

    local Item = Player.Functions.GetItemBySlot(ItemData.Slot)
    if Item == nil then return Player.Functions.Notify("Je mist het item..", "error") end
    if Item.Item ~= ItemData.Item then return Player.Functions.Notify("Je mist het item..", "error") end
    if Item.CustomType ~= ItemData.CustomType then return Player.Functions.Notify("Je mist het item..", "error") end
    if Item.Amount < 1 then return Player.Functions.Notify("Je mist het item..", "error") end

    exports['ghmattimysql']:executeSync("INSERT INTO `laptop_market` (cid, item_data, price) VALUES (?, ?, ?)", {
        Player.PlayerData.citizenid,
        json.encode({
            Item = Item.Item,
            CustomType = Item.CustomType,
            Info = Item.Info,
            CreateDate = Item.CreateDate,
        }),
        Price
    })

    exports['ghmattimysql']:executeSync("DELETE FROM `player_inventories` WHERE `inventory` = ? AND `slot` = ? LIMIT 1", { 'ply-' .. Player.PlayerData.citizenid, ItemData.Slot })
    TriggerClientEvent('fw-inventory:Client:ShowActionBox', Source, 'Verkocht', ItemData.Item, 1, ItemData.CustomType)

    Player.Functions.RefreshInventory()

    TriggerEvent(
        "fw-phone:Server:Mails:AddMail",
        "#U-4310",
        "Je hebt een product verkocht op de markt.",
        ("Je hebt een product op de Holle Bolle Markt geplaatst. Zodra het verkocht is ontvang je 85%% van de inkomsten. We houden 15%% om de servicekosten te dekken. <br/><br/> Informatie over het product:<br/>%s voor <i class='fas fa-horse-head'></i> %s"):format(ItemLabel, Price),
        Source
    )

    TriggerEvent('fw-logs:Server:Log', 'market', 'Product Sold to Market', ("User: [%s] - %s - %s %s\nItem: %s\nGNE: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, ItemData.Item, Price), 'green')
end)

RegisterNetEvent("fw-laptop:Server:Market:PickupItems")
AddEventHandler("fw-laptop:Server:Market:PickupItems", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Pickups[Player.PlayerData.citizenid] == nil then
        return Player.Functions.Notify("Er is geen bestelling voor jou..")
    end

    if FW.Throttled('laptop-pickup-' .. Player.PlayerData.citizenid, 1000 * #Pickups[Player.PlayerData.citizenid]) then
        return Player.Functions.Notify("Kom later terug..")
    end

    for k, v in pairs(Pickups[Player.PlayerData.citizenid]) do
        local Slot = exports['fw-inventory']:FindSlot('ply-' .. Player.PlayerData.citizenid, v.item_data.Item, v.item_data.CustomType)
        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `player_inventories` (inventory, item_name, custom_type, slot, info, createdate) VALUES (?, ?, ?, ?, ?, ?)", {
            'ply-' .. Player.PlayerData.citizenid,
            v.item_data.Item,
            v.item_data.CustomType,
            Slot,
            json.encode(v.item_data.Info),
            v.item_data.CreateDate or 0,
        })

        TriggerClientEvent('fw-inventory:Client:ShowActionBox', Source, 'Ontvangen', v.item_data.Item, 1, v.item_data.Item.CustomType)
        Player.Functions.RefreshInventory()
        Citizen.Wait(100)
    end

    Pickups[Player.PlayerData.citizenid] = nil
end)

function PaySeller(Product)
    local Player = FW.Functions.GetPlayerByCitizenId(Product.cid)
    if Player then
        Player.Functions.AddCrypto("GNE", math.ceil(Product.price * 0.8))
    else
        local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `money` FROM `players` WHERE `citizenid` = ?", { Product.cid })
        if Result and Result[1] then
            local Money = json.decode(Result[1].money)
            Money.crypto.GNE = Money.crypto.GNE + math.ceil(Product.price * 0.8)

            exports['ghmattimysql']:executeSync("UPDATE `players` SET `money` = ? WHERE `id` = ?", { json.encode(Money), Result[1].id })
        end
    end
end