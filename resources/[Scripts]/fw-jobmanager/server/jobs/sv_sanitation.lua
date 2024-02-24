local SanitationVehicles, SanitationDumpsters = {}, {}

RegisterNetEvent("fw-jobmanager:Server:SpawnSanitationVehicle")
AddEventHandler("fw-jobmanager:Server:SpawnSanitationVehicle", function(GroupId, ActivityId)
    local Source = source
    local Group = JobCenter.GetGroup("sanitation", GroupId)
    if Group == nil then return end

    local VehicleModel = math.random(#Config.ChopShop.Vehicles)
    local Spawner = vector4(-335.41, -1564.36, 24.95, 60.2)
    local Plate = (FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()

    local NetId = FW.Functions.SpawnVehicle(Source, 'trash', {
        x = Spawner.x,
        y = Spawner.y,
        z = Spawner.z,
        a = Spawner.w,
    }, false, Plate)

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)

    SanitationVehicles[ActivityId] = {
        NetId = NetId,
        Vehicle = Vehicle,
    }

    for k, v in pairs(Group.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        TriggerClientEvent("fw-jobmanager:Client:SetSanitationVehicle", Target.PlayerData.source, NetId)
    end
end)

RegisterNetEvent("fw-jobmanager:Server:DeleteSanitationVehicle")
AddEventHandler("fw-jobmanager:Server:DeleteSanitationVehicle", function(ActivityId)
    if SanitationVehicles[ActivityId] then
        while DoesEntityExist(SanitationVehicles[ActivityId].Vehicle) do
            DeleteEntity(SanitationVehicles[ActivityId].Vehicle)
            Citizen.Wait(200)
        end
    end
end)

RegisterNetEvent("fw-jobmanager:Server:GiveSanitationReward")
AddEventHandler("fw-jobmanager:Server:GiveSanitationReward", function(GroupId, ActivityId)
    local Group = JobCenter.GetGroup("sanitation", GroupId)
    if Group == nil then return end
    if Group.Activity.Id ~= ActivityId then return end

    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddItem("recycle-mats", math.random(10, 20), nil, nil, true)
end)

FW.Functions.CreateCallback("fw-jobmanager:Server:Sanitation:IsDumpsterEmpty", function(Source, Cb, NetId)
    if SanitationDumpsters[NetId] == nil then
        SanitationDumpsters[NetId] = math.random(1, 3)

        SetTimeout((60 * 1000) * 30, function()
            SanitationDumpsters[NetId] = nil
        end)
    end

    if SanitationDumpsters[NetId] == 0 then
        Cb(true)
        return
    end

    SanitationDumpsters[NetId] = SanitationDumpsters[NetId] - 1
    Cb(false)
end)

RegisterNetEvent('fw-jobmanager:Server:Sanitation:DeleteBinbag', function(NetId)
    SanitationDumpsters[NetId] = 0
    DeleteEntity(NetworkGetEntityFromNetworkId(NetId))
end)