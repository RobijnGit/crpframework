local TowingVehicle, ImpoundVehicle, JobData = false, false, false
local RentedFlatbed = false

-- Impound Job
RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'impound' then return end
    JobData = Data

    if IsLeader then
        TriggerServerEvent("fw-jobmanager:Server:Impound:CreateImpoundVehicle", Data, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)

        Citizen.SetTimeout(250, function()
            if IsPedInAnyVehicle(PlayerPedId()) and GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) == GetHashKey("flatbed") then
                FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'impound' then return end
    TriggerServerEvent('fw-jobmanager:Server:Impound:DeleteImpoundVehicle', MyJob.CurrentGroup.Activity.Id, JobData, false)
    JobData = false
    
    RemoveRouteBlip()
    FW.VSync.DeleteVehicle(ImpoundVehicle)
end)

RegisterNetEvent("fw-jobmanager:Client:Impound:CreateBlip")
AddEventHandler("fw-jobmanager:Client:Impound:CreateBlip", function(Coords, NetId)
    Citizen.SetTimeout(500, function()
        SetRouteBlip("Voertuig", Coords)
    
        Citizen.CreateThread(function()
            while true do
                if CurrentTaskId == 3 then
                    RemoveRouteBlip()
                    break
                end
                
                if GetEntityModel(GetVehiclePedIsIn(PlayerPedId())) == GetHashKey("flatbed") and MyJob.CurrentGroup and #(GetEntityCoords(PlayerPedId()) - vector3(Coords.x, Coords.y, Coords.z)) < 10.0 then
                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
                end
                
                Citizen.Wait(1000)
            end
        end)

        while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
        local Vehicle = NetToVeh(NetId)

        ImpoundVehicle = Vehicle
        print("ImpoundVehicle set to " .. Vehicle)
    end)
end)

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    if MyJob.CurrentJob ~= 'impound' then return end
    
    if Vehicle == 0 or Vehicle == -1 then return end
    if GetEntityModel(Vehicle) ~= GetHashKey("flatbed") then return end
    
    if CurrentTaskId == 1 then
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
    end
end)

-- Actual Towing
exports("IsTowingVehicle", function()
    return DoesEntityExist(TowingVehicle)
end)

RegisterNetEvent("fw-jobmanager:Client:TowVehicle")
AddEventHandler("fw-jobmanager:Client:TowVehicle", function(Data, Entity)
    if DoesEntityExist(TowingVehicle) then return end

    if GetEntityModel(Entity) ~= GetHashKey("flatbed") then
        return FW.Functions.Notify("Dit is geen flatbed..")
    end

    local VehicleSpot = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -8.5, -1.0)
    local Vehicle, Distance = FW.Functions.GetClosestVehicle(VehicleSpot)

    if not Vehicle or not DoesEntityExist(Vehicle) then
        return FW.Functions.Notify("Je hebt geen voertuig achter je flatbed staan..")
    end

    if MyJob.CurrentJob and MyJob.CurrentJob == 'impound' and DoesEntityExist(ImpoundVehicle) and Vehicle ~= ImpoundVehicle then
        return FW.Functions.Notify("Dit is niet het voertuig die je moet wegslepen..")
    end

    local Finished = FW.Functions.CompactProgressbar(20000, "Haak aansluiten..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 0 }, {}, {}, false)
    if not Finished then return end

    TriggerEvent("fw-misc:Client:PlaySoundEntity", 'vehicle.flatbedTow', NetworkGetNetworkIdFromEntity(Entity), true, nil)
    FW.Functions.CompactProgressbar(5000, "Voertuig aan het takelen..", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 0 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)

    TowingVehicle = Vehicle
    NetworkRequestControlOfEntity(TowingVehicle)

    local Min, Max = GetModelDimensions(GetEntityModel(TowingVehicle))
    local ModelSize = (Max - Min)

    AttachEntityToEntity(TowingVehicle, Entity, GetEntityBoneIndexByName(Entity, 'bodyshell'), 0.0, -2.35, (ModelSize.z / 2) - 0.15, 0, 0, 0, 1, 1, 1, 1, 0, 1)
    FreezeEntityPosition(TowingVehicle, true)

    if MyJob.CurrentJob and MyJob.CurrentJob == 'impound' then
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
    end
end)

