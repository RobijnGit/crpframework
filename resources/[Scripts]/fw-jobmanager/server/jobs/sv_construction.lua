local ConstructionVehicles = {}

FW.RegisterServer("fw-jobmanager:Server:SetConstrucionObjective", function(Source, GroupId, ObjectiveId, Busy, Completed)
    local Group = JobCenter.GetGroup("construction", GroupId)
    if Group == nil then return end

    if Completed and math.random() > 0.6 then
        local Player = FW.Functions.GetPlayer(Source)
        if Player then
            Player.Functions.AddItem("recycle-mats", math.random(10, 20), nil, nil, true)
        end
    end

    for k, v in pairs(Group.Members) do
        local Player = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Player then
            TriggerClientEvent("fw-jobmanager:Client:SetObjectiveData", Player.PlayerData.source, ObjectiveId, Busy, Completed)
        end
    end
end)

RegisterNetEvent("fw-jobmanager:Server:SpawnConstructionVehicle")
AddEventHandler("fw-jobmanager:Server:SpawnConstructionVehicle", function(GroupId, ActivityId)
    local Source = source
    local Group = JobCenter.GetGroup("construction", GroupId)
    if Group == nil then return end

    local Spawner = vector4(1129.95, -1299.55, 34.63, 358.09)
    local Plate = (FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()

    local NetId = FW.Functions.SpawnVehicle(Source, 'tiptruck2', {
        x = Spawner.x,
        y = Spawner.y,
        z = Spawner.z,
        a = Spawner.w,
    }, false, Plate)

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)

    ConstructionVehicles[ActivityId] = {
        NetId = NetId,
        Vehicle = Vehicle,
    }

    for k, v in pairs(Group.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        TriggerClientEvent("fw-jobmanager:Client:SetConstructionVehicle", Target.PlayerData.source, NetId)
    end
end)

RegisterNetEvent("fw-jobmanager:Server:DeleteConstructionVehicle")
AddEventHandler("fw-jobmanager:Server:DeleteConstructionVehicle", function(ActivityId)
    if ConstructionVehicles[ActivityId] then
        while DoesEntityExist(ConstructionVehicles[ActivityId].Vehicle) do
            DeleteEntity(ConstructionVehicles[ActivityId].Vehicle)
            Citizen.Wait(200)
        end
    end
end)