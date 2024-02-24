FW, LoggedIn = exports['fw-core']:GetCoreObject(), false
local ShowMenu, MAX_MENU_ITEMS = false, 8

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function()
        LoggedIn = true
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

Citizen.CreateThread(function()
    FW.AddKeybind("radialMenu", "Algemeen", "Radial Menu", "F1", function(IsPressed)
        if not IsPressed or ShowMenu then return end

        ShowMenu = true
        SetNuiFocus(true, true)

        Config.HasHandCuffs = exports['fw-inventory']:HasEnoughOfItem('handcuffs', 1)

        local EnabledMenus = {}
        for _, menuConfig in ipairs(Config.Menu) do
            if menuConfig:Enabled() then
                local DataElements = {}
                local HasSubMenu = false
                if menuConfig.SubMenus ~= nil and #menuConfig.SubMenus > 0 then
                    HasSubMenu = true
                    local PreviousMenu = DataElements
                    local CurrentElement = {}
                    for i = 1, #menuConfig.SubMenus do
                        local SubMenu = Config.SubMenus[menuConfig.SubMenus[i]]
                        if SubMenu.Enabled == nil or SubMenu:Enabled() then
                            CurrentElement[#CurrentElement+1] = SubMenu
                            CurrentElement[#CurrentElement].Id = menuConfig.SubMenus[i]
                            CurrentElement[#CurrentElement].Enabled = nil
                            if i % MAX_MENU_ITEMS == 0 and i < (#menuConfig.SubMenus - 1) then
                                PreviousMenu[MAX_MENU_ITEMS + 1] = {
                                    Id = "_more",
                                    Title = "Meer",
                                    Icon = "#more",
                                    Items = CurrentElement
                                }
                                PreviousMenu = CurrentElement
                                CurrentElement = {}
                            end
                        end
                    end
                    if #CurrentElement > 0 then
                        PreviousMenu[MAX_MENU_ITEMS + 1] = {
                            Id = "_more",
                            Title = "Meer",
                            Icon = "#more",
                            Items = CurrentElement
                        }
                    end
                    DataElements = DataElements[MAX_MENU_ITEMS + 1].Items
                end
                EnabledMenus[#EnabledMenus+1] = {
                    Id = menuConfig.Id,
                    Title = menuConfig.Title,
                    Close = menuConfig.Close,
                    Type = menuConfig.Type,
                    Parameters = menuConfig.Parameters,
                    Event = menuConfig.Event,
                    Icon = menuConfig.Icon,
                }
                if HasSubMenu then
                    EnabledMenus[#EnabledMenus].Items = DataElements
                end
            end
        end

        SendNUIMessage({
            state = "show",
            data = EnabledMenus,
            menuKeyBind = 'F1'
        })

        SetCursorLocation(0.5, 0.5)
        SetNuiFocus(true, true)
        PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
    end)
end)

RegisterNetEvent('fw-menu:client:force:close')
AddEventHandler('fw-menu:client:force:close', function()
    Config.HasHandCuffs = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    SetTimeout(150, function() ShowMenu = false end)

end)

RegisterNUICallback('closemenu', function(data, cb)
    Config.HasHandCuffs = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    SetTimeout(150, function() ShowMenu = false end)

    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
    cb('ok')
end)

RegisterNUICallback('triggerAction', function(data, cb)
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)
    if string.find(data.Action:lower(), ":server:") then
        TriggerServerEvent(data.Action, data.Parameters)
    else
        TriggerEvent(data.Action, data.Parameters)
    end
    cb('ok')
end)