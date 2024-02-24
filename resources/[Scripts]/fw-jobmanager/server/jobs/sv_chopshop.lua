local ChopVehicles = {}

local function GetLootMultiplier()
    local SalaryRate = exports['fw-phone']:CalculateSalaryRate("chopshop")
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

RegisterNetEvent("fw-jobmanager:Server:CreateChopVehicle")
AddEventHandler("fw-jobmanager:Server:CreateChopVehicle", function(GroupId, ActivityId)
    local Source = source
    local Group = JobCenter.GetGroup("chopshop", GroupId)
    if Group == nil then return end

    local VehicleModel = math.random(#Config.ChopShop.Vehicles)
    local Spawner = math.random(#Config.ChopShop.Spawners)
    local Plate = (FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()

    local NetId = FW.Functions.SpawnVehicle(Source, Config.ChopShop.Vehicles[VehicleModel], {
        x = Config.ChopShop.Spawners[Spawner].x,
        y = Config.ChopShop.Spawners[Spawner].y,
        z = Config.ChopShop.Spawners[Spawner].z + 1.5,
        a = Config.ChopShop.Spawners[Spawner].w,
    }, false, Plate)

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    SetVehicleDoorsLocked(Vehicle, 2)

    ChopVehicles[ActivityId] = {
        NetId = NetId,
        Vehicle = Vehicle,
    }

    Citizen.SetTimeout(500, function()
        for k, v in pairs(Group.Members) do
            local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
            TriggerClientEvent("fw-jobmanager:Client:Chopshop:CreateBlip", Target.PlayerData.source, Config.ChopShop.Spawners[Spawner], NetId)
        end
    end)
end)

RegisterNetEvent("fw-jobmanager:Server:DeleteChopVehicle")
AddEventHandler("fw-jobmanager:Server:DeleteChopVehicle", function(ActivityId, Canceled)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if ChopVehicles[ActivityId] then
        while DoesEntityExist(ChopVehicles[ActivityId].Vehicle) do
            DeleteEntity(ChopVehicles[ActivityId].Vehicle)
            Citizen.Wait(200)
        end

        if not Canceled then
            Player.Functions.AddItem("recycle-mats", math.ceil(math.random(15, 40) * GetLootMultiplier()), nil, nil, true)
        end
    end
end)

FW.RegisterServer("fw-jobmanager:Server:ReceiveChopReward", function(Source, ActivityId, NetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if ChopVehicles[ActivityId] == nil then return end
    if ChopVehicles[ActivityId].NetId ~= NetId then return end

    Player.Functions.AddItem("recycle-mats", math.ceil(math.random(15, 35) * GetLootMultiplier()), nil, nil, true)
end)