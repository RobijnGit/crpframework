local IsAttachingRope, RopeVehicle = false, false
local ActiveRopes, ATMRopes = {}, {}

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    local ATMs = { "fw_fleeca_atm_console", "fw_atm_02_console", "fw_atm_03_console" }
    for k, v in pairs(ATMs) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
            Type = 'Model',
            Model = v,
            Distance = 2.5,
            Options = {
                {
                    Name = 'search',
                    Icon = 'fas fa-money-bill-wave',
                    Label = 'Zoeken naar Cash',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:SearchATM',
                    EventParams = {},
                    Enabled = function(Entity)
                        -- return (not IsEntityPositionFrozen(Entity) and IsAtmNearCity(GetEntityCoords(Entity)))
                        return (not IsEntityPositionFrozen(Entity))
                    end,
                },
                {
                    Name = 'pickup',
                    Icon = 'fas fa-level-up fa-flip-horizontal',
                    Label = 'Pin Automaat Oppakken',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:PickupATM',
                    EventParams = {},
                    Enabled = function(Entity)
                        -- return (not IsEntityPositionFrozen(Entity) and IsAtmNearCity(GetEntityCoords(Entity)))
                        return (not IsEntityPositionFrozen(Entity))
                    end,
                },
            }
        })
    end
end)

RegisterNetEvent("fw-heists:Client:AttachRope")
AddEventHandler("fw-heists:Client:AttachRope", function(Data, Entity)
    if CurrentCops < 2 then
        return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    if DataManager.Get("HeistsDisabled", 0) == 1 then
        return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    -- if not IsAtmNearCity(GetEntityCoords(Entity)) then
    --     return FW.Functions.Notify("Hier kan je niks trekken, behalve jezelf..", "error")
    -- end

    if IsAttachingRope then
        return
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, 1000)
    Citizen.Wait(1000)
    local Finished = FW.Functions.CompactProgressbar(8000, "Sleeptouw koppelen..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 1 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)

    if not Finished then return end
    IsAttachingRope, RopeVehicle = true, Entity

    FW.TriggerServer("fw-heists:Server:CreateRope", NetworkGetNetworkIdFromEntity(Entity))
end)

RegisterNetEvent("fw-heists:Client:DetachRope")
AddEventHandler("fw-heists:Client:DetachRope", function(Data, Entity)
    if not IsAttachingRope then
        return
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, 1000)
    Citizen.Wait(1000)
    local Finished = FW.Functions.CompactProgressbar(8000, "Sleeptouw ontkoppelen..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 1 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)

    if not Finished then return end
    FW.TriggerServer("fw-heists:Server:DetachATM", NetworkGetNetworkIdFromEntity(Entity), false)
end)

