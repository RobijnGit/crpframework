RegisterNUICallback("Properties/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Properties:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Properties/FetchProperty", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Properties:FetchProperty", Data)
    Cb(Result)
end)