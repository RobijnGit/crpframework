local LimiterEnabled, SpeedLimit = false, 999.0

FW.AddKeybind("speedLimiter", "Voertuigen", "Begrenzer", 'B', function(IsPressed)
    if not IsPressed then return end

    local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
	local DriverPed = GetPedInVehicleSeat(Vehicle, -1)
	if DriverPed ~= PlayerPedId() then
        return
    end

    local Speed = GetEntitySpeed(Vehicle)
    if Speed < 9.7 then
        return FW.Functions.Notify("Begrenzer kan alleen worden ingeschakeld als je harder dan 35km/u rijdt.", "error")
    end

    if LimiterEnabled then
        SetEntityMaxSpeed(Vehicle, 999.0)
        FW.Functions.Notify("Begrenzer Uitgeschakeld")
        LimiterEnabled, SpeedLimit = false, 999.0
    else
        SetEntityMaxSpeed(Vehicle, Speed)
        FW.Functions.Notify("Begrenzer Ingeschakeld")
        LimiterEnabled, SpeedLimit = true, Speed
    end
end)

exports("GetSpeedLimit", function()
    return SpeedLimit
end)