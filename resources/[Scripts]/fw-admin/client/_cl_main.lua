FW, LoggedIn = exports['fw-core']:GetCoreObject(), true
RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(500, function()
        LoggedIn = true
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

local Binds = {}
Citizen.CreateThread(function()
    FW.AddKeybind("openAdminMenu", 'Admin', 'Open Menu', '', nil, 'fw-admin:Client:Try:Open:Menu')

    for k, v in pairs(Config.AdminMenus) do
        if v.Id == "setTimeWeather" then
            local _Types = {}
            local WeatherTypes = exports['fw-sync']:GetWeatherTypes()

            for k, v in pairs(WeatherTypes) do
                _Types[#_Types + 1] = { Val = v[2], Text = v[1] .. " (" .. GetHashKey(v[2]) .. ")" }
            end

            Config.AdminMenus[k].Options[2].Choices = _Types
        end
    end

    if IsPlayerAdmin() then
        Binds = json.decode(GetResourceKvpString("admin-binds") or "[]")

        SendNUIMessage({
            Action = 'LoadBindableItems',
            BindableItems = Config.BindableItems,
            Values = Binds,
            Binds = 5,
        })

        for i = 1, 5, 1 do
            FW.AddKeybind("adminBind" .. i, 'Admin', 'Bind ' .. i, '', function(IsPressed)
                if not IsPressed then return end
                if not IsPlayerAdmin() then return end
                
                if Binds["bind_" .. i] == "cloak" then
                    SetCloak()
                else
                    local MenuItem = Config.AdminMenus[tonumber(Binds["bind_" .. i])]
                    if not MenuItem then return end

                    if MenuItem.EventType == nil then MenuItem.EventType = 'Client' end
                    
                    if MenuItem.Event ~= nil and MenuItem.EventType ~= nil then
                        TriggerServerEvent('fw-admin:Server:RegisterCommand', {Event = MenuItem.Event})
                        if MenuItem.EventType == 'Client' then
                            TriggerEvent(MenuItem.Event)
                        else
                            TriggerServerEvent(MenuItem.Event)
                        end
                    end
                end
            end)
        end
    end
end)

-- Code
local MenuOpen, Focus = false, false

function IsPlayerAdmin()
    local Promise = promise:new()
    Citizen.SetTimeout(50, function() -- Is nodig, anders gaat het te snel en doet hij 't niet
        FW.Functions.TriggerCallback('fw-admin:Server:IsPlayerAdmin', function(IsAdmin)
            Promise:resolve(IsAdmin)
        end)
    end)
    return Citizen.Await(Promise)
end

-- // Events \\ --

RegisterNetEvent('fw-admin:Client:Try:Open:Menu')
AddEventHandler('fw-admin:Client:Try:Open:Menu', function()
    if not LoggedIn then return end

    if IsPlayerAdmin() then
        FW.Functions.TriggerCallback('fw-admin:Server:GetPlayers', function(Players)
            SetCursorLocation(0.87, 0.15)
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(Focus, Focus)
            SendNUIMessage({
                Action = 'OpenMenu',
                AllPlayers = Players,
                AdminItems = Config.AdminMenus,
                Favorites = json.decode(GetResourceKvpString("admin-favorites") or "{}"),
            })

            MenuOpen = true

            Citizen.CreateThread(function()
                while MenuOpen do
                    DisableControlAction(0, 1, true) -- INPUT_LOOK_LR
                    DisableControlAction(0, 2, true) -- INPUT_LOOK_UD
                    DisableControlAction(0, 24, true) -- INPUT_ATTACK
                    DisableControlAction(0, 25, true) -- INPUT_AIM
                    DisableControlAction(0, 36, true) -- INPUT_DUCK
                    DisableControlAction(0, 199, true) -- INPUT_FRONTEND_PAUSE 
                    DisableControlAction(0, 200, true) -- INPUT_FRONTEND_PAUSE_ALTERNATE
                    DisableControlAction(0, 257, true) -- INPUT_ATTACK2
                    DisableControlAction(0, 288, true) -- INPUT_REPLAY_START_STOP_RECORDING
                    DisableControlAction(0, 289, true) -- INPUT_REPLAY_START_STOP_RECORDING_SECONDARY
                    DisableControlAction(0, 346, true) -- INPUT_VEH_MELEE_LEFT
                    DisableControlAction(0, 347, true) -- INPUT_VEH_MELEE_RIGHT
                    Citizen.Wait(1)
                end
            end)
        end)
    else
        FW.Functions.Notify("Nou, volgensmij ben jij niet zo god-achtig dan jij denkt dat jij bent...", "error")
    end
end)

RegisterNetEvent('fw-admin:Client:Force:Close')
AddEventHandler('fw-admin:Client:Force:Close', function()
    MenuOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false, false)
    SendNUIMessage({
        Action = 'CloseMenu',
    })
end)

RegisterNetEvent("fw-admin:Client:CopyToClipboard")
AddEventHandler("fw-admin:Client:CopyToClipboard", function(Text)
    SendNUIMessage({
        Action = 'CopyClipboard',
        Text = Text
    })
end)

-- // Functions \\ --

function round(input, decimalPlaces)
    return tonumber(string.format("%." .. (decimalPlaces or 0) .. "f", input))
end

RegisterNUICallback('Close', function(Data, Cb)
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false, false)
    Citizen.SetTimeout(200, function()
        MenuOpen = false
    end)
    Cb('Ok')
end)

