Config = Config or {}

Config.Sounds = {
    -- dlc_robijn_events/events
    ['events.scream'] = { AudioId = 'scream', AudioBank = 'DLC_ROBIJN_EVENTS', Timeout = 2000 },
    ['events.wind'] = { AudioId = 'wind', AudioBank = 'DLC_ROBIJN_EVENTS', Timeout = 11000 },
    ['events.phoneAlert'] = { AudioId = 'phone-alert', AudioBank = 'DLC_ROBIJN_EVENTS', Timeout = 2000 },

    -- dlc_robijn_general/general
    ['general.death'] = { AudioId = 'death', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.doorClose'] = { AudioId = 'door-close', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.doorKeys'] = { AudioId = 'door-keys', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.doorOpen'] = { AudioId = 'door-open', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.elevator'] = { AudioId = 'elevator', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.houseDoorbell'] = { AudioId = 'house-doorbell', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.stashOpen'] = { AudioId = 'stash-open', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.changeClothes'] = { AudioId = 'change-clothes', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.metalDetector'] = { AudioId = 'metal-detector', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.wrapping'] = { AudioId = 'wrapping', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },
    ['general.frying'] = { AudioId = 'frying', AudioBank = 'DLC_ROBIJN_GENERAL', Timeout = 1000 },

    -- dlc_robijn_heists/heists
    ['heists.glassSmash'] = { AudioId = 'glass-smash', AudioBank = 'DLC_ROBIJN_HEISTS', Timeout = 1000 },
    ['heists.metronome'] = { AudioId = 'metronome', AudioBank = 'DLC_ROBIJN_HEISTS', Timeout = 1000 },
    ['heists.alarmBeep'] = { AudioId = 'alarm-beep', AudioBank = 'DLC_ROBIJN_HEISTS', Timeout = 1000 },
    ['heists.alarmBeepDouble'] = { AudioId = 'alarm-beep-double', AudioBank = 'DLC_ROBIJN_HEISTS', Timeout = 500 },
    ['heists.alarm'] = { AudioId = 'alarm-beep-alarm', AudioBank = 'DLC_ROBIJN_HEISTS', Timeout = 1000 },
    ['heists.vaultAlarm'] = { AudioId = 'vault-beep', AudioBank = 'DLC_ROBIJN_HEISTS_VAULT', Timeout = 3500 },

    -- dlc_robijn_items/items
    ['items.coinflip'] = { AudioId = 'coinflip', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 3000 },
    ['items.cuff'] = { AudioId = 'cuff', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },
    ['items.dice'] = { AudioId = 'dice', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },
    ['items.lighter'] = { AudioId = 'lighter', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },
    ['items.nightvision'] = { AudioId = 'nightvision', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },
    ['items.pickaxe'] = { AudioId = 'pickaxe', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },
    ['items.grapple'] = { AudioId = 'grapple', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },
    ['items.lockpick'] = { AudioId = 'lockpick', AudioBank = 'DLC_ROBIJN_ITEMS', Timeout = 1000 },

    -- dlc_robijn_phone/phone
    ['phone.radioClick'] = { AudioId = 'radio-click', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 1000 },
    ['phone.radioDistortion'] = { AudioId = 'radio-distortion', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 1000 },
    ['phone.radioOff'] = { AudioId = 'radio-off', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 1000 },
    ['phone.radioOn'] = { AudioId = 'radio-on', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 1000 },
    ['phone.radioTransmission'] = { AudioId = 'radio-transmission', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 1000 },
    ['phone.phoneRing'] = { AudioId = 'phone-ring', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 5000 },
    ['phone.phoneDial'] = { AudioId = 'phone-dial', AudioBank = 'DLC_ROBIJN_PHONE', Timeout = 5000 },

    -- dlc_robijn_state/state
    ['state.alertHighCrime'] = { AudioId = 'alert-high-crime', AudioBank = 'DLC_ROBIJN_STATE', Timeout = 1000 },
    ['state.alertHighPrio'] = { AudioId = 'alert-high-prio', AudioBank = 'DLC_ROBIJN_STATE', Timeout = 1000 },
    ['state.jailCell'] = { AudioId = 'jail-cell', AudioBank = 'DLC_ROBIJN_STATE', Timeout = 5000 },
    ['state.jailPhoto'] = { AudioId = 'jail-photo', AudioBank = 'DLC_ROBIJN_STATE', Timeout = 1000 },
    ['state.gavel'] = { AudioId = 'judge-gavel', AudioBank = 'DLC_ROBIJN_STATE', Timeout = 1000 },

    -- dlc_robijn_vehicle/vehicle
    ['vehicle.anchorDrop'] = { AudioId = 'boat-anchor-drop', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 7000 },
    ['vehicle.anchorRaise'] = { AudioId = 'boat-anchor-raise', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 4000 },
    ['vehicle.flatbedTow'] = { AudioId = 'flatbed-tow', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 6000 },
    ['vehicle.garageRespray'] = { AudioId = 'garage-respray', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 4000 },
    ['vehicle.garageWrench'] = { AudioId = 'garage-wrench', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 1000 },
    ['vehicle.buckle'] = { AudioId = 'vehicle-buckle', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 1000 },
    ['vehicle.lock'] = { AudioId = 'vehicle-lock', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 1000 },
    ['vehicle.unbuckle'] = { AudioId = 'vehicle-unbuckle', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 1000 },
    ['vehicle.unlock'] = { AudioId = 'vehicle-unlock', AudioBank = 'DLC_ROBIJN_VEHICLE', Timeout = 1000 },

    ['ringtones.pullu'] = { AudioId = 'pullu', AudioBank = 'DLC_ROBIJN_RINGTONES', Timeout = 2030 },
    ['ringtones.skype'] = { AudioId = 'skype', AudioBank = 'DLC_ROBIJN_RINGTONES', Timeout = 3280 },
    ['ringtones.snot'] = { AudioId = 'snot', AudioBank = 'DLC_ROBIJN_RINGTONES', Timeout = 3280 },
}