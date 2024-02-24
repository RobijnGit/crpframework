function CreateRandomToken(Length)
    local Token = ''
    local CharTable = {}
    local Chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&'
    for C in Chars:gmatch(".") do
        table.insert(CharTable, C)
    end
    for i = 1, Length do
        Token = Token .. CharTable[math.random(1, #CharTable)]
    end
    print(('^6Security Token Generated: ^1%s^7'):format(Token))
    return Token
end

FW.EventGuard = {}
FW.EventGuard.Token = nil
FW.EventGuard.Events = {}
FW.EventGuard.Callbacks = {}

Citizen.CreateThread(function()
    FW.EventGuard.Token = CreateRandomToken(32)
end)

FW.RegisterServer = function(Name, Callback)
    if Name == nil then return end
    if FW.EventGuard.Callbacks[Name] then RemoveEventHandler(FW.EventGuard.Events[Name]) end

    FW.EventGuard.Callbacks[Name] = Callback

    print("[FW] Event Guard Added: " .. Name)

    RegisterNetEvent(Name)
    FW.EventGuard.Events[Name] = AddEventHandler(Name, function(Token, ...)
        local Src = source
        local Name = Name -- undefined type, for whatever reason.

        if Token == FW.EventGuard.Token then
            if FW.EventGuard.Callbacks[Name] ~= nil then
                FW.EventGuard.Callbacks[Name](Src, ...)
            end
        else
            local TimeTable = os.date('*t', 3132036000)
            exports['ghmattimysql']:execute('INSERT INTO server_bans (name, steam, license, reason, expire, bannedby) VALUES (@name, @steam, @license, @reason, @expire, @bannedby)', {
                ['@name'] = GetPlayerName(Src),
                ['@steam'] = GetPlayerIdentifiers(Src)[1],
                ['@license'] = GetPlayerIdentifiers(Src)[2],
                ['@reason'] = "Joe, cheaten doe je maar ergens anders dud",
                ['@expire'] = 3132036000,
                ['@bannedby'] = 'CONSOLE'
            })

            TriggerEvent('fw-logs:Server:Log', 'bans', 'Player Banned', GetPlayerName(Src)..' werd gebanned door ANTICHEAT met de reden: Joe, cheaten doe je maar ergens anders dud', 'red')
            TriggerEvent('fw-logs:Server:Log', 'anticheat', 'Player Prebanned', ('Player (%s | %s) executed a server event with a incorrect token (%s, %s)..'):format(Src, GetPlayerName(Src), Name, Token), 'red')

            DropPlayer(Src, 'Je werd verbannen met de reden:\nJoe, cheaten doe je maar ergens anders dud\n\nJouw ban is permanent.')
            return
        end
    end)
end

FW.TriggerServer = function(Name, ...)
    FW.EventGuard.Callbacks[Name](...)
end

RegisterNetEvent("fw-core:Server:EventGuard:LoadToken")
AddEventHandler("fw-core:Server:EventGuard:LoadToken", function()
    TriggerClientEvent('fw-core:Client:EventGuard:SetToken', source, FW.EventGuard.Token)
end)

FW.RegisterServer("FW:AddItem", function(Source, ...)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    Player.Functions.AddItem(...)
end)

function BanFakeEvent()
    local Src = source
    local TimeTable = os.date('*t', 3132036000)

    exports['ghmattimysql']:execute('INSERT INTO server_bans (name, steam, license, reason, expire, bannedby) VALUES (@name, @steam, @license, @reason, @expire, @bannedby)', {
        ['@name'] = GetPlayerName(Src),
        ['@steam'] = GetPlayerIdentifiers(Src)[1],
        ['@license'] = GetPlayerIdentifiers(Src)[2],
        ['@reason'] = "Joe, cheaten doe je maar ergens anders dud",
        ['@expire'] = 3132036000,
        ['@bannedby'] = 'CONSOLE'
    })

    TriggerEvent('fw-logs:Server:Log', 'bans', 'Player Banned', GetPlayerName(Src)..' werd gebanned door ANTICHEAT met de reden: Joe, cheaten doe je maar ergens anders dud', 'red')
    TriggerEvent('fw-logs:Server:Log', 'anticheat', 'Player Prebanned', ('Player (%s | %s) executed a server event with a incorrect token (%s)..'):format(Src, GetPlayerName(Src), "Triggered a Bait Event"), 'red')

    DropPlayer(Src, 'Je werd verbannen met de reden:\nJoe, cheaten doe je maar ergens anders dud\n\nJouw ban is permanent.')
end

RegisterNetEvent("fw-items:Server:AddItem")
AddEventHandler("fw-items:Server:AddItem", BanFakeEvent)

RegisterNetEvent("fw-businesses:Server:AddItem")
AddEventHandler("fw-businesses:Server:AddItem", BanFakeEvent)