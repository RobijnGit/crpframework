local PodiumActive, ListenForKeypress = false, false
local LockerActions = {
    ['MRPD'] = {
        PersonalStash = true,
        Trash = true,
        HC = true,
    },
    ['LaMesa'] = {
        PersonalStash = true,
        Trash = true,
        Armory = true,
        Lab = true,
        HC = true,
    },
    ['Davis'] = {
        PersonalStash = true,
        Trash = true,
        Armory = true,
        HC = true,
    },
    ['VBPD'] = {
        PersonalStash = true,
        Evidence = true,
        Trash = true,
        Lab = true,
        Armory = true,
        HC = true,
    },
    ['SDSO'] = {
        PersonalStash = true,
        Trash = true,
        Lab = true,
        Armory = true,
        HC = true,
    },
    ['PBSO'] = {
        PersonalStash = true,
        Trash = true,
        Lab = true,
        Armory = true,
        HC = true,
        Evidence = true,
    },
    ['SAPR'] = {
        PersonalStash = true,
        Evidence = true,
        Trash = true,
        Lab = true,
        Armory = true,
        HC = true,
    },
}

local LockerItems = {
    PersonalStash = {
        Icon = 'box-open',
        Title = "Persoonlijke Stash",
        Desc = "Voor je persoonlijke spullen.",
        Data = {
            Event = "fw-police:Client:OpenPersonalStash",
            Type = "Client",
        },
    },
    Evidence = {
        Icon = 'archive',
        Title = "Bewijskuis",
        Desc = "Sla bewijs op.",
        Data = {
            Event = "fw-police:Client:OpenEvidence",
            Type = "Client",
        },
    },
    Trash = {
        Icon = 'trash',
        Title = "Prullenbak",
        Desc = "Gooi jezelf er maar in, hier hoor je thuis.",
        Data = {
            Event = "fw-police:Client:OpenTrash",
            Type = "Client",
        },
    },
    Lab = {
        Icon = 'microscope',
        Title = "Laboratorium",
        Desc = "Serienummers ontdekken.",
        Data = {
            Event = "fw-police:Client:OpenLab",
            Type = "Client",
        },
    },
    Armory = {
        Icon = 'shield-alt',
        Title = "Wapenkluis",
        Desc = "Voor je wapens en andere benodigdheden.",
        Data = {
            Event = "fw-police:Client:OpenArmory",
            Type = "Client",
        },
    },
    HC = {
        Icon = 'graduation-cap',
        Title = "Leidinggevende Wapenkluis",
        Desc = "Zeldzaam ding dit, denk ik.",
        Data = {
            Event = "fw-police:Client:OpenHCStore",
            Type = "Client",
        },
        DisabledFnc = function()
            return not FW.Functions.GetPlayerData().metadata.ishighcommand
        end
    },
}

function CheckForKeypress(Key, Interaction, Cb)
    local PlayerData = FW.Functions.GetPlayerData()
    if (PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'storesecurity') or not PlayerData.job.onduty then return end

    ListenForKeypress = true

    exports['fw-ui']:ShowInteraction(Interaction)

    Citizen.CreateThread(function()
        while ListenForKeypress do
            Citizen.Wait(4)
    
            if IsControlJustReleased(0, Key) then
                Cb()
            end
        end
    
        exports['fw-ui']:HideInteraction()
    end)
end

function StopKeypressListen()
    ListenForKeypress = false
end

-- MRPD
-- La Mesa
-- Davis
-- Vespucci (VBPD)
-- Sandy (SDSO) 
-- Paleto (PBSO)

