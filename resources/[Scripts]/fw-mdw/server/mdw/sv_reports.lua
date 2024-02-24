FW.Functions.CreateCallback("fw-mdw:Server:Reports:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `author`, `category`, `title`, `scums`, `created`, `tags` FROM `mdw_reports` ORDER BY `created` DESC")
    for k, v in pairs(Result) do
        v.tags = json.decode(v.tags)
    end
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:FetchById", function(Source, Cb, Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Id
    })

    local Retval = {}
    if Result[1] then
        Retval = Result[1]
        Retval.evidence = json.decode(Retval.evidence)
        Retval.tags = json.decode(Retval.tags)
        Retval.officers = json.decode(Retval.officers)
        Retval.persons = json.decode(Retval.persons)
        -- Retval.vehicles = json.decode(Retval.vehicles)
        Retval.scums = json.decode(Retval.scums)
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:SaveReport", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Data.id then
        local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `category` = @Category, `title` = @Title, `report` = @Report WHERE `id` = @Id", {
            ['@Category'] = Data.category,
            ['@Title'] = Data.title,
            ['@Report'] = Data.report,
            ['@Id'] = Data.id
        })
        return Cb({Success = Result.affectedRows > 0})
    else
        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_reports` (`author`, `category`, `title`, `report`) VALUES (@Author, @Category, @Title, @Report)", {
            ['@Author'] = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            ['@Category'] = Data.category,
            ['@Title'] = Data.title,
            ['@Report'] = Data.report,
        })
        return Cb({Success = Result.affectedRows > 0, Id = Result.insertId})
    end

    Cb(false)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:Export", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Data.id then
        return Cb({Msg = "Het rapport dat je wilt exporteren bestaat niet.", Url = false})
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT `title`, `report` FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.id,
    })

    local Retval = ExportReportToGoogleDoc({Id = Data.id})
    Cb({Msg = Retval.Msg, Url = Retval.Url})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:RemoveReport", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    -- if not Player.PlayerData.metadata.ishighcommand then
    --     return Cb(false)
    -- end
    
    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })
    
    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:AddEvidence", function(Source, Cb, Data)
    local Report = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })

    if Report[1] == nil then
        return Cb({Success = false})
    end

    Report = Report[1]
    local Evidence = json.decode(Report.evidence)

    if Data.Create then
        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_evidence` (`type`, `identifier`, `description`, `citizenid`) VALUES (@Type, @Identifier, @Description, @Cid)", {
            ['@Type'] = Data.Form.Type,
            ['@Identifier'] = Data.Form.Identifier,
            ['@Description'] = Data.Form.Description,
            ['@Cid'] = Data.Form.Cid,
        })

        Evidence[#Evidence + 1] = Result.insertId
    else
        local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_evidence` WHERE `id` = @Id", {
            ['@Id'] = Data.Form.Id
        })
        if Result[1] == nil then return Cb({Success = false}) end
        Evidence[#Evidence + 1] = tonumber(Data.Form.Id)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `evidence` = @Evidence WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
        ['@Evidence'] = json.encode(Evidence),
    })

    Cb({Success = Result.affectedRows > 0, Data = Evidence[#Evidence]})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:RemoveEvidence", function(Source, Cb, Data)
    local Report = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })
    if Report[1] == nil then return Cb({Success = false}) end

    local Evidence = json.decode(Report[1].evidence)
    table.remove(Evidence, Data.EvidenceId + 1)

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `evidence` = @Evidence WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
        ['@Evidence'] = json.encode(Evidence),
    })

    Cb({Success = Result.affectedRows > 0})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:AddOfficer", function(Source, Cb, Data)
    local Report = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })
    if Report[1] == nil then return Cb({Success = false}) end

    local Officers = json.decode(Report[1].officers)
    Officers[#Officers + 1] = Data.OfficerId

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `officers` = @Officers WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
        ['@Officers'] = json.encode(Officers),
    })

    Cb({Success = Result.affectedRows > 0})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:RemoveOfficer", function(Source, Cb, Data)
    if not Data.ReportId or not Data.OfficerId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
    })

    if Result[1] == nil then return Cb(false) end
    local Officers = json.decode(Result[1].officers)
    table.remove(Officers, Data.OfficerId + 1)

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `officers` = @Officers WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
        ['@Officers'] = json.encode(Officers),
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:AddPerson", function(Source, Cb, Data)
    local Report = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })
    if Report[1] == nil then return Cb({Success = false}) end

    local Persons = json.decode(Report[1].persons)
    Persons[#Persons + 1] = Data.PersonId

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `persons` = @Persons WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
        ['@Persons'] = json.encode(Persons),
    })

    Cb({Success = Result.affectedRows > 0})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:RemovePerson", function(Source, Cb, Data)
    if not Data.ReportId or not Data.PersonId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
    })

    if Result[1] == nil then return Cb(false) end
    local Persons = json.decode(Result[1].persons)
    table.remove(Persons, Data.PersonId + 1)

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `persons` = @Persons WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId,
        ['@Persons'] = json.encode(Persons),
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:AddTag", function(Source, Cb, Data)
    if not Data.ReportId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    Tags[#Tags + 1] = Data.TagId

    exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.ReportId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:RemoveTag", function(Source, Cb, Data)
    if not Data.ReportId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    table.remove(Tags, Data.TagId + 1)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.ReportId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:AddCriminalScum", function(Source, Cb, Data)
    if not Data.ReportId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })

    if Result[1] == nil then return Cb(false) end
    local Scums = json.decode(Result[1].scums)
    Scums[#Scums + 1] = Data.ScumData

    exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `scums` = @Scums WHERE `id` = @Id", {
        ['@Scums'] = json.encode(Scums),
        ['@Id'] = Data.ReportId,
    })

    Cb(Scums[#Scums])
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:SaveScum", function(Source, Cb, Data)
    if not Data.ReportId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })

    if Result[1] == nil then return Cb(false) end
    local Scums = json.decode(Result[1].scums)
    Scums[Data.ScumId + 1] = Data.ScumData

    exports['ghmattimysql']:execute("UPDATE `mdw_profiles` SET `wanted` = @Wanted WHERE `id` = @Id", {
        ['@Wanted'] = Data.ScumData.Warrent,
        ['@Id'] = Data.ScumData.Id
    })

    exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `scums` = @Scums WHERE `id` = @Id", {
        ['@Scums'] = json.encode(Scums),
        ['@Id'] = Data.ReportId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Reports:DeleteScum", function(Source, Cb, Data)
    if not Data.ReportId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_reports` WHERE `id` = @Id", {
        ['@Id'] = Data.ReportId
    })

    if Result[1] == nil then return Cb(false) end
    local Scums = json.decode(Result[1].scums)
    table.remove(Scums, Data.ScumId + 1)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_reports` SET `scums` = @Scums WHERE `id` = @Id", {
        ['@Scums'] = json.encode(Scums),
        ['@Id'] = Data.ReportId,
    })

    Cb(true)
end)

function ExportReportToGoogleDoc(Data)
    local Prom = promise.new()
    PerformHttpRequest('http://localhost:3000/export-mdw-report?reportId=' .. Data.Id, function(statusCode, responseText)
        if statusCode == 200 then
            Prom:resolve({Msg = "Downloadlink naar de geexporteerde PDF is gekopieerd naar je clipboard!<br/>(Expose de link niet op stream!)", Url = json.decode(responseText).downloadLink})
        else
            Prom:resolve({Msg = "Een fout was opgetreden tijdens het exporteren van dit report, probeer later opnieuw!<br/>Fout-code: " .. statusCode, Url = false})
        end
    end, 'GET', '', {})

    return Citizen.Await(Prom)
end