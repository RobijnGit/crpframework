-- Application: Unknown (Gangs)
local GangInvitations = {}

FW.Commands.Add("gangs:refresh", "Refetch all gangs from DB.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    LoadGangs()
end, 'admin')

Citizen.CreateThread(function()
    LoadGangs()
end)

function LoadGangs()
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `laptop_gangs`")
    if Result[1] == nil then return end

    for k, v in pairs(Result) do
        Config.Gangs[v.gang_id] = {
            Id = v.gang_id,
            Label = v.gang_label,
            Leader = {Cid = v.gang_leader, Name = FW.Functions.GetPlayerCharName(v.gang_leader)},
            Members = json.decode(v.gang_members),
            MaxMembers = Config.GangSizes[v.gang_id] or 7,
            Sales = 0,
            TotalCollected = 0,
            TotalSprays = #(exports['fw-graffiti']:GetSpraysByGang(v.gang_id)),
            MetaData = json.decode(v.gang_metadata)
        }
    end

    print("Fetched " .. #Result .. " gangs..")
end

function GetGangById(GangId)
    return Config.Gangs[GangId] or false
end
exports("GetGangById", GetGangById)

function GetGangByPlayer(CitizenId)
    for k, v in pairs(Config.Gangs) do
        if v.Leader.Cid == CitizenId then
            return v
        end

        for i, j in pairs(v.Members) do
            if j.Cid == CitizenId then
                return v, i
            end
        end
    end

    return false, 0
end
exports("GetGangByPlayer", GetGangByPlayer)

function SaveGang(GangId)
    if Config.Gangs[GangId] == nil then return end

    exports['ghmattimysql']:executeSync("UPDATE `laptop_gangs` SET `gang_leader` = @Leader, `gang_members` = @Members WHERE `gang_id` = @GangId", {
        ['@GangId'] = GangId,
        ['@Members'] = json.encode(Config.Gangs[GangId].Members),
        ['@Leader'] = Config.Gangs[GangId].Leader.Cid,
    })
end

function SetGangMetadata(GangId, MetaDataId, Value)
    if Config.Gangs[GangId] == nil then return false end
    Config.Gangs[GangId].MetaData[MetaDataId] = Value
    exports['ghmattimysql']:executeSync("UPDATE `laptop_gangs` SET `gang_metadata` = @MetaData WHERE `gang_id` = @GangId", {
        ['@GangId'] = GangId,
        ['@MetaData'] = json.encode(Config.Gangs[GangId].MetaData),
    })
    return true
end
exports("SetGangMetadata", SetGangMetadata)

function SetGangLeader(GangId, Cid)
    if Config.Gangs[GangId] == nil then return false end
    Config.Gangs[GangId].Leader = { Cid = Cid, Name = FW.Functions.GetPlayerCharName(Cid) }
    exports['ghmattimysql']:executeSync("UPDATE `laptop_gangs` SET `gang_leader` = ? WHERE `gang_id` = ?", {
        Cid,
        GangId,
    })
    SaveGang(GangId)
    return true
end
exports("SetGangLeader", SetGangLeader)

function GetGangMetadata(GangId, MetaDataId)
    if Config.Gangs[GangId] == nil then return false end
    return Config.Gangs[GangId].MetaData[MetaDataId]
end
exports("GetGangMetadata", GetGangMetadata)

function TriggerGangEvent(GangId, Event, ...)
    local Gang = exports['fw-laptop']:GetGangById(GangId)
    if not Gang then return end

    local Leader = FW.Functions.GetPlayerByCitizenId(Gang.Leader.Cid)
    if Leader then
        TriggerClientEvent(Event, Leader.PlayerData.source, ...)
    end
    
    for k, v in pairs(Gang.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Target then
            TriggerClientEvent(Event, Target.PlayerData.source, ...)
        end
    end
end
exports("TriggerGangEvent", TriggerGangEvent)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:GetGangById", function(Source, Cb, GangId)
    Cb(GetGangById(GangId))
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:GetDiscoveredSprays", function(Source, Cb, GangId)
    local Gang = Config.Gangs[GangId]

    local Result = exports['ghmattimysql']:executeSync("SELECT `discovered_sprays` FROM `laptop_gangs` WHERE `gang_id` = @GangId", {
        ['@GangId'] = GangId
    })

    if Result[1] == nil then return Cb(false) end
    Cb(json.decode(Result[1].discovered_sprays))
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:GetPlayerGang", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if not Player then return end

    local Gang = GetGangByPlayer(Player.PlayerData.citizenid)
    if Gang then
        if Config.Gangs[Gang.Id] then
            Config.Gangs[Gang.Id].TotalSprays = #(exports['fw-graffiti']:GetSpraysByGang(Gang.Id))
        end
    end

    Cb(Gang)
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:AddMember", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if not Player then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if not Target then return end

    local Gang = GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then return end

    local TargetGang = GetGangByPlayer(Data.Cid)
    if TargetGang then return end
    
    if GangInvitations[Gang.Id] == nil then GangInvitations[Gang.Id] = {} end
    GangInvitations[Gang.Id][Data.Cid] = true

    TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, "gang-invite-" .. Target.PlayerData.citizenid, "fas fa-user-ninja", { "white", "transparent" }, "Gang Invitation", Gang.Label .. " is inviting you to their gang.", false, true, "fw-laptop:Server:Unknown:AcceptInvite", "fw-phone:Client:RemoveNotificationById", { Id = "gang-invite-" .. Target.PlayerData.citizenid, Gang = Gang.Id })

    Cb(Gang)
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:KickMember", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if not Player then return end

    local Gang = GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then return end

    local TargetGang, TargetId = GetGangByPlayer(Data.Cid)
    if not TargetGang then return end

    if Gang.Id ~= TargetGang.Id then return end
    table.remove(Config.Gangs[Gang.Id].Members, TargetId)
    SaveGang(Gang.Id)

    Cb(true)
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:GetMessages", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({}) return end

    local Gang = GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then return end

    local Chats = {}
    local Result = exports['ghmattimysql']:executeSync('SELECT * FROM `laptop_gangs_chat` WHERE `gang_id` = @GangId ORDER BY `timestamp` DESC', { ['@GangId'] = Gang.Id })

    for k, v in pairs(Result) do
        Chats[#Chats + 1] = {
            Sender = v.sender,
            SenderName = FW.Functions.GetPlayerCharName(v.sender) or "Onbekend",
            Message = v.message,
            Attachments = json.decode(v.attachments),
            Timestamp = v.timestamp
        }
    end

    Cb(Chats)
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:SendMessage", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({Success = false, Msg = "Ongeldige Speler"}) return end

    local Gang = GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then return end

    exports['ghmattimysql']:executeSync("INSERT INTO `laptop_gangs_chat` (`gang_id`, `sender`, `message`, `attachments`) VALUES (@GangId, @Sender, @Message, @Attachments)", {
        ['@GangId'] = Gang.Id,
        ['@Sender'] = Player.PlayerData.citizenid,
        ['@Message'] = Data.Message,
        ['@Attachments'] = json.encode(Data.Attachments),
    })

    TriggerEvent("fw-logs:Server:Log", 'laptopConversations', "Text Sent", ("User: [%s] - %s - %s\nGangId: %s\nMessage: %s\nAttachments: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Gang.Label, Data.Message, json.encode(Data.Attachments)), "green")

    TriggerGangEvent(Gang.Id, "fw-laptop:Client:Unknown:RefreshGangChat")
    TriggerGangEvent(Gang.Id, 'fw-phone:Client:Notification', Gang.Id .. '-new-message-' .. math.random(1, 999999), "fas fa-user-ninja", {"white", "transparent"}, Gang.Label, ("%s - %s"):format(Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Message))

    -- TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Accepting Invitation...", true)

    Cb({Success = true})
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:GetCraftingName", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb(false) end

    local Gang = GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then return Cb(false) end

    if Gang.TotalSprays >= 54 then
        return Cb('Powerful')
    elseif Gang.TotalSprays >= 36 then
        return Cb('Feared')
    elseif Gang.TotalSprays >= 24 then
        return Cb('Respected')
    elseif Gang.TotalSprays >= 16 then
        return Cb('Established')
    elseif Gang.TotalSprays >= 8 then
        return Cb('WellKnown')
    elseif Gang.TotalSprays >= 4 then
        return Cb('Known')
    end

    Cb(false)
end)

RegisterNetEvent("fw-laptop:Server:Unknown:AcceptInvite")
AddEventHandler("fw-laptop:Server:Unknown:AcceptInvite", function(Data)
    local Source = source

    local Player = FW.Functions.GetPlayer(Source)
    if not Player then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Invalid Invitation!", true)
        return
    end

    local Gang = Config.Gangs[Data.Gang]
    if not Gang then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Invalid Invitation!", true)
        return
    end

    if not GangInvitations[Data.Gang] or not GangInvitations[Data.Gang][Player.PlayerData.citizenid] then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Invalid Invitation!", true)
        return
    end

    -- if #Gang.Members + 2 > Gang.MaxMembers then
    --     TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Members Limit reached...", true)
    --     return
    -- end

    TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Accepting Invitation...", true)

    table.insert(Config.Gangs[Data.Gang].Members, {
        Cid = Player.PlayerData.citizenid,
        Name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
    })

    SaveGang(Data.Gang)
end)

RegisterNetEvent("fw-laptop:Server:AddDiscovered")
AddEventHandler("fw-laptop:Server:AddDiscovered", function(GangId, SprayId)
    local Gang = Config.Gangs[GangId]

    local Result = exports['ghmattimysql']:executeSync("SELECT `discovered_sprays` FROM `laptop_gangs` WHERE `gang_id` = @GangId", {
        ['@GangId'] = GangId
    })

    if Result[1] == nil then return end

    local DiscoveredSprays = json.decode(Result[1].discovered_sprays)
    DiscoveredSprays[#DiscoveredSprays + 1] = SprayId

    exports['ghmattimysql']:executeSync("UPDATE `laptop_gangs` SET `discovered_sprays` = @Sprays WHERE `gang_id` = @GangId", {
        ['@Sprays'] = json.encode(DiscoveredSprays),
        ['@GangId'] = GangId
    })

    local Leader = FW.Functions.GetPlayerByCitizenId(Gang.Leader.Cid)
    if Leader then
        TriggerClientEvent("fw-graffiti:Client:UpdateDiscovered", Leader.PlayerData.source, DiscoveredSprays)
    end

    for k, v in pairs(Gang.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Target then
            TriggerClientEvent("fw-graffiti:Client:UpdateDiscovered", Target.PlayerData.source, DiscoveredSprays)
        end
    end
end)