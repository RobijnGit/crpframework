FW.Functions.CreateCallback("fw-mdw:Server:FetchAllCharges", function(Source, Cb, Type)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_charges` WHERE `gov_type` = @GovType ORDER BY `id` ASC", {
        ['@GovType'] = Type,
    })
    for k, v in pairs(Result) do
        v.accomplice = json.decode(v.accomplice)
        v.attempted = json.decode(v.attempted)
    end
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:FetchStaffRoles", function(Source, Cb, Data)
    local Result = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `roles` FROM `mdw_staff` WHERE `citizenid` = @Cid", {
        ['@Cid'] = Data.Cid
    })

    if not Result[1] then
        Cb({Success = false})
        return
    end

    Result[1].roles = json.decode(Result[1].roles)
    Result[1].Success = true
    Cb(Result[1])
end)

FW.Functions.CreateCallback("fw-mdw:Server:FetchAllTags", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_tags` ORDER BY `id` DESC")
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:FetchAllCerts", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_certs` ORDER BY `id` DESC")
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:FetchAllRanks", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_ranks` ORDER BY `id` DESC")
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:FetchAllEvidenceTypes", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_evidence_types` ORDER BY `id` DESC")
    local Retval = {}

    for k, v in pairs(Result) do
        Retval[#Retval + 1] = {
            deleted = v.deleted,
            Id = v.id,
            Text = v.type,
            Color = v.color,
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-mdw:Server:FetchAllRoles", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_roles` ORDER BY `id` DESC")

    for k, v in pairs(Result) do
        v.permissions = json.decode(v.permissions)
    end

    Cb(Result[1] and Result or {})
end)