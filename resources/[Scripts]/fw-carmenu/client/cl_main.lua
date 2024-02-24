local FW = exports['fw-core']:GetCoreObject()
local enabled = false

RegisterNetEvent('veh:options')
AddEventHandler('veh:options', function()
    if GetVehiclePedIsIn(PlayerPedId()) == 0 then return end
    EnableGUI(true)
end)

function EnableGUI(enable)
    enabled = enable

    SetNuiFocus(enable, enable)

    SendNUIMessage({
        type = "enablecarmenu",
        enable = enable
    })

    if not enabled then return end

    Citizen.CreateThread(function()
        while enabled do
            Citizen.Wait(100)
            refreshUI()
        end
    end)
end

function checkSeat(player, veh, seatIndex)
    local ped = GetPedInVehicleSeat(veh, seatIndex)
    if ped == player then
        return seatIndex
    elseif ped ~= 0 then
        return false
    else
        return true
    end
end

function refreshUI()
    local settings = {}
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    if veh == 0 then
        SendNUIMessage({
            type = "resetcarmenu"
        })
        return
    end

    settings.seat1 = checkSeat(player, veh, -1)
    settings.seat2 = checkSeat(player, veh,  0)
    settings.seat3 = checkSeat(player, veh,  1)
    settings.seat4 = checkSeat(player, veh,  2)

    settings.doorAccess = settings.seat1 == -1 and true or false

    -- Doors
    if GetVehicleDoorAngleRatio(veh, 0) ~= 0 then settings.door0 = true end
    if GetVehicleDoorAngleRatio(veh, 1) ~= 0 then settings.door1 = true end
    if GetVehicleDoorAngleRatio(veh, 2) ~= 0 then settings.door2 = true end
    if GetVehicleDoorAngleRatio(veh, 3) ~= 0 then settings.door3 = true end
    if GetVehicleDoorAngleRatio(veh, 4) ~= 0 then settings.hood = true end
    if GetVehicleDoorAngleRatio(veh, 5) ~= 0 then settings.trunk = true end

    -- Windows
    if not IsVehicleWindowIntact(veh, 0) then settings.windowr1 = true end
    if not IsVehicleWindowIntact(veh, 1) then settings.windowl1 = true end
    if not IsVehicleWindowIntact(veh, 2) then settings.windowr2 = true end
    if not IsVehicleWindowIntact(veh, 3) then settings.windowl2 = true end

    -- Engine
    local engine = GetIsVehicleEngineRunning(veh)
    settings.engine = engine and true or false

    SendNUIMessage({
        type = "refreshcarmenu",
        settings = settings
    })
end

RegisterNUICallback('openDoor', function(data, cb)
    local doorIndex = tonumber(data['doorIndex'])
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    if veh == 0 then return end

    local lockStatus = GetVehicleDoorLockStatus(veh)
    if lockStatus == 1 or lockStatus == 0 then
        if (GetVehicleDoorAngleRatio(veh, doorIndex) == 0) then
            FW.VSync.SetVehicleDoorOpen(veh, doorIndex, false, false)
        else
            FW.VSync.SetVehicleDoorShut(veh, doorIndex, false)
        end
    end
    cb('ok')
end)

RegisterNUICallback('switchSeat', function(data, cb)
    local seatIndex = tonumber(data['seatIndex'])
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    if veh == 0 then return end
    SetPedIntoVehicle(player, veh, seatIndex)
    cb('ok')
end)

RegisterNUICallback('togglewindow', function(data, cb)
    local windowIndex = tonumber(data['windowIndex'])
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    
    if veh == 0 then return end
    if not IsVehicleWindowIntact(veh, windowIndex) then
        RollUpWindow(veh, windowIndex)
        if not IsVehicleWindowIntact(veh, windowIndex) then
            RollDownWindow(veh, windowIndex)
        end
    else
        RollDownWindow(veh, windowIndex)
    end
    cb('ok')
end)

RegisterNUICallback('toggleengine', function(data, cb)
    local player = PlayerPedId()
    local veh = GetVehiclePedIsIn(player, false)
    if veh == 0 then return end
    if exports['fw-vehicles']:IsVehicleStalled() then return end

    local engine = not GetIsVehicleEngineRunning(veh)
    if not IsPedInAnyHeli(player) then
        SetVehicleEngineOn(veh, engine, false, true)
        SetVehicleJetEngineOn(veh, engine)
    else
        FW.Functions.Notify("Dat kan hier niet..", "error")
    end
    cb('ok')
end)

RegisterNUICallback('escape', function(data, cb)
    EnableGUI(false)
    cb('ok')
end)