RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if #(GetEntityCoords(PlayerPedId()) - vector3(-596.25, -283.85, 50.32)) <= 1.5 then
        if DataManager.Get(GetJewelryPrefix() .. "powerbox", 0) == 1 then
            return FW.Functions.Notify("Ziet er verbrand uit..", "error")
        end
    
        if DataManager.Get("HeistsDisabled", 0) == 1 then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if CurrentCops < Config.RequiredCopsJewelry or DataManager.Get("GlobalCooldown", false) == true then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end
    
        TriggerServerEvent('fw-inventory:Server:DecayItem', 'heavy-thermite', nil, 25.0)
        local Outcome = DoThermite(6, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.3, 0))
        if Outcome then
            local DidRemove = FW.SendCallback("FW:RemoveItem", "heavy-thermite", 1)
            if not DidRemove then return end
    
            DataManager.Set(GetJewelryPrefix() .. "powerbox", 1)
            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'JEWELRY_DOOR_LEFT', 0)
            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'JEWELRY_DOOR_RIGHT', 0)
    
            TriggerServerEvent("fw-mdw:Server:SendAlert:JewelryAlarm", GetEntityCoords(PlayerPedId()))
            FW.TriggerServer("fw-heists:Server:Jewelry:Reset")

            StartCoordsChecker(vector3(-630.5, -237.13, 38.08), 100.0, function()
                FW.TriggerServer("fw-heists:Server:Jewelry:LeftArea")
            end)
        end
    end
end)

RegisterNetEvent("fw-heists:Client:Jewelry:HackSecurity")
AddEventHandler("fw-heists:Client:Jewelry:HackSecurity", function()
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    if DataManager.Get(GetJewelryPrefix() .. "powerbox", 0) ~= 1 then return end
    if DataManager.Get(GetJewelryPrefix() .. "sec-system", 0) == 1 then return end

    local Success = exports['fw-ui']:StartUntangle({
        Dots = 12,
        Timeout = 30000,
    })

    if Success then
        DataManager.Set(GetJewelryPrefix() .. "sec-system", 1)
    end
end)

RegisterNetEvent('fw-heists:Client:Jewelry:SmashVitrine', function(Data)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end
    if DataManager.Get(GetJewelryPrefix() .. "powerbox", 0) ~= 1 then return end

    if not Config.Jewelry.Weapons[GetSelectedPedWeapon(PlayerPedId())] then
        return FW.Functions.Notify("Met dit wapen ga je het niet redden..", "error")
    end

    if DataManager.Get(GetJewelryPrefix() .. "vitrine-" .. Data.VitrineId, 0) ~= 0 then
        return FW.Functions.Notify("Vitrinekast is al ingeslagen..", "error")
    end

    DataManager.Set(GetJewelryPrefix() .. "vitrine-" .. Data.VitrineId, 1)
    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Smashing = true
    FW.Functions.Progressbar("smash_vitrine", "Juwelen jatten..", 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function()
        Smashing = false
        DataManager.Set(GetJewelryPrefix() .. "vitrine-" .. Data.VitrineId, 2)
        FW.TriggerServer('fw-heists:Server:Jewelry:Reward', Data.VitrineId)
    end, function()
        DataManager.Set(GetJewelryPrefix() .. "vitrine-" .. Data.VitrineId, 0)
    end)

    while Smashing do
        exports['fw-assets']:RequestAnimationDict("missheist_jewel")
        TaskPlayAnim(PlayerPedId(), "missheist_jewel", "smash_case", 3.0, 3.0, -1, 2, 0, 0, 0, 0 )
        Citizen.Wait(500)
        TriggerEvent('fw-misc:Client:PlaySoundCoords', 'heists.glassSmash', GetEntityCoords(PlayerPedId()), 55.0, true)
        TriggerServerEvent('fw-ui:Server:gain:stress', 1)
        Citizen.Wait(3000)
    end
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("jewelry_sec_system", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-631.07, -230.61, 38.06),
            Length = 0.2,
            Width = 0.6,
            Data = {
                heading = 41,
                minZ = 37.86,
                maxZ = 38.16
            }
        },
        Options = {
            {
                Name = 'hack',
                Icon = 'fas fa-project-diagram',
                Label = 'Hacken',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:HackSecurity',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-heists']:IsJewelryRobbed()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_1", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-625.78, -238.71, 38.06),
            Length = 2.2,
            Width = 1,
            Data = {
                heading = 305,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 1 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_2", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-626.55, -234.64, 38.06),
            Length = 2.2,
            Width = 0.6,
            Data = {
                heading = 306,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 2 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_3", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-627.18, -233.87, 38.06),
            Length = 2.2,
            Width = 0.6,
            Data = {
                heading = 306,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 3 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_4", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-619.33, -234.53, 38.06),
            Length = 2.2,
            Width = 0.6,
            Data = {
                heading = 306,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 4 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_5", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-617.42, -229.71, 38.06),
            Length = 2.2,
            Width = 0.6,
            Data = {
                heading = 216,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 5 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_6", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-619.54, -226.82, 38.06),
            Length = 2.2,
            Width = 0.6,
            Data = {
                heading = 216,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 6 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_7", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-624.72, -227.0, 38.06),
            Length = 2.2,
            Width = 0.6,
            Data = {
                heading = 126,
                minZ = 37.66,
                maxZ = 38.46
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 7 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_8", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-620.47, -232.97, 38.06),
            Length = 1.4,
            Width = 0.6,
            Data = {
                heading = 126,
                minZ = 37.66,
                maxZ = 38.66
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 8 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_9", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-620.11, -230.74, 38.06),
            Length = 1.4,
            Width = 0.6,
            Data = {
                heading = 36,
                minZ = 37.66,
                maxZ = 38.66
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 9 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_10", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-621.47, -229.05, 38.06),
            Length = 1.4,
            Width = 0.6,
            Data = {
                heading = 36,
                minZ = 37.66,
                maxZ = 38.66
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 10 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_11", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-623.62, -228.63, 38.06),
            Length = 1.4,
            Width = 0.6,
            Data = {
                heading = 306,
                minZ = 37.66,
                maxZ = 38.66
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 11 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_12", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-624.04, -230.82, 38.06),
            Length = 1.4,
            Width = 0.6,
            Data = {
                heading = 216,
                minZ = 37.66,
                maxZ = 38.66
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 12 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
    exports['fw-ui']:AddEyeEntry("jewelry_vitrine_13", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.2,
        ZoneData = {
            Center = vector3(-622.53, -232.86, 38.06),
            Length = 1.4,
            Width = 0.6,
            Data = {
                heading = 216,
                minZ = 37.66,
                maxZ = 38.66
            }
        },
        Options = {
            {
                Name = 'smash_jewelry_vitrine',
                Icon = 'fas fa-circle',
                Label = 'Slaan!',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Jewelry:SmashVitrine',
                EventParams = { VitrineId = 13 },
                Enabled = function(Entity)
                    return exports['fw-heists']:CanSmashVitrine()
                end,
            }
        }
    })
end)

exports("IsJewelryRobbed", function()
    return DataManager.Get(GetJewelryPrefix() .. "powerbox", 0)
end)

exports("CanSmashVitrine", function()
    return DataManager.Get(GetJewelryPrefix() .. "powerbox", 0) == 1 and DataManager.Get(GetJewelryPrefix() .. "sec-system", 0) == 1
end)