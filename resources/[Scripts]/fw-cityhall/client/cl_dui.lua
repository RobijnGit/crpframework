local InsideBriefing = false

Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({
        center = vector3(-525.19, -178.48, 38.22),
        length = 21.4, 
        width = 21.2,
    }, {
        name = "townhall-courthouse",
        heading = 209,
        minZ = 37.02,
        maxZ = 46.22,
        debugPoly = false
    }, function(IsInside, Zone, Points)
        InsideBriefing = IsInside

        if IsInside then
            local DuiData = exports['fw-assets']:GenerateNewDui('https://i.imgur.com/5Ust2GQ.jpg', 1920, 1080, 'townhall-courthouse')
            if DuiData == false then
                local SecondDuiData = exports['fw-assets']:GetDuiData('townhall-courthouse')
                AddReplaceTexture('np_town_hall_bigscreen', 'projector_screen', SecondDuiData['TxdDictName'], SecondDuiData['TxdName'])
                exports['fw-assets']:ActivateDui('townhall-courthouse')
            else
                AddReplaceTexture('np_town_hall_bigscreen', 'projector_screen', DuiData['TxdDictName'], DuiData['TxdName'])
            end
        else
            local DuiData = exports['fw-assets']:GetDuiData('townhall-courthouse')
            RemoveReplaceTexture('np_town_hall_bigscreen', 'projector_screen')
            exports['fw-assets']:ReleaseDui('townhall-courthouse')
        end
    end)
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("cityhall-screen", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 2.5,
        ZoneData = {
            Center = vector3(-518.83, -177.19, 38.55),
            Length = 0.4,
            Width = 1.0,
            Data = {
                heading = 332,
                minZ = 38.55,
                maxZ = 38.95
            },
        },
        Options = {
            {
                Name = 'dui_url',
                Icon = 'fas fa-circle',
                Label = 'URL Veranderen',
                EventType = 'Client',
                EventName = 'fw-assets:client:change:dui:menu',
                EventParams = { DuiId = 'townhall-courthouse' },
                Enabled = function(Entity)
                    return FW.Functions.GetPlayerData().job.name == 'judge'
                end,
            },
        },
    })
end)