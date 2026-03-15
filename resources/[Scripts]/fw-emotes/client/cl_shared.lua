local RequestData = nil

Citizen.CreateThread(function()
    FW.AddKeybind("emotesAcceptShared", "Emotes", "Accept Emote Request", "Y", function(IsPressed)
        if not IsPressed then return end
        if not RequestData or GetGameTimer() > RequestData.ExpireTime then return end

        FW.Functions.Notify("Request accepted!", "success")
        FW.TriggerServer("fw-emotes:Server:RespondToRequest", true, RequestData.Requestor, RequestData.EmoteName)

        RequestData = nil
    end)
    
    FW.AddKeybind("emotesRefuseShared", "Emotes", "Deny Emote Request", "N", function(IsPressed)
        if not IsPressed then return end
        if not RequestData or GetGameTimer() > RequestData.ExpireTime then return end

        FW.Functions.Notify("Request denied!", "error")
        FW.TriggerServer("fw-emotes:Server:RespondToRequest", false, RequestData.Requestor, RequestData.EmoteName)

        RequestData = nil
    end)
end)

RegisterNetEvent("fw-emotes:Client:GiveRequestChoice")
AddEventHandler("fw-emotes:Client:GiveRequestChoice", function(Requestor, EmoteName)
    if RequestData and RequestData.ExpireTime > GetGameTimer() then return end

    FW.Functions.Notify(("Emote request from ID %s: %s - Press %s to accept, or %s to deny."):format(Requestor, EmoteName, FW.GetCustomizedKey("emotesAcceptShared"), FW.GetCustomizedKey("emotesRefuseShared")), "primary", 7000)

    RequestData = {Requestor = Requestor, EmoteName = EmoteName, ExpireTime = GetGameTimer() + 7000}
end)

RegisterNetEvent("fw-emotes:Client:RequestSyncedEmote")
AddEventHandler("fw-emotes:Client:RequestSyncedEmote", function(SyncedEmoteId, EmoteData)
    RequestAnimDict(EmoteData.Dict)
    while not HasAnimDictLoaded(EmoteData.Dict) do
        Citizen.Wait(10)
    end

    TriggerServerEvent("fw-emotes:Client:TryStartSyncedEmote", SyncedEmoteId, EmoteName)
end)