RegisterNetEvent("fw-heists:Client:AttachATM")
AddEventHandler("fw-heists:Client:AttachATM", function(Data, Entity)
    if not DoesEntityExist(RopeVehicle) then
        return
    end

    if Config.ATMs[GetEntityModel(Entity)] == nil then
        return
    end

    local Model = Config.ATMs[GetEntityModel(Entity)]
    local BrokenModels = Config.BrokenATMModels[Model]
    if not BrokenModels then return end

    local IsATMCooldown = FW.SendCallback("fw-heists:Server:IsATMRobbed", GetEntityCoords(Entity))
    if IsATMCooldown then
        return FW.Functions.Notify("Deze pin automaat lijkt al gesloopt te zijn..", "error")
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, 1000)
    Citizen.Wait(1000)
    local Finished = FW.Functions.CompactProgressbar(20000, "Sleeptouw koppelen..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "mini@repair", anim = "fixing_a_ped", flags = 1 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_ped", 1.0)

    if not Finished then return end
    local IsRemoved = FW.SendCallback("FW:RemoveItem", 'tow-rope', 1)
    if not IsRemoved then return end

    local Coords = GetEntityCoords(Entity)
    local Heading = GetEntityHeading(Entity)

    local ATMDes = CreateObject(BrokenModels[1], Coords.x, Coords.y, Coords.z + 0.35, true)
    local ATMConsole = CreateObject(BrokenModels[2], Coords.x, Coords.y, Coords.z + 0.65, true)

    SetEntityHeading(ATMDes, Heading)
    SetEntityHeading(ATMConsole, Heading)

    FreezeEntityPosition(ATMDes, true)
    FreezeEntityPosition(ATMConsole, true)

    local NetIdATM = NetworkGetNetworkIdFromEntity(Entity)
    local NetIdVeh = NetworkGetNetworkIdFromEntity(RopeVehicle)
    local NetIdConsole = NetworkGetNetworkIdFromEntity(ATMConsole)

    IsAttachingRope = false
    SetEntityCoords(Entity, Coords.x, Coords.y, Coords.z - 10.0)
    FW.TriggerServer("fw-heists:Server:AttachRopeToATM", NetIdATM, NetIdVeh, NetIdConsole, Coords)
    TriggerServerEvent("fw-mdw:Server:SendAlert:ATM", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())

    Citizen.CreateThread(function()
        while true do

            if IsPedInAnyVehicle(PlayerPedId()) then
                Citizen.Wait(math.random(25, 120) * 1000)
                if GetVehicleCurrentRpm(RopeVehicle) > 0.25 then
                    FW.TriggerServer("fw-heists:Server:DetachATM", NetIdVeh, NetIdConsole)
                    Citizen.SetTimeout(200, function()
                        FreezeEntityPosition(ATMConsole, false)
                        local PlayerPos = GetEntityCoords(PlayerPedId())
                        local Direction = PlayerPos - Coords
                        Direction = Direction / #(Direction)
                        local Force = Direction * 50.0
                        ApplyForceToEntity(ATMConsole, 1, Force.x, Force.y, Force.z, 0.0, 0.0, 0.0, true, true, true, true, true)
                    end)
                end
                break
            end

            Citizen.Wait(4)
        end

        Citizen.SetTimeout((1000 * 60) * 5, function()
            DeleteEntity(ATMDes)
        end)
    end)
end)

RegisterNetEvent("fw-heists:Client:CreateRope")
AddEventHandler("fw-heists:Client:CreateRope", function(Source, NetId)
    local Player = GetPlayerPed(GetPlayerFromServerId(Source))
    if not DoesEntityExist(Player) then return end

    if GetPlayerServerId(PlayerId()) ~= Source then
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(Player)) > 150.0 or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(Player)) == 0 then
            return
        end
    end

    print("[ATM] Creating rope with RopeId: " .. NetId)

    RopeLoadTextures()
    ActiveRopes[NetId] = AddRope(vector3(1.0, 1.0, 1.0), vector3(0.0, 0.0, 0.0), 3.5, 1, 7.0, 1.0, 0, false, false, false, 1.0, false)

    Citizen.CreateThread(function()
        while ActiveRopes[NetId] ~= nil and ATMRopes[NetId] == nil do
            local Vehicle = NetworkGetEntityFromNetworkId(NetId)
            if DoesEntityExist(Vehicle) then
                AttachEntitiesToRope(ActiveRopes[NetId], Vehicle, Player, GetOffsetFromEntityInWorldCoords(Vehicle, 0, -2.3, 0.5), GetPedBoneCoords(Player, 6286, 0.0, 0.0, 0.0), 7.0, 0, 0, "rope_attach_a", "rope_attach_b")
            end
            Citizen.Wait(10)
        end
    end)
end)

