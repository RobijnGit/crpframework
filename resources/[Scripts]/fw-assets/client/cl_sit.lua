local SittingInChair, GoingUp, PrevCoords = false, false, vector3(0, 0, 0)

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and SittingInChair then
            if IsControlJustReleased(0, 73) then
                TriggerEvent('fw-animations:Client:Clear:Chair')
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-animations:Client:Sit:Chair')
AddEventHandler('fw-animations:Client:Sit:Chair', function(Data, Entity)
    if SittingInChair then return end
        local EntityCoords, Offset = GetEntityCoords(Entity), Config.Chairs[Data.Id].ZOffset
        PrevCoords, SittingInChair = GetEntityCoords(PlayerPedId()), true
        TaskStartScenarioAtPosition(PlayerPedId(), 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', EntityCoords.x, EntityCoords.y, EntityCoords.z + Offset, GetEntityHeading(Entity) + 180.0, 0, true, true)
end)

RegisterNetEvent('fw-animations:Client:Clear:Chair')
AddEventHandler('fw-animations:Client:Clear:Chair', function()
    if not SittingInChair or GoingUp then return end
    GoingUp = true
    ClearPedTasks(PlayerPedId())
    Citizen.SetTimeout(850, function()
        SetEntityCoords(PlayerPedId(), PrevCoords.x, PrevCoords.y, PrevCoords.z - 0.5)
        PrevCoords, GoingUp, SittingInChair = vector3(0, 0, 0), false, false
    end)
end)

RegisterNetEvent('fw-animations:Client:Reset:Chair')
AddEventHandler('fw-animations:Client:Reset:Chair', function()
    PrevCoords, GoingUp, SittingInChair = vector3(0, 0, 0), false, false
end)

-- // Functions \\ --

function InitChairs()
    Citizen.CreateThread(function()

        for k, v in pairs(Config.Chairs) do
            exports['fw-ui']:AddEyeEntry(GetHashKey(v.Model), {
                Type = 'Model',
                Model = v.Model,
                SpriteDistance = 1.7,
                Options = {
                    {
                        Name = 'chair_sit',
                        Icon = 'fas fa-chair',
                        Label = 'Zit',
                        EventType = 'Client',
                        EventName = 'fw-animations:Client:Sit:Chair',
                        EventParams = {Type = 'Entity', Id = k},
                        Enabled = function(Entity)
                            return true
                        end,
                    }
                }
            })
        end
        
    end)
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", InitChairs)