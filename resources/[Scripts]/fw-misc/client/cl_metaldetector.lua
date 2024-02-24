local IsDetecting = false
local DetectorObject = false
local LastDetectCoords = vector3(0.0, 0.0, 0.0)
local DetectedCoords = {}

local MaterialHashes = {
    [-124769592] = true, [223086562] = true, [-309121453] = true,
    [435688960] = true, [-461750719] = true, [581794674] = true,
    [627123000] = true, [-700658213] = true, [-840216541] = true,
    [-913351839] = true, [930824497] = true,[1109728704] = true,
    [-1286696947] = true, [1333033863] = true, [-1595148316] = true,
    [-1833527165] = true, [-1885547121] = true, [-1915425863] = true,
    [-1942898710] = true, [-2041329971] = true, [-2073312001] = true,
    [2128369009] = true,
}

RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    if IsDetecting and not exports['fw-inventory']:HasEnoughOfItem('metaldetector', 1) then
        DeleteEntity(DetectorObject)
        IsDetecting = false
    end
end)

RegisterNetEvent("fw-misc:Client:UsedMetaldetector")
AddEventHandler("fw-misc:Client:UsedMetaldetector", function()
    IsDetecting = not IsDetecting

    if not IsDetecting then
        DeleteEntity(DetectorObject)
        StopAnimTask(PlayerPedId(), "mini@golfai", "wood_idle_a", 1.0)
        return
    end

    local Coords = GetEntityCoords(PlayerPedId())
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(Coords.x, Coords.y, Coords.z, Coords.x, Coords.y, Coords.z - 2.0, 1, 0, 4)
    local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)

    if not MaterialHashes[MaterialHash] then
        IsDetecting = false
        return FW.Functions.Notify("Ik betwijfel of hier wat ligt..", "error")
    end

    exports['fw-assets']:RequestModelHash("w_am_metaldetector")
    exports['fw-assets']:RequestAnimationDict("mini@golfai")

    DetectorObject = CreateObject("w_am_metaldetector", Coords.x, Coords.y, Coords.z, true, false, false)
    AttachEntityToEntity(DetectorObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 18905), 0.13, 0.03, -0.03, -150.0, -10.0, -10.0, true, true, false, true, 1, true)
    TaskPlayAnim(PlayerPedId(), "mini@golfai", "wood_idle_a", 1.0, 1.0, -1, 49, -1, 0, 0, 0)

    StartMetaldetecting()
end)

RegisterNetEvent("fw-misc:Client:UsedTrowel")
AddEventHandler("fw-misc:Client:UsedTrowel", function()
    -- Am I detecting?
    if IsDetecting then
        return FW.Functions.Notify("Ik zou die metaaldetector maar eerst eens even weg doen..", "error")
    end

    -- Am I near the detection spot?
    if #(GetEntityCoords(PlayerPedId()) - LastDetectCoords) > 2.0 then
        return
    end

    -- OH MY DAYS I FOUND SOME GOLD DIGGERS GOLD !!!!!!!
    ClearPedTasks(PlayerPedId())
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(8000, "Graven graven graven...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())
    exports['fw-inventory']:SetBusyState(false)

    if not Finished then return end
    LastDetectCoords = vector3(0.0, 0.0, 0.0)
    FW.TriggerServer("fw-misc:Server:MetalDetectorReward")
end)

function StartMetaldetecting()
    -- Get random spots
    Citizen.CreateThread(function()
        while IsDetecting do
            Citizen.Wait(math.random(10000, 30000))

            local Coords = GetEntityCoords(PlayerPedId())
            if #(Coords - LastDetectCoords) > 30.0 and math.random() > 0.15 then
                local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(Coords.x, Coords.y, Coords.z, Coords.x, Coords.y, Coords.z - 2.0, 1, 0, 4)
                local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)

                if MaterialHashes[MaterialHash] and not HasAlreadyDetectedCoords(Coords) then
                    LastDetectCoords = Coords
                    DetectedCoords[#DetectedCoords + 1] = Coords
                end
            end
        end
    end)

    -- Play sound if near
    Citizen.CreateThread(function()
        local LastSound = GetCloudTimeAsInt()
        while IsDetecting do

            local Coords = GetEntityCoords(PlayerPedId())
            local Distance = #(Coords - LastDetectCoords)

            if Distance < 2.0 and GetCloudTimeAsInt() > LastSound + 3 then
                LastSound = GetCloudTimeAsInt()
                TriggerEvent("fw-misc:Client:PlaySoundCoords", "general.metalDetector", LastDetectCoords, 10.0, true)
            end

            if not IsEntityPlayingAnim(PlayerPedId(), "mini@golfai", "wood_idle_a", 49) then
                TaskPlayAnim(PlayerPedId(), "mini@golfai", "wood_idle_a", 1.0, 1.0, -1, 49, -1, 0, 0, 0)
            end

            Citizen.Wait(250)
        end
    end)
end

function HasAlreadyDetectedCoords(Coords)
    for k, v in pairs(DetectedCoords) do
        if #(Coords - v) <= 15.0 then
            return true
        end
    end

    return false
end