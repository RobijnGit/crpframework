local LimiterEnabled, SpeedLimit = false, 999.0

FW.AddKeybind("speedLimiter", "Vehicles", "Speed Limiter", 'B', function(IsPressed)
    if not IsPressed then return end

    local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local DriverPed = GetPedInVehicleSeat(Vehicle, -1)
	if DriverPed ~= PlayerPedId() then
        return
    end

    local Speed = GetEntitySpeed(Vehicle)
    if Speed < 9.7 then
        return FW.Functions.Notify("Speed Limiter can only be enabled when you are going over 35km/u", "error")
    end

    if LimiterEnabled then
        SetEntityMaxSpeed(Vehicle, 999.0)
        FW.Functions.Notify("Speed Limiter deactivated")
        LimiterEnabled, SpeedLimit = false, 999.0
    else
        SetEntityMaxSpeed(Vehicle, Speed)
        FW.Functions.Notify("Speed Limiter activated")
        LimiterEnabled, SpeedLimit = true, Speed
    end
end)

exports("GetSpeedLimit", function()
    return SpeedLimit
end)