FW.AddKeybind("indicatorLeft", "Voertuigen", "Knipperlicht Aan-/uitzetten (Right)", "", function(IsPressed)
    if not CurrentVehicle or not IsPressed then return end
    if not IsVehicleDriver() then return end
	SetLightIndicators(GetVehiclePedIsIn(PlayerPedId()), 2)
end)

FW.AddKeybind("indicatorRight", "Voertuigen", "Knipperlicht Aan-/uitzetten (Left)", "", function(IsPressed)
    if not CurrentVehicle or not IsPressed then return end
    if not IsVehicleDriver() then return end
	SetLightIndicators(GetVehiclePedIsIn(PlayerPedId()), 3)
end)

FW.AddKeybind("indicatorHazard", "Voertuigen", "Knipperlicht Aan-/uitzetten (Hazard)", "", function(IsPressed)
    if not CurrentVehicle or not IsPressed then return end
    if not IsVehicleDriver() then return end
	SetLightIndicators(GetVehiclePedIsIn(PlayerPedId()), 1)
end)

function IsVehicleDriver()
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    return GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId()
end

function SetLightIndicators(Vehicle, Mode)
	local NetId = NetworkGetNetworkIdFromEntity(Vehicle)

    if Mode == 1 then
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'HazardIndicator', Value = not Entity(Vehicle).state.HazardIndicator })
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'LeftIndicator', Value = false })
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'RightIndicator', Value = false })
    elseif Mode == 2 then
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'RightIndicator', Value = not Entity(Vehicle).state.RightIndicator })
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'LeftIndicator', Value = false })
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'HazardIndicator', Value = false })
    elseif Mode == 3 then
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'LeftIndicator', Value = not Entity(Vehicle).state.LeftIndicator })
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'RightIndicator', Value = false })
		TriggerServerEvent("fw-vehicles:Server:SetState", NetId, { State = 'HazardIndicator', Value = false })
    end

	Citizen.SetTimeout(100, function()
		SetVehicleIndicatorLights(Vehicle, 0, Entity(Vehicle).state.HazardIndicator or Entity(Vehicle).state.RightIndicator)
		SetVehicleIndicatorLights(Vehicle, 1, Entity(Vehicle).state.HazardIndicator or Entity(Vehicle).state.LeftIndicator)
	end)

    PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
end