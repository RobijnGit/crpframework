local FoodchainCoords, DeliveryCoords = false, false

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    for k, v in pairs(Config.FoodDelivery.Foodchains) do
        exports['fw-ui']:AddEyeEntry("fooddelivery-restaurant-" .. k, {
            Type = "Zone",
            SpriteDistance = 5.0,
            Distance = 2.5,
            ZoneData = {
                Center = vector3(v.x, v.y, v.z),
                Length = 1.0,
                Width = 1.0,
                Data = {
                    heading = v.w,
                    minZ = v.z - 1.0,
                    maxZ = v.z + 1.5,
                },
            },
            Options = {
                {
                    Name = "grab",
                    Icon = "fas fa-box",
                    Label = "Bestelling Ophalen",
                    EventType = "Client",
                    EventName = "fw-jobmanager:Client:FoodDelivery:PickupOrder",
                    EventParams = {},
                    Enabled = function()
                        if not FoodchainCoords then return false end
                        return #(vector3(v.x, v.y, v.z) - FoodchainCoords) < 5.0
                    end,
                },
            }
        })
    end

    for k, v in pairs(Config.FoodDelivery.Deliveries) do
        exports['fw-ui']:AddEyeEntry("fooddelivery-delivery-" .. k, {
            Type = "Zone",
            SpriteDistance = 5.0,
            Distance = 2.5,
            ZoneData = {
                Center = vector3(v.x, v.y, v.z),
                Length = 1.0,
                Width = 1.0,
                Data = {
                    heading = v.w,
                    minZ = v.z - 1.0,
                    maxZ = v.z + 1.5,
                },
            },
            Options = {
                {
                    Name = "grab",
                    Icon = "fas fa-box",
                    Label = "Bestelling Inleveren",
                    EventType = "Client",
                    EventName = "fw-jobmanager:Client:FoodDelivery:DeliverOrder",
                    EventParams = {},
                    Enabled = function()
                        if not DeliveryCoords then return false end
                        return #(vector3(v.x, v.y, v.z) - DeliveryCoords) < 5.0
                    end,
                },
            }
        })
    end
end)

RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'fooddelivery' then return end

    FoodchainCoords = vector3(Data.Foodchain.x, Data.Foodchain.y, Data.Foodchain.z)
    DeliveryCoords = vector3(Data.House.x, Data.House.y, Data.House.z)

    SetRouteBlip("Pickup", FoodchainCoords)

    if not IsLeader then return end

    Citizen.CreateThread(function()
        while true do
            if #(FoodchainCoords - GetEntityCoords(PlayerPedId())) < 3.0 then
                FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
                break
            end

            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent("fw-jobmanager:Client:FoodDelivery:PickupOrder")
AddEventHandler("fw-jobmanager:Client:FoodDelivery:PickupOrder", function()
    FoodchainCoords = false

    TriggerEvent('fw-emotes:Client:PlayEmote', 'handshake', false, true)
    Citizen.Wait(1200)
    TriggerEvent('fw-emotes:Client:CancelEmote', true)

    TriggerServerEvent("fw-jobmanager:Server:FoodDelivery:CollectOrder")

    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'fooddelivery' then return end

    if TaskId == 3 then
        RemoveRouteBlip()
        SetRouteBlip("Bezorgadres", DeliveryCoords)
    end

    if not IsLeader then return end

    if TaskId == 3 then
        Citizen.CreateThread(function()
            while true do
                if #(DeliveryCoords - GetEntityCoords(PlayerPedId())) < 3.0 then
                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
                    break
                end
    
                Citizen.Wait(1000)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:FoodDelivery:DeliverOrder')
AddEventHandler('fw-jobmanager:Client:FoodDelivery:DeliverOrder', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'fooddelivery' then return end

    local DidRemove = FW.SendCallback("FW:RemoveItem", 'food-box', 1, false, false)
    if not DidRemove then return end

    PlaySoundFrontend(0, "DOOR_BUZZ", "MP_PLAYER_APARTMENT", 1)
    exports['fw-assets']:RequestAnimationDict('mp_doorbell')
    TaskPlayAnim(PlayerPedId(), 'mp_doorbell', 'ring_bell_a', 8.0, 8.0, -1, 0, 0.0, 0, 0, 0)

    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'fooddelivery' then return end
    RemoveRouteBlip()
    FoodchainCoords, DeliveryCoords = false, false
end)