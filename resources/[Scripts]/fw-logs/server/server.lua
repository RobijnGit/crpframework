FW = exports['fw-core']:GetCoreObject()

RegisterServerEvent('fw-logs:Server:Log')
AddEventHandler('fw-logs:Server:Log', function(Type, Title, Content, Color, UseTag, Image)
    local Webhook = Config.Webhooks[Type] or Config.Webhooks["default"]
    if Webhook == nil then return end

    local Embeds = {
        {
            title = Title,
            type = "rich",
            color = Config.Colors[Color] or Config.Colors["black"],
            description = Content,
            footer = {
                text = 'Logs - ' .. os.date("%c"),
            },
            image = {
                url = Image or "",
            }
        }
    }

    PerformHttpRequest(Webhook, function(err, text, headers)end, 'POST', json.encode({
        username = "Logs",
        content = UseTag and "@everyone" or "",
        embeds = Embeds
    }), {
        ['Content-Type'] = 'application/json'
    })
end)

AddEventHandler('chatMessage', function(author, color, message)
    if author ~= nil then
        if string.sub(message, 1, 5) == '/ooc' then
            TriggerEvent("fw-logs:Server:Log", 'ooc', "(LOCAL) OOC", "User: " .. GetPlayerName(author) .. "\nMessage: " .. message, "green")
        elseif string.sub(message, 1, 4) == '/oocg' then
            TriggerEvent("fw-logs:Server:Log", 'ooc', "(GLOBAL) OOC", "User: " .. GetPlayerName(author) .. "\nMessage: " .. message, "red")
        else
            TriggerEvent("fw-logs:Server:Log", 'chat', "Command Used", "User: " .. GetPlayerName(author) .. "\nMessage: " .. message)
        end
    end
end)