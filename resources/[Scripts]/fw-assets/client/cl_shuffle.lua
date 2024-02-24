local inVehicle = false

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    inVehicle = true
    SetPedConfigFlag(PlayerPedId(), 184, true) -- CPED_CONFIG_FLAG_PreventAutoShuffleToDriversSeat

    while inVehicle do 
        if GetIsTaskActive(PlayerPedId(), 165) then
            local currentSeat = 0
            if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
                currentSeat = -1
            end

            SetPedIntoVehicle(PlayerPedId(), Vehicle, currentSeat)
            SetPedConfigFlag(PlayerPedId(), 184, true) -- CPED_CONFIG_FLAG_PreventAutoShuffleToDriversSeat
        end

        Citizen.Wait(150)
    end

    SetPedConfigFlag(PlayerPedId(), 184, false) -- CPED_CONFIG_FLAG_PreventAutoShuffleToDriversSeat
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    inVehicle = false
end)