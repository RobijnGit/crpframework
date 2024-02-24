-- Lasers
local IsLaserTripped = false
local DrawLasers = true
local StaticLasers = {
    { vector3(253.469, 221.149, 96.49), vector3(254.601, 224.315, 96.49) },
    { vector3(253.467, 221.15, 97.073), vector3(254.601, 224.315, 97.073) },
    { vector3(253.467, 221.15, 97.619), vector3(254.58, 224.323, 97.619) },
    { vector3(253.477, 221.146, 98.148), vector3(254.574, 224.325, 98.148) },
    { vector3(261.582, 216.625, 96.741), vector3(258.413, 217.737, 96.741) },
    { vector3(261.58, 216.62, 97.723), vector3(258.413, 217.738, 97.723) },
    { vector3(261.579, 216.617, 98.593), vector3(258.412, 217.735, 98.593) },
    { vector3(258.311, 217.817, 96.752), vector3(260.418, 223.656, 96.752) },
    { vector3(258.317, 217.811, 97.727), vector3(260.429, 223.652, 97.727) },
    { vector3(258.311, 217.809, 98.583), vector3(260.443, 223.647, 98.583) },
    { vector3(239.339, 226.292, 96.49), vector3(240.472, 229.458, 96.49) },
    { vector3(239.331, 226.294, 97.073), vector3(240.471, 229.458, 97.073) },
    { vector3(239.329, 226.295, 97.619), vector3(240.471, 229.458, 97.619) },
    { vector3(239.327, 226.296, 98.148), vector3(240.473, 229.457, 98.148) },
}

-- Origin, Destination, [MinZ, MaxZ], Increase, DirectionQ
local MovingLasers = {
    { vector3(262.776, 217.762, 96.741), vector3(263.899, 220.931, 96.741), {96.741, 98.4}, 1.4, 'up' }, -- Front
    { vector3(260.596, 223.737, 96.741), vector3(263.662, 222.611, 96.741), {96.741, 98.593}, 1.4, 'up' }, -- Corner Inner
    { vector3(260.7, 228.687, 96.716), vector3(259.629, 225.75, 96.716), {96.741, 98.593}, 1.4, 'up' }, -- Corner Outer
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        local Distance = #(GetEntityCoords(PlayerPedId()) - vector3(285.73, 264.89, 105.59))
        DrawLasers = Distance <= 150.0 and DataManager.Get(GetVaultPrefix() .. "lasers-hacked", 0) == 0
    end
end)

Citizen.CreateThread(function()
    while true do
        if DrawLasers then
            DrawStaticVaultLasers()
            DrawMovingVaultLasers()
        end

        Citizen.Wait(4)
    end
end)

local function RayCast(Origin, Destination, Flags)
    local Ray = StartShapeTestRay(Origin.x, Origin.y, Origin.z, Destination.x, Destination.y, Destination.z, Flags, nil, 0)
    return GetShapeTestResult(Ray)
end

function CheckLaserHit(Start, End)
    local _, hit, hitPos, _, hitEntity = RayCast(Start, End, 12)
    if hit and hitEntity == PlayerPedId() then
        IsLaserTripped = true
        Citizen.CreateThread(function()
            -- only play sound and set tripped if being robbed
            if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) == 1 then
                DataManager.Set(GetVaultPrefix() .. "lasers-tripped", 1)
                TriggerEvent("fw-misc:Client:PlaySoundEntity", 'heists.vaultAlarm', GetEntityCoords(PlayerPedId()), 50.0, true)
            end

            Citizen.Wait(3500)
            IsLaserTripped = false
        end)
    end
end

function DrawStaticVaultLasers()
    for k, v in pairs(StaticLasers) do
        DrawLine(v[1], v[2], 250, 0, 0, 255)
        if not IsLaserTripped then
            CheckLaserHit(v[1], v[2])
        end
    end
end

function DrawMovingVaultLasers()
    local FrameTime = GetFrameTime()

    for k, v in pairs(MovingLasers) do
        DrawLine(v[1], v[2], 250, 0, 0, 255)
        if not IsLaserTripped then
            CheckLaserHit(v[1], v[2])
        end

        if v[1].z <= v[3][1] then
            v[5] = 'up'
        elseif v[1].z >= v[3][2] then
            v[5] = 'down'
        end

        if v[5] == 'up' then
            v[1] = vector3(v[1].x, v[1].y, v[1].z + (v[4] * FrameTime))
            v[2] = vector3(v[2].x, v[2].y, v[2].z + (v[4] * FrameTime))
        else
            v[1] = vector3(v[1].x, v[1].y, v[1].z - (v[4] * FrameTime))
            v[2] = vector3(v[2].x, v[2].y, v[2].z - (v[4] * FrameTime))
        end
    end
end

