local GroupInvitations = {}

FW.Functions.CreateCallback("fw-phone:Server:TierUp:GetPlayerGroup", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = GetPlayerGroup(Player.PlayerData.citizenid)

    if not Group or Group == nil then
        return Cb(false)
    end

    Cb(Group)
end)

FW.Functions.CreateCallback("fw-phone:Server:TierUp:CreateGroup", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if IsPlayerInGroup(Player.PlayerData.citizenid) then
        Cb({ Success = false, Msg = "Je zit al in een groep!" })
        return
    end

    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `phone_tierup` (`members`) VALUES (@Members)", {
        ['@Members'] = json.encode({{Cid = Player.PlayerData.citizenid}})
    })

    Cb({Success = true })
end)

FW.Functions.CreateCallback("fw-phone:Server:TierUp:InviteParticipate", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if Target == nil then
        Cb({ Success = false, Msg = "Ongeldige Speler" })
        return
    end

    if not IsPlayerInGroup(Player.PlayerData.citizenid) then
        Cb({ Success = false, Msg = "Je zit niet in een groep!" })
        return
    end

    if IsPlayerInGroup(Target.PlayerData.citizenid) then
        Cb({ Success = false, Msg = "Speler zit al in een groep!" })
        return
    end

    local Group = GetPlayerGroup(Player.PlayerData.citizenid)
    if Group.members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({ Success = false, Msg = "Alleen de eigenaar kan dit doen!" })
        return
    end

    TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, "tierup-invite-" .. Target.PlayerData.citizenid, "fas fa-trophy", { "white", "transparent" }, "TierUp! Uitnodiging", Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. " heeft je uitgenodigd om deel te nemen aan een TierUp-groep!", false, true, "fw-phone:Server:TierUp:AcceptInvite", "fw-phone:Client:RemoveNotificationById", { Id = "tierup-invite-" .. Target.PlayerData.citizenid, GroupId = Group.id })

    if GroupInvitations[Group.id] == nil then
        GroupInvitations[Group.id] = {}
    end

    GroupInvitations[Group.id][Target.PlayerData.citizenid] = true

    Cb({Success = true })
end)

FW.Functions.CreateCallback("fw-phone:Server:TierUp:LeaveGroup", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = GetPlayerGroup(Player.PlayerData.citizenid)
    if not Group or Group == nil then
        Cb({ Success = false, Msg = "Je zit niet in een groep!" })
        return
    end

    for k, v in pairs(Group.members) do
        if v.Cid == Player.PlayerData.citizenid then
            table.remove(Group.members, k)
            break
        end
    end

    exports['ghmattimysql']:executeSync("UPDATE `phone_tierup` SET `members` = @Members WHERE `id` = @Id", {
        ['@Id'] = Group.id,
        ['@Members'] = json.encode(Group.members),
    })

    Cb({Success = true })
end)

FW.Functions.CreateCallback("fw-phone:Server:TierUp:KickMember", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = GetPlayerGroup(Player.PlayerData.citizenid)
    if not Group or Group == nil then
        Cb({ Success = false, Msg = "Je zit niet in een groep!" })
        return
    end

    if Group.members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({ Success = false, Msg = "Alleen de eigenaar kan dit doen!" })
    end

    for k, v in pairs(Group.members) do
        if v.Cid == Data.Cid then
            table.remove(Group.members, k)
            break
        end
    end

    exports['ghmattimysql']:executeSync("UPDATE `phone_tierup` SET `members` = @Members WHERE `id` = @Id", {
        ['@Id'] = Group.id,
        ['@Members'] = json.encode(Group.members),
    })

    Cb({Success = true })
end)

