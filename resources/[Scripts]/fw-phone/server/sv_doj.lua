local Statusses = {}

FW.Functions.CreateCallback("fw-phone:Server:DOJ:GetUsers", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Retval = {
        IsDOJ = Player.PlayerData.job.name == 'judge' or Player.PlayerData.job.name == 'lawyer' or Player.PlayerData.job.name == 'griffier' or Player.PlayerData.job.name == 'mayor',
        Users = {},
    }

    for k, v in pairs(FW.GetPlayers()) do
        local Target = FW.Functions.GetPlayer(v.ServerId)

        if not Target or (Target.PlayerData.job.name ~= 'judge' and Target.PlayerData.job.name ~= 'lawyer' and Target.PlayerData.job.name ~= 'griffier' and Target.PlayerData.job.name ~= 'mayor') then
            goto Skip
        end

        table.insert(Retval.Users, {
            Cid = Target.PlayerData.citizenid,
            CharName = Target.PlayerData.charinfo.firstname .. " " .. Target.PlayerData.charinfo.lastname,
            Number = Target.PlayerData.charinfo.phone,
            Status = Statusses[Target.PlayerData.citizenid] or "Bezet",
            Job = Target.PlayerData.job.name,
        })

        ::Skip::
    end

    Cb(Retval)
end)

FW.RegisterServer("fw-phone:Server:DOJ:SetStatus", function(Source, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Statusses[Player.PlayerData.citizenid] = Data.Status
end)