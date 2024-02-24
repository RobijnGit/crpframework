FW.Functions.CreateCallback('fw-phone:Server:GetVehicles', function(Source, Cb, Shop)
    local Retval = {}
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_vehicles` WHERE `shop` = @Shop ORDER BY `vehicle` DESC", {
        ['@Shop'] = Shop
    })

    for k, v in pairs(Result) do
        local SharedData = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        if SharedData == nil then goto Skip end

        Retval[#Retval + 1] = {
            Vehicle = v.vehicle,
            Stock = v.stock,
            Name = SharedData.Name,
            Class = SharedData.Class,
            Price = SharedData.Price,
        }

        ::Skip::
    end

    Cb(Retval)
end)