-- LightsOut
local LightsOutPromise

function StartGridMinigame(Amount)
    SendUIMessage("Minigames/LightsOut", "StartMinigame", {
        Amount = Amount,
        HasBuff = exports['fw-hud']:HasBuff('Smartness')
    })
    SetNuiFocus(true, true)

    LightsOutPromise = promise.new()
    return Citizen.Await(LightsOutPromise)
end
exports("StartGridMinigame", StartGridMinigame)

RegisterNUICallback("Minigames/LightsOut/Finished", function(Data, Cb)
    LightsOutPromise:resolve(Data.Success)
    SetNuiFocus(false, false)
    Cb("Ok")
end)

-- Untangle
local UntanglePromise

function StartUntangle(Data)
    SendUIMessage("Minigames/Untangle", "StartMinigame", Data)
    SetNuiFocus(true, true)

    UntanglePromise = promise.new()
    return Citizen.Await(UntanglePromise)
end
exports("StartUntangle", StartUntangle)

RegisterNUICallback("Minigames/Untangle/Finished", function(Data, Cb)
    UntanglePromise:resolve(Data.Success)
    SetNuiFocus(false, false)
    Cb("Ok")
end)

-- Thermite
local ThermitePromise

function StartThermite(Size)
    SendUIMessage("Minigames/Thermite", "StartMinigame", {Size = Size, HasBuff = exports['fw-hud']:HasBuff('Smartness')})
    SetNuiFocus(true, true)

    ThermitePromise = promise.new()
    return Citizen.Await(ThermitePromise)
end
exports("StartThermite", StartThermite)

RegisterNUICallback("Minigames/Thermite/Finished", function(Data, Cb)
    ThermitePromise:resolve(Data.Success)
    SetNuiFocus(false, false)
    Cb("Ok")
end)

-- UI Restart
RegisterNetEvent("fw-ui:appRestart")
AddEventHandler("fw-ui:appRestart", function(App)
    if UntanglePromise then
        UntanglePromise:resolve(false)
    end

    if ThermitePromise then
        ThermitePromise:resolve(false)
    end
end)