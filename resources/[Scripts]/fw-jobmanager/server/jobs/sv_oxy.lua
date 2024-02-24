local OxyVehicles = {}

RegisterNetEvent("fw-jobmanager:Server:Oxy:CollectPackage")
AddEventHandler("fw-jobmanager:Server:Oxy:CollectPackage", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddItem('oxy-box', 1, false, false, true)
end)

RegisterNetEvent("fw-jobmanager:Server:CreateOxyVehicle")
AddEventHandler("fw-jobmanager:Server:CreateOxyVehicle", function(Coords, GroupId, ActivityId)
    local Source = source
    local Group = JobCenter.GetGroup("oxy", GroupId)
    if Group == nil then return end

    local VehicleModel = math.random(#Config.OxyDelivery.Vehicles)
    local PedModel = math.random(#Config.OxyDelivery.Peds)
    local Plate = (FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()

    local NetId = FW.Functions.SpawnVehicle(Source, Config.OxyDelivery.Vehicles[VehicleModel], {
        x = Coords.x,
        y = Coords.y,
        z = Coords.z,
        a = Coords.w,
    }, false, Plate)

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    local Ped = CreatePed(-1, GetHashKey(Config.OxyDelivery.Peds[PedModel]), Coords.x, Coords.y, Coords.z + 1.5, Coords.w, true, true)
    while not DoesEntityExist(Ped) or not DoesEntityExist(Vehicle) do Citizen.Wait(1) end

    TaskWarpPedIntoVehicle(Ped, Vehicle, -1)

    OxyVehicles[ActivityId] = {
        NetId = NetId,
        Vehicle = Vehicle,
        Ped = Ped
    }

    Citizen.SetTimeout(500, function()
        for k, v in pairs(Group.Members) do
            local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
            TriggerClientEvent("fw-jobmanager:Client:Oxy:SetOxyVehicle", Target.PlayerData.source, false, NetworkGetNetworkIdFromEntity(Ped), NetId)
        end
    end)
end)

RegisterNetEvent("fw-jobmanager:Server:DeleteOxyVehicle")
AddEventHandler("fw-jobmanager:Server:DeleteOxyVehicle", function(GroupId, ActivityId)
    if OxyVehicles[ActivityId] then
        while DoesEntityExist(OxyVehicles[ActivityId].Vehicle) do
            DeleteEntity(OxyVehicles[ActivityId].Vehicle)
            Citizen.Wait(200)
        end

        while DoesEntityExist(OxyVehicles[ActivityId].Ped) do
            DeleteEntity(OxyVehicles[ActivityId].Ped)
            Citizen.Wait(200)
        end
    end

    local Group = JobCenter.GetGroup("oxy", GroupId)
    if Group == nil then return end

    for k, v in pairs(Group.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        TriggerClientEvent("fw-jobmanager:Client:Oxy:SetOxyVehicle", Target.PlayerData.source, true)
    end
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:Oxy:DeliverGoods", function(Source, Cb, GroupId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = JobCenter.GetGroup("oxy", GroupId)
    if Group == nil then return end

    for k, v in pairs(Group.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        TriggerClientEvent("fw-jobmanager:Client:Oxy:SetOxyVehicle", Target.PlayerData.source, true)
    end

    --[[
        markedbills €500
        money-roll €280
    ]]

    if Player.Functions.RemoveItem('oxy-box', 1, false, true) then
        Player.Functions.AddMoney('cash', math.random(75, 100))
        if math.random(1, 100) <= 75 then Player.Functions.AddItem('oxy', math.random(1, 3), false, nil, true) end

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

        Cb(true)
    else
        Cb(false)
    end
end)