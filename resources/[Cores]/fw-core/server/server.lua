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
    local Name, LicenseId = GetPlayerName(Source), GetPlayerIdentifiers(Source)[1]
    local SpecialMessage = Config.SpecialMessage[LicenseId] ~= nil and Config.SpecialMessage[LicenseId] or ('👋 Welcome %s, please give us a moment while verify your connection...'):format(Name)

    Deferral.defer()
    
    Config.ConnectCard.body[2].text = 'Your name is being verified.'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(1500)

    local IsBanned, Message = FW.Functions.IsPlayerBanned(Source)
    if IsBanned then
        Deferral.done(Message)
        CancelEvent() return
    end

    -- Config.ConnectCard.body[2].text = 'Your allowlist is being verified..'
    -- Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    -- Deferral.update()

    -- Citizen.Wait(1000)

    -- if not exports['fw-queue']:CheckDiscordRole(Source) then
    --     Deferral.done('It seems you are not allowlisted, please contact an administrator for more information on how to apply for an allowlist.')
    --     CancelEvent() return
    -- end

    Config.ConnectCard.body[2].text = 'Your license is being verified..'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(1000)
    local Identifiers = GetPlayerIdentifiers(Source)[1]

    if Identifiers == nil or (Identifiers:sub(1,8) == "license:") == false then
        Deferral.done('We failed to verify your license, it is required to play on this server.')
        CancelEvent() return
    end

    Config.ConnectCard.body[2].text = 'All good! Just some last checks...'
    Deferral.presentCard(Config.ConnectCard, function(data, rawData) end)
    Deferral.update()

    Citizen.Wait(math.random(1000, 5000))
    local License = FW.Functions.GetIdentifier(Source, "license")

    if FW.AreLicensesUsed(License) then
        TriggerEvent('fw-logs:Server:Log', 'anticheat', 'Player Join Canceled', ('%s (%s / %s) joined the server but has an client already active.'):format(Name, License, License), 'orange')
        Deferral.done('Oh-oh! It seems your Rockstar-account is already connected on an another client.')
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