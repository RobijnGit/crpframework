RegisterNetEvent("fw-misc:Server:PurchaseJobVehicle")
AddEventHandler("fw-misc:Server:PurchaseJobVehicle", function(Data)
    local Source = source

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Vehicle)]
    if SharedData == nil then return end

    TriggerClientEvent("fw-phone:Client:Notification", Source, "purchase-vehicle-" .. Data.Vehicle, "fas fa-car", { "white", "rgb(38, 50, 56)" }, "Voertuig Kopen", exports['fw-businesses']:NumberWithCommas(FW.Shared.CalculateTax('Vehicle Registration Tax', tonumber(SharedData.Price))) .. " incl. tax", false, true, "fw-misc:Server:AcceptJobVehicle", "fw-phone:Client:RemoveNotificationById", { Id = "purchase-vehicle-" .. Data.Vehicle, Model = Data.Vehicle })
end)

RegisterNetEvent('fw-misc:Server:AcceptJobVehicle')
AddEventHandler('fw-misc:Server:AcceptJobVehicle', function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Model)]
    TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Kopen...", true)

    Citizen.SetTimeout(1000, function()
        if exports['fw-financials']:RemoveMoneyFromAccount('1001', '1', Player.PlayerData.charinfo.account, FW.Shared.CalculateTax('Vehicle Registration Tax', SharedData.Price), "PURCHASE", "Bought " .. Data.Model) then
            TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Voltooid!", true)
    
            local Plate = FW.Functions.GeneratePlate()
            local VIN = FW.Functions.GenerateVin()
    
            exports['ghmattimysql']:executeSync("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `state`, `vinnumber`) VALUES (@Cid, @Vehicle, @Plate, 'out', @Vin)", {
                ['@Cid'] = Player.PlayerData.citizenid,
                ['@Vehicle'] = Data.Model,
                ['@Plate'] = Plate,
                ['@Vin'] = VIN,
            })

            exports['ghmattimysql']:executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", {
                "Premium Deluxe Motorsports",
                Player.PlayerData.citizenid,
                Plate,
                SharedData.Price,
                os.time() * 1000
            })
    
            TriggerEvent("fw-logs:Server:Log", 'pdm', "Job Vehicle Sold", ("User: [%s] - %s - %s\nModel: %s [%s]\nSold Price: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Model, Plate, exports['fw-businesses']:NumberWithCommas(FW.Shared.CalculateTax('Vehicle Registration Tax', SharedData.Price))), "green")
            
            local Date = os.date("*t", os.time())
            TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
                Type = 3,
                Title = SharedData.Name .. ' - ' .. Plate,
                Content = (exports['fw-businesses']:GetVehicleRegistration()):format(SharedData.Name, Data.Model, Plate, VIN, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, 'Rico Pieters', Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min, exports['fw-businesses']:NumberWithCommas(tonumber(SharedData.Price))),
                Signatures = {
                    { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
                    { Signed = true, Name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Timestamp = os.time() * 1000, Cid = Player.PlayerData.citizenid },
                },
                Sharees = { Player.PlayerData.citizenid },
                Finalized = 1,
            })

            TriggerClientEvent('fw-misc:Client:SpawnJobVehicle', Source, Data.Model, Plate)
        else
            TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Geweigerd!", true)
        end
    end)
end)
