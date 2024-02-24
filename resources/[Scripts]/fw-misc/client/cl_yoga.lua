local DoingYoga = false

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    for k, PropName in pairs(Config.YogaProps) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(PropName), {
            Type = 'Model',
            Model = PropName,
            SpriteDistance = 10.0,
            Distance = 2.0,
            Options = {
                {
                    Name = 'yoga',
                    Icon = 'fas fa-circle',
                    Label = 'Yoga',
                    EventType = 'Client',
                    EventName = 'fw-interactions:client:yoga',
                    EventParams = {},
                    Enabled = function()
                        return true
                    end,
                },
            }
        })
    end
end)

RegisterNetEvent('fw-interactions:client:yoga')
AddEventHandler('fw-interactions:client:yoga', function(Data, Entity)
    if DoingYoga then return end

    local EntityCoords = GetEntityCoords(Entity)
    local Heading = GetEntityHeading(Entity)
    TaskStartScenarioAtPosition(PlayerPedId(), "WORLD_HUMAN_YOGA", EntityCoords.x, EntityCoords.y, EntityCoords.z, (Heading + 90.0), 25000, false, true)

    DoingYoga = true

    Citizen.CreateThread(function()
        while DoingYoga do
            TriggerServerEvent('fw-ui:Server:remove:stress', math.random(1, 5))
            Citizen.Wait(5000)
        end
    end)

    FW.Functions.Progressbar("yoga", "Adem in..", 25000, false, true, {
        disableMovement = true,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        DoingYoga = false
        ClearPedTasks(PlayerPedId())
    end, function()
        DoingYoga = false
        FW.Functions.Notify("Geannuleerd..", "error")
        ClearPedTasks(PlayerPedId())
    end, true)
end)