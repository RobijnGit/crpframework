local RobbedBanktrucks = {}
local Trackers = {}
local BanktruckLoot = {
    { Item = "money-roll", Worth = 250 },
    { Item = "rolex", Worth = 188 },
    { Item = "goldchain", Worth = 100 },
    { Item = "goldbar", Worth = 675 },
}

FW.Functions.CreateCallback("fw-heists:Server:Banktruck:CanRobTruck", function(Source, Cb, NetId)
    Cb(RobbedBanktrucks[NetId] == nil)
end)

FW.RegisterServer("fw-heists:Server:Banktruck:SetTruckState", function(Source, NetId, State, StreetLabel)
    RobbedBanktrucks[NetId] = State
    TriggerClientEvent('fw-heists:Client:Banktruck:Setup', Source, NetId)

    Trackers[NetId] = 18
    StartGlobalCooldown()

    local Entity = NetworkGetEntityFromNetworkId(NetId)
    Citizen.CreateThread(function()
        while Trackers[NetId] > 0 do
            Citizen.Wait(10000)

            Trackers[NetId] = Trackers[NetId] - 1

            local Coords = GetEntityCoords(Entity)
            TriggerClientEvent("fw-heists:Client:Backtruck:TrackerBlip", -1, Coords.x, Coords.y, Coords.z)
        end
    end)
end)

FW.RegisterServer("fw-heists:Server:Banktruck:ReceiveGoods", function(Source, NetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local RandomValue = math.random(1, 100)

    -- if RandomValue > 95 then
    --     Player.Functions.AddItem('heist-usb', 1, false, nil, true, 'green')
    -- end

    local Loot = generateLoot()

    for k, v in pairs(Loot) do
        Player.Functions.AddItem(v.Item, v.Amount, false, nil, true)
    end
end)

function generateLoot()
    local lootTable = {}

    -- Function to get the total worth of items in the table
    local function getTotalWorth(loot)
        local totalWorth = 0
        for _, item in ipairs(loot) do
            if item.Amount then
                totalWorth = totalWorth + (item.Amount * item.Worth)
            end
        end
        return totalWorth
    end

    local remainingWorth = math.random(75000, 90000)

    for _, item in ipairs(BanktruckLoot) do
        local maxAmount = math.floor(remainingWorth / item.Worth)
        if maxAmount > 1 then
            local amount = math.random(1, maxAmount)
            remainingWorth = remainingWorth - (amount * item.Worth)
            if amount > 0 then
                table.insert(lootTable, { Item = item.Item, Amount = amount })
            end
        end
    end

    return lootTable
end