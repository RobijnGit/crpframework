local PedNetIds = {}

FW.Functions.CreateCallback("fw-misc:Server:StartCornering", function(Source, Cb, Zone, Coords)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Config.CornerZones[Zone] then
        Cb({false, "Niemand koopt hier in de buurt."})
        return
    end

    Cb({true, "Verkoop actief"})
end)

FW.Functions.CreateCallback("fw-illegal:Server:CornerSale", function(Source, Cb, Type, Coords, NetId, Zone, IsInGangTurf)
    if PedNetIds[NetId] == nil then
        Cb(false)
        return
    end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then
        Cb(false)
        return
    end

    PedNetIds[NetId] = false

    local ItemName = Type == 'meth' and '1gmeth' or 'weed-bag'
    local RewardTable = Config.CornerPrices[Type]
    if not RewardTable then return end

    local CashReward = 0
    for i = 1, math.random(4, 12), 1 do
        local Item = Player.Functions.GetItemByName(ItemName)
        if Item and (Type ~= 'meth' or Item.Info.Purity > 0) then
            if Player.Functions.RemoveItemByName(ItemName, 1, true) then
                if Type == 'meth' then
                    CashReward = CashReward + math.ceil(RewardTable[Zone] * (Item.Info.Purity / 100))
                else
                    CashReward = CashReward + RewardTable[Zone]
                end
            end
        end
    end

    if IsInGangTurf then
        CashReward = CashReward + math.random(15, 30)
    end

    Player.Functions.AddMoney('cash', CashReward, 'Corner Sale')

    if math.random() < 0.15 then
        Player.Functions.AddItem('heist-safecracking', 1, false, nil, true)
    end

    Cb(true)
end)

FW.RegisterServer("fw-illegal:Server:CornerMoney", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    --[[
        markedbills €500
        money-roll €280
    ]]
    local RandomValue = math.random(1, 100)
    local Item = 'markedbills'
    local Earnings = math.random(485, 500)

    if RandomValue > 33 and RandomValue <= 85 then
        Item = 'money-roll'
        Earnings = math.random(235, 270)
    end

    local Amount = math.random(3, 7)
    if Player.Functions.HasEnoughOfItem(Item, Amount) then
        if Player.Functions.RemoveItemByName(Item, Amount, true, nil) then
            Player.Functions.AddMoney('cash', (Earnings * Amount))
        end
    end

end)

FW.RegisterServer("fw-illegal:Server:SyncCornerSale", function(Source, Coords, NetId)
    PedNetIds[NetId] = true
    TriggerClientEvent("fw-misc:Client:SyncHandoff", -1, Coords, NetId)
end)