RegisterNetEvent("fw-heists:Client:AttachRopeToATM")
AddEventHandler("fw-heists:Client:AttachRopeToATM", function(NetIdATM, NetIdVeh, NetIdConsole, Coords)
    if ActiveRopes[NetIdVeh] == nil then
        return
    end

    local Vehicle = NetworkGetEntityFromNetworkId(NetIdVeh)
    local ATMConsole = NetworkGetEntityFromNetworkId(NetIdConsole)

    if not DoesEntityExist(Vehicle) or not DoesEntityExist(ATMConsole) then
        return
    end

    print("[ATM] Attach rope to ATM with RopeId: " .. NetIdVeh)

    ATMRopes[NetIdVeh] = true
    Citizen.Wait(100)

    local ConsolePos = GetEntityCoords(ATMConsole)
    AttachEntitiesToRope(ActiveRopes[NetIdVeh], Vehicle, ATMConsole, GetOffsetFromEntityInWorldCoords(Vehicle, 0, -2.3, 0.5), ConsolePos.x, ConsolePos.y, ConsolePos.z + 1.0, 7.0, 0, 0, "rope_attach_a", "rope_attach_b")
end)

RegisterNetEvent("fw-heists:Client:DetachATM")
AddEventHandler("fw-heists:Client:DetachATM", function(NetIdVeh, NetIdConsole)
    if ActiveRopes[NetIdVeh] then
        DeleteRope(ActiveRopes[NetIdVeh])
        ActiveRopes[NetIdVeh] = nil
        ATMRopes[NetIdVeh] = nil
        print("[ATM] Deleting rope with RopeId: " .. NetIdVeh)
    end
end)

RegisterNetEvent("fw-heists:Client:SearchATM")
AddEventHandler("fw-heists:Client:SearchATM", function(Data, Entity)
    local IsSearched = FW.SendCallback("fw-heists:Server:IsATMSearched", NetworkGetNetworkIdFromEntity(Entity))
    if IsSearched then return end

    FW.TriggerServer("fw-heists:Server:SetATMSearched", NetworkGetNetworkIdFromEntity(Entity), true)
    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, 1000)
    
    Citizen.Wait(1000)
    local Finished = FW.Functions.CompactProgressbar(10000, "Pinautomaat doorzoeken..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_bum_wash@male@low@idle_a", anim = "idle_a", flags = 1 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "amb@world_human_bum_wash@male@low@idle_a", "idle_a", 1.0)

    if not Finished then
        FW.TriggerServer("fw-heists:Server:SetATMSearched", NetworkGetNetworkIdFromEntity(Entity), false)
        return
    end
    FW.TriggerServer("fw-heists:Server:SearchATM", NetworkGetNetworkIdFromEntity(Entity))
end)

RegisterNetEvent("fw-heists:Client:PickupATM")
AddEventHandler("fw-heists:Client:PickupATM", function(Data, Entity)
    TaskTurnPedToFaceEntity(PlayerPedId(), Entity, 1000)
    Citizen.Wait(1000)
    local Finished = FW.Functions.CompactProgressbar(3000, "Pinautomaat oppakken..", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_bum_wash@male@low@idle_a", anim = "idle_a", flags = 1 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "amb@world_human_bum_wash@male@low@idle_a", "idle_a", 1.0)
    if not Finished then return end

    FW.TriggerServer("fw-heists:Server:PickupATM", NetworkGetNetworkIdFromEntity(Entity))
end)

RegisterNetEvent("fw-heists:Client:CrackATM")
AddEventHandler("fw-heists:Client:CrackATM", function()
    if not exports['fw-inventory']:HasEnoughOfItem('atm-blackbox', 1) then
        return
    end

    local Outcome = exports['fw-ui']:StartSkillTest(3, { 10, 15 }, { 950, 1500 }, false)
    if not Outcome then return end

    local IsRemoved = FW.SendCallback("FW:RemoveItem", 'atm-blackbox', 1)
    if not IsRemoved then return end

    FW.TriggerServer("fw-heists:Server:ATMReward")
end)

exports("GetAttachingRope", function()
    return IsAttachingRope
end)

exports("IsRopeAttached", function(Entity)
    return RopeVehicle == Entity and IsAttachingRope
end)

function IsAtmNearCity(Coords)
    return #(vector2(-344.15, -1641.1) - vector2(Coords.x, Coords.y)) < 2000.0
end