-- // Register Player Data in client \\ --
RegisterNetEvent('FW:Player:SetPlayerData')
AddEventHandler('FW:Player:SetPlayerData', function(val)
	FW.PlayerData = val
end)

-- // FW Command Events \\ --
RegisterNetEvent('FW:Command:TeleportToPlayer')
AddEventHandler('FW:Command:TeleportToPlayer', function(othersource)
	local coords = FW.OneSync.GetPlayerCoords(othersource)
	local entity = PlayerPedId()
	if IsPedInAnyVehicle(entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, coords.x, coords.y, coords.z)
	SetEntityHeading(entity, coords.a)
end)

RegisterNetEvent('FW:Command:TeleportToCoords')
AddEventHandler('FW:Command:TeleportToCoords', function(x, y, z)
	local entity = PlayerPedId()
	if IsPedInAnyVehicle(entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, x, y, z)
end)

RegisterNetEvent('FW:client:spawn:vehicle')
AddEventHandler('FW:client:spawn:vehicle', function(Veh, Model)
	if IsModelValid(Model) then
		DoScreenFadeOut(250)
		Citizen.Wait(250)
		while not NetworkDoesEntityExistWithNetworkId(Veh) do
			Citizen.Wait(300)
		end
		Citizen.SetTimeout(100, function()
			local Vehicle = NetToVeh(Veh)
			exports['fw-vehicles']:SetVehicleKeys(GetVehicleNumberPlateText(Vehicle), true, false)
			TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
			exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
			SetVehicleHasBeenOwnedByPlayer(Vehicle,  true)
			SetNetworkIdCanMigrate(Veh, true)
			SetVehicleNeedsToBeHotwired(Vehicle, false)
			SetVehRadioStation(Vehicle, "OFF")
			SetVehicleOnGroundProperly(Vehicle)
			DoScreenFadeIn(250)
			FW.Functions.Notify(Model..' ingespawned!', 'success')
		end)
	else
		FW.Functions.Notify('Model bestaat niet..', 'error')
	end
end)

RegisterNetEvent('FW:client:add:vehicle:properties')
AddEventHandler('FW:client:add:vehicle:properties', function(Veh)
	while not NetworkDoesEntityExistWithNetworkId(Veh) do
		Citizen.Wait(300)
	end
	local Vehicle = NetToVeh(Veh)
	while not DoesEntityExist(Vehicle) do
		Citizen.Wait(100)
	end
	SetVehicleHasBeenOwnedByPlayer(Vehicle,  true)
	SetNetworkIdCanMigrate(Veh, true)
	SetVehicleNeedsToBeHotwired(Vehicle, false)
	SetVehRadioStation(Vehicle, "OFF")
	SetVehicleOnGroundProperly(Vehicle)
	NetworkRegisterEntityAsNetworked(Vehicle)
end)

RegisterNetEvent('FW:client:set:vehicle:plate')
AddEventHandler('FW:client:set:vehicle:plate', function(Veh, Plate)
	while not NetworkDoesEntityExistWithNetworkId(Veh) do
		Citizen.Wait(300)
	end
	local Vehicle = NetToVeh(Veh)
	while not DoesEntityExist(Vehicle) do
		Citizen.Wait(100)
	end
	NetworkRequestControlOfEntity(Vehicle)
	SetVehicleNumberPlateText(Vehicle, Plate)
end)

RegisterNetEvent('FW:Command:DeleteVehicle')
AddEventHandler('FW:Command:DeleteVehicle', function()
	if IsPedInAnyVehicle(PlayerPedId()) then
		local Vehicle = GetVehiclePedIsIn(PlayerPedId())
		FW.Functions.DeleteVehicle(Vehicle)
	else
		local Vehicle, Distance = FW.Functions.GetClosestVehicle()
		if Vehicle ~= -1 and Distance < 7.0 then
			FW.Functions.DeleteVehicle(Vehicle)
		end
	end
	FW.Functions.Notify('Succesvol voertuig verwijderd!', 'error')
end)

RegisterNetEvent('FW:Command:Revive')
AddEventHandler('FW:Command:Revive', function()
	local coords = FW.Functions.GetCoords(PlayerPedId())
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(PlayerPedId(), false)
	ClearPedBloodDamage(PlayerPedId())
end)

RegisterNetEvent('FW:Command:GoToMarker')
AddEventHandler('FW:Command:GoToMarker', function()
	Citizen.CreateThread(function()
		local entity = PlayerPedId()
		if IsPedInAnyVehicle(entity, false) then
			entity = GetVehiclePedIsUsing(entity)
		end
		local success = false
		local blipFound = false
		local blipIterator = GetBlipInfoIdIterator()
		local blip = GetFirstBlipInfoId(8)

		while DoesBlipExist(blip) do
			if GetBlipInfoIdType(blip) == 4 then
				cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
				blipFound = true
				break
			end
			blip = GetNextBlipInfoId(blipIterator)
		end

		if blipFound then
			local groundFound = false
			local yaw = GetEntityHeading(entity)
			
			for i = 0, 1000, 1 do
				SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
				SetEntityRotation(entity, 0, 0, 0, 0 ,0)
				SetEntityHeading(entity, yaw)
				SetGameplayCamRelativeHeading(0)
				Citizen.Wait(0)
				if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then
					cz = ToFloat(i)
					groundFound = true
					break
				end
			end
			if not groundFound then
				cz = -300.0
			end
			success = true
		end

		if success then
			SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
			SetGameplayCamRelativeHeading(0)
			if IsPedSittingInAnyVehicle(PlayerPedId()) then
				if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
					SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
				end
			end
		end
	end)
end)

-- Other stuff
RegisterNetEvent('FW:Notify')
AddEventHandler('FW:Notify', function(text, type, length)
	FW.Functions.Notify(text, type, length)
end)

RegisterNetEvent('FW:Client:CloseNui')
AddEventHandler('FW:Client:CloseNui', function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent('fw-core:client:opennui')
AddEventHandler('fw-core:client:opennui', function()
	SetNuiFocus(true, true)
end)

RegisterNetEvent('FW:Client:TriggerCallback')
AddEventHandler('FW:Client:TriggerCallback', function(cbId, ...)
	if FW.ServerCallbacks[cbId] ~= nil then
		FW.ServerCallbacks[cbId](...)
		FW.ServerCallbacks[cbId] = nil
	end
end)