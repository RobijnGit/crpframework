RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("vbpd_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(-1087.08, -814.19, 19.3),
            Length = 0.6,
            Width = 0.4,
            Data = {
                heading = 18,
                minZ = 19.45,
                maxZ = 19.65
            },
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Police' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("mrpd_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(441.76, -982.05, 30.69),
            Length = 0.8,
            Width = 0.6,
            Data = {
                heading = 10,
                minZ = 30.79,
                maxZ = 31.19
            },
        },
        Options = {
            {
                Name = 'pd',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Police' },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'dispatch',
                Icon = 'fas fa-circle',
                Label = '(Dispatch) In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Dispatch' },
                Enabled = function(Entity)
                    return FW.Functions.GetPlayerData().job.name == 'storesecurity' or (FW.Functions.GetPlayerData().job.name == 'police' and FW.Functions.GetPlayerData().metadata.division == 'DISPATCH')
                end,
            },
            {
                Name = 'dispatch',
                Icon = 'fas fa-circle',
                Label = '(Winkel Cooperatie) In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'StoreSecurity' },
                Enabled = function(Entity)
                    return FW.Functions.GetPlayerData().job.name == 'storesecurity'
                end,
            },
            {
                Name = 'stash',
                Icon = 'fas fa-inbox',
                Label = 'Servicebalie Stash',
                EventType = 'Client',
                EventName = 'fw-police:OpenServicedeskStash',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("davispd_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(381.19, -1595.68, 30.05),
            Length = 0.25,
            Width = 1.75,
            Data = {
                heading = 50,
                minZ = 30.05,
                maxZ = 31.3
            },
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Police' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("sandypd_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(1833.74, 3678.39, 34.19),
            Length = 0.55,
            Width = 0.35,
            Data = {
                heading = 303,
                minZ = 34.19,
                maxZ = 34.44
            },
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Police' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("paletopd_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(-447.28, 6013.02, 32.29),
            Length = 0.6,
            Width = 0.4,
            Data = {
                heading = 315,
                minZ = 32.34,
                maxZ = 32.69
            },
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Police' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })
    
    exports['fw-ui']:AddEyeEntry("lamesapd_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(837.7, -1289.32, 28.24),
            Length = 0.4,
            Width = 0.55,
            Data = {
                heading = 344,
                minZ = 28.24,
                maxZ = 28.49
            }
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'Police' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })
    
    exports['fw-ui']:AddEyeEntry("crusade_hosp_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(358.1, -1397.71, 32.5),
            Length = 0.75,
            Width = 0.55,
            Data = {
                heading = 7,
                minZ = 32.2,
                maxZ = 32.6
            }
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'EMS' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("sandy_hosp_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(1672.2, 3665.91, 35.34),
            Length = 0.8,
            Width = 0.4,
            Data = {
                heading = 300,
                minZ = 35.39,
                maxZ = 35.79
            }
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'EMS' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("paleto_hosp_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(-252.81, 6334.71, 32.45),
            Length = 0.8,
            Width = 0.4,
            Data = {
                heading = 315,
                minZ = 32.45,
                maxZ = 33.05
            }
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'EMS' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })

    exports['fw-ui']:AddEyeEntry("paleto_hosp_clock_in", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(1838.16, 2575.3, 46.01),
            Length = 1.5,
            Width = 0.1,
            Data = {
                heading = 0,
                minZ = 45.96,
                maxZ = 47.16
            }
        },
        Options = {
            {
                Name = 'clock_in',
                Icon = 'fas fa-circle',
                Label = 'In / Uit Dienst',
                EventType = 'Client',
                EventName = 'fw-mdw:Client:DutyAction',
                EventParams = { Job = 'DOC' },
                Enabled = function(Entity)
                    return true
                end,
            },
        },
    })
end)