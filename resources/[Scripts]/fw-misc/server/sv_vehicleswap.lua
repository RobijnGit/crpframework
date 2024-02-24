FW.Functions.CreateCallback("fw-misc:Server:GetPlayerVehicles", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `citizenid` = ?", {
        Player.PlayerData.citizenid
    })

    Cb(Result)
end)

RegisterNetEvent("fw-misc:Server:SetVehicleSwap")
AddEventHandler("fw-misc:Server:SetVehicleSwap", function(Data)
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    if not Data.Vehicle or not Data.VIN or not Data.Plate or not Data.Swap then
        print("[CHEATER]: Possible cheater tried to swap vehicle!", Player.PlayerData.steam)
        return
    end

    if FW.Throttled("vehicleswap-" .. Player.PlayerData.citizenid, 5250) then
        print("[CHEATER]: Possible cheater spamming swap vehicle!", Player.PlayerData.steam)
        Player.Functions.Notify("Je gaat te snel..")
        return
    end

    Citizen.Wait(250)

    local SharedData = FW.Shared.HashVehicles[GetHashKey(Data.Vehicle)]
    if not SharedData then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `citizenid` = ? AND `plate` = ? AND `vinnumber` = ?", {
        Player.PlayerData.citizenid,
        Data.Plate,
        Data.VIN
    })

    if Result[1] == nil then
        return Player.Functions.Notify("Je kan dit voertuig niet omruilen!", "error")
    end

    if Data.Swap == "Refund" then
        local IsDeleted = exports['ghmattimysql']:executeSync("DELETE FROM `player_vehicles` WHERE `plate` = ? AND `vinnumber` = ?", {Data.Plate, Data.VIN})
        if IsDeleted.affectedRows >= 1 then
            if Result[1].vinscratched == 0 then
                exports['fw-financials']:AddMoneyToAccount('1001', '1', Player.PlayerData.charinfo.account, FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price), "REFUND", ("Refund voor %s"):format(SharedData.Name))
            end
            TriggerEvent("fw-logs:Server:Log", 'vehicleswaps', "Vehicle Refunded", ("User: [%s] - %s - %s\nVehicle: %s [%s - %s]\nRefund: %s\nIsVIN: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Vehicle, Data.Plate, Data.VIN, exports['fw-businesses']:NumberWithCommas(FW.Shared.CalculateTax("Vehicle Registration Tax", SharedData.Price)), Result[1].vinscratched == 1), "red")
        end

        return
    end

    exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `vehicle` = ? WHERE `plate` = ? AND `vinnumber` = ?", {
        Data.Swap,
        Data.Plate,
        Data.VIN
    })

    TriggerEvent("fw-logs:Server:Log", 'vehicleswaps', "Vehicle Swapped", ("User: [%s] - %s - %s\nVehicle: %s [%s - %s]\nSwapped Model: %s\nIsVIN: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Vehicle, Data.Plate, Data.VIN, Data.Swap, Result[1].vinscratched == 1), "green")

    Player.Functions.Notify(("%s omgeruild naar %s!"):format(Data.Vehicle, Data.Swap), "success")
end)