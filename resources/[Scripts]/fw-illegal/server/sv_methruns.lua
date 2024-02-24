local GetTasksCooldown, MethrunCooldown, MethrunVehicle, MethrunDropoff, MethrunRewardsCache, MethrunRewards, SuppliesCollected, CurrentCops = false, false, false, false, {}, {}, 0, 0
AddEventHandler("fw-police:SetCopCount", function(Result)
    CurrentCops = Result
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetMethDealer", function(Source, Cb)
    Cb(Config.MethDealer)
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetMethSupplier", function(Source, Cb)
    Cb(Config.MethSupplier)
end)

FW.Functions.CreateCallback("fw-illegal:Server:IsMethVehicle", function(Source, Cb, NetId)
    Cb(MethrunVehicle and MethrunVehicle.NetId == NetId)
end)

FW.Functions.CreateCallback("fw-illegal:Server:HasMethrunRewards", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(MethrunRewards[Player.PlayerData.citizenid] ~= nil)
end)

FW.Functions.CreateCallback("fw-illegal:Server:IsFloorCleanerInTrunk", function(Source, Cb)
    if not MethrunVehicle then return end
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Inventory = exports['fw-inventory']:GetInventoryItemsUnproccessed('trunk' .. GetVehicleNumberPlateText(MethrunVehicle.Vehicle))
    local Floorcleaners = 0

    for k, v in pairs(Inventory) do
        if v.item_name == 'floorcleaner' then
            Floorcleaners = Floorcleaners + 1
        end
    end

    Cb(Floorcleaners >= 10)
end)

RegisterNetEvent("fw-illegal:Server:Methruns:GetTasks")
AddEventHandler("fw-illegal:Server:Methruns:GetTasks", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if CurrentCops < 5 then
        return Player.Functions.Notify("Kan geen opdracht starten..", "error")
    end

    local Gang = exports['fw-laptop']:GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then
        return Player.Functions.Notify("Kan geen opdracht starten..", "error")
    end

    if MethrunCooldown then
        return Player.Functions.Notify("Kan geen opdracht starten..", "error")
    end

    if GetTasksCooldown then
        return
    end

    GetTasksCooldown = true
    Citizen.SetTimeout(5000, function()
        GetTasksCooldown = false
    end)

    local Inventory = exports['fw-inventory']:GetInventoryItemsUnproccessed('methruns_dealer')
    local MethItems = {}

    local MethReward = 0

    for k, v in pairs(Inventory) do
        if v.item_name == 'methcured' and exports['fw-inventory']:CalculateQuality(v.item_name, v.createdate) > 0.0 then
            v.info = json.decode(v.info)
            MethItems[#MethItems + 1] = v

            local ThisReward = (25 * v.info._Purity)
            if v.info._Purity >= 99.0 then
                ThisReward = ThisReward + 500
            end

            MethReward = MethReward + ThisReward
        end
    end

    if #MethItems == 0 then
        return Player.Functions.Notify("De man zegt 'Als je niks hebt donder je maar op.' en gebaart dat je weg moet gaan.", "error")
    end

    if #MethItems < 50 then
        return Player.Functions.Notify("De man zegt 'Hiermee ga je het niet redden.' en kijkt je van top tot teen aan.", "error")
    end

    MethrunRewardsCache[Player.PlayerData.citizenid] = MethReward

    Player.Functions.Notify("Ziet er goed uit, ready when you are.")

    MethrunCooldown = true
    Citizen.SetTimeout((60 * 1000) * 120, function()
        MethrunCooldown = false
    end)

    exports['ghmattimysql']:executeSync("DELETE FROM `player_inventories` WHERE `inventory` = 'methruns_dealer' AND `item_name` IN ('methcured')")

    -- Create the Vehicle and peds
    local VehicleLocation = Config.MethSpawners[math.random(#Config.MethSpawners)]
    local Vehicle = Config.MethVehicles[math.random(#Config.MethVehicles)]

    local Plate = ("MET" .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()
    local NetId = FW.Functions.SpawnVehicle(Source, Vehicle, { x = VehicleLocation.Vehicle.x, y = VehicleLocation.Vehicle.y, z = VehicleLocation.Vehicle.z, a = VehicleLocation.Vehicle.w, }, false, Plate)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)

    MethrunVehicle = {
        Vehicle = Vehicle,
        NetId = NetId
    }

    TriggerClientEvent("fw-illegal:Client:SetMethVehicle", Source, NetId, VehicleLocation)
end)

RegisterNetEvent("fw-illegal:Server:MethrunCollect")
AddEventHandler("fw-illegal:Server:MethrunCollect", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not MethrunCooldown or not MethrunVehicle then
        return Player.Functions.Notify("Ik heb niks voor je..", "error")
    end

    local Distance = #(GetEntityCoords(MethrunVehicle.Vehicle) - vector3(Config.MethSupplier.x, Config.MethSupplier.y, Config.MethSupplier.z))
    if Distance > 8 then
        return Player.Functions.Notify("Ik heb niks voor je..", "error")
    end

    SuppliesCollected = SuppliesCollected + 1
    if SuppliesCollected > 10 then
        return Player.Functions.Notify("Je hebt alle spullen, wacht op de locatie van de baas, wees voorzichtig.", "error")
    end

    if SuppliesCollected == 10 then
        TriggerClientEvent("fw-illegal:Client:SupplierCountdown", Source)

        Citizen.SetTimeout(60000, StartMethVehicleTracker)
        Citizen.SetTimeout((60 * 1000) * math.random(16, 21), function()
            SuppliesCollected = 0
            MethrunDropoff = Config.MethDropoffs[math.random(#Config.MethDropoffs)]
            TriggerClientEvent("fw-illegal:Client:SetMethDropoff", Source, MethrunDropoff)
        end)
    end

    Player.Functions.AddItem('floorcleaner', 1, false, nil, true)
end)

RegisterNetEvent("fw-illegal:Server:Methruns:GetReward")
AddEventHandler("fw-illegal:Server:Methruns:GetReward", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if MethrunRewards[Player.PlayerData.citizenid] == nil or MethrunRewards[Player.PlayerData.citizenid] == 0 then
        return
    end

    if MethrunRewards[Player.PlayerData.citizenid] == 0 then
        MethrunRewards[Player.PlayerData.citizenid] = nil
        return
    end

    if Player.Functions.AddMoney('cash', math.floor(MethrunRewards[Player.PlayerData.citizenid])) then
        MethrunRewards[Player.PlayerData.citizenid] = nil
        MethrunRewardsCache[Player.PlayerData.citizenid] = nil
    end
end)

FW.RegisterServer("fw-illegal:Server:ResetMethrun", function(Source, NetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if MethrunVehicle.NetId ~= NetId then
        return
    end

    Citizen.Wait(60000)

    while DoesEntityExist(MethrunVehicle.Vehicle) do
        DeleteEntity(MethrunVehicle.Vehicle)
        Citizen.Wait(100)
    end

    MethrunRewards[Player.PlayerData.citizenid] = MethrunRewardsCache[Player.PlayerData.citizenid]
    MethrunVehicle, MethrunDropoff, SuppliesCollected = false, false, 0
end)

function StartMethVehicleTracker()
    Citizen.CreateThread(function()
        while MethrunVehicle and type(MethrunVehicle) == 'table' and DoesEntityExist(MethrunVehicle.Vehicle) do
            Citizen.Wait(45000)
            TriggerClientEvent("fw-illegal:Client:VehicleTracker", -1, GetEntityCoords(MethrunVehicle.Vehicle))
        end
    end)
end