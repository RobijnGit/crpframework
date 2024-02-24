local InsideBriefing = false

Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({
        center = vector3(445.2, -985.92, 34.97), 
        length = 9.6, 
        width = 11.6,
    }, {
        name = "mrpd-briefing-room",
        heading = 0,
        minZ = 33.37,
        maxZ = 36.37,
    }, function(IsInside, Zone, Points)
        InsideBriefing = IsInside

        if IsInside then
            local DuiData = exports['fw-assets']:GenerateNewDui('https://i.imgur.com/5Ust2GQ.jpg', 1920, 1080, 'police-briefing')
            if DuiData == false then
                local SecondDuiData = exports['fw-assets']:GetDuiData('police-briefing')
                AddReplaceTexture('prop_planning_b1', 'prop_base_white_01b', SecondDuiData['TxdDictName'], SecondDuiData['TxdName'])
                exports['fw-assets']:ActivateDui('police-briefing')
            else
                AddReplaceTexture('prop_planning_b1', 'prop_base_white_01b', DuiData['TxdDictName'], DuiData['TxdName'])
            end
        else
            local DuiData = exports['fw-assets']:GetDuiData('police-briefing')
            RemoveReplaceTexture('prop_planning_b1', 'prop_base_white_01b')
            exports['fw-assets']:ReleaseDui('police-briefing')
        end
    end)

end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey('p_planning_board_02'), {
        Type = 'Model',
        Model = 'p_planning_board_02',
        Distance = 3.0,
        Options = {
            {
                Name = 'dui_url',
                Icon = 'fas fa-circle',
                Label = 'URL Veranderen',
                EventType = 'Client',
                EventName = 'fw-assets:client:change:dui:menu',
                EventParams = { DuiId = 'police-briefing' },
                Enabled = function(Entity)
                    return InsideBriefing and FW.Functions.GetPlayerData().job.name == 'police'
                end,
            },
        }
    })
end)