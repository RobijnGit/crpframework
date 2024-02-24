Citizen.CreateThread(function()
    local InteriorId = GetInteriorAtCoords(-257.04330444336,216.21157836914,91.889678955078)

    DeactivateInteriorEntitySet(InteriorId, "jeu1")
    DeactivateInteriorEntitySet(InteriorId, "jeu2")
    DeactivateInteriorEntitySet(InteriorId, "jeu3")
    DeactivateInteriorEntitySet(InteriorId, "jeu4")
    DeactivateInteriorEntitySet(InteriorId, "jeu5")
    DeactivateInteriorEntitySet(InteriorId, "jeu6")
    DeactivateInteriorEntitySet(InteriorId, "jeu7")
    DeactivateInteriorEntitySet(InteriorId, "jeu8")
    DeactivateInteriorEntitySet(InteriorId, "jeu9")
    DeactivateInteriorEntitySet(InteriorId, "jeu10")

    ActivateInteriorEntitySet(InteriorId, "jeu1")
    RefreshInterior(InteriorId)

    exports['fw-ui']:AddEyeEntry("bin-sceneswitch", {
        Type = 'Zone',
        SpriteDistance = 5.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(-248.55, 212.86, 92.09),
            Length = 0.85,
            Width = 0.4,
            Data = {
                heading = 0,
                minZ = 91.89,
                maxZ = 92.14
            },
        },
        Options = {
            {
                Name = 'changeEntitySet',
                Icon = 'fas fa-circle',
                Label = 'Decor aanpassen',
                EventType = 'Client',
                EventName = 'fw-misc:Client:EditBinDecor',
                EventParams = { ContainerId = k },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
end)

RegisterNetEvent("fw-misc:Client:SetBinDecor")
AddEventHandler("fw-misc:Client:SetBinDecor", function(DecorId)
    local InteriorId = GetInteriorAtCoords(-257.04330444336,216.21157836914,91.889678955078)

    for i = 1, 10, 1 do
        DeactivateInteriorEntitySet(InteriorId, "jeu" .. i)
    end

    ActivateInteriorEntitySet(InteriorId, DecorId)
    RefreshInterior(InteriorId)
end)

RegisterNetEvent("fw-misc:Client:EditBinDecor")
AddEventHandler("fw-misc:Client:EditBinDecor", function()
    FW.Functions.OpenMenu({
        MainMenuItems = {
            {
                Title = "Decor Aanpassen",
                Icon = "home-alt"
            },
            {
                Title = "Talk Show",
                Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu1" }
            },
            {
                Title = "Quiz Time",
                Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu2" }
            },
            {
                Title = "Standup",
                Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu3" }
            },
            -- {
            --     Title = "Los Santos Announcement",
            --     Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu4" }
            -- },
            {
                Title = "Live Music",
                Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu5" }
            },
            {
                Title = "News",
                Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu6" }
            },
            -- {
            --     Title = "Leeg",
            --     Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu7" }
            -- },
            -- {
            --     Title = "Leeg",
            --     Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu8" }
            -- },
            -- {
            --     Title = "Leeg",
            --     Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu9" }
            -- },
            -- {
            --     Title = "Leeg",
            --     Data = { Event = "fw-misc:Server:SetBinDecor", DecorId = "jeu10" }
            -- },
        }
    })
end)