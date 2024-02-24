FW = FW or {}
FW.Config = Config
FW.Shared = Shared
FW.ServerCallbacks = {}
FW.UseableItems = {}

Citizen.CreateThread(function()
    local Result = exports['ghmattimysql']:executeSync("SELECT `taxes` FROM server_config")

    FW.Shared.Tax = {}
    for k, v in pairs(json.decode(Result[1].taxes)) do
        FW.Shared.Tax[k] = v
        print("^7Tax [" .. k .. "] set to " .. tostring(v) .. "%")
    end
end)

-- // Functions \\ --

function GetCoreObject()
	return FW
end

AddEventHandler("playerConnecting", function(Name, KickReason, Deferral)
    local Source = source
    local Name, SteamId = GetPlayerName(Source), GetPlayerIdentifiers(Source)[1]
    local SpecialMessage = Config.SpecialMessage[SteamId] ~= nil and Config.SpecialMessage[SteamId] or ('👋 Welkom %s, alles is gecontroleerd en we kijken voor een plekje...'):format(Name)

    Deferral.defer()
    
    Config.ConnectCard.body[2].text = 'Je naam wordt gecontroleerd..'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(1500)

    local IsBanned, Message = FW.Functions.IsPlayerBanned(Source)
    if IsBanned then
        Deferral.done(Message)
        CancelEvent() return
    end

    Config.ConnectCard.body[2].text = 'Je whitelist wordt gecontroleerd..'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(1000)

    if not exports['fw-queue']:CheckDiscordRole(Source) then
        Deferral.done('Het lijkt erop dat je geen whitelist hebt..')
        CancelEvent() return
    end

    Config.ConnectCard.body[2].text = 'Je steam wordt gecontroleerd..'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(1000)
    local Identifiers = GetPlayerIdentifiers(Source)[1]

    if Identifiers == nil or (Identifiers:sub(1,6) == "steam:") == false then
        Deferral.done('We konden geen steam vinden, je hebt steam nodig om te kunnen spelen..')
        CancelEvent() return
    end

    Config.ConnectCard.body[2].text = 'We controleren de laatste dingen nog even..'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(math.random(1000, 5000))
    local Steam = FW.Functions.GetIdentifier(Source, "steam")
    local License = FW.Functions.GetIdentifier(Source, "license")

    if FW.AreLicensesUsed(Steam, License) then
        TriggerEvent('fw-logs:Server:Log', 'anticheat', 'Player Join Canceled', ('%s (%s / %s) joined the server but has an client already active.'):format(Name, Steam, License), 'orange')
        Deferral.done('Je zit al op de server met een andere FiveM-client..')
        CancelEvent() return
    end

    if SpecialMessage ~= nil and SpecialMessage ~= false then
        Config.ConnectCard.body[2].text = '\n\n'..SpecialMessage..'\n'
        Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
        Deferral.update()
        Citizen.Wait(8000)
    end

    Citizen.Wait(1500)

    local PlayerName, Identifiers = GetPlayerName(Source), GetPlayerIdentifiers(Source)
    if PlayerName == nil then return end

    print(("^7[NEUTRAL]^7 ^5[%s]^7: %s"):format("Player", ("Player Connecting [Player: %s]"):format(Name)))
    TriggerEvent("fw-queue:Server:Player:Connect", Source, KickReason, Deferral)
    TriggerEvent('fw-logs:Server:Log', 'joinleave', 'Connecting', ("User: %s\nIdentifiers: ```json\n%s```"):format(PlayerName, json.encode(GetPlayerIdentifiersWithoutIp(Source), {indent=4})), 'green')
end)