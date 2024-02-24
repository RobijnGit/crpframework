local ImpoundVehicles = {}

RegisterNetEvent("fw-jobmanager:Server:Impound:AddImpoundRequest")
AddEventHandler("fw-jobmanager:Server:Impound:AddImpoundRequest", function(NetId)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    local Coords = GetEntityCoords(Vehicle)
    
    local RequestId = #Config.ImpoundRequests + 1
    Config.ImpoundRequests[RequestId] = {
        Id = RequestId,
        Model = GetEntityModel(Vehicle),
        Plate = GetVehicleNumberPlateText(Vehicle),
        Coords = vector4(Coords.x, Coords.y, Coords.z, GetEntityHeading(Vehicle)),
        NetId = NetId,
    }

    if exports['fw-boosting']:IsBoostingVehicle(GetVehicleNumberPlateText(Vehicle)) then
        TriggerEvent("fw-boosting:Server:OnImpound", GetVehicleNumberPlateText(Vehicle))
    end
end)

RegisterNetEvent("fw-jobmanager:Server:Impound:CreateImpoundVehicle")
AddEventHandler("fw-jobmanager:Server:Impound:CreateImpoundVehicle", function(Data, GroupId, ActivityId)
    local Source = source
    local Group = JobCenter.GetGroup("impound", GroupId)
    if Group == nil then return end

    local Model, Coords = Data.Model, Data.Coords
    local Plate, NetId, Vehicle = false, false, false

    if not Data.IsRequest then
        Plate = (FW.Shared.RandomStr(3) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()
        NetId = FW.Functions.SpawnVehicle(Source, Model, {
            x = Coords.x,
            y = Coords.y,
            z = Coords.z,
            a = Coords.w,
        }, false, Plate)
    
        Vehicle = NetworkGetEntityFromNetworkId(NetId)
        SetVehicleDoorsLocked(Vehicle, 2)
    else
        NetId = Config.ImpoundRequests[Data.RequestId].NetId
        Vehicle = NetworkGetEntityFromNetworkId(NetId)
    end

    ImpoundVehicles[ActivityId] = {
        NetId = NetId,
        Vehicle = Vehicle,
    }

    Citizen.SetTimeout(500, function()
        for k, v in pairs(Group.Members) do
            local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
            TriggerClientEvent("fw-jobmanager:Client:Impound:CreateBlip", Target.PlayerData.source, Coords, NetId)
        end
    end)
end)

RegisterNetEvent("fw-jobmanager:Server:Impound:DeleteImpoundVehicle")
AddEventHandler("fw-jobmanager:Server:Impound:DeleteImpoundVehicle", function(ActivityId, JobData, WasCompleted)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if JobData.IsRequest then
        if not WasCompleted then
            for k, v in pairs(Config.ImpoundRequests) do
                if v.Id == JobData.RequestId then
                    v.AlreadyTaken = false
                    break
                end
            end
        else
            for k, v in pairs(Config.ImpoundRequests) do
                if v.Id == JobData.RequestId then
                    local Plate = v.Plate
                    local Result = exports['ghmattimysql']:executeSync("SELECT `vinscratched` FROM `player_vehicles` WHERE `plate` = @Plate", {
                        ['@Plate'] = Plate
                    })

                    if Result[1] and Result[1].vinscratched == 1 then
                        exports['ghmattimysql']:executeSync("DELETE FROM `player_vehicles` WHERE `plate` = @Plate", {
                            ["@Plate"] = Plate
                        })
                    end

                    table.remove(Config.ImpoundRequests, k)
                    break
                end
            end
        end
    end

    if ImpoundVehicles[ActivityId] then
        while DoesEntityExist(ImpoundVehicles[ActivityId].Vehicle) do
            DeleteEntity(ImpoundVehicles[ActivityId].Vehicle)
            Citizen.Wait(200)
        end
    end
end)

FW.RegisterServer("fw-jobmanager:Server:Impound:ReturnFlatbed", function(Source, ReturnPrice)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddMoney("cash", ReturnPrice)
end)