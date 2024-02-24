RegisterNUICallback("Evidence/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Evidence:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Evidence/FetchById", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Evidence:FetchById", Data.Id)
    Cb(Result)
end)

RegisterNUICallback("Evidence/SaveEvidence", function(Data, Cb)
    local Saved = FW.SendCallback("fw-mdw:Server:Evidence:Save", Data)
    local Result = Data

    if Saved.Success then
        Result = FW.SendCallback("fw-mdw:Server:Evidence:FetchById", Saved.Id or Data.id)
    end

    Cb(Result)
end)

RegisterNUICallback("Evidence/DeleteEvidence", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Evidence:Delete", Data)
    Cb(Result)
end)

RegisterNUICallback("Evidence/AddTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Evidence:AddTag", Data)
    Cb(Result)
end)

RegisterNUICallback("Evidence/RemoveTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Evidence:RemoveTag", Data)
    Cb(Result)
end)