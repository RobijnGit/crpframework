local VehicleFuel = {}

RegisterNetEvent("fw-vehicles:Server:FuelHelicopter")
AddEventHandler("fw-vehicles:Server:FuelHelicopter", function(Data, NetId)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

-- todo: calculate based on fuel level
    -- local Price = math.random(1000, 7500)

    local Fuel = GetVehicleMeta(NetId, 'Fuel')
    local Price = FW.Shared.CalculateTax("Gas", math.ceil((100 - Fuel) * Config.FuelPrice * 2))

    TriggerClientEvent("fw-phone:Client:Notification", Player.PlayerData.source, "fuel-aircraft-" .. Player.PlayerData.citizenid, "fas fa-gas-pump", { "white", "rgb(38, 50, 56)" }, "Zakelijke Facturatie", exports['fw-businesses']:NumberWithCommas(tonumber(Price)) .. " incl. tax", false, true, "fw-vehicles:Server:AcceptHeliFuelCharge", "fw-phone:Client:RemoveNotificationById", { Id = "fuel-aircraft-" .. Player.PlayerData.citizenid, Amount = Price, NetId = NetId })
end)

RegisterNetEvent('fw-vehicles:Server:AcceptHeliFuelCharge')
AddEventHandler('fw-vehicles:Server:AcceptHeliFuelCharge', function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if exports['fw-financials']:RemoveMoneyFromAccount('1001', '1', Player.PlayerData.charinfo.account, Data.Amount, 'PURCHASE', 'Vliegvaartuig Benzine', false) then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Betaling Voltooid!", true)
        TriggerClientEvent("fw-vehicles:Client:Fuel:StartRefuel", Source, {Liters = 100})
    else
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Betaling Geweigerd!", true)
    end
end)

RegisterNetEvent("fw-vehicles:Server:Fuel:SendBill")
AddEventHandler("fw-vehicles:Server:Fuel:SendBill", function(Plate, Target, Liters)
    local Player = FW.Functions.GetPlayerByCitizenId(Target)
    if Player == nil then return end

    local Price = (Liters * Config.FuelPrice) * 1.17
    TriggerClientEvent("fw-phone:Client:Notification", Player.PlayerData.source, "fuel-bill-" .. Player.PlayerData.citizenid, "fas fa-gas-pump", { "white", "rgb(38, 50, 56)" }, "Tankstation", exports['fw-businesses']:NumberWithCommas(tonumber(Price)) .. " incl. BTW", false, true, "fw-vehicles:Server:Fuel:PayBill", "fw-phone:Client:RemoveNotificationById", { Id = "fuel-bill-" .. Player.PlayerData.citizenid, Amount = Price, Plate = Plate, Liters = Liters })
end)

RegisterNetEvent("fw-vehicles:Server:Fuel:PayBill")
AddEventHandler("fw-vehicles:Server:Fuel:PayBill", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if exports['fw-financials']:RemoveMoneyFromAccount('1001', '1', Player.PlayerData.charinfo.account, Data.Amount, 'PURCHASE', math.ceil(Data.Liters) .. ' liter aan brandstof gekocht.', false) then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Voltooid!", true)
        VehicleFuel[Data.Plate] = true

        local _, Deduction = FW.Shared.DeductTax("Gas", Data.Amount)
        exports['fw-financials']:AddMoneyToAccount('1001', "1", "1", Deduction, 'TAX', 'Betaling benzinepomp ' .. Data.Plate .. " (" .. math.ceil(Data.Liters) .. " liter)") -- Tax to the state
    else
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Geweigerd!", true)
    end
end)

RegisterNetEvent("fw-vehicles:Server:Fuel:SetPaidState")
AddEventHandler("fw-vehicles:Server:Fuel:SetPaidState", function(Plate)
    VehicleFuel[Plate] = false
end)

FW.Functions.CreateCallback("fw-vehicles:Server:Fuel:IsBillPaid", function(Source, Cb, Plate)
    Cb(VehicleFuel[Plate])
end)