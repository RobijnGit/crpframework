SteamIdToSource, ConnectingList, QueueList = {}, {}, {}
local AnyoneJoining = false

FW = exports['fw-core']:GetCoreObject()

Citizen.CreateThread(function()
    LoadPriorityList()
    SetMaxAmountOfPlayers(164)

    RegisterServerEvent('fw-queue:Server:Activate:Player')
    AddEventHandler('fw-queue:Server:Activate:Player', function()
        local Source = source

        local SteamId = GetPlayerIdentifiers(Source)[1]
        -- print('Reactivate the queue after loading or quiting..', SteamId, Source)
        if SteamIdToSource[SteamId] ~= nil then 
            local JoinSource = SteamIdToSource[SteamId]
            RemovePlayerFromConnection(JoinSource)
            RemovePlayerFromQueue(JoinSource)
            SteamIdToSource[SteamId] = nil
        end
    end)
end)

-- Code

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        for k, v in pairs(ConnectingList) do
            if ConnectingList[k] ~= nil and ConnectingList[k].Source ~= nil then
                if GetPlayerPing(v.Source) == 0 or GetPlayerPing(v.Source) > 400 then
                    RemovePlayerFromConnection(v.Source)
                end
            end
        end
        for k, v in pairs(QueueList) do
            if QueueList[k] ~= nil and QueueList[k].Source ~= nil then
                if GetPlayerPing(v.Source) == 0 or GetPlayerPing(v.Source) > 400 then
                    RemovePlayerFromQueue(v.Source)
                end
            end
        end
        Citizen.Wait(1500)
    end
end)

-- // Events \\ --

AddEventHandler('playerDropped', function(Reason)
    local Source = source
    local SteamId = GetPlayerIdentifiers(Source)[1]
    if SteamIdToSource[SteamId] ~= nil then 
        local JoinSource = SteamIdToSource[SteamId]
        RemovePlayerFromQueue(JoinSource)
        RemovePlayerFromConnection(JoinSource)
        -- print('Reactivate the queue after loading or quiting..', SteamId, JoinSource)
        SteamIdToSource[SteamId] = nil
    end
    if SteamIdToSource[SteamId] == nil and Config.PriorityList[SteamId] == nil or Config.PriorityList[SteamId] < 75 then
        Config.PriorityList[SteamId] = 75
        Citizen.SetTimeout(1000 * 60 * 3, function()
            Config.PriorityList[SteamId] = nil
        end)
    end
end)

RegisterServerEvent('fw-queue:Server:Player:Connect')
AddEventHandler('fw-queue:Server:Player:Connect', function(Source, KickReason, Deferral)
    local Source, SteamId, Connecting = Source, GetPlayerIdentifiers(Source)[1], true
    local Priority = GetPlayerPriority(SteamId)

    local HasPrioRole, PrioIncrease = HasDiscordPrioRole(Source)
    if HasPrioRole and Priority < 20 then
        Priority = Priority + PrioIncrease
    end

    Deferral.defer()
    AddPlayerToConnection(Source)
    SteamIdToSource[SteamId] = Source

    Citizen.CreateThread(function()
        while ConnectingList[GetConnectionId(Source)] ~= nil and ConnectingList[GetConnectionId(Source)].Source ~= nil do
            Citizen.Wait(100)
        end
        Connecting = false
        CancelEvent() return
    end)
    
    Citizen.Wait(500)

    if IsServerFull() then
        AddPlayerToQueue(Source, Priority)
        Citizen.CreateThread(function()
            while Connecting do
                local QueuePos = GetQueuePosition(Source)
                if not IsServerFull() then
                    if QueuePos == 1 and not AnyoneJoining then
                        Deferral.done() Connecting = false
                        if GetTotalQueue() - 1 > 0 then DoJoinTimeout() end CancelEvent() return
                    else
                        Config.Card.body[2].text = Config.Emotes[math.random(1, #Config.Emotes)]..' Je bent '..QueuePos..'/'..GetTotalQueue()..' in de wachtrij '..Config.Emotes[math.random(1, #Config.Emotes)]..'\n(Prio: '..(Priority <= 0 and 'Geen' or 'Ja, Level: '..(Priority == 75 and "Crash Prio" or Priority))..')'
                        Deferral.presentCard(Config.Card, function(data, rawData) end)
                        Deferral.update()
                    end
                else
                    Config.Card.body[2].text = Config.Emotes[math.random(1, #Config.Emotes)]..' Je bent '..QueuePos..'/'..GetTotalQueue()..' in de wachtrij '..Config.Emotes[math.random(1, #Config.Emotes)]..'\n(Prio: '..(Priority <= 0 and 'Geen' or 'Ja, Level: '..(Priority == 75 and "Crash Prio" or Priority))..')'
                    Deferral.presentCard(Config.Card, function(data, rawData) end)
                    Deferral.update()
                end
                Citizen.Wait(3500)
            end
        end)
    else
        Deferral.done()
        CancelEvent() return
    end
end)

-- // Functions \\ --

function SetMaxAmountOfPlayers(MaxAmount)
    Config.MaxPlayers = MaxAmount
    print("Queue limited to " .. tostring(MaxAmount) .. " players!")
end
exports('SetMaxAmountOfPlayers', SetMaxAmountOfPlayers)

function IsServerFull()
    local ServerMembers = GetNumPlayerIndices()
    if ServerMembers >= Config.MaxPlayers then
        return true
    end
    return false
end
exports('IsServerFull', IsServerFull)

-- // Connect

function AddPlayerToConnection(Source)
    table.insert(ConnectingList, {Source = Source})
end

function GetConnectionId(Source)
    for k, v in pairs(ConnectingList) do
        if Source == v.Source then
            return k
        end
    end
end

function RemovePlayerFromConnection(Source)
    for k, v in pairs(ConnectingList) do
        if Source == v.Source then
            table.remove(ConnectingList, k)
            return
        end
    end
end

-- // Queue

function AddPlayerToQueue(Source, Priority)
    local QueuePosition = GetTotalQueue() + 1
    for k, v in pairs(QueueList) do
        if Priority == 0 then break end
        if QueueList[k] ~= nil and QueueList[k].Priority ~= nil then 
            if Priority > v.Priority and k < QueuePosition then
                QueuePosition = k
            end
        end
    end
    table.insert(QueueList, QueuePosition, {Source = Source, Priority = Priority})
end

function GetTotalQueue()
    local TotalQueue = 0
    for k, v in pairs(QueueList) do
        if QueueList[k] ~= nil and QueueList[k].Source ~= nil then
            TotalQueue = TotalQueue + 1
        end
    end
    return TotalQueue
end
exports('GetTotalQueue', GetTotalQueue)

function GetQueuePosition(Source)
    for k, v in pairs(QueueList) do
        if Source == v.Source then
            return k
        end
    end
    return 0
end

function RemovePlayerFromQueue(Source)
    for k, v in pairs(QueueList) do
        if Source == v.Source then
            table.remove(QueueList, k)
            return
        end
    end
end

function DoJoinTimeout()
    if AnyoneJoining then return end
    AnyoneJoining = true
    Citizen.CreateThread(function()
        Citizen.SetTimeout((1000 * 60) * 1, function()
            AnyoneJoining = false
        end)
    end)
end


RegisterCommand('refreshQueueSlots', function(source, args, rawCommand)
	local MaxClients = GetConvarInt('sv_maxclients', 128)
    SetMaxAmountOfPlayers(MaxClients)
end, true)