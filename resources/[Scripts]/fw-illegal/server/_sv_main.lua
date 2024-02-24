FW = exports['fw-core']:GetCoreObject()
local Drying = false

-- Code
FW.Functions.CreateCallback("fw-illegal:Server:Start:Dry:Process", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Drying then
        Cb(false)
        return Player.Functions.Notify("Het droogrek is al in gebruik..", "error")
    end

    local InvItems = exports['fw-inventory']:GetInventoryItems('temp-dry-rack')
    if InvItems == nil then
        Cb(false)
        return Player.Functions.Notify("Droogrek is leeg..", "error")
    end

    Cb(true)

    local WeedBuds = {}
    for k, v in pairs(InvItems) do
        if v and v.Item == 'weed-branch' then
            local BudsAmount = CalculateAmountBuds(v.Info.WeedQuality ~= nil and v.Info.WeedQuality or 0, v.Amount)
            WeedBuds[#WeedBuds + 1] = {
                Item = 'weed-dried-bud-one',
                Slot = v.Slot,
                Amount = BudsAmount,
            }
        end
    end

    if #WeedBuds == 0 then
        return Player.Functions.Notify("Er is niks om te drogen..", "error")
    end

    Drying = true
    Player.Functions.Notify("Droogprocess gestart..", "success")
    Citizen.SetTimeout((1000 * 60) * 2, function()
        for k, v in pairs(WeedBuds) do
            if v.Amount and v.Amount > 0 then
                exports['fw-inventory']:SetInventoryItemSlot('temp-dry-rack', v.Item, v.Amount, v.Slot)
            end
        end
        Drying = false
    end)
end)

-- // Functions \\ --

function CalculateAmountBuds(Quality, Amount)
    if Quality <= 20 then
        return (math.random(1, 3) * Amount)
    elseif Quality >= 21 and Quality < 40 then
        return (math.random(5, 8) * Amount)
    elseif Quality >= 41 and Quality < 60 then
        return (math.random(8, 11) * Amount)
    elseif Quality >= 60 and Quality < 80 then
        return (math.random(11, 14) * Amount)
    elseif Quality >= 80 and Quality <= 100 then
        return (math.random(14, 16) * Amount)
    end
end

function IsThisASellItem(ItemName)
    for k, v in pairs(IllegalSelling) do
        if k == ItemName then
            return true
        end
    end
    return false
end

FW.Functions.CreateCallback("fw-illegal:Server:Is:Dryer:Busy", function(Source, Cb)
    Cb(Drying)
end)