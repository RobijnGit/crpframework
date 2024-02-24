local isInVehicle = false
local isEnteringVehicle = false
local currentVehicle = 0
local currentSeat = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local ped = PlayerPedId()

		if not isInVehicle and not IsPlayerDead(PlayerId()) then
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not isEnteringVehicle then
				-- trying to enter a vehicle!
				local vehicle = GetVehiclePedIsTryingToEnter(ped)
				local seat = GetSeatPedIsTryingToEnter(ped)
				local netId = VehToNet(vehicle)
				isEnteringVehicle = true
				TriggerEvent('baseevents:enteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
				TriggerServerEvent('baseevents:enteringVehicle', vehicle, seat, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), netId)
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not IsPedInAnyVehicle(ped, true) and isEnteringVehicle then
				-- vehicle entering aborted
				TriggerEvent('baseevents:enteringAborted')
				TriggerServerEvent('baseevents:enteringAborted')
				isEnteringVehicle = false
			elseif IsPedInAnyVehicle(ped, false) then
				-- suddenly appeared in a vehicle, possible teleport
				isEnteringVehicle = false
				isInVehicle = true
				currentVehicle = GetVehiclePedIsUsing(ped)
				currentSeat = GetPedVehicleSeat(ped)
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
				TriggerServerEvent('baseevents:enteredVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
			end
		elseif isInVehicle then
			if not IsPedInAnyVehicle(ped, false) or IsPlayerDead(PlayerId()) then
				-- bye, vehicle
				local model = GetEntityModel(currentVehicle)
				local name = GetDisplayNameFromVehicleModel()
				local netId = VehToNet(currentVehicle)
				TriggerEvent('baseevents:leftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
				TriggerServerEvent('baseevents:leftVehicle', currentVehicle, currentSeat, GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)), netId)
				isInVehicle = false
				currentVehicle = 0
				currentSeat = 0
			end
		end
		Citizen.Wait(50)
	end
end)

Citizen.CreateThread(function()
    local airTime = 0

    while true do
        local idle = 1000

        if CurrentVehicle and CurrentVehicle ~= 0 and CurrentSeat == -1 and not IsThisModelABicycle(GetEntityModel(CurrentVehicle)) then
            PreviousSpeed = CurrentSpeed
            PreviousVelocity = CurrentVelocity
            PreviousBodyHealth = CurrentBodyHealth

            CurrentSpeed = GetEntitySpeed(CurrentVehicle)
            CurrentVelocity = GetEntityVelocity(CurrentVehicle)
            CurrentBodyHealth = GetVehicleBodyHealth(CurrentVehicle)

            if IsEntityInAir(CurrentVehicle) and (IsThisModelABike(GetEntityModel(CurrentVehicle)) or IsThisModelAQuadbike(GetEntityModel(CurrentVehicle))) then                
                airTime = airTime + 1
            elseif airTime ~= 0 then
                airTime = 0
            end

            if CurrentSpeed > 28 and not IsSpeeding then
                IsSpeeding = true
                TriggerEvent('baseevents:vehicleSpeeding', true, CurrentVehicle, CurrentSeat, CurrentSpeed)
            elseif IsSpeeding and CurrentSpeed < 28 then
                IsSpeeding = false
                TriggerEvent('baseevents:vehicleSpeeding', false, CurrentVehicle, CurrentSeat, CurrentSpeed)
            end

            idle = 100
        end

        Citizen.Wait(idle)
    end
end)

function GetPedVehicleSeat(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)
    for i=-2,GetVehicleMaxNumberOfPassengers(vehicle) do
        if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
    end
    return -2
end
