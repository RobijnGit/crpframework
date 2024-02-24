local HivesPlaced = 0

-- todo: Maybe also save in DB? I do not feel like it is necessary, unless we want to make a beehive last longer. (On NoPixel it lasts 26 hours.)
Citizen.CreateThread(function()
    while true do

        local Timestamp = os.time()
        for k, v in pairs(Config.Beehives) do
            local TimeDifference = (Timestamp - v.Timestamp) / 60
            if TimeDifference >= 420 then -- 7 * 60 = 420 (1 hive lasts 7 hours, 2 harvests)
                table.remove(Config.Beehives, k)
                TriggerClientEvent("fw-misc:Client:SetHiveData", -1, "Remove", k) 
            end
        end

        Citizen.Wait((1000 * 60) * 5)
    end
end)

FW.Functions.CreateUsableItem("beehive", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    TriggerClientEvent("fw-misc:Client:PlaceBeehive", Source)
end)

FW.Functions.CreateCallback("fw-misc:Server:GetBeehives", function(Source, Cb)
    Cb(Config.Beehives)
end)

FW.RegisterServer("fw-misc:Server:PlaceBeehive", function(Source, Coords, Rotation)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local HiveId = #Config.Beehives + 1
    HivesPlaced = HivesPlaced + 1

    Config.Beehives[HiveId] = {
        Id = HivesPlaced,
        Coords = Coords,
        Rotation = Rotation,
        HasQueen = false,
        LastHarvest = 0,
        Timestamp = os.time(),
    }

    TriggerClientEvent("fw-misc:Client:SetHiveData", -1, "Set", HiveId, Config.Beehives[HiveId])
end)

FW.RegisterServer("fw-misc:Server:AddQueenToHive", function(Source, HiveId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local HiveKey = GetBeehiveKeyById(HiveId)
    if not HiveKey then return end
    Config.Beehives[HiveKey].HasQueen = true

    TriggerClientEvent("fw-misc:Client:SetHiveData", -1, "Set", HiveId, Config.Beehives[HiveKey])
end)

FW.RegisterServer("fw-misc:Server:DestroyHive", function(Source, HiveId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local HiveKey = GetBeehiveKeyById(HiveId)
    if not HiveKey then return end
    table.remove(Config.Beehives, HiveKey)

    TriggerClientEvent("fw-misc:Client:SetHiveData", -1, "Remove", HiveId)
end)

FW.RegisterServer("fw-misc:Server:HarvestHive", function(Source, HiveId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local HiveKey = GetBeehiveKeyById(HiveId)
    if not HiveKey then return end
    Config.Beehives[HiveKey].LastHarvest = os.time()

    Player.Functions.AddItem('ingredient', math.random(1, 3), false, { Buff = 'Smartness', BuffPercentage = '8' }, true, "Honey")
    Player.Functions.AddItem('bee-wax', math.random(2, 6), false, nil, true)

    local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Beekeeping')

    -- Getting a queen = bye hive.
    if HasBuff and math.random() < 0.5 or math.random() < 0.2 then
        Player.Functions.AddItem('bee-queen', 1, false, nil, true) 
        Player.Functions.Notify('Verwelkom de nieuwe bijen koningin!', 'success')

        table.remove(Config.Beehives, HiveKey)
        TriggerClientEvent("fw-misc:Client:SetHiveData", -1, "Remove", HiveId)
    else
        TriggerClientEvent("fw-misc:Client:SetHiveData", -1, "Set", HiveId, Config.Beehives[HiveKey])
    end
end)

function GetBeehiveKeyById(HiveId)
    for k, v in pairs(Config.Beehives) do
        if v.Id == HiveId then
            return k
        end
    end
    return false
end