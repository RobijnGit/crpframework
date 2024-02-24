-- // Events \\ --
local SubmixActive = false

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    local VehicleClass = GetVehicleClass(Vehicle)
    if VehicleClass == 15 then
        ToggleHeliSubmix(true)
        SetAudioFlag("DisableFlightMusic", true)
    end
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    if SubmixActive then
        ToggleHeliSubmix(false)
        SetAudioFlag("DisableFlightMusic", true)
    end
end)

-- // Functions \\ --

function ToggleHeliSubmix(Bool)
    SubmixActive = Bool
    if Bool then
        SetAudioSubmixEffectRadioFx(0, 0)
        SetAudioSubmixEffectParamInt(0, 0, GetHashKey('enabled'), 1)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('freq_low'), 100.0)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('freq_hi'), 5000.0)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('rm_mod_freq'), 300.0)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('rm_mix'), 0.1)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('fudge'), 4.0)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('o_freq_lo'), 300.0)
        SetAudioSubmixEffectParamFloat(0, 0, GetHashKey('o_freq_hi'), 5000.0)
    else
        SetAudioSubmixEffectParamInt(0, 0, GetHashKey('enabled'), 0)
    end
end