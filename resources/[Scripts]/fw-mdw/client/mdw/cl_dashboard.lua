RegisterNUICallback("Dashboard/GetWarrents", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Dashboard:GetWarrents")
    Cb(Result)
end)

RegisterNUICallback("Dashboard/GetBulletin", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Dashboard:GetBulletin")
    Cb(Result)
end)