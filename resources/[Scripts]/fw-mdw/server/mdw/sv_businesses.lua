FW.Functions.CreateCallback("fw-mdw:Server:Businesses:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `business_name`, `business_account` FROM `phone_businesses` ORDER BY `business_name` ASC")
    Cb(Result)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Businesses:FetchEmployees", function(Source, Cb, Data)
    local Result = exports['ghmattimysql']:executeSync("SELECT `business_owner`, `business_employees` FROM `phone_businesses` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    local Employees = {}
    if Result[1] then
        Employees = json.decode(Result[1].business_employees)
        table.insert(Employees, 1, {
            Cid = Result[1].business_owner,
            Role = "Eigenaar"
        })

        for k, v in pairs(Employees) do
            v.Name = FW.Functions.GetPlayerCharName(v.Cid) or "Persoon bestaat niet..."
        end
    end

    Cb({ id = Data.Id, Employees = Employees })
end)