local Promise = nil
local active = false

RegisterNUICallback('NUI:close', function(data, cb)
    Promise:resolve(data.success)
    Promise = nil
    active = false
    SetNuiFocus(false, false)
    cb('ok')
end)

local OpenHack = function(allowed, timer)
    active = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "start",
        allowed = allowed,
        timer = timer
    })
end

StartHack = function(allowed, timer)
    if Promise then return end
    while active do Wait(0) end
    Promise = promise.new()
    OpenHack(allowed, timer)
    local result = Citizen.Await(Promise)
    return result
end

exports("StartHack", StartHack)