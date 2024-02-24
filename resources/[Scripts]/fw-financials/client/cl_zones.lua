RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['PolyZone']:CreateBox(Config.Zones, {
        name = "banking_zone",
        IsMultiple = true,
    }, function(IsInside, Zone, Points)
        NearBank = IsInside
        if not NearBank then return end

        Citizen.CreateThread(function()
            exports['fw-ui']:ShowInteraction("[E] Bank")

            while NearBank do
                if IsControlJustPressed(0, 38) then
                    exports['fw-ui']:HideInteraction()
                    TriggerEvent('fw-financials:Client:OpenFinancial', true)
                end

                Citizen.Wait(4)
            end
            
            exports['fw-ui']:HideInteraction()
        end)
    end)

    exports['fw-ui']:AddEyeEntry(GetHashKey("prop_fleeca_atm"), {
        Type = 'Model',
        Model = 'prop_fleeca_atm',
        SpriteDistance = 1.0,
        Options = {
            {
                Name = 'open_atm',
                Icon = 'fas fa-dollar-sign',
                Label = 'Pin Automaat',
                EventType = 'Client',
                EventName = 'fw-financials:Client:OpenFinancial',
                EventParams = false,
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'rob',
                Icon = 'fas fa-cog',
                Label = 'Koppel aan Pin Automaat',
                EventType = 'Client',
                EventName = 'fw-heists:Client:AttachATM',
                EventParams = {},
                Enabled = function(Entity)
                    return exports['fw-heists']:GetAttachingRope()
                end,
            }
        }
    })

    for i = 1, 3 do
        exports['fw-ui']:AddEyeEntry(GetHashKey("prop_atm_0"..i), {
            Type = 'Model',
            Model = 'prop_atm_0'..i,
            SpriteDistance = 1.5,
            Options = {
                {
                    Name = 'open_atm',
                    Icon = 'fas fa-dollar-sign',
                    Label = 'Pin Automaat',
                    EventType = 'Client',
                    EventName = 'fw-financials:Client:OpenFinancial',
                    EventParams = false,
                    Enabled = function(Entity)
                        return true
                    end,
                },
                {
                    Name = 'rob',
                    Icon = 'fas fa-cog',
                    Label = 'Koppel Sleeptouw aan Pin Automaat',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:AttachATM',
                    EventParams = {},
                    Enabled = function(Entity)
                        return i > 1 and exports['fw-heists']:GetAttachingRope()
                    end,
                }
            }
        })
    end
end)