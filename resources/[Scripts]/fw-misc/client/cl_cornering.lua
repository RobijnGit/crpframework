local IsCornering, CorneringType, CornerVehicle, CornerZone = false, false, false, false
local CornerPeds, UsedPeds = {}, {}
-- CornerPeds = Peds to sell
-- UsedPeds = Peds that are already checked (for eg. sellers and robbers)

RegisterNetEvent("fw-misc:Client:StartCornering")
AddEventHandler("fw-misc:Client:StartCornering", function(Data, Entity)
    local VehicleCoords = GetEntityCoords(Entity)
    CornerZone = GetNameOfZone(VehicleCoords)

    local CanCorner, Notif = table.unpack(FW.SendCallback("fw-misc:Server:StartCornering", CornerZone, VehicleCoords))
    FW.Functions.Notify(Notif)

    if not CanCorner then
        return
    end

    IsCornering = true
    CorneringType = Data.Type
    CornerVehicle = Entity

    FW.VSync.SetVehicleDoorOpen(CornerVehicle, 5, false, false)

    Citizen.CreateThread(function()
        local FailCounter = 0
        while IsCornering do
            local PlyCoords = GetEntityCoords(PlayerPedId())
            if #(PlyCoords - VehicleCoords) > 50.0 then
                FW.Functions.Notify("Verkoopt gestopt...")
                StopCornering()
                return
            end

            local Peds = GetGamePool('CPed')
            local FoundPed
            for _, Ped in ipairs(Peds) do
                if not IsPedDeadOrDying(Ped, true) and not IsPedAPlayer(Ped) and not IsPedFleeing(Ped) and IsPedOnFoot(Ped) and not IsPedInAnyVehicle(Ped, true)
                and IsPedHuman(Ped) and NetworkGetEntityIsNetworked(Ped) and not IsPedInMeleeCombat(Ped) and not UsedPeds[Ped] and not CornerPeds[Ped] and #(VehicleCoords - GetEntityCoords(Ped)) < 100.0 then
                    FoundPed = Ped
                    FailCounter = 0
                    break
                end
            end

            if not FoundPed then
                FailCounter = FailCounter + 1
                goto Skip
            end

            DoCornerPed(FoundPed, VehicleCoords)

            ::Skip::

            if FailCounter > 10 then
                FW.Functions.Notify("Lijkt dat niemand meer geinteresseerd is hier..")
                StopCornering()
            end

            Citizen.Wait(math.random(1, 2) * (60 * 1000))
        end
    end)
end)

RegisterNetEvent("fw-misc:Client:CorneringSale")
AddEventHandler("fw-misc:Client:CorneringSale", function(Data, Entity)
    if not DoesEntityExist(Entity) or IsPedDeadOrDying(Entity) then
        return
    end

    CornerPeds[Entity] = false

    local HasDrugs = exports['fw-inventory']:HasEnoughOfItem(CorneringType == 'meth' and '1gmeth' or 'weed-bag', 1)
    if not HasDrugs then
        TaskWanderStandard(Entity, 10.0, 10)
        return FW.Functions.Notify("Ik heb meer nodig..")
    end

    RequestAnimDict("mp_safehouselost@")
    while not HasAnimDictLoaded("mp_safehouselost@") do
        Citizen.Wait(10)
    end

    SetPedCanRagdoll(PlayerPedId(), false)
    PlayAmbientSpeech1(Entity, 'Generic_Hi', 'Speech_Params_Force')
    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, 1000)
    TaskPlayAnim(PlayerPedId(), 'mp_safehouselost@', 'package_dropoff', 8.0, -8.0, -1, 4096, 0, false, false, false)

    FW.TriggerServer("fw-illegal:Server:SyncCornerSale", GetEntityCoords(Entity), NetworkGetNetworkIdFromEntity(Entity))

    Citizen.Wait(2000)

    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    local IsInGangTurf = Gang and Gang.Id and exports['fw-graffiti']:IsInGangTurf(Gang.Id) or false

    SetPedCanRagdoll(PlayerPedId(), true)
    local DidSale = FW.SendCallback('fw-illegal:Server:CornerSale', CorneringType, GetEntityCoords(Entity), NetworkGetNetworkIdFromEntity(Entity), CornerZone, IsInGangTurf)
    if not DidSale then
        return
    end

    if math.random() < 0.05 then
        TriggerServerEvent("fw-mdw:Server:SendAlert:Oxy", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())
    end

    PlayAmbientSpeech1(Entity, 'Chat_State', 'Speech_Params_Force')

    if math.random() < 0.12 then
        FW.TriggerServer("fw-illegal:Server:CornerMoney")
    end
end)

RegisterNetEvent("fw-misc:Client:SyncHandoff")
AddEventHandler("fw-misc:Client:SyncHandoff", function(Coords, NetId)
    if #(GetEntityCoords(PlayerPedId()) - Coords) > 100.0 then
        return
    end

    local Ped = NetworkGetEntityFromNetworkId(NetId)
    local Relation = GetPedRelationshipGroupHash(Ped)

    SetRelationshipBetweenGroups(0, GetHashKey("PLAYER"), Relation)
    SetRelationshipBetweenGroups(0, Relation, GetHashKey("PLAYER"))

    if NetworkHasControlOfEntity(Ped) then
        RequestAnimDict("mp_safehouselost@")
        while not HasAnimDictLoaded("mp_safehouselost@") do
            Citizen.Wait(10)
        end

        local TaskSequenceId = OpenSequenceTask()
        TaskSetBlockingOfNonTemporaryEvents(0, true)
        TaskTurnPedToFaceEntity(0, PlayerPedId(), 0)
        TaskPlayAnim(0, 'mp_safehouselost@', 'package_dropoff', 8.0, -8.0, -1, 0, 0, false, false, false)
        TaskSetBlockingOfNonTemporaryEvents(0, false)
        TaskWanderStandard(0, 10.0, 10)
        CloseSequenceTask(TaskSequenceId)

        TaskPerformSequence(Ped, TaskSequenceId)
        ClearSequenceTask()
        SetPedKeepTask(Ped, true)
    end
end)

