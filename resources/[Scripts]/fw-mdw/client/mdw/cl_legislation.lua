RegisterNUICallback("Legislation/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Legislation:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Legislation/FetchById", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Legislation:FetchById", Data.Id)
    Cb(Result)
end)

RegisterNUICallback("Legislation/SaveLegislation", function(Data, Cb)
    local Saved = FW.SendCallback("fw-mdw:Server:Legislation:SaveLegislation", Data)
    local Result = Data
    if Saved.Success then
        Result = FW.SendCallback("fw-mdw:Server:Legislation:FetchById", Saved.Id or Data.id)
    end

    Cb(Result)
end)

RegisterNUICallback("Legislation/DeleteLegislation", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Legislation:DeleteLegislation", Data)
    Cb(Result)
end)

RegisterNUICallback("Legislation/AddTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Legislation:AddTag", Data)
    Cb(Result)
end)

RegisterNUICallback("Legislation/RemoveTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Legislation:RemoveTag", Data)
    Cb(Result)
end)