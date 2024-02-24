FW.Functions.CreateCallback("fw-mdw:Server:Legislation:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `title` FROM `mdw_legislation` ORDER BY `created` DESC")
    Cb(Result[1] and Result or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Legislation:FetchById", function(Source, Cb, Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_legislation` WHERE `id` = @Id", {
        ['@Id'] = Id
    })

    local Retval = {}
    if Result[1] then
        Retval = Result[1]
        Retval.tags = json.decode(Retval.tags)
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Legislation:SaveLegislation", function(Source, Cb, Data)
    if Data.id then
        local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_legislation` SET `title` = @Title, `content` = @Content WHERE `id` = @Id", {
            ['@Title'] = Data.title,
            ['@Content'] = Data.content,
            ['@Id'] = Data.id
        })
        return Cb({Success = Result.affectedRows > 0})
    else
        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_legislation` (`title`, `content`) VALUES (@Title, @Content)", {
            ['@Title'] = Data.title,
            ['@Content'] = Data.content,
        })
        return Cb({Success = Result.affectedRows > 0, Id = Result.insertId})
    end

    Cb(false)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Legislation:DeleteLegislation", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- if not Player.PlayerData.metadata.ishighcommand then
    --     return Cb(false)
    -- end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `mdw_legislation` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Legislation:AddTag", function(Source, Cb, Data)
    if not Data.LegislationId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_legislation` WHERE `id` = @Id", {
        ['@Id'] = Data.LegislationId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    Tags[#Tags + 1] = Data.TagId

    exports['ghmattimysql']:executeSync("UPDATE `mdw_legislation` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.LegislationId,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Legislation:RemoveTag", function(Source, Cb, Data)
    if not Data.LegislationId or not Data.TagId then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_legislation` WHERE `id` = @Id", {
        ['@Id'] = Data.LegislationId
    })

    if Result[1] == nil then return Cb(false) end
    local Tags = json.decode(Result[1].tags)
    table.remove(Tags, Data.TagId + 1)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_legislation` SET `tags` = @Tags WHERE `id` = @Id", {
        ['@Tags'] = json.encode(Tags),
        ['@Id'] = Data.LegislationId,
    })

    Cb(true)
end)