-- 

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    -- MRPD
    exports['fw-ui']:AddEyeEntry("mrpd-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(463.36, -984.23, 30.69),
            Length = 0.6,
            Width = 1.2,
            Data = {
                heading = 0,
                minZ = 29.69,
                maxZ = 31.09
            },
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "MRPD" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(440.55, -985.85, 34.97),
        length = 2.6,
        width = 2.0,
    }, {
        name = 'police_podium',
        heading = 0,
        minZ = 33.97,
        maxZ = 36.97
    }, function() end)

    exports['PolyZone']:CreateBox({
        center = vector3(474.78, -995.41, 26.28),
        length = 2,
        width = 5,
    }, {
        name = "mrpd-evidence",
        heading = 270,
        minZ = 25.28,
        maxZ = 28.28
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Bewijskluis", function()
            TriggerEvent('fw-police:Client:OpenEvidence')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(483.35, -988.83, 30.69),
        length = 3.0,
        width = 2.0,
    }, {
        name = "mrpd-lab",
        heading = 0,
        minZ = 29.69,
        maxZ = 32.69
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Laboratorium", function()
            TriggerEvent('fw-police:Client:OpenLab')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(482.58, -995.7, 30.69),
        length = 1.4,
        width = 2.45,
    }, {
        name = "mrpd-armory",
        heading = 0,
        minZ = 29.69,
        maxZ = 32.69
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Wapenkluis", function()
            if exports['fw-inventory']:CanOpenInventory() then
                FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'PoliceArmory')
            end
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(479.06, -996.7, 30.69),
        length = 2.2,
        width = 1.2,
    }, {
        name = "mrpd-actions",
        heading = 0,
        minZ = 29.69,
        maxZ = 32.69
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['MRPD'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['MRPD'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['MRPD'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['MRPD'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['MRPD'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['MRPD'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)

    -- La Mesa
    exports['fw-ui']:AddEyeEntry("lamesa-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(857.77, -1300.3, 28.24),
            Length = 4.6,
            Width = 0.5,
            Data = {
                heading = 0,
                minZ = 27.24,
                maxZ = 29.59
            }
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "LAMESA" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(849.3, -1312.66, 28.24),
        length = 2.2,
        width = 3.8,
    }, {
        name = "lamesa-evidence",
        heading = 0,
        minZ = 27.24,
        maxZ = 29.64
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Bewijskluis", function()
            TriggerEvent('fw-police:Client:OpenEvidence')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(836.68, -1287.12, 28.25),
        length = 1.2,
        width = 3.2,
    }, {
        name = "lasmesa-actions",
        heading = 270,
        minZ = 27.25,
        maxZ = 29.65
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['LaMesa'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['LaMesa'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['LaMesa'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['LaMesa'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['LaMesa'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['LaMesa'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)

    -- Davis
    exports['fw-ui']:AddEyeEntry("davis-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(358.07, -1589.73, 31.06),
            Length = 4.2,
            Width = 0.5,
            Data = {
                heading = 320,
                minZ = 30.06,
                maxZ = 31.26
            }
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "DAVIS" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(381.28, -1609.28, 30.2),
        length = 3.7,
        width = 1.3,
    }, {
        name = "davis-evidence",
        heading = 320,
        minZ = 29.2,
        maxZ = 31.6
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Bewijskluis", function()
            TriggerEvent('fw-police:Client:OpenEvidence')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(368.52, -1592.21, 25.45),
        length = 1.5,
        width = 1.1,
    }, {
        name = "davis-lab",
        heading = 320,
        minZ = 24.45,
        maxZ = 26.65
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Laboratorium", function()
            TriggerEvent('fw-police:Client:OpenLab')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(365.54, -1598.38, 25.46),
        length = 1.5,
        width = 1.5,
    }, {
        name = "davis-actions",
        heading = 320,
        minZ = 24.46,
        maxZ = 26.66
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['Davis'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['Davis'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['Davis'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['Davis'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['Davis'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['Davis'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)

    -- VBPD
    exports['fw-ui']:AddEyeEntry("vbpd-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(-1075.75, -816.45, 19.3),
            Length = 2.05,
            Width = 0.5,
            Data = {
                heading = 40,
                minZ = 18.3,
                maxZ = 20.5
            }
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "VBPD" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(-1080.25, -822.69, 19.3),
        length = 2.7,
        width = 1.5,
    }, {
        name = "vbpd-actions",
        heading = 309,
        minZ = 18.3,
        maxZ = 20.5
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['VBPD'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['VBPD'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['VBPD'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['VBPD'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['VBPD'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['VBPD'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)
    
    -- SDSO
    exports['fw-ui']:AddEyeEntry("sdso-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(1824.55, 3674.28, 38.86),
            Length = 4.0,
            Width = 0.5,
            Data = {
                heading = 300,
                minZ = 37.86,
                maxZ = 40.06
            }
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "SDSO" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(1831.04, 3680.14, 38.86),
        length = 2.7,
        width = 1.1,
    }, {
        name = "sdso-evidence",
        heading = 300,
        minZ = 37.86,
        maxZ = 40.66
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Bewijskluis", function()
            TriggerEvent('fw-police:Client:OpenEvidence')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(1838.01, 3686.12, 34.19),
        length = 1.3,
        width = 2.7,
    }, {
        name = "sdso-actions",
        heading = 300,
        minZ = 33.19,
        maxZ = 35.59
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['SDSO'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['SDSO'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['SDSO'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['SDSO'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['SDSO'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['SDSO'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)

    -- PBSO
    exports['fw-ui']:AddEyeEntry("pbso-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(-435.71, 6008.77, 37.0),
            Length = 2.8,
            Width = 0.5,
            Data = {
                heading = 315,
                minZ = 36.0,
                maxZ = 38.2
            }
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "PBSO" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(1831.04, 3680.14, 38.86),
        length = 2.1,
        width = 0.9,
    }, {
        name = "pbso-evidence",
        heading = 315,
        minZ = 36.01,
        maxZ = 38.61
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] Bewijskluis", function()
            TriggerEvent('fw-police:Client:OpenEvidence')
        end)
    end)

    exports['PolyZone']:CreateBox({
        center = vector3(-443.95, 6013.44, 37.01),
        length = 2.9,
        width = 1.5,
    }, {
        name = "pbso-actions",
        heading = 315,
        minZ = 36.01,
        maxZ = 39.01
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['PBSO'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['PBSO'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['PBSO'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['PBSO'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['PBSO'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['PBSO'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)

    -- SAPR
    exports['fw-ui']:AddEyeEntry("sapr-hc-cabin", {
        Type = 'Zone',
        SpriteDistance = 7.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(387.48, 800.26, 190.49),
            Length = 0.6,
            Width = 2.2,
            Data = {
                heading = 0,
                minZ = 189.49,
                maxZ = 192.24
            },
        },
        Options = {
            {
                Name = 'cabin',
                Icon = 'fas fa-archive',
                Label = 'HC Stash',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenHCStash',
                EventParams = { Department = "SAPR" },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_badge',
                Icon = 'fas fa-id-badge',
                Label = 'Politie Pas Maken',
                EventType = 'Client',
                EventName = 'fw-ui:Client:CreateBadge',
                EventParams = { Badge = 'pd', Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'highcommand_employees',
                Icon = 'fas fa-users',
                Label = 'PD Medewerkerslijst',
                EventType = 'Client',
                EventName = 'fw-police:Client:OpenEmployeelist',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
            {
                Name = 'usb',
                Icon = 'fas fa-road',
                Label = 'Time Trial USB Pakken',
                EventType = 'Client',
                EventName = 'fw-police:Client:GrabTimeTrialUSB',
                EventParams = { Job = 'police' },
                Enabled = function(Entity)
                    local PlayerData = FW.Functions.GetPlayerData()
                    return PlayerData.job.name == 'police' and PlayerData.metadata.ishighcommand
                end,
            },
        }
    })

    exports['PolyZone']:CreateBox({
        center = vector3(387.3, 799.62, 187.55),
        length = 0.8,
        width = 2.2,
    }, {
        name = "sapr-actions",
        heading = 0,
        minZ = 186.55,
        maxZ = 188.6
    }, function(IsInside, Zone, Points)
        if not IsInside then
            StopKeypressListen()
            return
        end

        CheckForKeypress(38, "[E] PD Acties", function()
            local MenuItems = {}

            if LockerActions['SAPR'].PersonalStash then
                table.insert(MenuItems, LockerItems.PersonalStash)
            end

            if LockerActions['SAPR'].Evidence then
                table.insert(MenuItems, LockerItems.Evidence)
            end
            
            if LockerActions['SAPR'].Trash then
                table.insert(MenuItems, LockerItems.Trash)
            end

            if LockerActions['SAPR'].Lab then
                table.insert(MenuItems, LockerItems.Lab)
            end

            if LockerActions['SAPR'].Armory then
                table.insert(MenuItems, LockerItems.Armory)
            end

            if LockerActions['SAPR'].HC and not LockerItems.HC.DisabledFnc() then
                table.insert(MenuItems, LockerItems.HC)
            end

            Citizen.SetTimeout(50, function()
                FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
            end)
        end)
    end)

    -- Jail
    exports['fw-ui']:AddEyeEntry("jail_return_seized_items", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(1840.35, 2578.44, 46.01),
            Length = 0.2,
            Width = 1.0,
            Data = {
                heading = 0,
                minZ = 45.86,
                maxZ = 46.96
            },
        },
        Options = {
            {
                Name = 'return_seized',
                Icon = 'fas fa-circle',
                Label = 'Spullen terugvragen',
                EventType = 'Client',
                EventName = 'fw-prison:Client:OpenSeizedPossessions',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("mrpd_return_seized_items", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(473.12, -1006.89, 26.28),
            Length = 0.5,
            Width = 1.0,
            Data = {
                heading = 0,
                minZ = 26.17,
                maxZ = 26.5,
            },
        },
        Options = {
            {
                Name = 'return_seized',
                Icon = 'fas fa-circle',
                Label = 'Spullen terugvragen',
                EventType = 'Client',
                EventName = 'fw-prison:Client:OpenSeizedPossessions',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    -- Prison Craft
    -- exports['fw-ui']:AddEyeEntry("jail_craft", {
    --     Type = 'Zone',
    --     SpriteDistance = 5.0,
    --     Distance = 3.5,
    --     ZoneData = {
    --         Center = vector3(1636.12, 2585.52, 45.79),
    --         Length = 0.6,
    --         Width = 1.2,
    --         Data = {
    --             debugPoly = false,
    --             heading = 0,
    --             minZ = 44.79,
    --             maxZ = 45.79
    --         },
    --     },
    --     Options = {
    --         {
    --             Name = 'jail_craft',
    --             Icon = 'fas fa-circle',
    --             Label = '????',
    --             EventType = 'Client',
    --             EventName = 'fw-prison:Client:OpenJailCraft',
    --             EventParams = {},
    --             Enabled = function(Entity)
    --                 return true
    --             end,
    --         }
    --     }
    -- })
end)

RegisterNetEvent('PolyZone:OnEnter')
AddEventHandler('PolyZone:OnEnter', function(Poly)
    if Poly.name == 'police_podium' then
        if PodiumActive then return end
        TriggerServerEvent("fw-voice:Server:Transmission:State", 'Podium', true)
        TriggerEvent('fw-voice:Client:Proximity:Override', "Podium", 3, 15.0, 2)
        PodiumActive = true
    end
end)

RegisterNetEvent('PolyZone:OnExit')
AddEventHandler('PolyZone:OnExit', function(Poly)
    if Poly.name == 'police_podium' then
        if not PodiumActive then return end
        TriggerServerEvent("fw-voice:Server:Transmission:State", 'Podium', false)
        TriggerEvent('fw-voice:Client:Proximity:Override', "Podium", 3, -1, -1)
        PodiumActive = false
    end
end)