RegisterNetEvent('fw-sound:client:play')
AddEventHandler('fw-sound:client:play', function(soundFile, soundVolume)
    SendNUIMessage({
        action = 'PlaySound',
        SoundId = soundFile,
        Volume = soundVolume
    })
end)