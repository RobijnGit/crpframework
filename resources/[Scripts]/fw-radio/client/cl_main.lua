local FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

RegisterNetEvent('FW:Client:CloseNui', function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    DisconnectFromChannel(true)
    LoggedIn = false
end)

-- // Events \\ --

local RadioChannel, ChannelCache, ConnectedToRadio = 0, 0, false

RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    if not exports['fw-inventory']:HasEnoughOfItem('radio', 1) and not exports['fw-inventory']:HasEnoughOfItem('pdradio', 1) and RadioChannel > 0 then
        CloseRadio()
        DisconnectFromChannel(false)
    end
end)

RegisterNetEvent("fw-radio:Client:Use:Radio")
AddEventHandler("fw-radio:Client:Use:Radio", function()
    OpenRadio()
end)

function OpenRadio()
    if not exports['fw-inventory']:HasEnoughOfItem('radio', 1) and not exports['fw-inventory']:HasEnoughOfItem('pdradio', 1) then
        return
    end

    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-ui']:SendUIMessage("Radio", "SetVisibility", {
        Visible = true,
        Channel = ChannelCache,
    })

    PhonePlayIn()
end

function CloseRadio()
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage("Radio", "SetVisibility", {Visible = false})
    PhonePlayOut()
end

RegisterNUICallback("Radio/Close", function(Data, Cb)
    CloseRadio()
    Cb("Ok")
end)

RegisterNUICallback("Radio/Connect", function(Data, Cb)
    local Channel = tonumber(Data.RadioChannel)
    if Channel == nil then return end
    ConnectToChannel(Channel)
    Cb("Ok")
end)

RegisterNUICallback("Radio/Disconnect", function(Data, Cb)
    DisconnectFromChannel(true)
    Cb("Ok")
end)

RegisterNUICallback("Radio/Toggle", function(Data, Cb)
    if Data.State then
        local Channel = tonumber(Data.Channel)
        if Channel and Channel > 0 then
            ConnectToChannel(Channel)
        end
    else
        DisconnectFromChannel(false)
    end
    Cb("Ok")
end)

function ConnectToChannel(Channel)
    if Channel <= 100 and not DoIHaveAStateJob() then
        FW.Functions.Notify('Dit zijn geCODEERDE kanalen..', 'error')
        return
    end

    if Channel > 100 and not exports['fw-inventory']:HasEnoughOfItem('radio', 1) then
        FW.Functions.Notify("PD Radio kan niet verbinden met andere kanalen!", "error")
        return
    end

    if Channel > Config.MaxFrequency then
        FW.Functions.Notify('Nou dat denk ik niet..', 'error')
        return
    end

    RadioChannel, ChannelCache = Channel, Channel
    TriggerServerEvent('fw-voice:Server:Add:Player:To:Radio', Channel, true)

    local RadioVisibility = exports['fw-hud']:GetPreferenceById('Status.RadioVisibility')
    if RadioVisibility ~= 'Nooit' then
        exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', RadioChannel)

        if RadioVisibility == 'Relevant' then
            Citizen.SetTimeout(3000, function()
                if not NetworkIsPlayerTalking(PlayerId()) then
                    exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', false)
                end
            end)
        end
    end

    if SplitStr(tostring(Channel), ".")[2] ~= nil and SplitStr(tostring(Channel), ".")[2] ~= "" then
        FW.Functions.Notify('Je bent verbonden met: '..Channel..' MHz', 'success')
    else
        FW.Functions.Notify('Je bent verbonden met: '..Channel..'.00 MHz', 'success')
    end

    exports['fw-hud']:SetHudIcon(exports['fw-hud']:GetHudId('Voice'), 'headset')
end

function DisconnectFromChannel(ClearCache)
    TriggerServerEvent('fw-voice:Server:Remove:Player:From:Radio', RadioChannel)   
    RadioChannel = 0 ExecuteCommand("-radiotalk")

    if ClearCache then
        FW.Functions.Notify('Frequentie verlaten' , 'error')
        ChannelCache = 0
    end
    exports['fw-hud']:SetHudIcon(exports['fw-hud']:GetHudId('Voice'), 'microphone')
    exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', false)
end

function DoIHaveAStateJob()
    local PlayerData = FW.Functions.GetPlayerData()
    for k, v in pairs(Config.StateJobs) do
        if v == PlayerData.job.name and PlayerData.job.onduty then return true end
    end
    return false
end

function GetCurrentChannel()
    return RadioChannel
end
exports('GetCurrentChannel', GetCurrentChannel)

function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

FW.AddKeybind("radioUp", "Radio", "Frequentie Omhoog", "", function(IsPressed)
    if not IsPressed then return end
    
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] then return end
    ConnectToChannel(RadioChannel + 1)
end)

FW.AddKeybind("radioDown", "Radio", "Frequentie Omlaag", "", function(IsPressed)
    if not IsPressed then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] then return end
    if RadioChannel -1 <= 0 then return end
    ConnectToChannel(RadioChannel - 1)
end)

FW.AddKeybind("radioVolumeUp", "Radio", "Volume Omhoog", "", function(IsPressed)
    if not IsPressed then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] then return end
    local CurrentVolume = exports['fw-voice']:GetRadioVolume() 

    if RadioChannel == 0 then return end
    if CurrentVolume + 0.1 > 1.0 then
        return
    end

    exports['fw-hud']:SetPreferenceById('Audio.RadioVolume', CurrentVolume + 0.1)
    FW.Functions.Notify('Nieuw volume: '..math.ceil((CurrentVolume + 0.1) * 100) .. '%', 'success')
end)

FW.AddKeybind("radioVolumeDown", "Radio", "Volume Omlaag", "", function(IsPressed)
    if not IsPressed then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] then return end
    local CurrentVolume = exports['fw-voice']:GetRadioVolume() 
    
    if RadioChannel == 0 then return end
    if CurrentVolume - 0.1 < 0.0 then
        return
    end

    exports['fw-hud']:SetPreferenceById('Audio.RadioVolume', CurrentVolume - 0.1)
    FW.Functions.Notify('Nieuw volume: '..math.ceil((CurrentVolume - 0.1) * 100) .. '%', 'success')
end)

FW.AddKeybind("openRadio", "Radio", "Openen", "", function(IsPressed)
    if not IsPressed then return end
    OpenRadio()
end)