function IsVaultTripped()
    if DataManager.Get(GetVaultPrefix() .. "lasers-tripped", 0) == 1 then
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do
            Wait(0)
        end

        for i = 1, 25, 1 do
            Citizen.CreateThread(function()
                UseParticleFxAsset("core")
                local partiResult = StartParticleFxLoopedOnEntity("ent_amb_elec_crackle", PlayerPedId(), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, false, false, false)
                Wait(200)
                StopParticleFxLooped(partiResult, true)
            end)
        end

        FW.Functions.Notify("Anti-diefstal systeem is geactiveerd..", "error")
        
        ApplyForceToEntity(PlayerPedId(), 1, 400.0, -400.0, 0.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
        Citizen.Wait(5)
        SetPedToRagdoll(PlayerPedId(), 3000, 3000, 0, true, true, false);
    end

    return DataManager.Get(GetVaultPrefix() .. "lasers-tripped", 0) == 1
end

-- Vault Door
function CheckVaultDoor()
    if AnimatingDoor then
        return
    end

    local VaultCoords = vector3(234.99, 228.07, 97.72)

    local PlyCoords = GetEntityCoords(PlayerPedId())
    local Distance = #(PlyCoords - VaultCoords)
    if Distance > 100.0 then
        return
    end

    local Object = GetClosestObjectOfType(VaultCoords.x, VaultCoords.y, VaultCoords.z, 5.0, GetHashKey("v_ilev_bk_vaultdoor"), false, false, false)
    local Heading = GetEntityHeading(Object)

    if DataManager.Get(GetVaultPrefix() .. "vault-big-hacked", 0) == 2 then
        if Heading ~= -54.95 then
            AnimateObjectHeading(Object, -54.95)
        end
    else
        if Heading ~= 70.16 then
            AnimateObjectHeading(Object, 70.16)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        CheckVaultDoor()
    end
end)

