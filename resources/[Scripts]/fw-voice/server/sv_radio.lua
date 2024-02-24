local ActiveChannels, ChannelSubscribers = {}, {}

RegisterNetEvent("fw-voice:Server:Add:Player:To:Radio")
AddEventHandler("fw-voice:Server:Add:Player:To:Radio", function(ChannelId, RemoveOld)
    local Sid = source
    AddPlayerToRadio(Sid, ChannelId, RemoveOld)
    TriggerEvent("fw-mdw:Server:SetRadio", Sid, ChannelId)
end)

RegisterNetEvent("fw-voice:Server:Remove:Player:From:Radio")
AddEventHandler("fw-voice:Server:Remove:Player:From:Radio", function(ChannelId)
    local Sid = source
    RemovePlayerFromRadio(Sid, ChannelId)
    TriggerEvent("fw-mdw:Server:SetRadio", Sid, "Uit")
end)

AddEventHandler('playerDropped', function(Reason)
    local Source = source
    if ChannelSubscribers[Source] then
        RemovePlayerFromRadio(Source, ChannelSubscribers[Source])
    end
end)

-- // Functions \\ --

function RemovePlayerFromRadio(SiD, ChannelId)
    if not ActiveChannels[ChannelId] then return end
    ActiveChannels[ChannelId].Count = ActiveChannels[ChannelId].Count - 1
    if ActiveChannels[ChannelId].Count == 0 then
        ActiveChannels[ChannelId] = nil
    else
        ActiveChannels[ChannelId].Subscribers[SiD] = nil
        for k, v in pairs(ActiveChannels[ChannelId].Subscribers) do
            TriggerClientEvent("fw-voice:Client:Radio:Removed", k, ChannelId, SiD)
        end
    end

    ChannelSubscribers[SiD] = nil
    TriggerClientEvent("fw-voice:Client:Radio:Disconnect", SiD, ChannelId)
    -- print("Removing player: " .. SiD  .. " from channel: " .. ChannelId)
end

function AddPlayerToRadio(SiD, ChannelId, RemoveOld)

    if RemoveOld then
        RemovePlayerFromRadio(SiD, ChannelSubscribers[SiD])
    end

    if ActiveChannels[ChannelId] == nil then
        ActiveChannels[ChannelId] = {}
        ActiveChannels[ChannelId].Subscribers = {}
        ActiveChannels[ChannelId].Count = 0
    end
    ActiveChannels[ChannelId].Count = ActiveChannels[ChannelId].Count + 1

    for k, v in pairs(ActiveChannels[ChannelId].Subscribers) do
        TriggerClientEvent("fw-voice:Client:Radio:Added", k, ChannelId, SiD)
    end

    ChannelSubscribers[SiD] = ChannelId
    ActiveChannels[ChannelId].Subscribers[SiD] = SiD
    TriggerClientEvent('fw-voice:Client:Radio:Connect', SiD, ChannelId, ActiveChannels[ChannelId].Subscribers)
    -- print(SiD,ChannelId)
    -- print("Adding player: " .. SiD  .. " to channel: " .. ChannelId)
end

function GetSubscriberChannel(SiD)
    return ChannelSubscribers[SiD] or "Uit"
end
exports("GetSubscriberChannel", GetSubscriberChannel)