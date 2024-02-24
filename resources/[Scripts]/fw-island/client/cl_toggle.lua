local IslandActive = false
Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({ center = vector3(4840.571, -5174.425, 2.0), length = 4000.0, width = 4000.0 }, {
        name = "cayo_island", heading = 0.0,
        minZ = -200.0, maxZ = 1000.0,
        debugPoly = false,
    }, function(IsInside, Zone, Point)
        ToggleIsland(IsInside)
    end)
end)

function ToggleIsland(Bool)
    IslandActive = Bool
    if Bool then
        SetIslandHopperEnabled("HeistIsland", true)
        SetScenarioGroupEnabled("Heist_Island_Peds", true)
        SetAudioFlag('PlayerOnDLCHeist4Island', true)
        SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', true, true)
        SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', false, true)
        SetAiGlobalPathNodesType(1)
        LoadGlobalWaterType(1)
        SetWindSpeed(0.0)
        SetToggleMinimapHeistIsland(true)
        Wait(0)
        RemoveIpl("h4_islandx_sea_mines")
        RemoveIpl("h4_aa_guns_lod")
        RemoveIpl("h4_aa_guns")
        return
    end

    SetIslandHopperEnabled("HeistIsland", false)
    SetScenarioGroupEnabled("Heist_Island_Peds", false)
    SetAudioFlag('PlayerOnDLCHeist4Island', false)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', false, true)
    SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', true, true)
    SetAiGlobalPathNodesType(0)
    LoadGlobalWaterType(0)
    SetWindSpeed(1.0)
    SetToggleMinimapHeistIsland(false)
end

exports("GetIslandActive", function()
    return IslandActive
end)