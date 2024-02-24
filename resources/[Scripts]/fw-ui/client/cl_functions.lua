function RayCastGamePlayCamera(Distance)
    local CameraRotation = GetGameplayCamRot()
    local CameraCoord = GetGameplayCamCoord()
    local Direction = RotationToDirection(CameraRotation)
    local Destination = {x = CameraCoord.x + Direction.x * Distance, y = CameraCoord.y + Direction.y * Distance, z = CameraCoord.z + Direction.z * Distance}
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(CameraCoord.x, CameraCoord.y, CameraCoord.z, Destination.x, Destination.y, Destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function RotationToDirection(Rotation)
	local AdjustedRotation = {x = (math.pi / 180) * Rotation.x, y = (math.pi / 180) * Rotation.y, z = (math.pi / 180) * Rotation.z}
	local Direction = {x = -math.sin(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)), y = math.cos(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)), z = math.sin(AdjustedRotation.x)}
	return Direction
end