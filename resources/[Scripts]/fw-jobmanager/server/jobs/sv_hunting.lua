local HuntingSellItems = { ['hunting-carcass-one'] = math.random(50, 100), ['hunting-carcass-two'] = math.random(100, 130), ['hunting-carcass-three'] = math.random(400, 485)}
local CidTimers = {}

-- // Functions \\ --
RegisterNetEvent("fw-jobmanager:Server:HuntingReceiveGoods")
AddEventHandler("fw-jobmanager:Server:HuntingReceiveGoods", function(AnimalName, Baited, Illegal)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local CurrentTime = os.time()
    local TimeDifferance = CurrentTime - (CidTimers[Player.PlayerData.citizenid] or 0)
    if CidTimers[Player.PlayerData.citizenid] and TimeDifferance < 4.0 then
        CidTimers[Player.PlayerData.citizenid] = CurrentTime
        TriggerEvent("fw-logs:Server:Log", 'anticheatJobmanager', "Fast Hunting Reward", ("User: [%s] - %s - %s %s\n%s seconds since last mining reward, should be more then 5 seconds!"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, math.ceil(TimeDifferance)), "orange")
    end

    local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Hunting')

    if Baited then
        if HasBuff then
            if Illegal and math.random(1, 50) < 25 then
                Player.Functions.AddItem('hunting-carcass-four', 1, false, { Animal = AnimalName, Date = os.date() }, true)
            else
                Player.Functions.AddItem('hunting-carcass-three', 1, false, { Animal = AnimalName, Date = os.date() }, true)
            end
        else
            Player.Functions.AddItem('hunting-carcass-two', 1, false, { Animal = AnimalName, Date = os.date() }, true)
        end
        Player.Functions.AddItem('ingredient', HasBuff and math.random(8, 17) or math.random(5, 10), false, nil, true, 'Beef')
    else
        Player.Functions.AddItem('hunting-carcass-one', 1, false, { Animal = AnimalName, Date = os.date() }, true)
        if math.random(1, 100) <= 20 then Player.Functions.AddItem('ingredient', 1, false, nil, true, 'Beef') end
    end
end)

RegisterNetEvent("fw-jobmanager:Server:HuntingSell")
AddEventHandler("fw-jobmanager:Server:HuntingSell", function()
    local Source = source
    local TotalReceive = 0

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Items = exports['ghmattimysql']:executeSync("SELECT item_name, custom_type, slot, createdate FROM `player_inventories` WHERE `inventory` = @Inventory", {
        ['@Inventory'] = 'ply-' .. Player.PlayerData.citizenid,
    })

    local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Salary')
    for k, v in pairs(Items) do
        if IsThisASellItem(v.item_name) then
            if exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate) > 0 then
                TotalReceive = TotalReceive + HuntingSellItems[v.item_name]
                if HasBuff then TotalReceive = TotalReceive + math.random(10, 30) end
                Player.Functions.RemoveItem(v.item_name, 1, v.slot, true)
            end
        elseif v.item_name == 'hunting-carcass-four' then
            local Time = exports['fw-sync']:GetCurrentTime()
            if (Time.Hour >= 20 and Time.Hour <= 23) or (Time.Hour >= 0 and Time.Hour <= 6) then
                if exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate) > 0 then
                    Player.Functions.RemoveItem(v.item_name, 1, v.slot, true)
                    Citizen.SetTimeout(100, function()
                        Player.Functions.AddItem('money-roll', math.random(20, 25), false, false, true)
                    end)
                end
            else
                Player.Functions.Notify('Kom je vannacht even terug? Ik ga dit soort dingen niet overdag aannemen..', 'error')
            end
        end
    end

    if TotalReceive > 0 then
        Player.Functions.Notify('Toegevoegd op bank balans.')
        exports['fw-financials']:AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, TotalReceive, 'SALES', 'Baan: Jaag Verkoop')
    end
end)

function IsThisASellItem(ItemName)
    for k, v in pairs(HuntingSellItems) do
        if k == ItemName then
            return true
        end
    end
    return false
end

function InsideHuntingZone(Source)
    local Coords = GetEntityCoords(GetPlayerPed(Source))
    local Distance = #(Coords - Config.HuntingLocation)
    if Distance < 700.0 then
        return true
    else
        return false
    end
end