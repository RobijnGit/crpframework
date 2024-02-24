Messages = {
    CurrentChat = nil,
}

function Messages.SetChats()
    local Result = FW.SendCallback("fw-phone:Server:Messages:GetChats", UsingBurner)
    SendNUIMessage({
        Action = "Messages/SetChats",
        Chats = Result,
    })
end

RegisterNUICallback("Messages/GetChats", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Messages:GetChats", UsingBurner)
    Cb(Result)
end)

RegisterNUICallback("Messages/SetChatRead", function(Data, Cb)
    TriggerServerEvent('fw-phone:Server:Messages:SetChatRead', Data, UsingBurner)
    Cb("Ok")
end)

RegisterNUICallback("Messages/SendMessage", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Messages:SendMessage", Data, UsingBurner)
    Cb(Result)
end)

RegisterNetEvent("fw-phone:Client:Messages:RefreshMessagesChat")
AddEventHandler("fw-phone:Client:Messages:RefreshMessagesChat", function(Data, Notify)
    if Notify and CurrentApp ~= 'messages' then
        if exports['fw-hud']:GetPreferenceById('Notifications.SMS') then
            Notification("new-sms-" .. Data.Phone .. '-' .. math.random(1, 999), "fas fa-comment", { "white", "#8FC24C" }, Data.Name, Data.Message)
        end
        SetAppUnread("messages")
        return
    end

    Messages.SetChats()
end)