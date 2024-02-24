-- // Events \\ --
local CidTimers = {}

RegisterServerEvent('fw-jobmanager:Server:Mining:SetData')
AddEventHandler('fw-jobmanager:Server:Mining:SetData', function(SpotId, Type, Bool)
    if Config.MiningSpots[SpotId] ~= nil then
        Config.MiningSpots[SpotId][Type] = Bool
        if Type == 'Mined' and Bool then
            Citizen.SetTimeout((1000 * 60) * 5, function() -- Reset Timer for 3 minutes
                Config.MiningSpots[SpotId]['Mined'] = false
                Config.MiningSpots[SpotId]['Busy'] = false
            end)
        end
    end
end)

RegisterNetEvent("fw-jobmanager:Server:MiningGrab")
AddEventHandler("fw-jobmanager:Server:MiningGrab", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddItem('pickaxe', 1, false, false, true) 
end)

RegisterNetEvent("fw-jobmanager:Server:Mining:ReceiveGoods")
AddEventHandler("fw-jobmanager:Server:Mining:ReceiveGoods", function(AlreadyMined)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local CurrentTime = os.time()
    local TimeDifferance = CurrentTime - (CidTimers[Player.PlayerData.citizenid] or 0)
    if CidTimers[Player.PlayerData.citizenid] and TimeDifferance < 3.5 then
        CidTimers[Player.PlayerData.citizenid] = CurrentTime
        TriggerEvent("fw-logs:Server:Log", 'anticheatJobmanager', "Fast Mining Reward", ("User: [%s] - %s - %s %s\n%s seconds since last mining reward, should be more then 3.5 seconds!"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, math.ceil(TimeDifferance)), "orange")
    end

    if not AlreadyMined then
        for i = 1, 3 do
            local RandomItem = Config.MaterialTypes[math.random(1, #Config.MaterialTypes)]
            Player.Functions.AddItem(RandomItem, math.random(1, 3), false, nil, true)
        end
    else
        local RandomItem = Config.MaterialTypes[math.random(1, #Config.MaterialTypes)]
        Player.Functions.AddItem(RandomItem, 1, false, nil, true)
    end
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:CanMineThisSpot", function(Source, Cb, SpotId)
    if Config.MiningSpots[SpotId] ~= nil then
        if Config.MiningSpots[SpotId]['Busy'] then
            Cb("No")
        elseif Config.MiningSpots[SpotId]['Mined'] then
            Cb(true)
        else
            Cb(false)
        end
    else
        Cb(nil)
    end
end)