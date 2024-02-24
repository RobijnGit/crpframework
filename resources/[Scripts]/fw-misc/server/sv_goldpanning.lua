local MaterialItems = {
    'rubber', 'steel', 'plastic', 'copper', 'aluminum'
}

RegisterNetEvent("fw-misc:Server:GoldPanning:Loot")
AddEventHandler("fw-misc:Server:GoldPanning:Loot", function(Multiplier)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local ReceivedDust = false
    local GoldDustChance = math.random(1, 100)
    if GoldDustChance >= 40 and GoldDustChance <= 80 then
        ReceivedDust = true
        for i = 1, math.random(1, GetAmountOfDust(Source, GetEntityCoords(GetPlayerPed(Source)))), 1 do
            Player.Functions.AddItem('golddust', 1, false, nil, true)
        end
    end

    local MaterialChance = math.random(1, 100)
    if MaterialChance >= 20 then
        for i = 1, math.random(1, 4), 1 do
            local Amount = Multiplier > 1 and math.random(1, Multiplier + 1) or 1
            Player.Functions.AddItem(MaterialItems[math.random(#MaterialItems)], Amount, false, nil, true)
        end
    end

    if not ReceivedDust then
        local ShoeChance = math.random(1, 100)
        if Multiplier == 3 and ShoeChance >= 90 then
            for i = 1, math.random(1, 2), 1 do
                Player.Functions.AddItem("weapon_shoe", 1, false, nil, true)
            end
        end

        local NecklaceChance = math.random(1, 100)
        if Multiplier >= 2 and NecklaceChance >= 30 and NecklaceChance <= 50 then
            Player.Functions.AddItem("goldchain", 1, false, nil, true)
        end
    end
end)

-- max of a normal spot is 2, 'lucky' spots is default of 3 + a possible buff.
function GetAmountOfDust(Source, Coords)
    local Retval = 2

    for k, v in pairs(Config.PanningLocations) do
        if #(v[1] - Coords) < v[2] then
            Retval = 3 * v[3]
        end
    end

    local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Fishing')
    if HasBuff then
        Retval = Retval + 2
    end

    return math.ceil(Retval)
end