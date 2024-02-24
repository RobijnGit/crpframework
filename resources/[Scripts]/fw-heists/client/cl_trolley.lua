local RobbingTrolley = false
local Trollies = {}
local TrolleyTypes = {
    Cash = GetHashKey('ch_prop_ch_cash_trolly_01c'),
    Gold = GetHashKey('ch_prop_gold_trolly_01c')
}

function SpawnTrolley(Id, Type, Coords)
    if not TrolleyTypes[Type] then
        return print("Invalid Trolley Type.")
    end

    if Trollies[Id] and DoesEntityExist(Trollies[Id].Object) then
        print("Already exists, creating new.")
        DeleteTrolley(Id)
    end

    print("Creating trolley: ", Id, Type, Coords, TrolleyTypes[Type])

    exports['fw-assets']:RequestModelHash(TrolleyTypes[Type])
    local TrolleyObject = CreateObject(TrolleyTypes[Type], Coords.x, Coords.y, Coords.z, true, false, false)
    SetEntityHeading(TrolleyObject, Coords.w)
    PlaceObjectOnGroundProperly(TrolleyObject)

    Trollies[Id] = {
        Type = Type,
        Object = TrolleyObject,
    }
end

function DeleteTrolley(Id)
    NetworkRequestControlOfEntity(Trollies[Id].Object)
    while not NetworkHasControlOfEntity(Trollies[Id].Object) do
        Citizen.Wait(1)
    end

    DeleteEntity(Trollies[Id].Object)
    Trollies[Id] = {}
end

RegisterNetEvent("fw-heists:Client:Trolley:Grab")
AddEventHandler("fw-heists:Client:Trolley:Grab", function(Data, Entity)
    if RobbingTrolley then
        return
    end

    local Coords = GetEntityCoords(Entity)
    local TrolleyId, TrolleyType = 0, nil

    for k, v in pairs(Trollies) do
        if v.Object == Entity or #(GetEntityCoords(v.Object) - Coords) < 1.0 then
            TrolleyId, TrolleyType = k, v.Type
            break
        end
    end

    if TrolleyId == 0 or TrolleyType == nil then
        return print("Invalid Trolly or Trolly Type")
    end

    if DataManager.Get("trolley-" .. TrolleyId, 0) ~= 0 then

        return FW.Functions.Notify("Dit kan je nu niet doen..", "error")
    end
    
    DataManager.Set("trolley-" .. TrolleyId, 1)
    RobbingTrolley = true

    local PropsCache = {}
    local PlyCoords = GetEntityCoords(PlayerPedId())
    local BagProp, GrabProp = "hei_p_m_bag_var22_arm_s", "hei_prop_heist_cash_pile"

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    if GetEntityModel(Entity) == TrolleyTypes.Gold then
        GrabProp = 'ch_prop_gold_bar_01a'
    end

    exports['fw-assets']:RequestModelHash(BagProp)
    exports['fw-assets']:RequestModelHash(GrabProp)
    exports['fw-assets']:RequestAnimationDict('anim@heists@ornate_bank@grab_cash')

    local GrabObject = CreateObject(GetHashKey(GrabProp), PlyCoords, true)
    FreezeEntityPosition(GrabObject, true)
    SetEntityInvincible(GrabObject, true)
    SetEntityNoCollisionEntity(GrabObject, PlayerPedId())
    SetEntityVisible(GrabObject, false, false)
    AttachEntityToEntity(GrabObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)

    table.insert(PropsCache, GrabObject)

    local StartedGrabbing = GetGameTimer()
    Citizen.CreateThread(function()
        while GetGameTimer() - StartedGrabbing < 37000 do
            Citizen.Wait(4)
            DisableControlAction(0, 73, true)
            if HasAnimEventFired(PlayerPedId(), GetHashKey("CASH_APPEAR")) then
                if not IsEntityVisible(GrabObject) then
                    SetEntityVisible(GrabObject, true, false)
                end
            end
            if HasAnimEventFired(PlayerPedId(), GetHashKey("RELEASE_CASH_DESTROY")) then
                if IsEntityVisible(GrabObject) then
                    SetEntityVisible(GrabObject, false, false)
                end
            end
        end
    end)

    NetworkRequestControlOfEntity(Entity)
    while not NetworkHasControlOfEntity(Entity) do
        Citizen.Wait(1)
    end

    local BagObject = CreateObject(GetHashKey(BagProp), GetEntityCoords(PlayerPedId()), true, false, false)
    table.insert(PropsCache, BagObject)

    local GrabAnimationOne = NetworkCreateSynchronisedScene(GetEntityCoords(Entity), GetEntityRotation(Entity), 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), GrabAnimationOne, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(BagObject, GrabAnimationOne, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(GrabAnimationOne)
    Citizen.Wait(1500)

    local GrabAnimationTwo = NetworkCreateSynchronisedScene(GetEntityCoords(Entity), GetEntityRotation(Entity), 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), GrabAnimationTwo, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(BagObject, GrabAnimationTwo, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(Entity, GrabAnimationTwo, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(GrabAnimationTwo)
    Citizen.Wait(37000)

    local GrabAnimationThree = NetworkCreateSynchronisedScene(GetEntityCoords(Entity), GetEntityRotation(Entity), 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), GrabAnimationThree, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(BagObject, GrabAnimationThree, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(GrabAnimationThree)
    Citizen.Wait(1800)

    for k, v in pairs(PropsCache) do
        DeleteEntity(v)
    end
    
    DataManager.Set("trolley-" .. TrolleyId, 2)
    FW.TriggerServer("fw-heists:Server:Trolley:PayoutGrab", TrolleyId, Trollies[TrolleyId])

    Citizen.SetTimeout(250, function()
        DeleteTrolley(TrolleyId)
        RobbingTrolley = false
    end)
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("ch_prop_ch_cash_trolly_01c"), {
        Type = 'Model',
        Model = 'ch_prop_ch_cash_trolly_01c',
        SpriteDistance = 5.0,
        Distance = 1.3,
        Options = {
            {
                Name = 'heist_trolly',
                Icon = 'fas fa-hand-holding-usd',
                Label = 'Meenemen!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Trolley:Grab',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
    exports['fw-ui']:AddEyeEntry(GetHashKey("ch_prop_gold_trolly_01c"), {
        Type = 'Model',
        Model = 'ch_prop_gold_trolly_01c',
        SpriteDistance = 5.0,
        Distance = 1.3,
        Options = {
            {
                Name = 'heist_trolly',
                Icon = 'fas fa-hand-holding-usd',
                Label = 'Meenemen!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Trolley:Grab',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
end)