FW.Functions.CreateCallback("fw-phone:Server:TierUp:TransferOwnership", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Group = GetPlayerGroup(Player.PlayerData.citizenid)
    if not Group or Group == nil then
        Cb({ Success = false, Msg = "Je zit niet in een groep!" })
        return
    end

    if Group.members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({ Success = false, Msg = "Alleen de eigenaar kan dit doen!" })
    end

    for k, v in pairs(Group.members) do
        if v.Cid == Data.Cid then
            v.Cid = Player.PlayerData.citizenid
            break
        end
    end

    Group.members[1].Cid = Data.Cid

    exports['ghmattimysql']:executeSync("UPDATE `phone_tierup` SET `members` = @Members WHERE `id` = @Id", {
        ['@Id'] = Group.id,
        ['@Members'] = json.encode(Group.members),
    })

    Cb({Success = true })
end)

FW.Functions.CreateCallback("fw-phone:Server:TierUp:DeleteGroup", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not IsPlayerInGroup(Player.PlayerData.citizenid) then
        Cb({ Success = false, Msg = "Je zit niet in een groep!" })
        return
    end

    local Group = GetPlayerGroup(Player.PlayerData.citizenid)
    if Group.members[1].Cid ~= Player.PlayerData.citizenid then
        Cb({ Success = false, Msg = "Alleen de eigenaar kan dit doen!" })
    end

    exports['ghmattimysql']:executeSync("DELETE FROM `phone_tierup` WHERE `id` = @Id", {
        ['@Id'] = Group.id
    })

    Cb({Success = true })
end)

RegisterNetEvent("fw-phone:Server:TierUp:AcceptInvite")
AddEventHandler("fw-phone:Server:TierUp:AcceptInvite", function(Data)
    local Source = source

    local Player = FW.Functions.GetPlayer(Source)
    if not Player then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Ongeldige Uitnodiging!", true)
        return
    end

    local Group = GetGroupById(Data.GroupId)
    if not Group or Group == nil then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Ongeldige Uitnodiging!", true)
        return
    end

    if not GroupInvitations[Data.GroupId] or not GroupInvitations[Data.GroupId][Player.PlayerData.citizenid] then
        TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Ongeldige Uitnodiging!", true)
        return
    end

    TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Uitnodiging geaccepteerd.", true)

    table.insert(Group.members, {Cid = Player.PlayerData.citizenid})

    exports['ghmattimysql']:executeSync("UPDATE `phone_tierup` SET `members` = @Members WHERE `id` = @Id", {
        ['@Id'] = Group.id,
        ['@Members'] = json.encode(Group.members),
    })
end)

function GetPlayerGroup(Cid)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_tierup` WHERE JSON_SEARCH(members, 'one', @Cid, NULL, '$[*].Cid') IS NOT NULL", {
        ['@Cid'] = Cid
    })

    if Result == nil or Result[1] == nil then
        return nil
    end

    Result[1].members = json.decode(Result[1].members)
    for k, v in pairs(Result[1].members) do
        v.Name = FW.Functions.GetPlayerCharName(v.Cid)
        v.Online = FW.Functions.GetPlayerByCitizenId(v.Cid) ~= nil
    end

    Result[1].Progression = exports['fw-heists']:GetProgressionByExperience(Result[1].experience)

    return Result[1]
end
exports("GetPlayerGroup", GetPlayerGroup)

function GetGroupById(Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_tierup` WHERE `id` = @Id", {
        ['@Id'] = Id
    })

    if Result == nil or Result[1] == nil then
        return nil
    end

    Result[1].members = json.decode(Result[1].members)
    for k, v in pairs(Result[1].members) do
        v.Name = FW.Functions.GetPlayerCharName(v.Cid)
        v.Online = FW.Functions.GetPlayerByCitizenId(v.Cid) ~= nil
    end

    Result[1].Progression = exports['fw-heists']:GetProgressionByExperience(Result[1].experience)

    return Result[1]
end
exports("GetGroupById", GetGroupById)

function IsPlayerInGroup(Cid)
    local Result = GetPlayerGroup(Cid)
    return Result ~= nil
end
exports("IsPlayerInGroup", IsPlayerInGroup)