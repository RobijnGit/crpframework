FW.Functions.CreateCallback("fw-phone:Server:HasUnreadConversations", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb(false) return end

    local Result = exports['ghmattimysql']:executeSync('SELECT COUNT(*) as amount FROM `phone_messages` WHERE `to_phone` = @Phone AND `unread` = 1', { ['@Phone'] = Player.PlayerData.charinfo.phone })
    Cb(Result[1].amount > 0)
end)

FW.Functions.CreateCallback("fw-phone:Server:Messages:GetChats", function(Source, Cb, UsingBurner)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({}) return end

    local MyPhone = UsingBurner and UsingBurner or Player.PlayerData.charinfo.phone

    local Chats = {}
    local Result = exports['ghmattimysql']:executeSync('SELECT * FROM `phone_messages` WHERE `from_phone` = @Phone OR `to_phone` = @Phone ORDER BY `timestamp` DESC', { ['@Phone'] = MyPhone })

    for k, v in pairs(Result) do
        local Receiver = MyPhone == v.to_phone and v.from_phone or v.to_phone
        if Chats[Receiver] == nil then
            Chats[Receiver] = {
                from_phone = MyPhone == v.to_phone and v.to_phone or v.from_phone,
                to_phone = Receiver,
                name = GetContactName(Player.PlayerData.citizenid, Receiver),
                messages = {}
            }
        end

        Chats[Receiver].messages[#Chats[Receiver].messages + 1] = {
            Sender = v.from_phone,
            Message = v.message,
            Attachments = json.decode(v.attachments),
            Timestamp = v.timestamp,
            Unread = v.unread,
        }
    end

    Cb(Chats)
end)

FW.Functions.CreateCallback("fw-phone:Server:Messages:SendMessage", function(Source, Cb, Data, UsingBurner)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then Cb({Success = false, Msg = "Ongeldige Speler"}) return end

    if not IsNetworkEnabled then
        return Cb({Success = false, Msg = "Geen internet toegang.."})
    end

    local MyPhone = UsingBurner and UsingBurner or Player.PlayerData.charinfo.phone

    exports['ghmattimysql']:executeSync("INSERT INTO `phone_messages` (`from_phone`, `to_phone`, `message`, `attachments`) VALUES (@FromPhone, @ToPhone, @Message, @Attachments)", {
        ['@FromPhone'] = MyPhone,
        ['@ToPhone'] = Data.Phone,
        ['@Message'] = Data.Message,
        ['@Attachments'] = json.encode(Data.Attachments),
    })

    TriggerEvent("fw-logs:Server:Log", 'conversations', "Text Sent", ("User: [%s] - %s - %s\nReceiver: %s - %s\nMessage: %s\nAttachments: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Phone, FW.Functions.GetPlayerCharNameByPhone(Data.Phone) or "Invalid Player.", Data.Message, json.encode(Data.Attachments)), "green")

    TriggerClientEvent('fw-phone:Client:Messages:RefreshMessagesChat', Player.PlayerData.source, {}, false)

    local ToPlayer = FW.Functions.GetPlayerByPhone(tostring(Data.Phone))
    if ToPlayer then
        local ChatData = {
            Name = GetContactName(ToPlayer.PlayerData.citizenid, MyPhone),
            Phone = MyPhone,
            Message = Data.Message,
        }
        TriggerClientEvent('fw-phone:Client:Messages:RefreshMessagesChat', ToPlayer.PlayerData.source, ChatData, true)
    end

    Cb({Success = true})
end)

RegisterNetEvent("fw-phone:Server:Messages:SetChatRead")
AddEventHandler("fw-phone:Server:Messages:SetChatRead", function(Data, UsingBurner)
-- todo: add UsingBurner check
    local Result = exports['ghmattimysql']:execute("UPDATE `phone_messages` SET `unread` = 0 WHERE `from_phone` = @FromPhone AND `to_phone` = @ToPhone AND `unread` = 1", {
        ["@FromPhone"] = Data.ToPhone,
        ["@ToPhone"] = Data.FromPhone,
    })
end)