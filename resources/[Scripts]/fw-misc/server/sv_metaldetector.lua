local Items = {
    { Item = "coin", AllowMultiple = false, Chance = 0.8 },
    { Item = "goldchain", AllowMultiple = false, Chance = 0.7 },
    { Item = "cult-necklace", AllowMultiple = false, Chance = 0.7 },
    { Item = "goldnugget", AllowMultiple = false, Chance = 0.6 },
    { Item = "white-pearl", AllowMultiple = false, Chance = 0.6 },
    { Item = "heirloom", AllowMultiple = false, Chance = 0.5 },
    { Item = "gold-record", AllowMultiple = false, Chance = 0.5 },
    -- { Item = "iron", AllowMultiple = true, Chance = 0.4 },
    { Item = "aluminum", AllowMultiple = true, Chance = 0.4 },
    { Item = "steel", AllowMultiple = true, Chance = 0.4 },
    { Item = "copper", AllowMultiple = true, Chance = 0.4 },
    { Item = "metalscrap", AllowMultiple = false, Chance = 0.4 },
    { Item = "burnerphone", AllowMultiple = false, Chance = 0.01 },
}

FW.RegisterServer("fw-misc:Server:MetalDetectorReward", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local DidFind = math.random() > 0.4
    if not DidFind then
        return Player.Functions.Notify("Lijkt erop dat je niks kon vinden..", "error")
    end

    for i = 1, 3, 1 do
        local Item, AllowMultiple = GetRandomDetectorItem()
        if not Item then
            goto Skip
        end

        Player.Functions.AddItem(Item, AllowMultiple and math.random(2, 9) or 1, false, nil, true)

        ::Skip::
    end
end)

function GetRandomDetectorItem()
    math.randomseed(os.time() + math.random(1, 100))

    local TotalChance = 0
    for _, Item in ipairs(Items) do
        TotalChance = TotalChance + Item.Chance
    end

    local RandomValue = math.random() * TotalChance
    local CumulativeChance = 0

    for _, Item in ipairs(Items) do
        CumulativeChance = CumulativeChance + Item.Chance
        if RandomValue <= CumulativeChance then
            return Item.Item, Item.AllowMultiple
        end
    end

    return nil, false
end