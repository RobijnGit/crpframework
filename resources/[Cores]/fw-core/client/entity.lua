local IsPlacing, PlacingObject = false, nil

function CreateEntity(Model, Coords, Networked)
    exports['fw-assets']:RequestModelHash(GetHashKey(Model))
    return CreateObject(GetHashKey(Model), Coords, Networked ~= nil and Networked or false, false, false)
end
exports('CreateEntity', CreateEntity)

function DeleteEntityPlacer(Entity)
    if NetworkHasControlOfEntity(Entity) then
        SetEntityDrawOutline(Entity, false)
        DeleteEntity(Entity)
    else
        RequestSyncExecution("DeleteEntity", Entity)
    end
end

function IsPlacingEntity()
    return IsPlacing
end
exports('IsPlacingEntity', IsPlacingEntity)

function StopEntityPlacer()
    DeleteEntityPlacer(PlacingObject)
    IsPlacing, PlacingObject = false, nil
end
exports('StopEntityPlacer', StopEntityPlacer)

function DoEntityPlacer(Model, MaxDistance, StickToGround, PlayerHeading, ZMin, Cb, ShowOutline)
    local CenterCoords = GetEntityCoords(PlayerPedId()) + (GetEntityForwardVector(PlayerPedId()) * 1.5)
    PlacingObject = CreateEntity(Model, CenterCoords, false)

    if ShowOutline then
        SetEntityDrawOutline(PlacingObject, true)
        SetEntityDrawOutlineColor(0, 255, 0, 255)
    end

    if PlacingObject ~= false then
        IsPlacing = true
        SetEntityCollision(PlacingObject, false)
        SetEntityAlpha(PlacingObject, 0.3, true)
        Citizen.CreateThread(function()
            while IsPlacing do
                Citizen.Wait(4)
                DisableControlAction(0, 24, true)
                DisableControlAction(1, 38, true)
                DisableControlAction(0, 44, true)
                DisableControlAction(0, 142, true)
                DisablePlayerFiring(PlayerPedId(), true)

                if StickToGround and ZMin == nil then
                    PlaceObjectOnGroundProperly(PlacingObject)
                end

                if PlayerHeading then
                    SetEntityHeading(PlacingObject, GetFinalRenderedCamRot(0).z)
                end
                
                local _, Coords, _ = RayCastGamePlayCamera(10.0)
                SetEntityCoords(PlacingObject, Coords.x, Coords.y, (ZMin ~= nil and Coords.z - ZMin or Coords.z))

                if IsControlJustPressed(0, 180) and not PlayerHeading then
                    local EntityHeading = GetEntityHeading(PlacingObject)
                    SetEntityHeading(PlacingObject, EntityHeading + 5.0)
                end

                if IsControlJustPressed(0, 181) and not PlayerHeading then
                    local EntityHeading = GetEntityHeading(PlacingObject)
                    SetEntityHeading(PlacingObject, EntityHeading - 5.0)
                end

                if IsControlJustPressed(0, 177) then
                    DeleteEntityPlacer(PlacingObject)
                    IsPlacing, PlacingObject = false, nil
                    Cb(false)
                end
                
                if IsControlJustPressed(0, 191) then
                    local EntityCoords, EntityHeading = GetEntityCoords(PlacingObject), GetEntityHeading(PlacingObject)
                    DeleteEntityPlacer(PlacingObject)
                    Cb(true, EntityCoords, EntityHeading)
                    IsPlacing, PlacingObject = false, nil
                end

                if PlacingObject ~= nil and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(PlacingObject)) > MaxDistance then
                    DeleteEntityPlacer(PlacingObject)
                    IsPlacing, PlacingObject = false, nil
                    Cb(false)
                end
            end
        end)
    else
        Cb(false)
    end
end
exports('DoEntityPlacer', DoEntityPlacer)

function RayCastGamePlayCamera(Distance)
    local CameraRotation = GetGameplayCamRot()
    local CameraCoord = GetGameplayCamCoord()
    local Direction = RotationToDirection(CameraRotation)
    local Destination = {x = CameraCoord.x + Direction.x * Distance, y = CameraCoord.y + Direction.y * Distance, z = CameraCoord.z + Direction.z * Distance}
    local A, B, C, D, E = GetShapeTestResult(StartShapeTestRay(CameraCoord.x, CameraCoord.y, CameraCoord.z, Destination.x, Destination.y, Destination.z, -1, PlayerPedId(), 0))
    return B, C, E
end

function RotationToDirection(Rotation)
	local AdjustedRotation = {x = (math.pi / 180) * Rotation.x, y = (math.pi / 180) * Rotation.y, z = (math.pi / 180) * Rotation.z}
	local Direction = {x = -math.sin(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)), y = math.cos(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)), z = math.sin(AdjustedRotation.x)}
	return Direction
end