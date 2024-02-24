FW = exports['fw-core']:GetCoreObject()
LoggedIn, CurrentDoor, Listening = false, nil, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(450, function()
        FW.Functions.TriggerCallback("fw-doors:Server:GetDoorConfig", function(Result)
            Config.Doors = Result
        end)

        Citizen.SetTimeout(200, function()
            TriggerEvent('fw-doors:Client:Setup:Doors')
            InitElevator()
            InitZones()
            LoggedIn = true
        end)
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)
-- Code

-- // Loops \\ --

Citizen.CreateThread(function()
    -- Set connected to keys instead of info.
    local function GetDoorIndexByInfo(Info)
        for k, v in pairs(Config.Doors) do
            if v.Info == Info then
                return k
            end
        end
    end

    for k, v in pairs(Config.Doors) do
        if v.Connected ~= nil and next(v.Connected) then
            local NewConnected = {}

            for i, j in pairs(v.Connected) do
                NewConnected[#NewConnected + 1] = GetDoorIndexByInfo(j)
            end

            Config.Doors[k].Connected = NewConnected
        end
    end

    while true do
        Citizen.Wait(4)
        if LoggedIn and (CurrentDoor ~= nil) or CurrentDoor == nil and NearBollards ~= nil then
            local DoorConfig = Config.Doors[CurrentDoor]
            if IsControlJustReleased(0, 38) then
                TriggerEvent('fw-doors:Client:Press:Special:Door')
            end
        else
            Citizen.Wait(450)
        end 
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-doors:Client:Setup:Doors')
AddEventHandler('fw-doors:Client:Setup:Doors', function()
    for k, v in pairs(Config.Doors) do
        if v.Disabled then
            goto SkipDoor
        end

        if not IsDoorRegisteredWithSystem(k) then
            AddDoorToSystem(k, type(v.Model) == 'string' and GetHashKey(v.Model) or v.Model, v.Coords, false, false, false)
        end
        if v.IsGate then
            DoorSystemSetAutomaticDistance(k, 8.0, false, true)
        end
        DoorSystemSetAutomaticRate(k, 1.0, false, false)
        DoorSystemSetDoorState(k, v.Locked, false, true)
        DoorSystemSetHoldOpen(k, v.IsGate)

        ::SkipDoor::
    end
end)

RegisterNetEvent('fw-doors:Client:Press:Special:Door')
AddEventHandler('fw-doors:Client:Press:Special:Door', function()
    if NearBollards ~= nil then
        local DoorId = GetDoorIdByInfo(NearBollards)
        if DoorId ~= 0 and HasDoorAcces(DoorId) then
            TriggerServerEvent('fw-doors:Server:ToggleLockState', DoorId)
            if Config.Doors[DoorId].Connected ~= nil and next(Config.Doors[DoorId].Connected) then
                for k, v in pairs(Config.Doors[DoorId].Connected) do
                    TriggerServerEvent('fw-doors:Server:ToggleLockState', v)
                end
            end

            if Config.Doors[DoorId].Locked == 0 then
                TriggerEvent('fw-sound:client:play', 'GarageClose', 0.15)
            else
                TriggerEvent('fw-sound:client:play', 'GarageOpen', 0.15)
            end
        else
            FW.Functions.Notify("Geen toegang!", "error")
            PlaySoundFromEntity(-1, "Keycard_Fail", PlayerPedId(), "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", 1, 5.0)
        end
    end
end)

RegisterNetEvent('fw-ui:Client:Target:Changed')
AddEventHandler('fw-ui:Client:Target:Changed', function(Entity, EntityType, EntityCoords)
    if EntityType == nil or EntityType ~= 3 then
        CurrentDoor, Listening = nil, false
        return
    end

    local DoorId = GetTargetDoorId(Entity)
    if DoorId == nil then return end
    if DoorId ~= CurrentDoor then Listening = false end
    
    Citizen.SetTimeout(20, function()
        CurrentDoor = DoorId
        ListenForKeypress(CurrentDoor)
    end)
end)

RegisterNetEvent('fw-doors:Client:Sync:Doors')
AddEventHandler('fw-doors:Client:Sync:Doors', function(DoorId, DoorData)
    if Config.Debug then print(DoorId) end
    Config.Doors[DoorId] = DoorData
    DoorSystemSetAutomaticRate(DoorId, 1.0, false, false)
    DoorSystemSetDoorState(DoorId, Config.Doors[DoorId].Locked, false, true)
    DoorSystemSetHoldOpen(DoorId, Config.Doors[DoorId].IsGate)
    if DoorId ~= CurrentDoor then return end
    if Config.Doors[DoorId].IsGate then return end
    if #(GetEntityCoords(PlayerPedId()) - Config.Doors[DoorId].Coords) < 2.0 then
        local HasAccess = HasDoorAcces(DoorId)
        local DoorState = Config.Doors[DoorId].Locked == 1 and true or false
        if not Config.Doors[DoorId].IsHidden then
            exports['fw-ui']:EditInteraction((HasAccess and "[E] %s" or "%s"):format(DoorState and 'Gesloten' or 'Open'), DoorState and 'error' or 'success', true)
        end
    end
end)

RegisterNetEvent("fw-items:Client:UseLockpick")
AddEventHandler("fw-items:Client:UseLockpick", function(IsAdvanced, Item)
    if not CurrentDoor or Config.Doors[CurrentDoor] == nil then
        return
    end

    if not Config.Doors[CurrentDoor].IsLockpickable then
        return
    end

    if Config.Doors[CurrentDoor].Locked ~= 1 then
        return FW.Functions.Notify("Deur is al open sloeber..", "error")
    end

    if not IsAdvanced then
        return FW.Functions.Notify("Met deze lockpick ga je het niet redden..", "error")
    end

    local Outcome = exports['fw-ui']:StartSkillTest(math.random(2, 5), { 5, 10 }, { 500, 950 }, true)
    if not Outcome then
        exports['fw-assets']:RemoveLockpickChance(IsAdvanced)
        return
    end

    TriggerServerEvent('fw-doors:Server:ToggleLockState', CurrentDoor)
    if Config.Doors[CurrentDoor].Connected ~= nil and next(Config.Doors[CurrentDoor].Connected) then
        for k, v in pairs(Config.Doors[CurrentDoor].Connected) do
            TriggerServerEvent('fw-doors:Server:ToggleLockState', v)
        end
    end
end)

-- // Functions \\ --

function ListenForKeypress(DoorId)
    if not Listening then
        Listening = true
        Citizen.CreateThread(function()
            local CurrentDoorId, LockState = DoorId, nil
            local Distance = Config.Doors[CurrentDoorId].IsGate and 8.0 or 2.0
            local CurrentDoorLockState = (Config.Doors[CurrentDoorId].Locked == 1 and true or false)
            local HasDoorKeys, IsHidden = HasDoorAcces(CurrentDoorId), Config.Doors[CurrentDoorId].IsGate
            while Listening do
                Citizen.Wait(4)
                if CurrentDoorLockState ~= LockState and not IsHidden then
                    if #(GetEntityCoords(PlayerPedId()) - Config.Doors[CurrentDoorId].Coords) < Distance then
                        LockState = CurrentDoorLockState
                        if not Config.Doors[CurrentDoorId].IsHidden then
                            exports['fw-ui']:ShowInteraction((HasDoorKeys and "[E] %s" or "%s"):format(LockState and 'Gesloten' or 'Open'), LockState and 'error' or 'success')
                        end
                    end
                end
                if IsControlJustReleased(0, 38) then
                    local HasAccess = HasDoorAcces(CurrentDoorId)
                    if HasAccess and #(GetEntityCoords(PlayerPedId()) - Config.Doors[CurrentDoorId].Coords) < Distance then
                        if NearBollards == Config.Doors[CurrentDoorId].Id then
                            TriggerServerEvent('fw-doors:Server:ToggleLockState', CurrentDoorId)
                            if Config.Doors[CurrentDoorId].Connected ~= nil and next(Config.Doors[CurrentDoorId].Connected) then
                                for k, v in pairs(Config.Doors[CurrentDoorId].Connected) do
                                    TriggerServerEvent('fw-doors:Server:ToggleLockState', v)
                                end
                            end
                            if Config.Doors[CurrentDoorId].IsGate then
                                if Config.Doors[CurrentDoorId].Locked == 0 then
                                    TriggerEvent('fw-sound:client:play', 'GarageClose', 0.15)
                                else
                                    TriggerEvent('fw-sound:client:play', 'GarageOpen', 0.15)
                                end
                            else
                                DoorAnimation()
                                -- TriggerEvent("fw-misc:Client:PlaySound", 'general.doorKeys')
                            end
                        end
                    end
                end
            end
            Citizen.Wait(35)
            exports['fw-ui']:HideInteraction()
        end)
    end
end


function DoorAnimation()
    Citizen.CreateThread(function()
        if not IsPedInAnyVehicle(PlayerPedId()) then
            exports['fw-assets']:RequestAnimationDict('anim@heists@keycard@')
            TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
            Citizen.Wait(500)
            ClearPedTasks(PlayerPedId())
        end
    end)
end

function GetTargetDoorId(Entity)
    local ActiveDoors = DoorSystemGetActive()
    for _, ActiveDoor in pairs(ActiveDoors) do
        if ActiveDoor[2] == Entity then
            return ActiveDoor[1]
        end
    end
end

function GetDoorIdByInfo(Info)
    for k, v in pairs(Config.Doors) do
        if v.Info == Info then
            return k
        end
    end
end

function HasDoorAcces(DoorId)
    local PlayerData = FW.Functions.GetPlayerData()
    if Config.Doors[DoorId] ~= nil then
        for k, Job in pairs(Config.Doors[DoorId].Access.Job) do
            if PlayerData.job.name == Job then
                return true
            end
        end
        for k, Cid in pairs(Config.Doors[DoorId].Access.CitizenId) do
            if PlayerData.citizenid == Cid then
                return true
            end
        end
        for k, Business in pairs(Config.Doors[DoorId].Access.Business) do
            if exports['fw-businesses']:HasRolePermission(Business, 'PropertyKeys') then
                return true
            end
        end

        local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
        if Config.Doors[DoorId].Access.Gangs[1] == 'all' and Gang and Gang.Id then
            return true
        end

        for k, GangId in pairs(Config.Doors[DoorId].Access.Gangs) do
            if Gang and Gang.Id == GangId then
                return true
            end
        end
    end

    return false
end