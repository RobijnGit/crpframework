local GameData = {}

function SetSecureGuardData(Data)
    GameData = Data
end
exports("SetSecureGuardData", SetSecureGuardData)

RegisterNUICallback("SecureGuard/GetGameData", function(Data, Cb)
    Cb(GameData)
end)

RegisterNUICallback("SecureGuard/Finished", function(Data, Cb)
    TriggerEvent('fw-sound:client:play', Data.Success and 'beep-success' or 'beep-fail', 0.3)
    Cb("Ok")
end)