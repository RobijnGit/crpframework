FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

-- Code

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true

    Citizen.SetTimeout(1500, function()
        InitAssets()
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do
        Citizen.Wait(100)
    end

    -- Load all blips
    DisplayRadar(false)

    for k,v in pairs(Config.Blips) do
        local Blips = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
        SetBlipSprite(Blips, v.SpriteId)
        SetBlipDisplay(Blips, 4)
        SetBlipScale(Blips, v.Scale)
        SetBlipAsShortRange(Blips, true)
        SetBlipColour(Blips, v.Color)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.Name)
        EndTextCommandSetBlipName(Blips)
    end

    SetDiscordRichPresence()

    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_HILLBILLY"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_BALLAS"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_MEXICAN"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_FAMILY"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_MARABUNTE"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("AMBIENT_GANG_SALVA"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_1"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_2"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_9"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("GANG_10"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("FIREMAN"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("MEDIC"), GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(1, GetHashKey("COP"), GetHashKey('PLAYER'))
end)

function InitAssets()
    -- Disable Dispatch Services
    for i = 1, 15 do EnableDispatchService(i, false) end

    SetPedConfigFlag(PlayerPedId(), 35, false) -- CPED_CONFIG_FLAG_UseHelmet

    -- Enable friendly attack
    for i = 0, 255 do
        if NetworkIsPlayerConnected(i) then
            if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
                SetCanAttackFriendly(GetPlayerPed(i), true, true)
            end
        end
    end

    -- Disable some stuff
    SetTrainTrackSpawnFrequency(3, 99999999999)
    SetTrainTrackSpawnFrequency(0, 120000000)
    SwitchTrainTrack(0, true)
    SetRandomTrains(true)
    SetRandomBoats(true)
    SetRandomBoatsInMp(true)
    SetGarbageTrucks(false)
    SetMaxWantedLevel(0)
    SetCreateRandomCops(0)
    DistantCopCarSirens(false)
    SetCreateRandomCopsOnScenarios(0)
    SetCreateRandomCopsNotOnScenarios(0)
    NetworkSetFriendlyFireOption(true)
    DisablePlayerVehicleRewards(PlayerId())
    SetDispatchCopsForPlayer(PlayerId(), false)
    SetBlipAlpha(GetNorthRadarBlip(), 0) -- disable north indicator blip

    -- Misc stuff
    DisablePlayerRadioStations()
    SetDiscordRichPresenceAction(0, 'Discord', 'https://discord.gg/clarityrp')

    -- Config.SavedDuiData = FW.SendCallback("fw-assets:Server:GetDuiData")

    -- Remove soft border around minimap
    RequestStreamedTextureDict("squaremap", false)
	while not HasStreamedTextureDictLoaded("squaremap") do
		Wait(100)
	end

	AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    RequestStreamedTextureDict("minimap_0_0", false)
	RequestStreamedTextureDict("minimap_0_1", false)
	RequestStreamedTextureDict("minimap_1_0", false)
	RequestStreamedTextureDict("minimap_1_1", false)
	RequestStreamedTextureDict("minimap_2_0", false)
	RequestStreamedTextureDict("minimap_2_1", false)
	RequestStreamedTextureDict("minimap_lod_128", false)
	RequestStreamedTextureDict("minimap_sea_0_0", false)
	RequestStreamedTextureDict("minimap_sea_0_1", false)
	RequestStreamedTextureDict("minimap_sea_1_0", false)
	RequestStreamedTextureDict("minimap_sea_2_0", false)
	RequestStreamedTextureDict("minimap_sea_2_1", false)

    Citizen.Wait(100)

    SetMapZoomDataLevel(0, 2.3, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(1, 2.6, 0.9, 0.08, 0.0, 0.0) 
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0) 
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)

    Citizen.Wait(350)

    local Minimap = RequestScaleformMovie("minimap")
    while not HasScaleformMovieLoaded(Minimap) do
        Citizen.Wait(0)
    end

    SetMinimapComponentPosition("minimap", "L", "B", -0.0045, -0.025, 0.150, 0.18888)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.020, 0.022, 0.111, 0.159)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.03, -0.002, 0.266, 0.237)
    SetMinimapClipType(0)
    SetRadarBigmapEnabled(true, false)
    Citizen.Wait(250)
    SetRadarBigmapEnabled(false, false)
    SetRadarZoom(1100)
    DisplayRadar(false)

    InitChairs()

    print("[ASSETS]: Init done!")
end

function DisablePlayerRadioStations()
    local RadioStations = {
        ['RADIO_01_CLASS_ROCK'] = false,
        ['RADIO_02_POP'] = false,
        ['RADIO_03_HIPHOP_NEW'] = false,
        ['RADIO_04_PUNK'] = false,
        ['RADIO_05_TALK_01'] = false,
        ['RADIO_06_COUNTRY'] = false,
        ['RADIO_07_DANCE_01'] = false,
        ['RADIO_08_MEXICAN'] = false,
        ['RADIO_09_HIPHOP_OLD'] = false,
        ['RADIO_12_REGGAE'] = false,
        ['RADIO_13_JAZZ'] = false,
        ['DLC_BATTLE_MIX4_CLUB_PRIV'] = false,
        ['DLC_BATTLE_MIX2_CLUB_PRIV'] = false,
        ['DLC_BATTLE_MIX1_CLUB_PRIV'] = false,
        ['RADIO_23_DLC_XM19_RADIO'] = false,
        ['RADIO_34_DLC_HEI4_KULT'] = false,
        ['RADIO_35_DLC_HEI4_MLR'] = false,
        ['RADIO_36_AUDIOPLAYER'] = false,
        ['RADIO_14_DANCE_02'] = false,
        ['RADIO_15_MOTOWN'] = false,
        ['RADIO_20_THELAB'] = false,
        ['RADIO_16_SILVERLAKE'] = false,
        ['RADIO_17_FUNK'] = false,
        ['RADIO_18_90S_ROCK'] = false,
        ['RADIO_21_DLC_XM17'] = false,
        ['RADIO_11_TALK_02'] = false,
        ['RADIO_22_DLC_BATTLE_MIX1_RADIO'] = false,
        ['RADIO_23_DLC_BATTLE_MIX2_CLUB'] = false,
        ['RADIO_24_DLC_BATTLE_MIX3_CLUB'] = false,
        ['RADIO_25_DLC_BATTLE_MIX4_CLUB'] = false,
        ['RADIO_26_DLC_BATTLE_CLUB_WARMUP'] = false,
    }

    for k, v in pairs(RadioStations) do
        SetRadioStationIsVisible(k, v)
    end
end

FW.AddKeybind("handsUp", "Speler", "Handen omhoog doen", "", function(IsPressed)
    if not IsPressed then return end
    if not IsEntityPlayingAnim(PlayerPedId(), "missminuteman_1ig_2", "handsup_base", 1) then
        if not HasAnimDictLoaded("missminuteman_1ig_2") then
            RequestAnimDict("missminuteman_1ig_2")
            while not HasAnimDictLoaded("missminuteman_1ig_2") do Citizen.Wait(5) end
        end
        TaskPlayAnim(PlayerPedId(), "missminuteman_1ig_2", "handsup_base", 8.0, 8.0, -1, 50, 0, false, false, false)
    else
        StopAnimTask(PlayerPedId(), "missminuteman_1ig_2", "handsup_base", 1.0)
    end
end)
