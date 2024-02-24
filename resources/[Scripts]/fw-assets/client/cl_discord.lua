function SetDiscordRichPresence()
    local serverId = GetPlayerServerId(PlayerId())
    SetDiscordAppId(Config.DiscordSettings['AppId'])
    SetDiscordRichPresenceAsset('main')
    SetDiscordRichPresenceAssetText(Config.DiscordSettings['Text'])
    SetDiscordRichPresenceAssetSmall('main')
    SetDiscordRichPresenceAssetSmallText('Server ID: ' .. serverId)
end

RegisterNetEvent("setPlayerCount")
AddEventHandler("setPlayerCount", function(c)
    SetRichPresence(c .. " Speler(s)")
end)