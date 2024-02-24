RegisterNUICallback("Reports/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Reports/FetchById", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:FetchById", Data.Id)
    Cb(Result)
end)


RegisterNUICallback("Reports/SaveReport", function(Data, Cb)
    local Saved = FW.SendCallback("fw-mdw:Server:Reports:SaveReport", Data)
    local Result = Data
    if Saved.Success then
        Result = FW.SendCallback("fw-mdw:Server:Reports:FetchById", Saved.Id or Data.id)
    end
    
    Cb(Result)
end)

RegisterNUICallback("Reports/Export", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:Export", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/RemoveReport", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:RemoveReport", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/AddEvidence", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:AddEvidence", Data)
    Cb(Result.Data)
end)

RegisterNUICallback("Reports/RemoveEvidence", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:RemoveEvidence", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/AddOfficer", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:AddOfficer", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/RemoveOfficer", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:RemoveOfficer", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/AddPerson", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:AddPerson", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/RemovePerson", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:RemovePerson", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/AddTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:AddTag", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/RemoveTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:RemoveTag", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/AddCriminalScum", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:AddCriminalScum", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/SaveScum", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:SaveScum", Data)
    Cb(Result)
end)

RegisterNUICallback("Reports/DeleteScum", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Reports:DeleteScum", Data)
    Cb(Result)
end)