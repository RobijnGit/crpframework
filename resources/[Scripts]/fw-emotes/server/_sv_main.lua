local SyncedEmotes = {}

FW = exports['fw-core']:GetCoreObject()

FW.Commands.Add("am", "Open het animatie menu", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    TriggerClientEvent('fw-emotes:Client:OpenEmotes', Source)
end)

FW.Commands.Add("em", "Open het animatie menu", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    TriggerClientEvent('fw-emotes:Client:OpenEmotes', Source)
end)

FW.Commands.Add("a", "Doe een animatie, doe /am voor het menu.", {
    { name = "emote", help = "Emote die je wilt doen" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    TriggerClientEvent('fw-emotes:Client:PlayEmote', Source, Args[1]:lower())
end)

FW.Commands.Add("e", "Doe een animatie, doe /em voor het menu.", {
    { name = "emote", help = "Emote die je wilt doen" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    TriggerClientEvent('fw-emotes:Client:PlayEmote', Source, Args[1]:lower())
end)

FW.Commands.Add("dance", "Eventjes lekker dansen", {
    {name = "number", help = "een nummer of gewoon niks"}
}, false, function(Source, Args)
    local DanceNumber = -1
    if Args[1] ~= nil and Args[1] == 'c' then
        TriggerClientEvent('fw-emotes:Client:StopDance', Source)
        return
    elseif Args[1] ~= nil then
        DanceNumber = tonumber(Args[1])
    end

    TriggerClientEvent('fw-emotes:Client:PlayDance', Source, DanceNumber)
end)

FW.RegisterServer("fw-emotes:Server:SendRequest", function(Source, Target, EmoteName)
    local Player = FW.Functions.GetPlayer(Source)
    if not Player then return end

    Player.Functions.Notify("Verzoek verstuurd..", "success")

    TriggerClientEvent("fw-emotes:Client:GiveRequestChoice", Target, Source, EmoteName)
end)

FW.RegisterServer("fw-emotes:Server:RespondToRequest", function(Source, DidAccept, Requestor, EmoteName)
    local Player = FW.Functions.GetPlayer(Requestor)
    if not Player then return end

    local Target = FW.Functions.GetPlayer(Source)
    if not Target then return end

    if not DidAccept then
        Player.Functions.Notify("Verzoek was geweigerd..", "error")
        return
    end

    local SyncedEmoteId = #SyncedEmotes + 1
    SyncedEmotes[SyncedEmoteId] = {
        Requests = 0,
        Requestor = Requestor,
        Target = Source,
        EmoteName = EmoteName
    }

    local RequestorAnim = Config.Emotes[EmoteName].Requestor
    local TargetAnim = Config.Emotes[EmoteName].Target

    -- Request anim dict at REQUESTORs client
    TriggerClientEvent("fw-emotes:Client:RequestSyncedEmote", Requestor, SyncedEmoteId, RequestorAnim)

    -- Request anim dict at TARGETs client
    TriggerClientEvent("fw-emotes:Client:RequestSyncedEmote", Source, SyncedEmoteId, TargetAnim)
end)

RegisterNetEvent("fw-emotes:Client:TryStartSyncedEmote")
AddEventHandler("fw-emotes:Client:TryStartSyncedEmote", function(SyncedEmoteId)
    -- Is the synced emote valid?
    if SyncedEmotes[SyncedEmoteId] == nil then
        return
    end

    -- Increase counter
    SyncedEmotes[SyncedEmoteId].Requests = SyncedEmotes[SyncedEmoteId].Requests + 1

    -- Make sure both clients have loaded the animation dicts.
    if SyncedEmotes[SyncedEmoteId].Requests < 2 then
        return
    end

    -- Both clients have animation dicts loaded, play the animations!
    local EmoteData = Config.Emotes[SyncedEmotes[SyncedEmoteId].EmoteName]
    local RequestorAnim = EmoteData.Requestor
    local TargetAnim = EmoteData.Target

    -- Required for PlayEmote event to set player coords & heading
    RequestorAnim.IsSynced = true
    RequestorAnim.Target = SyncedEmotes[SyncedEmoteId].Target

    TriggerClientEvent("fw-emotes:Client:PlayEmote", SyncedEmotes[SyncedEmoteId].Requestor, "", RequestorAnim, false)
    TriggerClientEvent("fw-emotes:Client:PlayEmote", SyncedEmotes[SyncedEmoteId].Target, "", TargetAnim, false)
end)