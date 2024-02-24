FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1000, function()
        LoggedIn = true
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code
RegisterNetEvent("fw-island:Client:CheckFlights")
AddEventHandler("fw-island:Client:CheckFlights", function()
    local MenuItems = {
        {
            Icon = 'exclamation-circle',
            Title = "Actuele Beschikbare Vluchten",
            Desc = "",
            Data = { Event = '', Type = ''},
            CloseMenu = false,
        }
    }

    if #(GetEntityCoords(PlayerPedId()) - vector3(-1042.03, -2509.25, 12.94)) < 3.0 then
        MenuItems[#MenuItems + 1] = {
            Icon = 'plane',
            Title = "Los Santos -> Cayo Perico",
            Desc = "Vliegticket prijs: (€5.000)",
            Data = { Event = 'fw-island:Client:PurchaseFlight', Type = 'Client', Flight = "lsia_to_cayo", Label = "Los Santos -> Cayo Perico" },
            Disabled = not FW.SendCallback("fw-island:Server:IsFlightAvailable", "lsia_to_cayo")
        }
    elseif #(GetEntityCoords(PlayerPedId()) - vector3(4438.89, -4451.31, 4.33)) < 3.0 then
        MenuItems[#MenuItems + 1] = {
            Icon = 'plane',
            Title = "Cayo Perico -> Los Santos",
            Desc = "Vliegticket prijs: (€5.000)",
            Data = { Event = 'fw-island:Client:PurchaseFlight', Type = 'Client', Flight = "cayo_to_lsia", Label = "Cayo Perico -> Los Santos" },
            Disabled = not FW.SendCallback("fw-island:Server:IsFlightAvailable", "lsia_to_cayo")
        }
    end

    Citizen.SetTimeout(450, function()
        FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
    end)
end)

RegisterNetEvent("fw-island:Client:PurchaseFlight")
AddEventHandler("fw-island:Client:PurchaseFlight", function(Data)
    local MenuItems = {
        {
            Icon = 'exclamation-circle',
            Title = "Vluchtticket Aankoop",
            Desc = Data.Label,
            Data = { Event = '', Type = ''},
            CloseMenu = false,
        }
    }

    MenuItems[#MenuItems + 1] = {
        Icon = 'check-square',
        Title = "Aankoop Bevestigen (€5.000)",
        Data = { Event = 'fw-island:Server:BookFlight', Type = 'Server', Flight = Data.Flight },
    }

    MenuItems[#MenuItems + 1] = {
        Icon = 'times-square',
        Title = "Aankoop Annuleren",
        CloseMenu = true,
    }

    Citizen.SetTimeout(450, function()
        FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
    end)
end)


RegisterNetEvent("fw-island:Client:SpawnFlight")
AddEventHandler("fw-island:Client:SpawnFlight", function(Flight)
    DoScreenFadeOut(1000)

    Citizen.Wait(5000)

    if Flight == "lsia_to_cayo" then
        ToggleIsland(true)
        RequestCollisionAtCoord(-2392.838, -2427.619, 43.1663)
        LoadCutscene('hs4_nimb_lsa_isd_repeat', 1, 24)
        BeginCutsceneWithPlayer()

        Citizen.Wait(6000)
        DoScreenFadeOut(250)
        Citizen.Wait(1000)
        SetEntityCoords(PlayerPedId(), 4439.85, -4453.53, 4.33)
        Citizen.Wait(800)
        DoScreenFadeIn(250)
    elseif Flight == "cayo_to_lsia" then
        ToggleIsland(false)
        RequestCollisionAtCoord(-1652.79, -3117.5, 13.98)
        LoadCutscene('hs4_lsa_land_nimb', 1, 24)
        BeginCutsceneWithPlayer()
        RemoveCutscene()
        Citizen.Wait(9000)
        DoScreenFadeOut(250)
        Citizen.Wait(1000)
        SetEntityCoords(PlayerPedId(), -1090.87, -2595.41, 12.83)
        Citizen.Wait(500)
        DoScreenFadeIn(250)
    end
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("lsia-pilot-to-cayo", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.75,
        Position = vector4(-1042.03, -2509.25, 12.94, 242.28),
        Model = 's_m_m_pilot_01',
        Scenario = "WORLD_HUMAN_CLIPBOARD",
        Options = {
            {
                Name = "check_flights",
                Icon = "fas fa-plane-departure",
                Label = "Vluchten Bekijken",
                EventType = "Client",
                EventName = "fw-island:Client:CheckFlights",
                EventParams = {},
                Enabled = function()
                    return true
                end,
            },
            {
                Name = "toggle_flights",
                Icon = "fas fa-plane",
                Label = "Vluchten in-/uitschakelen van LSIA -> Cayo",
                EventType = "Server",
                EventName = "fw-island:Server:ToggleFlight",
                EventParams = { Flight = "lsia_to_cayo" },
                Enabled = function()
                    return false
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry("lsia-pilot-to-lsia", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.75,
        Position = vector4(4438.89, -4451.31, 3.33, 200.88),
        Model = 's_m_m_pilot_01',
        Scenario = "WORLD_HUMAN_CLIPBOARD",
        Options = {
            {
                Name = "check_flights",
                Icon = "fas fa-plane-departure",
                Label = "Vluchten Bekijken",
                EventType = "Client",
                EventName = "fw-island:Client:CheckFlights",
                EventParams = {},
                Enabled = function()
                    return true
                end,
            },
            {
                Name = "toggle_flights",
                Icon = "fas fa-plane",
                Label = "Vluchten in-/uitschakelen van LSIA -> Cayo",
                EventType = "Server",
                EventName = "fw-island:Server:ToggleFlight",
                EventParams = { Flight = "lsia_to_cayo" },
                Enabled = function()
                    return false
                end,
            },
        }
    })
end)