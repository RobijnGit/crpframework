local PodiumActive, ChangedRange = false, false

function InitZones()
    Citizen.CreateThread(function ()
        exports['PolyZone']:CreateBox({
            center = vector3(-526.75, -177.52, 38.22), 
            length =  3.7, 
            width = 2.4,
        }, {
            name = 'court_stand_1',
            minZ = 37.22,
            maxZ = 40.22,
            heading = 31.0,
            hasMultipleZones = false,
            debugPoly = false,
        }, function() end, function() end)
        exports['PolyZone']:CreateBox({
            center = vector3(-524.52, -182.03, 38.22), 
            length =  3.6, 
            width = 2.7,
        }, {
            name = 'court_stand_2',
            minZ = 37.22,
            maxZ = 40.22,
            heading = 30.0,
            hasMultipleZones = false,
            debugPoly = false,
        }, function() end, function() end)
        exports['PolyZone']:CreateBox({
            center = vector3(-518.18, -174.13, 38.55), 
            length =  6.4, 
            width = 3.4,
        }, {
            name = 'court_judge',
            minZ = 37.55,
            maxZ = 40.55,
            heading = 30.0,
            hasMultipleZones = false,
            debugPoly = false,
        }, function() end, function() end)
        exports['PolyZone']:CreateBox({
            center = vector3(-522.63, -177.85, 38.22), 
            length =  1.3, 
            width = 1.5,
        }, {
            name = 'court_podium',
            minZ = 37.22,
            maxZ = 39.42,
            heading = 30.0,
            hasMultipleZones = false,
            debugPoly = false,
        }, function() end, function() end)
        exports['PolyZone']:CreateBox({
            center = vector3(-779.99, -0.44, 41.56),
            length = 1.2,
            width = 2.2,
        }, {
            name = 'church_stand_1',
            heading = 30,
            minZ = 40.36,
            maxZ = 42.96,
        }, function() end, function() end)
        exports['PolyZone']:CreateBox({
            center = vector3(-782.53, -2.88, 41.59),
            length = 1.0,
            width = 1.0,
        }, {
            name = 'church_stand_2',
            heading = 30,
            minZ = 40.39,
            maxZ = 42.79
        }, function() end, function() end)
        exports['PolyZone']:CreateBox({
            center = vector3(-774.78, 1.73, 41.56),
            length = 1.6,
            width = 2.2,
        }, {
            name = 'church_stand_3',
            heading = 30,
            minZ = 40.36,
            maxZ = 42.76
        }, function() end, function() end)
    end)

    exports['fw-ui']:AddEyeEntry("cityhall-licenses", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 5.0,
        Position = vector4(-540.29, -191.04, 37.20, 120.46),
        Model = 'a_f_y_business_04',
        Anim = {},
        Props = {},
        Options = {
            {
                Name = 'purchase-id',
                Icon = 'fas fa-id-card-alt',
                Label = 'Identiteitskaart (' .. exports['fw-businesses']:NumberWithCommas(Config.IdPrice) .. ')',
                EventType = 'Server',
                EventName = 'fw-cityhall:Server:PurchaseId',
                EventParams = { Type = "Identity" },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'purchase-drivers',
                Icon = 'fas fa-id-card-alt',
                Label = 'Rijbewijs (' .. exports['fw-businesses']:NumberWithCommas(Config.IdPrice) .. ')',
                EventType = 'Server',
                EventName = 'fw-cityhall:Server:PurchaseId',
                EventParams = { Type = "Driver" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("cityhall-options", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 2.5,
        ZoneData = {
            Center = vector3(-553.17, -193.04, 38.22),
            Length = 0.4,
            Width = 1.0,
            Data = {
                heading = 23,
                minZ = 38.02,
                maxZ = 38.52
            },
        },
        Options = {
            {
                Name = 'pdActions',
                Icon = 'fas fa-crutch',
                Label = 'PD Acties',
                EventType = 'Client',
                EventName = 'fw-cityhall:Client:OpenPDActions',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' or PlayerData.job.name == 'judge'
                end,
            },
            -- {
            --     Name = 'clock_in_judge',
            --     Icon = 'fas fa-circle',
            --     Label = 'In / Uit Dienst',
            --     EventType = 'Client',
            --     EventName = 'fw-mdw:Client:DutyAction',
            --     EventParams = { Job = 'judge' },
            --     Enabled = function(Entity)
            --         local PlayerData = FW.Functions.GetPlayerData()
            --         return PlayerData.job.name == 'judge'
            --     end,
            -- },
        },
    })

    exports['fw-ui']:AddEyeEntry("cityhall-hammer", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 2.5,
        ZoneData = {
            Center = vector3(-519.33, -175.63, 38.55),
            Length = 0.3,
            Width = 0.25,
            Data = {
                heading = 85.0,
                minZ = 38.35,
                maxZ = 38.75
            },
        },
        Options = {
            {
                Name = 'gavel',
                Icon = 'fas fa-gavel',
                Label = 'Slaan met die hamer!!',
                EventType = 'Server',
                EventName = 'fw-cityhall:server:hamer',
                EventParams = { },
                Enabled = function(Entity)
                    return FW.Functions.GetPlayerData().job.name == 'judge'
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("judge-cabinet", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-521.32, -195.11, 38.22),
            Length = 0.6,
            Width = 0.4,
            Data = {
                heading = 30,
                minZ = 37.97,
                maxZ = 38.27,
            },
        },
        Options = {
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'DOJ Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'doj', Job = 'judge', Department = 'Department of Justice' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'judge' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'fetchBankId',
                Icon = 'fas fa-university',
                Label = 'Bankrekeningnummer Opvragen',
                EventType = 'Client',
                EventName = 'fw-cityhall:Client:RequestBankaccount',
                EventParams = {},
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'judge' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", InitZones)

RegisterNetEvent('PolyZone:OnEnter')
AddEventHandler('PolyZone:OnEnter', function(Poly)
    if Poly.name == 'court_stand_1' or Poly.name == 'court_stand_2' or Poly.name == 'court_judge' then
        if ChangedRange then return end
        TriggerEvent('fw-voice:Client:Proximity:Override', "Normal", 3, 11.5, 2)
        ChangedRange = true
    elseif Poly.name == 'court_podium' or Poly.name == 'church_stand_1' or Poly.name == 'church_stand_2' or Poly.name == 'church_stand_3' then
        if PodiumActive then return end
        TriggerServerEvent("fw-voice:Server:Transmission:State", 'Podium', true)
        TriggerEvent('fw-voice:Client:Proximity:Override', "Podium", 3, 15.0, 2)
        PodiumActive = true
    end
end)

RegisterNetEvent('PolyZone:OnExit')
AddEventHandler('PolyZone:OnExit', function(Poly)
    if Poly.name == 'court_stand_1' or Poly.name == 'court_stand_2' or Poly.name == 'court_judge' then
        if not ChangedRange then return end
        TriggerEvent('fw-voice:Client:Proximity:Override', "Normal", 3, -1, -1)
        ChangedRange = false
    elseif Poly.name == 'court_podium' or Poly.name == 'church_stand_1' or Poly.name == 'church_stand_2' or Poly.name == 'church_stand_3' then
        if not PodiumActive then return end
        TriggerServerEvent("fw-voice:Server:Transmission:State", 'Podium', false)
        TriggerEvent('fw-voice:Client:Proximity:Override', "Podium", 3, -1, -1)
        PodiumActive = false
    end
end)