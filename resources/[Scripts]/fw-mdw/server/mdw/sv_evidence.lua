FW.Functions.CreateCallback("fw-mdw:Server:Evidence:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `type`, `identifier`, `description`, `citizenid` FROM `mdw_evidence` ORDER BY `id` DESC")
    Cb(Result)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Evidence:FetchById", function(Source, Cb, Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_evidence` WHERE `id` = @Id", {
        ['@Id'] = Id
    })

    if Result[1] then
        Result[1].tags = json.decode(Result[1].tags)
    end

    Cb(Result[1] or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Evidence:Save", function(Source, Cb, Data)
    if Data.id then
        local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_evidence` SET `type` = @Type, `identifier` = @Identifier, `description` = @Description, `citizenid` = @Cid WHERE `id` = @Id", {
            ['@Type'] = Data.type,
            ['@Identifier'] = Data.identifier,
            ['@Description'] = Data.description,
            ['@Cid'] = Data.citizenid,
            ['@Id'] = Data.id
        })
        return Cb({Success = Result.affectedRows > 0})
    else
        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_evidence` (`type`, `identifier`, `description`, `citizenid`) VALUES (@Type, @Identifier, @Description, @Cid)", {
            ['@Type'] = Data.type,
            ['@Identifier'] = Data.identifier,
            ['@Description'] = Data.description,
            ['@Cid'] = Data.citizenid,
        })
        return Cb({Success = Result.affectedRows > 0, Id = Result.insertId})
    end

    Cb(false)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Evidence:Delete", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- if not Player.PlayerData.metadata.ishighcommand then
    --     return Cb(false)
    -- end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `mdw_evidence` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Evidence:AddTag", function(Source, Cb, Data)
    if not Data.EvidenceId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_evidence` WHERE `id` = @Id", {
        ['@Id'] = Data.EvidenceId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    Tags[#Tags + 1] = Data.TagId

    exports['ghmattimysql']:executeSync("UPDATE `mdw_evidence` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.EvidenceId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Evidence:RemoveTag", function(Source, Cb, Data)
    if not Data.EvidenceId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_evidence` WHERE `id` = @Id", {
        ['@Id'] = Data.EvidenceId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    table.remove(Tags, Data.TagId + 1)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_evidence` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.EvidenceId,
    })

    Cb(true)
end)