function DoCornerPed(Ped, CornerCoords)
    local Retval, Coords = GetPointOnRoadSide(CornerCoords.x, CornerCoords.y, CornerCoords.z, 1)

    UsedPeds[Ped] = true
    CornerPeds[Ped] = true

    if NetworkHasControlOfEntity(Ped) then
        local RobChance = math.random(1, 100)
        if RobChance > 98.99 then
            CornerPedRobTrunk(Ped, Coords, CornerVehicle)
            CornerPeds[Ped] = false
        else
            CornerPedWalkToCorner(Ped, Coords)
        end
    end
end

function CornerPedRobTrunk(Ped, Coords, Vehicle)
    ClearPedTasksImmediately(Ped)

    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(10)
    end

    local TaskSequenceId = OpenSequenceTask()
    TaskSetBlockingOfNonTemporaryEvents(0, true)
    TaskFollowNavMeshToCoord(0, Coords, 10.0, -1, 1.0, true, 40000.0)
    TaskTurnPedToFaceEntity(0, Vehicle, 0)
    TaskPlayAnim(0, 'mini@repair', 'fixing_a_player', 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskSetBlockingOfNonTemporaryEvents(0, false)
    TaskSmartFleePed(0, PlayerPedId(), 100.0, -1, false, false)
    CloseSequenceTask(TaskSequenceId)

    TaskPerformSequence(Ped, TaskSequenceId)
    ClearSequenceTask()
    SetPedKeepTask(Ped, true)

    SetEntityAsMissionEntity(Ped, true, true)
    Citizen.SetTimeout(12000, function()
        SetEntityAsNoLongerNeeded(Ped)
        SetPedKeepTask(Ped, false)
    end)
    -- Maybe add that you actually lose items?
end

function CornerPedWalkToCorner(Ped, Coords)
    ClearPedTasksImmediately(Ped)

    local AnimDict, AnimName = GetRandomIdleAnim()
    RequestAnimDict(AnimDict)

    while not HasAnimDictLoaded(AnimDict) do
        Citizen.Wait(10)
    end

    local RandomLength = (math.random() * 7.0) + 3.0
    local TaskSequenceId = OpenSequenceTask()
    TaskSetBlockingOfNonTemporaryEvents(0, true)
    TaskFollowNavMeshToCoord(0, Coords, 1.0, -1, RandomLength, true, 40000.0)
    TaskTurnPedToFaceEntity(0, PlayerPedId(), 0)
    TaskPlayAnim(0, AnimDict, AnimName, 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskPause(0, 10000)
    TaskSetBlockingOfNonTemporaryEvents(0, false)
    TaskWanderStandard(0, 10.0, 10)
    CloseSequenceTask(TaskSequenceId)

    TaskPerformSequence(Ped, TaskSequenceId)
    ClearSequenceTask()
    SetPedKeepTask(Ped, true)

    SetEntityAsMissionEntity(Ped, true, true)
    Citizen.SetTimeout(120000, function()
        SetEntityAsNoLongerNeeded(Ped)
        SetPedKeepTask(Ped, false)
    end)
end

function GetRandomIdleAnim()
    local Anims = {
        { 'anim@mp_corona_idles@male_c@idle_a', 'idle_a' },
        { 'friends@fra@ig_1', 'base_idle' },
        { 'amb@world_human_hang_out_street@male_b@idle_a', 'idle_b' },
        { 'anim@heists@heist_corona@team_idles@male_a', 'idle' },
        { 'anim@mp_celebration@idles@female', 'celebration_idle_f_a' },
        { 'anim@mp_corona_idles@female_b@idle_a', 'idle_a' },
        { 'random@shop_tattoo', '_idle_a' },
    }

    return table.unpack(Anims[math.random(#Anims)])
end

function IsCorneringActive(Type)
    if Type then
        return IsCornering and CorneringType == Type
    end

    return IsCornering
end
exports("IsCorneringActive", IsCorneringActive)

function IsCorneringVehicle()
    return true
end
exports("IsCorneringVehicle", IsCorneringVehicle)

function IsCorneringPed(Entity)
    return CornerPeds[Entity]
end
exports("IsCorneringPed", IsCorneringPed)

function StopCornering()
    FW.VSync.SetVehicleDoorShut(CornerVehicle, 5, true)

    for Ped, _ in pairs(UsedPeds) do
        SetEntityAsNoLongerNeeded(Ped)
        SetPedKeepTask(Ped, false)
        TaskWanderStandard(Ped, 10.0, 10)
    end

    IsCornering = false
    CorneringType = false
    CornerVehicle = false

    SetTimeout(90000, function()
        if not IsCornering then
            UsedPeds, CornerPeds = {}, {}
        end
    end)
end
RegisterNetEvent("fw-misc:Client:StopCornering")
AddEventHandler("fw-misc:Client:StopCornering", StopCornering)