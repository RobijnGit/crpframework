RegisterNUICallback("Businesses/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Businesses:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Businesses/FetchEmployees", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Businesses:FetchEmployees", Data)
    Cb(Result)
end)