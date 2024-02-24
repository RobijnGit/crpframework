function RemoveLockpickChance(IsAdvanced)
    local ItemName = IsAdvanced and "advlockpick" or "lockpick"
    if math.random(1, 100) > (IsAdvanced and 50 or 25) then
        TriggerServerEvent('fw-inventory:Server:DecayItem', ItemName, nil, 5.0)
    end
end
exports("RemoveLockpickChance", RemoveLockpickChance)

function AddTextEntry(Key, Value)
    Citizen.InvokeNative(GetHashKey("ADD_TEXT_ENTRY"), Key, Value)
end