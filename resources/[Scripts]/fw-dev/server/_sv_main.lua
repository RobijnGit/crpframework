FW = exports['fw-core']:GetCoreObject()

FW.Functions.CreateCallback("fw-dev:Server:IsDev", function(Source, Cb)
    Cb(FW.Functions.HasPermission(Source, "admin") or FW.Functions.HasPermission(Source, "god"))
end)

FW.Functions.CreateCallback("fw-dev:Server:GetVehicleDetails", function(Source, Cb, Hash, Plate)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM player_vehicles WHERE plate = ?", { Plate })
    local Retval = {}

    if Result[1] == nil then
        return Cb({
            {'Owner', 'Not Owned'},
            {'Plate', Plate},
            {'Hash', Hash},
            {'VIN', 'No Vin'},
        })
    end

    local Parts = json.decode(Result[1].parts)
    local Metadata = json.decode(Result[1].metadata)

    Cb({
        {'Owner', Result[1].citizenid},
        {'Plate', Result[1].plate},
        {'Hash', Hash},
        {'VIN', Result[1].vinnumber},
        {'Garage', Result[1].citizenid},
        {'State', Result[1].state},
        {'VINScratch', Result[1].vinscratched == 1},
        {'-----------------------Parts--------------------------', ''},
        {'Engine', exports['fw-businesses']:Round(Parts.Engine, 2) .. '%'},
        {'Axle', exports['fw-businesses']:Round(Parts.Axle, 2) .. '%'},
        {'Transmission', exports['fw-businesses']:Round(Parts.Transmission, 2) .. '%'},
        {'Fuel Injectors', exports['fw-businesses']:Round(Parts.FuelInjectors, 2) .. '%'},
        {'Clutch', exports['fw-businesses']:Round(Parts.Clutch, 2) .. '%'},
        {'Brakes', exports['fw-businesses']:Round(Parts.Brakes, 2) .. '%'},
        {'---------------------Metadata---------------------', ''},
        {'Waxed', Metadata.Waxed and exports['fw-businesses']:Round(Metadata.Waxed, 2) .. '%' or 'No'},
        {'Harness', Metadata.Harness and exports['fw-businesses']:Round(Metadata.Harness, 2) .. '%' or 'No'},
        {'Nitrous', Metadata.Nitrous and exports['fw-businesses']:Round(Metadata.Nitrous, 2) .. '%' or 'No'},
        {'Fake Plate', Metadata.FakePlate and exports['fw-businesses']:Round(Metadata.FakePlate, 2) .. '%' or 'No'},
        {'Flagged', Metadata.Flagged and exports['fw-businesses']:Round(Metadata.Flagged, 2) .. '%' or 'No'},
        {'------------------------Health-----------------------', ''},
        {'Engine', exports['fw-businesses']:Round(Metadata.Engine, 2) .. '%'},
        {'Body', exports['fw-businesses']:Round(Metadata.Body, 2) .. '%'},
        {'Fuel', exports['fw-businesses']:Round(Metadata.Fuel, 2) .. '%'},
    })


    Cb(Retval)
end)