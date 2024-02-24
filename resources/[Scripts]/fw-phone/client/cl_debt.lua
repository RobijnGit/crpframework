RegisterNUICallback("Debt/GetDebt", function(Data, Cb)
    local Result = FW.SendCallback("fw-misc:Server:GetDebts")
    Cb(Result)
end)

RegisterNUICallback("Debt/PayDebt", function(Data, Cb)
    local Result = FW.SendCallback("fw-misc:Server:PayDebt", Data)
    Cb(Result)
end)