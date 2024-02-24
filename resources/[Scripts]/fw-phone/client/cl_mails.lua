Mails = {
    Mails = {}
}

function Mails.SetMails()
    SendNUIMessage({
        Action = "Mails/SetMails",
        Mails = Mails.Mails,
    })
end

RegisterNUICallback("Mails/GetMails", function(Data, Cb)
    Cb(Mails.Mails)
end)

RegisterNetEvent("fw-phone:Client:Mails:AddMail")
AddEventHandler("fw-phone:Client:Mails:AddMail", function(Data)
    Mails.Mails[#Mails.Mails + 1] = Data
    if CurrentApp == 'mails' then
        Citizen.SetTimeout(5, function()
            Mails.SetMails()
        end)
    else
        if exports['fw-hud']:GetPreferenceById('Notifications.Email') then
            Notification("new-mail-" .. #Mails.Mails, "fas fa-envelope-open", { "white", "#44B5C4" }, 'Email', Data.Msg)
        end
        SetAppUnread("mails")
    end
end)