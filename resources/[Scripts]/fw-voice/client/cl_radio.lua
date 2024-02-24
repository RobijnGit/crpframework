RadioChannels, IsTalkingOnRadio, RadioVolume, RadioClickVolume, CurrentChannel, CurrentRadioId = {}, false, 0.5, 0.1, nil, 0

-- // Events \\ --

RegisterNetEvent("fw-voice:Client:Radio:Connect")
AddEventHandler("fw-voice:Client:Radio:Connect", function(RadioId, Subscribers)
    if RadioChannels[RadioId] then return end

    local Channel = RadioChannel:New(RadioId)
    for _, Subscriber in pairs(Subscribers) do
        Channel:AddSubscriber(Subscriber)
    end

    RadioChannels[RadioId] = Channel
    CurrentRadioId = RadioId

    SetRadioChannel(RadioId)

    if Config.Debug then print( ('[Radio] Connected | ID %s'):format(RadioId) ) end
end)

RegisterNetEvent("fw-voice:Client:Radio:Disconnect")
AddEventHandler("fw-voice:Client:Radio:Disconnect", function(RadioId)
    if not RadioChannels[RadioId] then return end

    CurrentRadioId = 0
    RadioChannels[RadioId] = nil

    if Config.Debug then print( ('[Radio] Disconnected | ID %s'):format(RadioId) ) end
end)

RegisterNetEvent("fw-voice:Client:Radio:Added")
AddEventHandler("fw-voice:Client:Radio:Added", function(RadioId, ServerId)
    if not RadioChannels[RadioId] then return end

    local Channel = RadioChannels[RadioId]

    if not Channel:SubscriberExists(ServerId) then
        Channel:AddSubscriber(ServerId)

        if IsTalkingOnRadio and CurrentChannel.Id == RadioId then
            AddPlayerToTargetList(ServerId, "Radio", true)
        end
        if Config.Debug then print( ('[Radio] Subscriber Added | Radio ID: %s | Player: %s'):format(RadioId, ServerId) ) end
    end
end)

RegisterNetEvent("fw-voice:Client:Radio:Removed")
AddEventHandler("fw-voice:Client:Radio:Removed", function(RadioId, ServerId)
    if not RadioChannels[RadioId] then return end

    local Channel = RadioChannels[RadioId]

    if Channel:SubscriberExists(ServerId) then
        Channel:RemoveSubscriber(ServerId)

        if IsTalkingOnRadio and CurrentChannel.Id == RadioId then
            RemovePlayerFromTargetList(ServerId, "Radio", true, true)
        end

        if Config.Debug then print( ('[Radio] Subscriber Added | Radio ID: %s | Player: %s'):format(RadioId, ServerId) ) end
    end
end)

RegisterNetEvent('fw-medical:Client:PlayerDied', function()
    if IsTalkingOnRadio then StopRadioTransmission(true) end
end)

-- // Functions \\ --

function SetRadioVolume(Volume)
    Volume = Volume * 1.0
    if Volume >= 0.0 and Volume <= 1.0 then
        RadioVolume = Volume
        UpdateContextVolume("Radio", Volume)
        SetSubmixBalanceVolume('RadioSubmix', Volume)
        if Config.Debug then print( ('[Radio] Volume Changed | Current: %s'):format(Volume) ) end
    end
end
exports('SetRadioVolume', SetRadioVolume)

function GetRadioVolume()
    return RadioVolume
end
exports('GetRadioVolume', GetRadioVolume)

function SetRadioChannel(RadioId)
    CurrentChannel = RadioChannels[RadioId]
    if Config.Debug then print( ('[Radio] Channel Changed | Radio ID: %s'):format(RadioId) ) end
end

