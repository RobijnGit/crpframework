-- Tags
FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateTag", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_tags` (`tag`, `color`, `icon`) VALUES (@Tag, @Color, @Icon)", {
        ['@Tag'] = Data.tag,
        ['@Color'] = Data.color,
        ['@Icon'] = Data.icon,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:SaveTag", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_tags` SET `tag` = @Tag, `color` = @Color, `icon` = @Icon, `deleted` = 0 WHERE `id` = @Id", {
        ['@Tag'] = Data.tag,
        ['@Color'] = Data.color,
        ['@Icon'] = Data.icon,
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteTag", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_tags` SET `deleted` = 1 WHERE `id` = @Id", {
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

-- Evidence Types
FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateEvidenceType", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_evidence_types` (`type`) VALUES (@Type)", {
        ['@Type'] = Data.Text,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:SaveEvidenceType", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_evidence_types` SET `type` = @Type, `deleted` = 0 WHERE `id` = @Id", {
        ['@Type'] = Data.Text,
        ['@Id'] = Data.Id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteEvidenceType", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_evidence_types` SET `deleted` = 1 WHERE `id` = @Id", {
        ['@Id'] = Data.Id,
    })

    Cb(true)
end)

-- Certs
FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateCert", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_certs` (`certificate`, `color`) VALUES (@Certificate, @Color)", {
        ['@Certificate'] = Data.certificate,
        ['@Color'] = Data.color or "#ffffff",
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:SaveCert", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_certs` SET `certificate` = @Certificate, `color` = @Color, `deleted` = 0 WHERE `id` = @Id", {
        ['@Certificate'] = Data.certificate,
        ['@Color'] = Data.color,
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteCert", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_certs` SET `deleted` = 1 WHERE `id` = @Id", {
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

-- Ranks
FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateRank", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_ranks` (`rank`) VALUES (@Rank)", {
        ['@Rank'] = Data.rank,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:SaveRank", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_ranks` SET `rank` = @Rank, `deleted` = 0 WHERE `id` = @Id", {
        ['@Rank'] = Data.rank,
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteRank", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_ranks` SET `deleted` = 1 WHERE `id` = @Id", {
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

-- Staff
FW.Functions.CreateCallback("fw-mdw:Server:Config:FetchAllStaff", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `citizenid`, `name`, `image`, `callsign`, `alias`, `phonenumber`, `department`, `rank`, `deleted` FROM `mdw_staff` ORDER BY `id` DESC")
    Cb(Result)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateStaff", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_staff` (`citizenid`, `name`, `image`, `callsign`, `alias`, `phonenumber`, `department`, `rank`) VALUES (@Cid, @Name, @Image, @Callsign, @Alias, @Phone, @Department, @Rank)", {
        ['@Cid'] = Data.citizenid,
        ['@Name'] = Data.name,
        ['@Image'] = Data.image,
        ['@Callsign'] = Data.callsign,
        ['@Alias'] = Data.alias,
        ['@Phone'] = Data.phonenumber,
        ['@Department'] = Data.department,
        ['@Rank'] = Data.rank,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:SaveStaff", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `citizenid` = @Cid, `name` = @Name, `image` = @Image, `callsign` = @Callsign, `alias` = @Alias, `phonenumber` = @Phone, `department` = @Department, `rank` = @Rank, `deleted` = 0 WHERE `id` = @Id", {
        ['@Cid'] = Data.citizenid,
        ['@Name'] = Data.name,
        ['@Image'] = Data.image,
        ['@Callsign'] = Data.callsign,
        ['@Alias'] = Data.alias,
        ['@Phone'] = Data.phonenumber,
        ['@Department'] = Data.department,
        ['@Rank'] = Data.rank,
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteStaff", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `deleted` = 1 WHERE `id` = @Id", {
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateBadge", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local ItemInfo = {
        Name = Data.name,
        Rank = Data.rank,
        Callsign = Data.callsign,
        Image = Data.image,
        Department = Data.departmentLabel,
    }

    Player.Functions.AddItem("identification-badge", 1, false, ItemInfo, true, Data.badgeType or "pd")

    Cb(true)
end)

-- Roles
FW.Functions.CreateCallback("fw-mdw:Server:Config:CreateRole", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `mdw_roles` (`name`, `icon`, `color`, `permissions`) VALUES (@Name, @Icon, @Color, @Permissions)", {
        ['@Name'] = Data.name,
        ['@Icon'] = Data.icon,
        ['@Color'] = Data.color,
        ['@Permissions'] = json.encode(Config.DefaultRolePermissions),
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:SaveRole", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_roles` SET `name` = @Name, `color` = @Color, `icon` = @Icon, `permissions` = @Permissions WHERE `id` = @Id", {
        ['@Name'] = Data.name,
        ['@Icon'] = Data.icon,
        ['@Color'] = Data.color,
        ['@Permissions'] = json.encode(Data.permissions),
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteRole", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.PlayerData.metadata.ishighcommand then
        return Cb(false)
    end

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `mdw_roles` WHERE `id` = @Id", {
        ['@Id'] = Data.id,
    })

    Cb(true)
end)

-- Charges

FW.Functions.CreateCallback("fw-mdw:Server:Config:EditCharge", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Query = false
    if Data.id then
        Query = "UPDATE mdw_charges SET `gov_type` = ?, `category` = ?, `fine` = ?, `jail` = ?, `points` = ?, `name` = ?, `description` = ?, `type` = ?, `accomplice` = ?, `attempted` = ? WHERE `id` = ?"
    else
        Query = "INSERT INTO mdw_charges (`gov_type`, `category`, `fine`, `jail`, `points`, `name`, `description`, `type`, `accomplice`, `attempted`) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    end

    if not Query then
        return Cb({Success = false, Msg = "Database fout opgetreden!"})
    end

    exports['ghmattimysql']:executeSync(Query, {
        Data.gov_type,
        Data.category,
        Data.fine,
        Data.jail,
        Data.points,
        Data.name,
        Data.description,
        Data.type,
        json.encode({
            jail = Data.accomplice.jail,
            fine = Data.accomplice.fine,
            points = Data.accomplice.points,
        }),
        json.encode({
            jail = Data.attempted.jail,
            fine = Data.attempted.fine,
            points = Data.attempted.points,
        }),
        Data.id,
    })

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Config:DeleteCharge", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Data.Id then
        return Cb({Success = false, Msg = "Invalid Charge Id"})
    end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `mdw_charges` SET `deleted` = 1 WHERE `id` = ?", {Data.Id})
    Cb({Success = Result.affectedRows > 0, Msg = "Database fout opgetreden!" })
end)