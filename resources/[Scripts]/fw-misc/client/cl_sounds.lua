-- RegisterCommand("sound:frontEnd", function(Source, Args)
--     TriggerEvent('fw-misc:Client:PlaySound', Args[1])
-- end)

-- RegisterCommand("sound:entity", function(Source, Args)
--     TriggerEvent('fw-misc:Client:PlaySoundEntity', Args[1], NetworkGetNetworkIdFromEntity(tonumber(Args[2])), true, nil)
-- end)

-- RegisterCommand("sound:plyCoords", function(Source, Args)
--     TriggerEvent('fw-misc:Client:PlaySoundCoords', Args[1], vector3(-210.04, -1320.3, 30.89), tonumber(Args[2]) + 0.0, true)
-- end)

-- From Entity
RegisterNetEvent("fw-misc:Client:PlaySoundEntity")
AddEventHandler("fw-misc:Client:PlaySoundEntity", function(SoundId, Entity, Networked, PlayerId)
    local SoundData = Config.Sounds[SoundId]
    if SoundData == nil then return print("PlaySoundEntity: Invalid Sound (" .. SoundId .. ")") end

    local Entity = NetworkGetEntityFromNetworkId(Entity)
    if PlayerId ~= nil then Entity = GetPlayerPed(GetPlayerFromServerId(PlayerId)) end
    if not DoesEntityExist(Entity) then return end

    PlaySoundFromEntity(-1, SoundData.AudioId, Entity, SoundData.AudioBank, Networked, false)
    Citizen.SetTimeout(SoundData.Timeout, function()
        StopSound(-1)
    end)
end)

-- From Coords
RegisterNetEvent("fw-misc:Client:PlaySoundCoords")
AddEventHandler("fw-misc:Client:PlaySoundCoords", function(SoundId, Coords, Range, Networked)
    local SoundData = Config.Sounds[SoundId]
    if SoundData == nil then return print("PlaySoundCoords: Invalid Sound (" .. SoundId .. ")") end
    
    PlaySoundFromCoord(-1, SoundData.AudioId, Coords.x, Coords.y, Coords.z, SoundData.AudioBank, Networked, Range, false)
    Citizen.SetTimeout(SoundData.Timeout, function()
        StopSound(-1)
    end)
end)

-- Front End
RegisterNetEvent("fw-misc:Client:PlaySound")
AddEventHandler("fw-misc:Client:PlaySound", function(SoundId)
    local SoundData = Config.Sounds[SoundId]
    if SoundData == nil then return print("PlaySound: Invalid Sound (" .. SoundId .. ")") end
    
    PlaySoundFrontend(-1, SoundData.AudioId, SoundData.AudioBank)
    Citizen.SetTimeout(SoundData.Timeout, function()
        StopSound(-1)
    end)
end)