function StartRadioTransmission()
    local PlayerData = FW.Functions.GetPlayerData()
    if CurrentChannel ~= nil and CurrentRadioId > 0 and not PlayerData.metadata["isdead"] and not PlayerData.metadata["ishandcuffed"] then
        if not IsTalkingOnRadio then
            IsTalkingOnRadio = true
            AddGroupToTargetList(CurrentChannel.Subscribers, "Radio")
            SetPlayerTalkingOverride(PlayerId(), true)
            PlayRadioClick(true)
            StartRadioTask()
            TriggerEvent('fw-hud:Client:SetHudData', exports['fw-hud']:GetHudId('Voice'), 'Color', '#ED153D')
            local RadioVisibility = exports['fw-hud']:GetPreferenceById('Status.RadioVisibility')
            if RadioVisibility ~= 'Nooit' then
                exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', CurrentChannel.Id)
            end
            if Config.Debug then print( ('[Radio] Transmission | Sending: %s | Radio ID: %s'):format(IsTalkingOnRadio, CurrentChannel.Id)) end
        end
        if RadioTimeout then
            RadioTimeout:resolve(false)
        end
    end
end

function StopRadioTransmission(Forced)
    local PlayerData = FW.Functions.GetPlayerData()
    if CurrentRadioId == 0 then return end
    if not (PlayerData.metadata["isdead"] and not PlayerData.metadata["ishandcuffed"]) or Forced then
        if IsTalkingOnRadio or not RadioTimeout then 
            RadioTimeout = TimeOut(300):next(function(Continue)
                RadioTimeout = nil
                if Forced ~= true and not Continue then return end
                IsTalkingOnRadio = false
                RemoveGroupFromTargetList(CurrentChannel.Subscribers, "Radio")
                SetPlayerTalkingOverride(PlayerId(), false)
                PlayRadioClick(false)
                TriggerEvent('fw-hud:Client:SetHudData', exports['fw-hud']:GetHudId('Voice'), 'Color', NetworkIsPlayerTalking(PlayerId()) and '#EBD334' or '#fff')
                local RadioVisibility = exports['fw-hud']:GetPreferenceById('Status.RadioVisibility')
                if RadioVisibility == 'Relevant' then
                    exports['fw-hud']:SetHudData(exports['fw-hud']:GetHudId('Voice'), 'InsideText', false)
                end
                if Config.Debug then print( ('[Radio] Transmission | Sending: %s | Radio ID: %s'):format( IsTalkingOnRadio, CurrentChannel.Id) ) end
            end)
            return RadioTimeout
        end
    end
end

function StartRadioTask()
    local Dict, Anim = "random@arrests", "generic_radio_chatter"
    if exports['fw-hud']:GetPreferenceById('Radio.Animation') == "Borst" then
        Dict, Anim = "anim@cop_mic_pose_002", "chest_mic"
    end

    Citizen.CreateThread(function()
        RequestAnimDict(Dict)
        while IsTalkingOnRadio do
            Citizen.Wait(4)
            if not IsEntityPlayingAnim(PlayerPedId(), Dict, Anim, 3) then
                TaskPlayAnim(PlayerPedId(), Dict, Anim, 8.0, 0.0, -1, 49, 0, false, false, false)
            end
            for i = 0, 2 do
                SetControlNormal(i, 249, 1.0)
            end
        end
        StopAnimTask(PlayerPedId(), Dict, Anim, 3.0)
    end)
end

function PlayRadioClick(Bool)
    if Bool then
        if exports['fw-hud']:GetPreferenceById('Audio.RadioClicksIn') then
            TriggerEvent("fw-misc:Client:PlaySound", 'phone.radioTransmission')
        end
    else
        if exports['fw-hud']:GetPreferenceById('Audio.RadioClicksOut') then
            TriggerEvent("fw-misc:Client:PlaySound", 'phone.radioOff')
        end
    end
end

function LoadRadio()
    RegisterModuleContext("Radio", 2)
    UpdateContextVolume("Radio", RadioVolume)
    SetSubmixBalanceVolume('RadioSubmix', RadioVolume)
end

exports("TalkingOnRadio", function()
    return IsTalkingOnRadio
end)