-- Zones
local HeistObjects = {}

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['PolyZone']:CreateBox({
        center = vector3(260.18, 219.44, 106.28),
        length = 80,
        width = 80,
    }, {
        name = "heist-vault-zone",
        heading = 340,
        minZ = 90.0,
        maxZ = 150.0,
    }, function(IsInside, Zone, Points)
        if not IsInside then
            for k, v in pairs(HeistObjects) do
                DeleteEntity(v)
            end

            HeistObjects = {}
            return
        end

        local PanelVault = CreateObject("hei_prop_hei_securitypanel", 272.25, 214.83, 106.30, false, false, false)
        SetEntityHeading(PanelVault, 249.99)

        local PanelOffice = CreateObject("hei_prop_hei_securitypanel", 271.99, 214.38, 110.20, false, false, false)
        SetEntityHeading(PanelOffice, 249.99)

        table.insert(HeistObjects, PanelVault)
        table.insert(HeistObjects, PanelOffice)
    end)

    for k, v in pairs(Config.Vault.Laptops) do
        exports['fw-ui']:AddEyeEntry("heist-vault-laptop-" .. k, {
            Type = 'Zone',
            SpriteDistance = 5.0,
            Distance = 1.5,
            ZoneData = {
                Center = v.center,
                Length = v.length,
                Width = v.width,
                Data = {
                    heading = v.heading,
                    minZ = v.minZ,
                    maxZ = v.maxZ
                },
            },
            Options = {
                {
                    Name = 'heist_laptop',
                    Icon = 'fas fa-laptop',
                    Label = 'Open',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:Vault:OpenLaptop',
                    EventParams = { Id = k },
                    Enabled = function(Entity)
                        return true
                    end,
                },
            }
        })
    end

    for k, v in pairs(Config.Vault.Loot) do
        exports['fw-ui']:AddEyeEntry("heist-vault-loot-" .. k, {
            Type = 'Zone',
            SpriteDistance = 5.0,
            Distance = 1.5,
            ZoneData = {
                Center = v.Center,
                Length = v.Length,
                Width = v.Width,
                Data = {
                    heading = v.Heading,
                    minZ = v.MinZ,
                    maxZ = v.MaxZ
                },
            },
            Options = {
                {
                    Name = 'rob',
                    Icon = 'fas fa-th',
                    Label = 'Overvallen',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:Vault:Loot',
                    EventParams = { Id = k },
                    Enabled = function(Entity)
                        return true
                    end,
                },
            }
        })
    end

    exports['fw-ui']:AddEyeEntry("heist-vault-panel-vault", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(272.31, 214.81, 106.28),
            Length = 0.6,
            Width = 0.2,
            Data = {
                heading = 340,
                minZ = 106.28,
                maxZ = 106.93
            },
        },
        Options = {
            {
                Name = 'heist_laptop',
                Icon = 'fas fa-laptop',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:HackVaultGate',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-panel-vault-office", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(272.03, 214.36, 110.17),
            Length = 0.6,
            Width = 0.2,
            Data = {
                heading = 340,
                minZ = 110.22,
                maxZ = 110.82
            },
        },
        Options = {
            {
                Name = 'heist_laptop',
                Icon = 'fas fa-project-diagram',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:HackMainOffice',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-panel-lower-right", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(270.52, 221.28, 97.12),
            Length = 0.6,
            Width = 0.2,
            Data = {
                heading = 340,
                minZ = 97.12,
                maxZ = 97.92
            },
        },
        Options = {
            {
                Name = 'heist_laptop',
                Icon = 'fas fa-project-diagram',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:DecryptBottomVault',
                EventParams = { Id = "right" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-panel-lower-left", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(267.59, 213.23, 97.12),
            Length = 0.6,
            Width = 0.2,
            Data = {
                heading = 340,
                minZ = 97.12,
                maxZ = 97.92
            },
        },
        Options = {
            {
                Name = 'heist_laptop',
                Icon = 'fas fa-project-diagram',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:DecryptBottomVault',
                EventParams = { Id = "left" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-grab-keycard", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(258.52, 222.16, 97.11),
            Length = 1.2,
            Width = 0.4,
            Data = {
                heading = 355,
                minZ = 96.11,
                maxZ = 97.01
            },
        },
        Options = {
            {
                Name = 'grab_left',
                Icon = 'fas fa-circle',
                Label = 'Keycard Links Oppaken',
                EventType = 'Server',
                EventName = 'fw-heists:Server:Vault:GrabKeycard',
                EventParams = { Type = 'Left' },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'grab_right',
                Icon = 'fas fa-circle',
                Label = 'Keycard Rechts Oppaken',
                EventType = 'Server',
                EventName = 'fw-heists:Server:Vault:GrabKeycard',
                EventParams = { Type = 'Right' },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-hack-electrical", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.0,
        ZoneData = {
            Center = vector3(260.61, 213.11, 97.12),
            Length = 0.8,
            Width = 0.6,
            Data = {
                heading = 340,
                minZ = 98.27,
                maxZ = 99.52
            },
        },
        Options = {
            {
                Name = 'hack',
                Icon = 'fas fa-keyboard',
                Label = 'Activeren',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:HackEletrical',
                EventParams = { },
                Enabled = function(Entity)
                    return GetEntityCoords(PlayerPedId()).z > 97.6
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-left", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(241.87, 218.69, 97.12),
            Length = 0.6,
            Width = 0.2,
            Data = {
                heading = 250,
                minZ = 97.12,
                maxZ = 97.92
            },
        },
        Options = {
            {
                Name = 'heist_laptop',
                Icon = 'fas fa-project-diagram',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:HackVault',
                EventParams = { DoorId = "PACIFIC_VAULT_SAFE_LEFT", Type = "left" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-right", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(247.32, 233.71, 97.12),
            Length = 0.6,
            Width = 0.2,
            Data = {
                heading = 70,
                minZ = 97.22,
                maxZ = 97.92
            },
        },
        Options = {
            {
                Name = 'heist_laptop',
                Icon = 'fas fa-project-diagram',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:HackVault',
                EventParams = { DoorId = "PACIFIC_VAULT_SAFE_RIGHT", Type = "right" },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-office-safe", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(278.73, 217.53, 110.17),
            Length = 0.25,
            Width = 1.0,
            Data = {
                heading = 340,
                minZ = 109.17,
                maxZ = 110.97
            },
        },
        Options = {
            {
                Name = 'open',
                Icon = 'fas fa-lock-alt',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:CrackSafe',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-office-password", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(279.1, 213.57, 110.17),
            Length = 1.75,
            Width = 0.85,
            Data = {
                heading = 340,
                minZ = 110.02,
                maxZ = 110.22
            },
        },
        Options = {
            {
                Name = 'password',
                Icon = 'fas fa-passport',
                Label = 'Wachtwoord Invoeren',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:EnterPassword',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-big-vault-panel-entry", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(227.86, 228.36, 97.11),
            Length = 0.2,
            Width = 0.5,
            Data = {
                heading = 340,
                minZ = 97.21,
                maxZ = 97.86
            },
        },
        Options = {
            {
                Name = 'hack',
                Icon = 'fas fa-credit-card',
                Label = 'Keycard Gebruiken',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:UseKeycard',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-vault-big-vault-panel", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(236.36, 231.77, 97.11),
            Length = 0.5,
            Width = 0.2,
            Data = {
                heading = 340,
                minZ = 97.21,
                maxZ = 97.86
            },
        },
        Options = {
            {
                Name = 'password',
                Icon = 'fas fa-laptop',
                Label = 'Open',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Vault:HackBigVault',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry(GetHashKey("hei_prop_heist_wooden_box"), {
        Type = 'Model',
        Model = 'hei_prop_heist_wooden_box',
        SpriteDistance = 5.0,
        Distance = 1.5,
        Options = {
            {
                Name = 'grab',
                Icon = 'fas fa-circle',
                Label = 'Oppakken',
                EventType = 'Server',
                EventName = 'fw-heists:Server:Vault:GrabBox',
                EventParams = {},
                Enabled = function(Entity)
                    local IsVaultBox = FW.SendCallback("fw-heists:Server:IsVaultBox", NetworkGetNetworkIdFromEntity(Entity))
                    return IsVaultBox
                end,
            }
        }
    })
end)

AddEventHandler("onResourceStop", function()
    for k, v in pairs(HeistObjects) do
        DeleteEntity(v)
    end

    HeistObjects = {}
end)
