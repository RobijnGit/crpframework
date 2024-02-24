RegisterNetEvent("fw-police:Client:Used:Spikestrip")
AddEventHandler("fw-police:Client:Used:Spikestrip", function()
    if IsPedInAnyVehicle(PlayerPedId()) then
        return
    end

    local Finished = FW.Functions.CompactProgressbar(500, "Spijkermat plaatsen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", anim = "plant_floor", flags = 49 }, {}, {}, false)
    if not Finished then return end

    local DidRemove = FW.SendCallback("FW:RemoveItem", 'spikestrip', 1)
    if not DidRemove then
        return FW.Functions.Notify("Welke spijkermatten wou je plaatsen dan?", "error")
    end

    local SpikeData = {
        Heading = GetEntityHeading(PlayerPedId()),
        Coords = {}
    }

    for i = 1, 3 do
        SpikeData.Coords[#SpikeData.Coords + 1] = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -1.5 + (3.5 * i), 0.15)
    end

    FW.TriggerServer('fw-police:Server:PlaceSpikestrip', SpikeData)
end)

RegisterNetEvent("fw-police:Client:PlaceSpikestrips")
AddEventHandler("fw-police:Client:PlaceSpikestrips", function(Data)
    local SpikeModel = GetHashKey('p_ld_stinger_s')
	exports['fw-assets']:RequestModelHash(SpikeModel)

    for k, v in pairs(Data.Coords) do
        local SpikeObj = CreateObject(SpikeModel, v.x, v.y, v.z, false, true, true)
        PlaceObjectOnGroundProperly(SpikeObj)
        SetEntityHeading(SpikeObj, Data.Heading)
        FreezeEntityPosition(SpikeObj, true)

        SpikesChecker(SpikeObj, v)
    end
end)

function SpikesChecker(Entity, Coords)
    Citizen.CreateThread(function()
        local SpikeModel, SpikeTimer = GetHashKey('p_ld_stinger_s'), 0
        while SpikeTimer < 500 do
            local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            local DriverPed = GetPedInVehicleSeat(Vehicle, -1)
            SpikeTimer = SpikeTimer + 1
            Citizen.Wait(1)	
    
            if DriverPed then
                local DimensionOne, DimensionTwo = GetModelDimensions(GetEntityModel(Vehicle))
                local LeftFront = GetOffsetFromEntityInWorldCoords(Vehicle, DimensionOne.x - 0.25, 0.25, 0.0)
                local RightFront = GetOffsetFromEntityInWorldCoords(Vehicle, DimensionTwo.x + 0.25,0.25,0.0)
                local LeftBack = GetOffsetFromEntityInWorldCoords(Vehicle, DimensionOne.x - 0.25,-0.85,0.0)
                local RightBack = GetOffsetFromEntityInWorldCoords(Vehicle, DimensionTwo.x + 0.25,-0.85,0.0)
    
                if #(Coords - LeftFront) < 1.5 and not IsVehicleTyreBurst(Vehicle, 0, true) then
                    if IsEntityTouchingEntity(Vehicle, GetClosestObjectOfType(Coords.x, Coords.y, Coords.z, 5.0, SpikeModel, 0, 0, 0)) then
                        FW.VSync.SetVehicleTyreBurst(Vehicle, 0, true, 1000.0)
                    end
                end
    
                if #(Coords - RightFront) < 1.5 and not IsVehicleTyreBurst(Vehicle, 1, true) then
                    if IsEntityTouchingEntity(Vehicle, GetClosestObjectOfType(Coords.x, Coords.y, Coords.z, 5.0, SpikeModel, 0, 0, 0)) then
                        FW.VSync.SetVehicleTyreBurst(Vehicle, 1, true, 1000.0)
                    end
                end
    
                if #(Coords - LeftBack) < 1.5 and not IsVehicleTyreBurst(Vehicle, 4, true) then
                    if IsEntityTouchingEntity(Vehicle, GetClosestObjectOfType(Coords.x, Coords.y, Coords.z, 5.0, SpikeModel, 0, 0, 0)) then
                        FW.VSync.SetVehicleTyreBurst(Vehicle, 2, true, 1000.0)
                        FW.VSync.SetVehicleTyreBurst(Vehicle, 4, true, 1000.0)	
                    end
                end
    
                if #(Coords - RightBack) < 1.5 and not IsVehicleTyreBurst(Vehicle,5,true) then
                    if IsEntityTouchingEntity(Vehicle, GetClosestObjectOfType(Coords.x, Coords.y, Coords.z, 5.0, SpikeModel, 0, 0, 0)) then
                        FW.VSync.SetVehicleTyreBurst(Vehicle, 3, true, 1000.0)
                        FW.VSync.SetVehicleTyreBurst(Vehicle, 5, true, 1000.0)	
                    end
                end
            end
        end
    
        DeleteEntity(Entity)
    end)
end