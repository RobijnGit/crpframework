local ObjectsToItem = {
    [GetHashKey("prop_tv_07")] = "stolen-tv",
    [GetHashKey("prop_tv_flat_01")] = "stolen-tv",
    [GetHashKey("prop_microwave_1")] = "stolen-micro",
}

local function GetRobMultiplier()
    local SalaryRate = exports['fw-phone']:CalculateSalaryRate("houses")
    if SalaryRate == 5 then
        return 1.0
    elseif SalaryRate == 4 then
        return 0.8
    elseif SalaryRate == 3 then
        return 0.6
    elseif SalaryRate == 2 then
        return 0.4
    elseif SalaryRate == 1 then
        return 0.2
    end
end

RegisterNetEvent("fw-jobmanager:Server:Houses:SetState")
AddEventHandler("fw-jobmanager:Server:Houses:SetState", function(HouseId, Key, Value)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Config.Houses.Houses[HouseId][Key] = Value

    TriggerClientEvent("fw-jobmanager:Client:Houses:SetState", -1, HouseId, Key, Value)
end)

FW.RegisterServer("fw-jobmanager:Server:Houses:ReceiveObject", function(Source, GroupId, EntityHash)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = JobCenter.GetGroup("houses", GroupId)
    if Group == nil then return end

    if Config.Houses.Houses[GroupId].Props[EntityHash] == 2 then
        return
    end

    Player.Functions.AddItem(ObjectsToItem[EntityHash], 1, false, nil, true)
end)

FW.RegisterServer("fw-jobmanager:Server:Houses:ReceiveGoods", function(Source, GroupId, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = JobCenter.GetGroup("houses", GroupId)
    if Group == nil then return end

    local LootMultiplier = GetRobMultiplier()

    local GoodsType = Data.Type
    if GoodsType == 'Shower' then
        local RandomItems = { 'goldchain', 'apple', 'rolex', 'cult-necklace', 'money-roll' }
        for i = 1, math.ceil(3 * LootMultiplier) do
            Player.Functions.AddItem(RandomItems[math.random(1, #RandomItems)], 1, false, nil, true)
        end
    elseif GoodsType == 'Kitchen' then
        local RandomItems = { 'sandwich', 'apple', 'beer', 'cult-necklace', 'ammonium-bicarbonate' }
        for i = 1, math.ceil(4 * LootMultiplier) do
            Player.Functions.AddItem(RandomItems[math.random(1, #RandomItems)], 1, false, nil, true)
        end
    elseif GoodsType == 'House' then
        local RandomItems = { 'cult-necklace', 'gold-record', 'water_bottle', 'apple', 'beer', 'rolex', 'screwdriver' }
        for i = 1, math.ceil(3 * LootMultiplier) do
            Player.Functions.AddItem(RandomItems[math.random(1, #RandomItems)], 1, false, nil, true)
        end

        if math.random() < (0.2 * LootMultiplier) then
            Player.Functions.AddItem('tow-rope', 1, false, nil, true)
        end
    elseif GoodsType == 'Bed' then
        local RandomItems = { 'goldchain', 'heirloom', 'rolex', 'apple', 'beer', 'money-roll' }
        for i = 1, math.ceil(3 * LootMultiplier) do
            Player.Functions.AddItem(RandomItems[math.random(1, #RandomItems)], 1, false, nil, true)
        end
    end

    if math.random(1, 120) <= (25 * LootMultiplier) then
        Player.Functions.AddItem('money-roll', math.random(2, 5), false, nil, true, false)
    end

    if math.random() < 0.1 then -- 10% to get 2 EVD.
        Player.Functions.AddItem('heist-loot-usb', 1, false, nil, true)
    end
end)

RegisterServerEvent('fw-jobmanager:Client:Houses:StartAlarm')
AddEventHandler('fw-jobmanager:Client:Houses:StartAlarm', function(HouseId)
    local Source = source
    local SoundTimeout, BeepSound = 1000, 'heists.alarmBeep'

    if Config.Houses.Houses[HouseId] == nil then return end
    
    local Timer = Config.Houses.Houses[HouseId].Timer
    while Config.Houses.Houses[HouseId].Alarm and Timer > 0 do
        Timer = Timer - 1
        if Timer < 10 and SoundTimeout ~= 500 then SoundTimeout = 500 end
        if Timer < 10 and BeepSound ~= 'heists.alarmBeepDouble' then BeepSound = 'heists.alarmBeepDouble' end

        TriggerClientEvent('fw-jobmanager:Client:Houses:AlarmBeep', -1, HouseId, BeepSound)
        Citizen.Wait(SoundTimeout)
    end

    if Timer == 0 then 
        TriggerClientEvent('fw-jobmanager:Client:Houses:AlarmBeep', -1, HouseId, 'heists.alarm')
        TriggerClientEvent("fw-jobmanager:Client:Houses:SetState", -1, HouseId, 'Alarm', false)
        TriggerClientEvent('fw-jobmanager:Client:Houses:SendAlarm', Source, HouseId) 
        Config.Houses.Houses[HouseId].Alarm = false
    end
end)

FW.RegisterServer('fw-jobmanager:Server:ConcealHouse', function(Source, HouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "police" and not Player.PlayerData.job.onduty then return end

    if not Config.Houses.Houses[HouseId].GroupId then
        return Player.Functions.Notify("Deze deur kan je niet vergrendelen..", "error")
    end

    local Group = JobCenter.GetGroup("houses", Config.Houses.Houses[HouseId].GroupId)
    if not Group then
        return Player.Functions.Notify("Deze deur kan je niet vergrendelen..", "error")
    end

    local GroupLeader = FW.Functions.GetPlayerByCitizenId(Group.Members[1].Cid)
    if not GroupLeader then
        return Player.Functions.Notify("Deze deur kan je niet vergrendelen..", "error")
    end

    Player.Functions.Notify("De deur is vergrendeld.", "error")
    TriggerClientEvent("fw-jobmanager:Client:Houses:ForceAbandon", GroupLeader.PlayerData.source)
end)