local FW = exports['fw-core']:GetCoreObject()

-- Code

-- Commands 

FW.Commands.Add("clear", "Clear je chat", {}, false, function(source, args)
    TriggerClientEvent('chat:clear', source)
end)

FW.Commands.Add("clearall", "Clear iedereen zijn chat", {}, false, function(source, args)
    TriggerClientEvent('chat:clear', -1)
end, 'admin')

-- Events

RegisterServerEvent('_chat:messageEntered')
AddEventHandler('_chat:messageEntered', function(author, color, message)
    if not message or not author then
        return
    end
    TriggerEvent('chatMessage', source, author, message)
end)

RegisterServerEvent('__cfx_internal:commandFallback')
AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)
    TriggerEvent('chatMessage', source, name, '/' .. command)
    if not WasEventCanceled() then
        TriggerClientEvent('chatMessage', -1, name, false, '/' .. command) 
    end
    CancelEvent()
end)

RegisterServerEvent('chat:init')
AddEventHandler('chat:init', function()
    refreshCommands(source)
end)

AddEventHandler('onServerResourceStart', function(resName)
    Citizen.SetTimeout(1000, function()
        for _, player in ipairs(GetPlayers()) do
            refreshCommands(player)
        end
    end)
end)

-- Functions

function refreshCommands(player)
    if GetRegisteredCommands then
        local registeredCommands = GetRegisteredCommands()
        local suggestions = {}
        for _, command in ipairs(registeredCommands) do
            if IsPlayerAceAllowed(player, ('command.%s'):format(command.name)) then
                table.insert(suggestions, {
                    name = '/' .. command.name,
                    help = ''
                })
            end
        end
        TriggerClientEvent('chat:addSuggestions', player, suggestions)
    end
end
