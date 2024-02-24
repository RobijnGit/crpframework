RegisterNUICallback("BankBusters/GetBusters", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:GetBusters")
    Cb(Result)
end)

RegisterNUICallback("BankBusters/ClaimHeist", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:ClaimHeist", Data)
    Cb(Result)
end)