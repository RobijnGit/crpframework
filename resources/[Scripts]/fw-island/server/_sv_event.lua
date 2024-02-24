FW = exports['fw-core']:GetCoreObject()

RegisterNetEvent("fw-island:Server:Foodchain:SetPaymentData")
AddEventHandler("fw-island:Server:Foodchain:SetPaymentData", function(Foodchain, RegisterId, Order, Costs)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)

    if tonumber(Costs) == nil or tonumber(Costs) <= 0 then
        return
    end

    Config.ActiveIslandPayments[Foodchain][RegisterId] = {
        Order = Order,
        Costs = FW.Shared.CalculateTax('Services', Costs),
        OrgCosts = Costs,
        Employee = {
            Name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            Cid = Player.PlayerData.citizenid,
            Source = Player.PlayerData.source,
            Account = Player.PlayerData.charinfo.account
        }
    }
end)

FW.Functions.CreateCallback("fw-island:Server:Foodchain:GetPaymentData", function(Source, Cb, Foodchain, RegisterId)
    Cb(Config.ActiveIslandPayments[Foodchain][RegisterId] or false)
end)

RegisterNetEvent("fw-island:Server:Foodchain:PayRegister")
AddEventHandler("fw-island:Server:Foodchain:PayRegister", function(Data)
    local Src = source
    local Player = FW.Functions.GetPlayer(Src)
    if Player == nil then return end
    local PaymentData = Config.ActiveIslandPayments[Data.Foodchain][Data.Register]
    if Player.PlayerData.citizenid == PaymentData.Employee.Cid then return end
    if not PaymentData then return end

    if (Data.PaymentType:lower() == 'cash' and Player.Functions.RemoveMoney('cash', PaymentData.Costs)) or (Data.PaymentType:lower() == 'bank' and exports['fw-financials']:RemoveMoneyFromAccount(PaymentData.Employee.Cid, PaymentData.Employee.Account, Player.PlayerData.charinfo.account, PaymentData.Costs, 'PURCHASE', 'Betaling zakelijke dienstverlening: ' .. PaymentData.Order, false)) then
        if Data.PaymentType:lower() == 'bank' then
            TriggerClientEvent('fw-phone:Client:Notification', Src, "business-pay-" .. Data.Foodchain .. Data.Register, "fas fa-home", { "white" , "rgb(38, 50, 56)" }, Data.Foodchain, exports['fw-businesses']:NumberWithCommas(PaymentData.Costs) .. " afgeschreven van je bankrekening.")
        end
        TriggerClientEvent('fw-phone:Client:Notification', PaymentData.Employee.Source, "business-charge-" .. Data.Foodchain .. Data.Register, "fas fa-home", { "white" , "rgb(38, 50, 56)" }, Data.Foodchain, exports['fw-businesses']:NumberWithCommas(PaymentData.Costs) .. " is succesvol afgeschreven.")
        exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, PaymentData.Employee.Account, PaymentData.OrgCosts, 'PURCHASE', 'Betaling zakelijke dienstverlening: ' .. PaymentData.Order)
        exports['fw-financials']:AddMoneyToAccount('1001', "1", "1", PaymentData.Costs - PaymentData.OrgCosts, 'TAX', ('Services Tax. (%s: %s)'):format(Data.Foodchain, exports['fw-businesses']:NumberWithCommas(PaymentData.Costs))) -- Tax to the state

        Config.ActiveIslandPayments[Data.Foodchain][Data.Register] = false
    else
        TriggerClientEvent('FW:Notify', Src, 'Je hebt niet genoeg geld..', 'error')
    end
end)