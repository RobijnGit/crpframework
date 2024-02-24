local VehicleIcons = {
    Car = "car",
    Motorcycle = "motorcycle",
    Truck = "truck",
    Bicycle = "bicycle",
    Van = "shuttle-van",
    Helicopter = "helicopter",
    Plane = "plane",
}

FW.Functions.CreateCallback("fw-phone:Server:Vehicles:GetVehicles", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicles = {}
    local PlayerVehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `citizenid` = @Cid", { ['@Cid'] = Player.PlayerData.citizenid })
    -- local PoliceVehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `police_vehicles` WHERE `owner` = @Cid", { ['@Cid'] = Player.PlayerData.citizenid })

    for k, v in pairs(PlayerVehicles) do
        local VehicleData = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        local MetaData = json.decode(v.metadata)
        Vehicles[#Vehicles + 1] = {
            Icon = VehicleData and VehicleIcons[VehicleData.Type] or "car",
            Plate = v.plate,
            State = v.state == 'in' and 'Binnen' or v.state == 'depot' and 'Depot' or 'Buiten',
            Label = VehicleData and VehicleData.Name or v.vehicle,
            Garage = v.garage,
            Engine = MetaData.Engine,
            Body = MetaData.Body,
        }
    end

    -- for k, v in pairs(PoliceVehicles) do
    --     local VehicleData = FW.Shared.HashVehicles[v.vehicle]
    --     local MetaData = json.decode(v.metadata)
    --     Vehicles[#Vehicles + 1] = {
    --         Icon = VehicleData and VehicleIcons[VehicleData.Type] or "car",
    --         Plate = v.plate,
    --         State = v.state == 'in' and 'Stored' or 'Out',
    --         Label = VehicleData and VehicleData.Name or v.vehicle,
    --         Garage = v.garage,
    --         Engine = MetaData.Engine,
    --         Body = MetaData.Body,
    --     }
    -- end

    Cb(Vehicles)
end)

RegisterNetEvent("fw-phone:Server:SellVehicle")
AddEventHandler("fw-phone:Server:SellVehicle", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if Target == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT `citizenid` FROM `player_vehicles` WHERE `plate` = @Plate", {
        ['@Plate'] = Data.Plate,
    })

    if Result[1] == nil then return end
    if Result[1].citizenid ~= Player.PlayerData.citizenid then return end

    local OutsideVehicles = exports['fw-vehicles']:GetOutsideVehicles()
    if OutsideVehicles[Data.Plate] == nil then return end

    local Vehicle = NetworkGetEntityFromNetworkId(OutsideVehicles[Data.Plate])
    if Vehicle == 0 then return end

    if #(GetEntityCoords(Vehicle) - GetEntityCoords(GetPlayerPed(Source))) > 5.0 then
        return Player.Functions.Notify("Te ver van het voertuig..", "error")
    end

    -- Do not allow to re-sell Gifted vehicles.
    if exports['fw-vehicles']:GetVehicleMeta(OutsideVehicles[Data.Plate], "Gifted") then
        return Player.Functions.Notify("Je kan dit voertuig niet doorverkopen aan een speler..", "error")
    end

    if #(GetEntityCoords(GetPlayerPed(Target.PlayerData.source)) - GetEntityCoords(GetPlayerPed(Source))) > 5.0 then
        return Player.Functions.Notify("Te ver van de koper..", "error")
    end

    TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, "purchase-vehicle-" .. Data.Cid, "fas fa-car", { "white", "rgb(38, 50, 56)" }, "Voertuig Kopen", exports['fw-businesses']:NumberWithCommas(tonumber(Data.Amount)), false, true, "fw-phone:Server:AcceptVehicleOffer", "fw-phone:Client:RemoveNotificationById", { Id = "purchase-vehicle-" .. Data.Cid, Cid = Data.Cid, Seller = Source, Amount = Data.Amount, Plate = Data.Plate })
end)

RegisterNetEvent("fw-phone:Server:AcceptVehicleOffer")
AddEventHandler("fw-phone:Server:AcceptVehicleOffer", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local Seller = FW.Functions.GetPlayer(Data.Seller)
    if Seller == nil then return end

    TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Kopen...", true)

    Citizen.SetTimeout(1000, function()
        if exports['fw-financials']:RemoveMoneyFromAccount(Seller.PlayerData.citizenid, Seller.PlayerData.charinfo.account, Player.PlayerData.charinfo.account, Data.Amount, "PURCHASE", "Voertuig gekocht: " .. Data.Plate) then
            TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Voltooid!", true)
    
            exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `citizenid` = @Cid WHERE `plate` = @Plate", {
                ['@Plate'] = Data.Plate,
                ['@Cid'] = Player.PlayerData.citizenid
            })
    
            exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, Seller.PlayerData.charinfo.account, Data.Amount, 'PURCHASE', 'Voertuig verkocht: ' .. Data.Plate)

            TriggerEvent("fw-logs:Server:Log", 'sellvehicle', "Vehicle Sold", ("User: [%s] - %s - %s\nBuyer: [%s] - %s - %s\nPlate:%s\nSold Price: %s"):format(Seller.PlayerData.source, Seller.PlayerData.citizenid, Seller.PlayerData.charinfo.firstname .. " " .. Seller.PlayerData.charinfo.lastname, Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Plate, exports['fw-businesses']:NumberWithCommas(Data.Amount)), "green")

            exports['ghmattimysql']:executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", {
                Seller.PlayerData.citizenid,
                Player.PlayerData.citizenid,
                Data.Plate,
                Data.Amount,
                os.time() * 1000
            })

            local Result = exports['ghmattimysql']:executeSync("SELECT `vehicle`, `vinnumber` FROM `player_vehicles` WHERE `plate` = @Plate", {
                ['@Plate'] = Data.Plate,
            })

            if Result[1] == nil then return end

            local SharedData = FW.Shared.HashVehicles[GetHashKey(Result[1].vehicle)]
            if SharedData == nil then return end
    
            local Date = os.date("*t", os.time())
            TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
                Type = 3,
                Title = SharedData.Name .. ' - ' .. Data.Plate,
                Content = (exports['fw-businesses']:GetVehicleRegistration()):format(SharedData.Name, Result[1].vehicle, Data.Plate, Result[1].vinnumber, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Seller.PlayerData.charinfo.firstname .. ' ' .. Seller.PlayerData.charinfo.lastname, Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min, exports['fw-businesses']:NumberWithCommas(tonumber(Data.Amount))),
                Signatures = {
                    { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
                    { Signed = true, Name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Timestamp = os.time() * 1000, Cid = Player.PlayerData.citizenid },
                },
                Sharees = { Player.PlayerData.citizenid },
                Finalized = 1,
            })
        else
            TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Geweigerd!", true)
        end
    end)
end)