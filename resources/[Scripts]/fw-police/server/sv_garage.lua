RegisterNetEvent('fw-police:Server:PurchaseVehicle')
AddEventHandler('fw-police:Server:PurchaseVehicle', function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' then return end

    local SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Vehicle)]
    local Plate = FW.Functions.GeneratePlate()
    local VIN = FW.Functions.GenerateVin()

    local Account = Data.Shared and "4" or Player.PlayerData.charinfo.account

    if exports['fw-financials']:RemoveMoneyFromAccount("1001", "1", Account, FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price), "PURCHASE", "Voertuig aankoop " .. SharedData.Name, false) then
        exports['ghmattimysql']:execute("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `garage`, `vinnumber`) VALUES (@Cid, @Vehicle, @Plate, 'gov_mrpd', @VIN)", {
            ['@Cid'] = Data.Shared and "gov_pd" or Player.PlayerData.citizenid,
            ['@Vehicle'] = Data.Vehicle,
            ['@Plate'] = Plate,
            ['@VIN'] = VIN,
        })

        exports['ghmattimysql']:executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", {
            "1001",
            Data.Shared and "gov_pd" or Player.PlayerData.citizenid,
            Plate,
            SharedData.Price,
            os.time() * 1000
        })

        TriggerClientEvent('FW:Notify', Player.PlayerData.source, "Je hebt een " .. SharedData.Name .. " gekocht..", "success")
    else
        Player.Functions.Notify("Niet genoeg geld..", "error")
    end
end)