RegisterNUICallback('Trigger/Button', function(Data, Cb) 
    if IsPlayerAdmin() then
        if Data.EventType == nil then Data.EventType = 'Client' end
        if type(Data.Result) == 'table' then
            if Data.Player then
                Data.Result['player'] = Data.Player
            else
                Data.Result['player'] = GetPlayerServerId(PlayerId())
            end
        end
        
        if Data.Event ~= nil and Data.EventType ~= nil then
            TriggerServerEvent('fw-admin:Server:RegisterCommand', Data)
            if Data.EventType == 'Client' then
                TriggerEvent(Data.Event, Data.Result)
            else
                TriggerServerEvent(Data.Event, Data.Result)
            end
        end
    end
    Cb('Ok')
end)

Cloaked = false
RegisterNUICallback("Trigger/Cloak", function(Data, Cb)
    if not IsPlayerAdmin() then return end
    SetCloak(Data.Cloak)
end)

function SetCloak(Bool)
    Cloaked = Bool == nil and not Cloaked or Bool
    
    SetEntityVisible(PlayerPedId(), not Cloaked, not Cloaked)
    
    if Cloaked then
        SetEntityAlpha(PlayerPedId(), 100, false)
    else
        ResetEntityAlpha(PlayerPedId())
    end

    Citizen.CreateThread(function()
        while Cloaked do
            Citizen.Wait(4)
            SetLocalPlayerVisibleLocally(true)
        end
    end)
end

RegisterNUICallback("Trigger/Focus", function(Data, Cb)
    if not IsPlayerAdmin() then return end
    if not MenuOpen then return end

    Focus = not Data.Focus
    SetNuiFocusKeepInput(Focus, Focus)
end)

RegisterNUICallback("SaveBinds", function(Data, Cb)
    if not IsPlayerAdmin() then return end

    Binds = Data
    SetResourceKvp("admin-binds", json.encode(Data))
end)

RegisterNUICallback("Favorites", function(Data, Cb)
    SetResourceKvp("admin-favorites", json.encode(Data.Favorites))
end)

-- Reports
RegisterNetEvent('qb-admin:client:SendReport', function(name, src, msg)
    TriggerServerEvent('qb-admin:server:SendReport', name, src, msg)
end)

RegisterNetEvent('qb-admin:client:SendStaffChat', function(name, msg)
    TriggerServerEvent('qb-admin:server:Staffchat:addMessage', name, msg)
end)