FW.Functions.CreateCallback("fw-mdw:Server:Staff:GetMyProfile", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT `callsign`, `name`, `alias`, `rank`, `certs`, `roles` FROM `mdw_staff` WHERE `citizenid` = @Cid AND `deleted` = '0' LIMIT 1", {
        ['@Cid'] = Player.PlayerData.citizenid
    })

    if Result[1] then
        for k, v in pairs(json.decode(Result[1].certs)) do
            if v == 21 or v == 22 then
                Result[1].investigator = true
                break
            end
        end
        Result[1].department = Player.PlayerData.metadata.department
    end

    Cb(Result[1] ~= nil and Result[1] or false)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Staff:FetchAll", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `citizenid`, `callsign`, `name`, `alias`, `department` FROM `mdw_staff` WHERE `deleted` = '0' ORDER BY `id` DESC")
    Cb(Result)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Staff:FetchById", function(Source, Cb, Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `mdw_staff` WHERE `id` = @Id", {
        ['@Id'] = Id
    })

    if Result[1] then
        Result[1].certs = json.decode(Result[1].certs)
        Result[1].roles = json.decode(Result[1].roles)
        Result[1].strikes = json.decode(Result[1].strikes)
    end

    Cb(Result[1] or {})
end)

FW.Functions.CreateCallback("fw-mdw:Server:Staff:AddCert", function(Source, Cb, Data)
    if not Data.Id or not Data.Cert then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT `certs` FROM `mdw_staff` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    if Result[1] == nil then return Cb(false) end
    local Certs = json.decode(Result[1].certs)
    Certs[#Certs + 1] = Data.Cert

    exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `certs` = @Certs WHERE `id` = @Id", {
        ['@Certs'] = json.encode(Certs),
        ['@Id'] = Data.Id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Staff:RemoveCert", function(Source, Cb, Data)
    if not Data.Id or not Data.Cert then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT `certs` FROM `mdw_staff` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    if Result[1] == nil then return Cb(false) end
    local Certs = json.decode(Result[1].certs)
    table.remove(Certs, Data.Cert)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `certs` = @Certs WHERE `id` = @Id", {
        ['@Certs'] = json.encode(Certs),
        ['@Id'] = Data.Id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Staff:AddRole", function(Source, Cb, Data)
    if not Data.Id or not Data.Role then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT `roles` FROM `mdw_staff` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    if Result[1] == nil then return Cb(false) end
    local Roles = json.decode(Result[1].roles)
    Roles[#Roles + 1] = Data.Role

    exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `roles` = @Roles WHERE `id` = @Id", {
        ['@Roles'] = json.encode(Roles),
        ['@Id'] = Data.Id,
    })

    Cb(true)
end)

FW.Functions.CreateCallback("fw-mdw:Server:Staff:RemoveRole", function(Source, Cb, Data)
    if not Data.Id or not Data.Role then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("SELECT `roles` FROM `mdw_staff` WHERE `id` = @Id", {
        ['@Id'] = Data.Id
    })

    if Result[1] == nil then return Cb(false) end
    local Roles = json.decode(Result[1].roles)
    table.remove(Roles, Data.Role)

    exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `roles` = @Roles WHERE `id` = @Id", {
        ['@Roles'] = json.encode(Roles),
        ['@Id'] = Data.Id,
    })

    Cb(true)
end)

FW.Commands.Add("strike", "Deel een strike uit.", {
    { name = "bsn", help = "BSN van degene die gestriked wordt." },
    { name = "punten", help = "Hoeveelheid strike punten" },
    { name = "reden", help = "Reden voor de strike" },
}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' or not Player.PlayerData.metadata.ishighcommand then
        return Player.Functions.Notify("Ze herkennen je niet..", "error")
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `strikes` FROM `mdw_staff` WHERE `citizenid` = @Cid", { ['@Cid'] = Args[1] })
    if Result[1] == nil then
        return Player.Functions.Notify("Profiel bestaat niet in het personeelsysteem..", "error")
    end

    local Strikes = json.decode(Result[1].strikes)
    local Target = Args[1]
    local Points = tonumber(Args[2])

    table.remove(Args, 1); table.remove(Args, 1)

    Strikes[#Strikes + 1] = {
        Issuer = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        Timestamp = os.time() * 1000,
        Points = Points,
        Reason = table.concat(Args, " "),
        Deleted = false
    }

    Player.Functions.Notify(Target .. " gestriked met " .. Points .. " strike punt(en)!")

    exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `strikes` = @Strikes WHERE `id` = @Id", {
        ['@Strikes'] = json.encode(Strikes),
        ['@Id'] = Result[1].id,
    })
end)

FW.Commands.Add("verwijderstrike", "Verwijder een strike van iemand.", {
    { name = "bsn", help = "BSN van degene die gestriked wordt." },
    { name = "strikeId", help = "Strike ID die je wilt verwijderen" },
}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' or not Player.PlayerData.metadata.ishighcommand then
        return Player.Functions.Notify("Ze herkennen je niet..", "error")
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT `id`, `strikes` FROM `mdw_staff` WHERE `citizenid` = @Cid", { ['@Cid'] = Args[1] })
    if Result[1] == nil then
        return Player.Functions.Notify("Profiel bestaat niet in het personeelsysteem..", "error")
    end

    local Strikes = json.decode(Result[1].strikes)

    if not Strikes[tonumber(Args[2])] or Strikes[tonumber(Args[2])].Deleted then
        return Player.Functions.Notify("Ongeldige strike ID.", "error")
    end

    Strikes[tonumber(Args[2])].Deleted = true
    Player.Functions.Notify("Strike verwijderd van " .. Args[1])

    exports['ghmattimysql']:executeSync("UPDATE `mdw_staff` SET `strikes` = @Strikes WHERE `id` = @Id", {
        ['@Strikes'] = json.encode(Strikes),
        ['@Id'] = Result[1].id,
    })
end)