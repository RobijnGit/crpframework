local PlacingObject, IsPlacing, CanPlace = nil, false, false
local RotationCam = false

Citizen.CreateThread(function()
    RotationCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 0)
end)

function CheckRay(coords, direction)
    local rayEndPoint = coords + direction * 1000.0
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, rayEndPoint.x, rayEndPoint.y, rayEndPoint.z, 1,  PlayerPedId())
    local retval, hit, endCoords, surfaceNormal, materialHash, entityHit = GetShapeTestResultEx(rayHandle)
    return surfaceNormal
end

function GetSprayRotation(Coords, CamDirection)
    local Normal = CheckRay(Coords, CamDirection) + vector3(0.0, 0.0, 0.0)
    local camLookPosition = Coords - Normal * 10

    SetCamCoord(RotationCam, Coords.x, Coords.y, Coords.z)
    PointCamAtCoord(RotationCam, camLookPosition.x, camLookPosition.y, camLookPosition.z)
    SetCamActive(RotationCam, true)

    Citizen.Wait(0)

    local rot = GetCamRot(RotationCam, 2)
    SetCamActive(RotationCam, false)

    return rot
end

function SetSprayRotation(Entity)
    Citizen.CreateThread(function()
        local CamDirection = RotationToDirection(GetGameplayCamRot())
        local Rotation = GetSprayRotation(GetEntityCoords(PlayerPedId()), CamDirection)
        SetEntityRotation(Entity, Rotation.x, Rotation.y, Rotation.z)

        local MarkerCoords = GetOffsetFromEntityInWorldCoords(PlacingObject, 0, -0.1, 0)
        if CanPlace and (Rotation.x < -1.0 or Rotation.x > 1.0) then CanPlace = false end

        DrawMarker(6, MarkerCoords.x, MarkerCoords.y, MarkerCoords.z, 0.0, 0.0, 0.0, Rotation.x, Rotation.y, Rotation.z, 0.8, 0.3, 0.8, CanPlace and 0 or 255, CanPlace and 255 or 0, 0, 255, false, false, false, false, false, false, false)
    end)
end

function DoGraffitiPlacer(Model, MaxDistance, StickToGround, PlayerHeading, ZMin, Cb)
    local HashEntity = GetHashKey(Model)
    exports['fw-assets']:RequestModelHash(HashEntity)

    local MaxDistance = MaxDistance ~= nil and MaxDistance or 5.0
    local CenterCoords = GetEntityCoords(PlayerPedId()) + (GetEntityForwardVector(PlayerPedId()) * 1.5)
    PlacingObject = CreateObject(HashEntity, CenterCoords, false, false, false)
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

                CanPlace = true
                local _, Coords, _ = RayCastGamePlayCamera(10.0)
                SetEntityCoords(PlacingObject, Coords.x, Coords.y, (ZMin ~= nil and Coords.z - ZMin or Coords.z))
                SetSprayRotation(PlacingObject)

                if IsControlJustPressed(0, 177) then
                    DeleteEntity(PlacingObject)
                    IsPlacing, PlacingObject = false, nil
                    Cb(false)
                end
                
                if CanPlace and IsControlJustPressed(0, 191) then
                    local EntityCoords, EntityRotation = GetEntityCoords(PlacingObject), GetEntityRotation(PlacingObject)
                    DeleteEntity(PlacingObject)
                    Cb(true, EntityCoords, EntityRotation)
                    IsPlacing, PlacingObject = false, nil
                end

                if PlacingObject ~= nil and #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(PlacingObject)) > MaxDistance then
                    CanPlace = false
                end

                if StickToGround and ZMin == nil then
                    PlaceObjectOnGroundProperly(PlacingObject)
                end
            end
        end)
    else
        Cb(false)
    end
end

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
	local Direction = vector3(-math.sin(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)), math.cos(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)), math.sin(AdjustedRotation.x))
	return Direction
end