RegisterNUICallback("Staff/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Staff:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Staff/FetchById", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Staff:FetchById", Data.Id)
    Cb(Result)
end)

RegisterNUICallback("Staff/AddCert", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Staff:AddCert", Data)
    Cb(Result)
end)

RegisterNUICallback("Staff/RemoveCert", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Staff:RemoveCert", Data)
    Cb(Result)
end)

RegisterNUICallback("Staff/AddRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Staff:AddRole", Data)
    Cb(Result)
end)

RegisterNUICallback("Staff/RemoveRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Staff:RemoveRole", Data)
    Cb(Result)
end)