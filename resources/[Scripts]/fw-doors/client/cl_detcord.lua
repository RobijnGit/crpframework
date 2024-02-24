local AlreadyDetcording = false

-- // Events \\ --

RegisterNetEvent('fw-doors:Client:Used:Detcord')
AddEventHandler('fw-doors:Client:Used:Detcord', function()
    Citizen.SetTimeout(450, function()
        local PlayerData = FW.Functions.GetPlayerData()
        if PlayerData.job.name ~= 'police' then FW.Functions.Notify("Leuk zo'n speeltje, maar wat moet ik ermee?", "error") return end

        -- Housing
        if exports['fw-housing']:GetCurrentHouse() then 
            local HouseData = exports['fw-housing']:GetCurrentHouse()
            if not HouseData.Locked then return end
            local Coords = vector3(HouseData.Coords.x, HouseData.Coords.y, GetEntityCoords(PlayerPedId()).z + 0.5)
            local DetcordDone = DoDetcord(Coords)
            if DetcordDone then
                TriggerEvent('fw-housing:Client:LockProperty', HouseData.Id, true)
            end
        else
            -- Doorlocks
            local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())
            if Entity == 0 or Entity == -1 or EntityType ~= 3 then return end
            local DoorId = GetTargetDoorId(Entity)
            if not CanDetcordDoor(DoorId) then 
                FW.Functions.Notify("Deze deur kan niet worden gedetcord worden.", "error")
                return 
            end
            local DetcordDone = DoDetcord(EntityCoords)
            if DetcordDone then
                TriggerServerEvent('fw-doors:Server:SetLockState', DoorId, 0)
                if Config.Doors[DoorId].Connected ~= nil and next(Config.Doors[DoorId].Connected) then
                    for k, v in pairs(Config.Doors[DoorId].Connected) do
                        TriggerServerEvent('fw-doors:Server:SetLockState', v, 0)
                    end
                end
            end
        end
    end)
end)

-- // Functions \\ --

function CanDetcordDoor(DoorId)
    if DoorId == nil or Config.Doors[DoorId] == nil then return false end
    if Config.Doors[DoorId].Locked == 1 then
        return Config.Doors[DoorId].CanDetcord
    else
        return false
    end
end

function DoDetcord(Coords)
    if AlreadyDetcording then return end

    local Coords = vector3(Coords.x, Coords.y, Coords.z - 0.4)

    AlreadyDetcording = true
    RequestModel("hei_p_m_bag_var22_arm_s")
    while not HasModelLoaded("hei_p_m_bag_var22_arm_s") do Citizen.Wait(4) end
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") do Citizen.Wait(4) end


    Citizen.Wait(100)
    local Rotation = GetEntityRotation(PlayerPedId())
    HeistBagScene = NetworkCreateSynchronisedScene(Coords.x, Coords.y, Coords.z, Rotation.x, Rotation.y, Rotation.z, 2, false, false, 1065353216, 0, 1.3)

    local HeistBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), Coords.x, Coords.y, Coords.z, true,  true, false)
    SetEntityCollision(HeistBag, false, true)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), HeistBagScene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(HeistBag, HeistBagScene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(HeistBagScene)

    Citizen.Wait(1500)

    local HeistThermite = CreateObject(GetHashKey("hei_prop_heist_thermite"), Coords.x, Coords.y, Coords.z, true,  true, true)
    SetEntityCollision(HeistThermite, false, true)
    AttachEntityToEntity(HeistThermite, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(4000)
    DeleteEntity(HeistBag)

    DetachEntity(HeistThermite, 1, 1)
    FreezeEntityPosition(HeistThermite, true)
    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'detcord', 1, false)
    
    Citizen.Wait(1500)

    TriggerServerEvent('fw-assets:Server:Fx:Thermite', Coords, true)
    TaskPlayAnim(Ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(Ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 6000, 49, 1, 0, 0, 0)
    Citizen.Wait(2000)
    ClearPedTasks(Ped)
    Citizen.Wait(11000)

    DeleteEntity(HeistThermite)
    AlreadyDetcording = false

    return true
end