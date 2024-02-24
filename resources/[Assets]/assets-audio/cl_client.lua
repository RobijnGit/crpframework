local AudioBanks = {
    'dlc_robijn_events/events',
    'dlc_robijn_general/general',
    'dlc_robijn_heists/heists',
    'dlc_robijn_heists_vault/heists_vault',
    'dlc_robijn_items/items',
    'dlc_robijn_phone/phone',
    'dlc_robijn_state/state',
    'dlc_robijn_vehicle/vehicle',
    'dlc_robijn_ringtones/ringtones',
}

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do Citizen.Wait(100) end
    for k, v in pairs(AudioBanks) do
        RequestScriptAudioBank(v, false, -1)
        while not RequestScriptAudioBank(v, false, -1) do
            Citizen.Wait(100)
        end
    end
    print("Loaded all (" .. #AudioBanks .. ") audio banks.")
end)