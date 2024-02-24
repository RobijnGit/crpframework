Employment = {}

RegisterNUICallback("Employment/GetBusinesses", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:GetBusinessesByPlayer")
    Cb(Result)
end)

RegisterNUICallback('Employment/HireEmployee', function(Data, Cb)
    local Result = FW.SendCallback('fw-businesses:Server:AddEmployee', Data.Business, Data.Employee, Data.Role)
    Cb(Result)
end)

RegisterNUICallback('Employment/RemoveEmployee', function(Data, Cb)
    local Result = FW.SendCallback('fw-businesses:Server:RemoveEmployee', Data.Business, Data.Employee)
    Cb(Result)
end)

RegisterNUICallback('Employment/GetFinancialAccess', function(Data, Cb)
    local Result = FW.SendCallback('fw-financials:Server:GetFinancialAccess', Data.AccountId, Data.Employee)
    Cb(Result)
end)

RegisterNUICallback('Employment/SetFinancialAccess', function(Data, Cb)
    local Result = FW.SendCallback('fw-financials:Server:SetFinancialAccess', Data)
    Cb(Result)
end)

RegisterNUICallback('Employment/ChangeRole', function(Data, Cb)
    local Result = FW.SendCallback('fw-businesses:Server:SetEmployeeRank', Data.Business, Data.Employee, Data.Role)
    Cb(Result)
end)

-- Roles
RegisterNUICallback("Employment/CreateRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:CreateRole", Data.Business, Data.Name, Data.Permissions)
    Cb(Result)
end)

RegisterNUICallback("Employment/EditRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:EditRole", Data.Business, Data.Name, Data.Permissions)
    Cb(Result)
end)

RegisterNUICallback("Employment/DeleteRole", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:DeleteRole", Data.Business, Data.Name)
    Cb(Result)
end)

-- Employees
RegisterNUICallback("Employment/PayExternal", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:PayExternal", Data.Business, Data.Cid, Data.Amount, Data.Comment)
    Cb(Result)
end)

RegisterNUICallback("Employment/ChargeCustomer", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:ChargeCustomer", Data.Business, Data.Cid, Data.Amount, Data.Comment)
    Cb(Result)
end)

-- Flightschool
RegisterNUICallback("Employment/GivePilotLicense", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:Flightschool:GivePilotLicense", Data)
    Cb(Result)
end)