-- Tags
RegisterNUICallback("Config/CreateTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateTag", Data)
    SendUIMessage("Mdw/SetTags", FW.SendCallback("fw-mdw:Server:FetchAllTags"))
    Cb(Result)
end)

RegisterNUICallback("Config/SaveTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:SaveTag", Data)
    SendUIMessage("Mdw/SetTags", FW.SendCallback("fw-mdw:Server:FetchAllTags"))
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteTag", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteTag", Data)
    SendUIMessage("Mdw/SetTags", FW.SendCallback("fw-mdw:Server:FetchAllTags"))
    Cb(Result)
end)

-- Evidence Types
RegisterNUICallback("Config/CreateEvidenceType", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateEvidenceType", Data)
    SendUIMessage("Mdw/SetEvidence", FW.SendCallback("fw-mdw:Server:FetchAllEvidenceTypes"))
    Cb(Result)
end)

RegisterNUICallback("Config/SaveEvidenceType", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:SaveEvidenceType", Data)
    SendUIMessage("Mdw/SetEvidence", FW.SendCallback("fw-mdw:Server:FetchAllEvidenceTypes"))
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteEvidenceType", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteEvidenceType", Data)
    SendUIMessage("Mdw/SetEvidence", FW.SendCallback("fw-mdw:Server:FetchAllEvidenceTypes"))
    Cb(Result)
end)

-- Certs
RegisterNUICallback("Config/CreateCert", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateCert", Data)
    SendUIMessage("Mdw/SetCerts", FW.SendCallback("fw-mdw:Server:FetchAllCerts"))
    Cb(Result)
end)

RegisterNUICallback("Config/SaveCert", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:SaveCert", Data)
    SendUIMessage("Mdw/SetCerts", FW.SendCallback("fw-mdw:Server:FetchAllCerts"))
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteCert", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteCert", Data)
    SendUIMessage("Mdw/SetCerts", FW.SendCallback("fw-mdw:Server:FetchAllCerts"))
    Cb(Result)
end)

-- Ranks
RegisterNUICallback("Config/CreateRank", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateRank", Data)
    SendUIMessage("Mdw/SetRanks", FW.SendCallback("fw-mdw:Server:FetchAllRanks"))
    Cb(Result)
end)

RegisterNUICallback("Config/SaveRank", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:SaveRank", Data)
    SendUIMessage("Mdw/SetRanks", FW.SendCallback("fw-mdw:Server:FetchAllRanks"))
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteRank", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteRank", Data)
    SendUIMessage("Mdw/SetRanks", FW.SendCallback("fw-mdw:Server:FetchAllRanks"))
    Cb(Result)
end)

-- Staff
RegisterNUICallback("Config/FetchAllStaff", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:FetchAllStaff", Data)
    Cb(Result)
end)

RegisterNUICallback("Config/CreateStaff", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateStaff", Data)
    Cb(Result)
end)

RegisterNUICallback("Config/SaveStaff", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:SaveStaff", Data)
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteStaff", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteStaff", Data)
    Cb(Result)
end)

RegisterNUICallback("Config/CreateBadge", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateBadge", Data)
    Cb(Result)
end)

-- Roles
RegisterNUICallback("Config/CreateRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:CreateRole", Data)
    SendUIMessage("Mdw/SetRoles", FW.SendCallback("fw-mdw:Server:FetchAllRoles"))
    Cb(Result)
end)

RegisterNUICallback("Config/SaveRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:SaveRole", Data)
    SendUIMessage("Mdw/SetRoles", FW.SendCallback("fw-mdw:Server:FetchAllRoles"))
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteRole", Data)
    SendUIMessage("Mdw/SetRoles", FW.SendCallback("fw-mdw:Server:FetchAllRoles"))
    Cb(Result)
end)

-- Charges
RegisterNUICallback("Config/EditCharge", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:EditCharge", Data)
    Result.Charges = FW.SendCallback("fw-mdw:Server:FetchAllCharges", MdwType)
    Cb(Result)
end)

RegisterNUICallback("Config/DeleteCharge", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:Config:DeleteCharge", Data)
    Result.Charges = FW.SendCallback("fw-mdw:Server:FetchAllCharges", MdwType)
    Cb(Result)
end)