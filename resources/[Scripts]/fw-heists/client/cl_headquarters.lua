local InsideHeadquarters = false
local NightclubCoords = vector4(-1618.43, -2999.34, -78.15, 3.31)

RegisterNetEvent("fw-heists:Client:HQ:UseElevator")
AddEventHandler("fw-heists:Client:HQ:UseElevator", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name == 'police' then
        return FW.Functions.Notify("Lijkt erop alsof deze lift kapot is..", "error")
    end

    if Data.Leave then
        local Finished = FW.Functions.CompactProgressbar(3500, "Wachten op lift...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_hang_out_street@female_hold_arm@idle_a", anim = "idle_a", flags = 8, }, {}, {}, false)
        StopAnimTask(PlayerPedId(),  "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)

        local Coords = FW.SendCallback("fw-heists:Server:GetPedCoords", "HeistHeadquartersPed")

        if not Finished then
            return
        end

        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do Citizen.Wait(10) end

        SetEntityCoords(PlayerPedId(), Coords.x, Coords.y, Coords.z)
        SetEntityHeading(PlayerPedId(), 89.74)

        SetGameplayCamRelativeHeading(0.0)
        RequestCollisionAtCoord(Coords.x, Coords.y, Coords.z)
        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            SetEntityCoords(PlayerPedId(), Coords.x, Coords.y, Coords.z)
            Citizen.Wait(100)
        end

        InsideHeadquarters = false
        DoScreenFadeIn(500)

        return
    end

    local Result = FW.SendCallback("fw-heists:Server:GetLevelProgression")
    local ContextItems = {}

    for i = 1, Result.MaxLevels, 1 do
        ContextItems[i] = {
            Title = 'Level ' .. i,
            Disabled = i > Result.CurrentLevel,
            Data = { Event = 'fw-heists:Client:EnterHeadquarters', Level = i },
        }
    end

    FW.Functions.OpenMenu({ MainMenuItems = ContextItems })
end)

RegisterNetEvent("fw-heists:Client:EnterHeadquarters")
AddEventHandler("fw-heists:Client:EnterHeadquarters", function(Data)
    local Result = FW.SendCallback("fw-heists:Server:GetLevelProgression")
    if Data.Level > Result.CurrentLevel then
        return FW.Functions.Notify("Je hebt deze level nog niet geunlocked..", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(3500, "Wachten op lift...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "amb@world_human_hang_out_street@female_hold_arm@idle_a", anim = "idle_a", flags = 8, }, {}, {}, false)
    StopAnimTask(PlayerPedId(),  "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)

    if not Finished then
        return
    end

    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Citizen.Wait(10) end

    SetEntityCoords(PlayerPedId(), NightclubCoords)
    SetEntityHeading(PlayerPedId(), NightclubCoords.w)

    SetGameplayCamRelativeHeading(0.0)
    RequestCollisionAtCoord(NightclubCoords.x, NightclubCoords.y, NightclubCoords.z)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        SetEntityCoords(PlayerPedId(), NightclubCoords.x + 0.0, NightclubCoords.y + 0.0, NightclubCoords.z + 0.0)
        Citizen.Wait(100)
    end

    InsideHeadquarters = true
    DoScreenFadeIn(500)
end)

RegisterNetEvent("fw-heists:Client:HQ:CryptoShop")
AddEventHandler("fw-heists:Client:HQ:CryptoShop", function()
    local Result = FW.SendCallback("fw-heists:Server:GetLevelItems")

    local ContextItems = {
        {
            Title = "Crypto Shop",
            CloseMenu = false,
        }
    }

    for k, v in pairs(Result) do
        table.insert(ContextItems,  {
            Icon = v.Icon,
            Title = "<div style='display: flex; justify-content: space-between;'><span>" .. v.Title .. "</span><span>▨ " .. v.Crypto .. "</span></div>",
            Data = { Event = 'fw-heists:Server:PurchaseCryptoshop', Item = v.Item, Crypto = v.Crypto },
        })
    end

    FW.Functions.OpenMenu({ MainMenuItems = ContextItems })
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    local HeistHeadquarters = FW.SendCallback("fw-heists:Server:GetPedCoords", "HeistHeadquarters")
    exports['fw-ui']:AddEyeEntry("heists_headquarters_enter", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = HeistHeadquarters,
            Length = 2.4,
            Width = 0.55,
            Data = {
                heading = 0,
                minZ = 35.64,
                maxZ = 37.99
            },
        },
        Options = {
            {
                Name = 'elevator',
                Icon = 'fas fa-sort',
                Label = 'Lift',
                EventType = 'Client',
                EventName = 'fw-heists:Client:HQ:UseElevator',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("heists_headquarters_leave", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = vector3(-1618.55, -2999.78, -78.15),
            Length = 2.8,
            Width = 0.6,
            Data = {
                heading = 270,
                minZ = -79.15,
                maxZ = -76.75
            },
        },
        Options = {
            {
                Name = 'elevator',
                Icon = 'fas fa-sort',
                Label = 'Lift',
                EventType = 'Client',
                EventName = 'fw-heists:Client:HQ:UseElevator',
                EventParams = { Leave = true },
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("heists_headquarters_trade_usbs", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = vector3(-1620.14, -3010.46, -75.21),
            Length = 0.8,
            Width = 0.6,
            Data = {
                heading = 318,
                minZ = -75.41,
                maxZ = -74.86,
            },
        },
        Options = {
            {
                Name = 'loot',
                Icon = 'fas fa-plug',
                Label = 'USBs Inleveren',
                EventType = 'Server',
                EventName = 'fw-heists:Server:TradeUSBs',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("heists_headquarters_trade_loot", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Position = vector4(-1634.17, -2996.86, -79.14, 235.42),
        Model = 'mp_m_weapwork_01',
        Anim = {
            Dict = "move_m@clipboard",
            Name = "idle",
            Flag = 49,
        },
        Props = {
            {
                Prop = 'p_amb_clipboard_01',
                Bone = 60309,
                Placement = { -0.01, -0.015, 0.005, 0.0, 0.0, -10.0 },
            },
        },
        Options = {
            {
                Name = 'loot',
                Icon = 'fas fa-donate',
                Label = 'Loot Inleveren',
                EventType = 'Server',
                EventName = 'fw-heists:Server:TradeLoot',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("heists_headquarters_crypto_shop", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Position = vector4(-1617.3, -3013.21, -76.21, 74.93),
        Model = 'mp_m_execpa_01',
        Anim = {
            Dict = "amb@world_human_stand_guard@male@idle_a",
            Name = "idle_a",
            Flag = 1,
        },
        Options = {
            {
                Name = 'loot',
                Icon = 'fas fa-comment',
                Label = 'Praten',
                EventType = 'Client',
                EventName = 'fw-heists:Client:HQ:CryptoShop',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })
end)
