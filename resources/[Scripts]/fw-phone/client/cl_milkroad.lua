RegisterNUICallback("MilkRoad/GetProducts", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:MilkRoad:GetProducts", CurrentNetwork)
    Cb(Result)
end)

RegisterNUICallback("MilkRoad/PurchaseProduct", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:MilkRoad:PurchaseProduct", CurrentNetwork, Data)
    Cb(Result)
end)