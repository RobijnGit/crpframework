local HudPercentages = { 33, 66, 100 }
local CurrentPursuit = 1

FW.AddKeybind('switchPursuit', 'Hulpdiensten', 'Pursuit Modus Veranderen', '', function(IsPressed)
    if not IsPressed then return end
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if Vehicle == 0 or Vehicle == -1 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() then return end

    if not IsThisAPursuitVehicle(Vehicle) then 
        return
    end

    local PursuitModes = GetPursuitModes(GetEntityModel(Vehicle))
    CurrentPursuit = CurrentPursuit + 1 > #PursuitModes and 1 or (CurrentPursuit + 1)
    local NewPursuit = PursuitModes[CurrentPursuit]

    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('PursuitMode'), GetPursuitPercentage(GetEntityModel(Vehicle)))
    FW.Functions.Notify(("Pursuit modus: %s"):format(NewPursuit))
    SetPursuitMode(Vehicle, NewPursuit)
end)

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    if not IsPoliceVehicle(Vehicle) or not IsThisAPursuitVehicle(Vehicle) then return end
    if Seat ~= -1 then return end

    CurrentPursuit = 1
    SetVehicleMod(Vehicle, 11, -1) -- Engine
    SetVehicleMod(Vehicle, 12, -1) -- Brakes
    SetVehicleMod(Vehicle, 13, -1) -- Transmission

    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('PursuitMode'), GetPursuitPercentage(GetEntityModel(Vehicle)))
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('PursuitMode'), 0)
    CurrentPursuit = 1

    SetVehicleMod(Vehicle, 11, -1) -- Engine
    SetVehicleMod(Vehicle, 12, -1) -- Brakes
    SetVehicleMod(Vehicle, 13, -1) -- Transmission
end)

function SetPursuitMode(Vehicle, Class)
    local Mods = Config.PursuitMods[Class]

    SetVehicleModKit(Vehicle, 0)
    SetVehicleMod(Vehicle, 11, Mods.Engine)
    SetVehicleMod(Vehicle, 12, Mods.Brakes)
    SetVehicleMod(Vehicle, 13, Mods.Transmission)
end

function IsThisAPursuitVehicle(Vehicle)
    local Model = GetEntityModel(Vehicle)
    for k, v in pairs(Config.PursuitVehicles) do
        if Model == GetHashKey(v) then
            return true
        end
    end
    return false
end

function GetPursuitModes(Model)
    return Config.PursuitModes[Model]
end

function GetPursuitPercentage(Model)
    local Modes = #Config.PursuitModes[Model]

    if Modes == 2 then
        return ({ 50, 100 })[CurrentPursuit]
    elseif Modes == 3 then
        return ({ 33, 66, 100 })[CurrentPursuit]
    end
end