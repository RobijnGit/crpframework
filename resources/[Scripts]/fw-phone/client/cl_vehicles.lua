Vehicles = {
    Vehicles = {}
}

RegisterNUICallback("Vehicles/GetVehicles", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Vehicles:GetVehicles")
    Cb(Result)
end)

RegisterNUICallback("Vehicles/TrackVehicle", function(Data, Cb)
    Cb("Ok")

    local Result = FW.SendCallback("fw-vehicles:Server:GetVehicleCoords", Data.Plate)
    if Result then
        SetWaypointOff()
        Citizen.SetTimeout(500, function()
            SetNewWaypoint(Result.x, Result.y)
        end)
    else
        FW.Functions.Notify("Kan voertuig niet lokaliseren..", "error")
    end
end)

RegisterNUICallback("Vehicles/SpawnVehicle", function(Data, Cb)
    Cb("Ok")

    if not exports['fw-vehicles']:IsNearParking() then
        return FW.Functions.Notify("Je moet bij een parkeerplaats zijn om het voertuig te spawnen.", "error")
    end

    TriggerEvent('fw-vehicles:Client:SpawnVehiclePhone', Data.Plate)
end)

RegisterNUICallback("Vehicles/SellVehicle", function(Data, Cb)
    Cb("Ok")
    TriggerServerEvent('fw-phone:Server:SellVehicle', Data)
end)