local DeliveryVehicles = {}

RegisterNetEvent("fw-jobmanager:Server:SpawnDeliveryVehicle")
AddEventHandler("fw-jobmanager:Server:SpawnDeliveryVehicle", function(GroupId, ActivityId)
    local Source = source
    local Group = JobCenter.GetGroup("postop", GroupId)
    if Group == nil then return end

    local Spawner = vector4(929.08, -1227.19, 25.58, 93.71)
    local Plate = (FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()

    local NetId = FW.Functions.SpawnVehicle(Source, 'benson', {
        x = Spawner.x,
        y = Spawner.y,
        z = Spawner.z,
        a = Spawner.w,
    }, false, Plate)

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)

    DeliveryVehicles[ActivityId] = {
        NetId = NetId,
        Vehicle = Vehicle,
    }

    for k, v in pairs(Group.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        TriggerClientEvent("fw-jobmanager:Client:SetDeliveryVehicle", Target.PlayerData.source, NetId)
    end
end)

RegisterNetEvent("fw-jobmanager:Server:DeleteDeliveryVehicle")
AddEventHandler("fw-jobmanager:Server:DeleteDeliveryVehicle", function(ActivityId)
    if DeliveryVehicles[ActivityId] then
        while DoesEntityExist(DeliveryVehicles[ActivityId].Vehicle) do
            DeleteEntity(DeliveryVehicles[ActivityId].Vehicle)
            Citizen.Wait(200)
        end
    end
end)