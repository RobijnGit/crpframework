CallData = nil
Contacts = {
    Suggestions = {}
}

RegisterNetEvent("fw-phone:Client:AddContactSuggestion")
AddEventHandler("fw-phone:Client:AddContactSuggestion", function(Data)
    local ContactId = #Contacts.Suggestions + 1
    Data.Id = ContactId
    Contacts.Suggestions[ContactId] = Data

    if CurrentApp == 'contacts' then
        Contacts.SetSuggestedContacts()
    else
        Notification("new-contact-suggestion-" .. ContactId, "fas fa-phone-alt", { "white", "#029587" }, Data.Name, "Contact gegevens gedeeld.")
        SetAppUnread("contacts")
    end
end)

RegisterNetEvent("fw-phone:Client:SetCallData")
AddEventHandler("fw-phone:Client:SetCallData", function(Data)
    CallData = Data

    Citizen.CreateThread(function()
        if CallData == nil or not CallData.Dialing then
            return
        end

        local AnimDict, AnimName = "cellphone@", "cellphone_text_to_call"
        if exports['fw-hud']:GetPreferenceById('Phone.Animation') == "Linkeroor" then
            AnimDict, AnimName = "yoinks@musclephone", "musclephone_clip"
        end

        RequestAnimDict(AnimDict)
        while not HasAnimDictLoaded(AnimDict) do
            Citizen.Wait(4)
        end

        while CallData and CallData.Dialing ~= nil do
            if not IsPhoneOpen and ((GetPlayerServerId(PlayerId()) == CallData.Target and not CallData.Dialing) or GetPlayerServerId(PlayerId()) ~= CallData.Target) then
                if not IsEntityPlayingAnim(PlayerPedId(), AnimDict, AnimName, 3) then
                    TaskPlayAnim(PlayerPedId(), AnimDict, AnimName, 3.0, -1, -1, 50, 0, false, false, false)
                end
            end

            Citizen.Wait(500)
        end

        if not IsPhoneOpen then
            StopAnimTask(PlayerPedId(), AnimDict, AnimName, 1.0)
            exports['fw-assets']:RemoveProp()
        end
    end)
end)

RegisterNetEvent('fw-phone:Client:Contacts:SetVoice')
AddEventHandler('fw-phone:Client:Contacts:SetVoice', function(StartCall, PhoneNumber, Receiver)
    if StartCall then
        TriggerServerEvent('fw-voice:Server:Phone:StartCall', PhoneNumber, Receiver)
    else
        TriggerServerEvent('fw-voice:Server:Phone:EndCall', PhoneNumber)
    end
end)

function Contacts.SetContacts()
    local Result = FW.SendCallback("fw-phone:Server:Contacts:GetContacts")
    SendNUIMessage({
        Action = "Contacts/SetContacts",
        Contacts = Result,
    })
end

function Contacts.SetSuggestedContacts()
    SendNUIMessage({
        Action = "Contacts/SetSuggestedContacts",
        Contacts = Contacts.Suggestions,
    })
end

RegisterNUICallback("Contacts/GetContacts", function(Data, Cb)
    if UsingBurner then
        return Cb({})
    end

    local Result = FW.SendCallback("fw-phone:Server:Contacts:GetContacts")
    Cb(Result)
end)

RegisterNUICallback("Contacts/GetSuggestions", function(Data, Cb)
    Cb(Contacts.Suggestions)
end)

RegisterNUICallback("Contacts/CreateContact", function(Data, Cb)
    if UsingBurner then return Cb("Ok") end
    local Result = FW.SendCallback("fw-phone:Server:Contacts:AddContacts", Data)
    Contacts.SetContacts()
    if Data.IsSuggestion then
        table.remove(Contacts.Suggestions, Data.SuggestionId)
        Contacts.SetSuggestedContacts()
    end
    Cb("Ok")
end)

RegisterNUICallback("Contacts/DeleteContact", function(Data, Cb)
    if UsingBurner then return Cb("Ok") end
    local Result = FW.SendCallback("fw-phone:Server:Contacts:DeleteContact", Data)
    Contacts.SetContacts()
    Contacts.SetSuggestedContacts()
    Cb("Ok")
end)

RegisterNUICallback("Contacts/EditContact", function(Data, Cb)
    if UsingBurner then return Cb("Ok") end
    local Result = FW.SendCallback("fw-phone:Server:Contacts:EditContact", Data)
    Contacts.SetContacts()
    Contacts.SetSuggestedContacts()
    Cb("Ok")
end)

RegisterNUICallback("Contacts/DeleteSuggested", function(Data, Cb)
    if UsingBurner then return Cb("Ok") end
    table.remove(Contacts.Suggestions, Data.Id)
    Contacts.SetSuggestedContacts()
    Cb("Ok")
end)

RegisterNUICallback("Contacts/Call", function(Data, Cb)
    TriggerServerEvent("fw-phone:Server:DialContact", Data, UsingBurner)
    Cb("Ok")
end)