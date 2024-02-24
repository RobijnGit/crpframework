FW = exports['fw-core']:GetCoreObject()

RegisterNetEvent('FW:Client:CloseNui')
AddEventHandler('FW:Client:CloseNui', function()
    SetNuiFocus(false, false)
end)

-- Keystroke Minigame
local KeystrokeMinigame = nil
function StartKeystrokeMinigame(Difficulty, Success, Fail)
    KeystrokeMinigame = promise.new()

    if exports['fw-hud']:HasBuff('Smartness') then
        Fail = Fail + 3
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'StartKeystrokeMinigame',
        Difficulty = Difficulty == 'Easy' and 0 or Difficulty == 'Medium' and 1 or 2,
        Success = Success,
        Fail = Fail
    })

    return Citizen.Await(KeystrokeMinigame)
end

exports("StartKeystrokeMinigame", StartKeystrokeMinigame)

RegisterNUICallback('Minigames/Keystroke/Won', function(Data, Cb)
    SetNuiFocus(false, false)
    KeystrokeMinigame:resolve(Data.Won)
    Cb('ok')
end)

-- Slider
local SliderMinigame = nil
function StartSliderMinigame(Sliders)
    SliderMinigame = promise.new()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'StartSliderMinigame',
        Sliders = Sliders
    })

    return Citizen.Await(SliderMinigame)
end

exports("StartSliderMinigame", StartSliderMinigame)

RegisterNUICallback('Minigames/Slider/Submit', function(Data, Cb)
    SetNuiFocus(false, false)
    SliderMinigame:resolve(Data.Result)
    Cb('ok')
end)
