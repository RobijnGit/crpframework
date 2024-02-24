RegisterNUICallback("Profiles/FetchAll", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:FetchAll")
    Cb(Result)
end)

RegisterNUICallback("Profiles/FetchById", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:FetchById", Data.Id)
    Cb(Result)
end)

RegisterNUICallback("Profiles/SaveProfile", function(Data, Cb)
    local Saved = FW.SendCallback("fw-mdw:Server:Profiles:SaveProfile", Data)
    local Result = Data
    if Saved.Success then
        Result = FW.SendCallback("fw-mdw:Server:Profiles:FetchById", Saved.Id or Data.id)
    end

    Cb(Result)
end)

RegisterNUICallback("Profiles/DeleteProfile", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:DeleteProfile", Data)
    Cb(Result)
end)

RegisterNUICallback("Profiles/RevokeLicense", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:RevokeLicense", Data)
    Cb(Result)
end)

RegisterNUICallback("Profiles/AddTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:AddTag", Data)
    Cb(Result)
end)

RegisterNUICallback("Profiles/RemoveTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:RemoveTag", Data)
    Cb(Result)
end)

RegisterNUICallback("Vehicles/FetchImpoundHistory", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:GetVehicleImpoundHistory", Data)
    Cb(Result)
end)

RegisterNUICallback("Vehicles/FetchOwnershipHistory", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Profiles:GetVehicleOwnershipHistory", Data)
    Cb(Result)
end)