RegisterNetEvent("fw-jobmanager:Client:UntowVehicle")
AddEventHandler("fw-jobmanager:Client:UntowVehicle", function(Data, Entity)
    if not DoesEntityExist(TowingVehicle) then return print("no existy") end

    local Finished = FW.Functions.CompactProgressbar(10000, "Haak afkoppelen..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 0 }, {}, {}, false)
    if not Finished then return end

    TriggerEvent("fw-misc:Client:PlaySoundEntity", 'vehicle.flatbedTow', NetworkGetNetworkIdFromEntity(Entity), true, nil)
    FW.Functions.CompactProgressbar(5000, "Voertuig aan het aftakelen..", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 0 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)

    local VehicleSpot = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -8.5, -1.0)
    NetworkRequestControlOfEntity(TowingVehicle)
    DetachEntity(TowingVehicle, true, true)
    FreezeEntityPosition(TowingVehicle, false)
    SetEntityCoords(TowingVehicle, VehicleSpot.x, VehicleSpot.y, VehicleSpot.z)
    SetEntityHeading(TowingVehicle, GetEntityHeading(Entity))

    if MyJob.CurrentJob and MyJob.CurrentJob == 'impound' and CurrentTaskId == 4 then
        if #(GetEntityCoords(PlayerPedId()) - vector3(1014.12, -2341.75, 30.51)) < 20.0 then
            TriggerServerEvent("fw-jobmanager:Server:Impound:DeleteImpoundVehicle", MyJob.CurrentGroup.Activity.Id, JobData, true)
            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        end
    else
        FW.Functions.DeleteVehicle(TowingVehicle)
    end

    TowingVehicle = false
end)

RegisterNetEvent("fw-jobmanager:Client:Impound:RentFlatbed")
AddEventHandler("fw-jobmanager:Client:Impound:RentFlatbed", function()
    local Plate = ("FL" .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(3)):upper()
    local Coords = vector4(1010.79, -2293.24, 30.6, 265.61)
    if not FW.Functions.IsSpawnPointClear(vector3(Coords.x, Coords.y, Coords.z), 1.85) then
        return FW.Functions.Notify("Er staat een voertuig in de weg..", "error")
    end

    local Paid = FW.SendCallback("FW:RemoveCash", 1500)
    if not Paid then
        return FW.Functions.Notify("Niet genoeg cash..", "error")
    end

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", "flatbed", { x = Coords.x, y = Coords.y, z = Coords.z - 1.0, a = Coords.w }, false, Plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end

    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    NetworkRequestControlOfEntity(Vehicle)

    TriggerServerEvent('fw-vehicles:Server:ReceiveRentalPapers', Plate)
    exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
    exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
    
    Citizen.SetTimeout(500, function()
        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)
        SetVehicleDirtLevel(Vehicle, 0.0)
        RentedFlatbed = Vehicle
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:Impound:ReturnFlatbed")
AddEventHandler("fw-jobmanager:Client:Impound:ReturnFlatbed", function()
    if not RentedFlatbed or not DoesEntityExist(RentedFlatbed) then
        return
    end

    local Health = GetVehicleEngineHealth(RentedFlatbed)
    DeleteEntity(RentedFlatbed)
    RentedFlatbed = false
    FW.TriggerServer("fw-jobmanager:Server:Impound:ReturnFlatbed", math.floor(1500 * (Health / 1000)))
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("rent-flatbed", {
        Type = "Zone",
        SpriteDistance = 5.0,
        Distance = 2.5,
        ZoneData = {
            Center = vector3(1002.88, -2306.53, 30.64),
            Length = 0.4,
            Width = 1.6,
            Data = {
                heading = 355,
                minZ = 30.34,
                maxZ = 31.09
            },
        },
        Options = {
            {
                Name = "grab",
                Icon = "fas fa-truck-container",
                Label = "Flatbed Huren (€1,500)",
                EventType = "Client",
                EventName = "fw-jobmanager:Client:Impound:RentFlatbed",
                EventParams = {},
                Enabled = function()
                    return not RentedFlatbed
                end,
            },
            {
                Name = "return",
                Icon = "fas fa-sign-out-alt",
                Label = "Flatbed Teruggeven",
                EventType = "Client",
                EventName = "fw-jobmanager:Client:Impound:ReturnFlatbed",
                EventParams = {},
                Enabled = function()
                    return RentedFlatbed
                end,
            },
        }
    })
end)