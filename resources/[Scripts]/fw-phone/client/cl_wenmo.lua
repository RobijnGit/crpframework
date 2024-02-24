RegisterNUICallback("Wenmo/GetTransactions", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Wenmo:GetTransactions")
    Cb(Result)
end)

RegisterNUICallback("Wenmo/SendMoney", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Wenmo:SendMoney", Data)
    if Result.Success then
        UpdatePlayerData()

        local Transactions = FW.SendCallback("fw-phone:Server:Wenmo:GetTransactions")
        SendNUIMessage({
            Action = "Wenmo/SetTransactions",
            Transactions = Transactions,
        })

    end
    Cb(Result)
end)