local RecycleProps = {}
local IsInsideRecycle = false
local CurrentRecycleId, CurrentRecycle, HasPackage = false, false, false

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['PolyZone']:CreateBox({
        center = vector3(1010.0, -3101.43, -39.0),
        length = 24.4,
        width = 36.6,
    }, {
        name = "recycle-center-zone",
        heading = 0,
        minZ = -40.0,
        maxZ = -30.0,
        debugPoly = false,
    }, function(IsInside, Zone, Points)
        IsInsideRecycle = IsInside

        if IsInsideRecycle then
            SpawnRecycleProps()
            StartInsideRecycleLoop()
        else
            ClearRecycleProps()
        end
    end)

    exports['fw-ui']:AddEyeEntry("recycle-deliver", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 2.0,
        ZoneData = {
            Center = vector3(997.27, -3091.94, -39.0),
            Length = 1.25,
            Width = 0.4,
            Data = {
                heading = 0,
                minZ = -40.0,
                maxZ = -37.75
            },
        },
        Options = {
            {
                Name = 'grab',
                Icon = 'fas fa-circle',
                Label = 'Materiaal Inleveren',
                EventType = 'Client',
                EventName = 'fw-misc:Client:DeliverRecycle',
                EventParams = {},
                Enabled = function(Entity)
                    return HasPackage
                end,
            },
        }
    })
end)

function SelectRandomRecycle()
    CurrentRecycleId = math.random(#Config.RecyclePropsCoords)
    CurrentRecycle = Config.RecyclePropsCoords[CurrentRecycleId]
end

function StartInsideRecycleLoop()
    Citizen.CreateThread(function()
        while IsInsideRecycle do

            if not CurrentRecycle then
                SelectRandomRecycle()
            end

            if not HasPackage then
                DrawMarker(32, CurrentRecycle.x, CurrentRecycle.y, CurrentRecycle.z + 3.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.0, 1.0, 255, 0, 0, 100, false, false, false, true, false, false, false)
            else
                DrawMarker(32, 997.81, -3091.93, -39.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 2.0, 1.0, 255, 0, 0, 100, false, false, false, true, false, false, false)
            end

            Citizen.Wait(1)
        end
    end)
end

function SpawnRecycleProps()
    ClearRecycleProps()

    for k, Coords in pairs(Config.RecyclePropsCoords) do
        local Prop = Config.RecycleProps[math.random(1, #Config.RecycleProps)]
        exports['fw-assets']:RequestModelHash(Prop)

        local Object = CreateObjectNoOffset(GetHashKey(Prop), Coords.x, Coords.y, Coords.z, false, false, false)
        FreezeEntityPosition(Object, true)
        SetEntityInvincible(Object, true)
        SetEntityHeading(Object, Coords.w)

        exports['fw-ui']:AddEyeEntry("recycle-grab-" .. k, {
            Type = 'Zone',
            SpriteDistance = 10.0,
            Distance = 2.0,
            ZoneData = {
                Center = vector3(Coords.x, Coords.y, Coords.z),
                Length = 2.0,
                Width = 2.0,
                Data = {
                    heading = Coords.w,
                    minZ = -40.0,
                    maxZ = -38.0
                },
            },
            Options = {
                {
                    Name = 'grab',
                    Icon = 'fas fa-circle',
                    Label = 'Materiaal Pakken',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:GrabRecycle',
                    EventParams = {},
                    Enabled = function(Entity)
                        return CurrentRecycleId == k
                    end,
                },
            }
        })

        RecycleProps[#RecycleProps + 1] = Object
    end
end

function ClearRecycleProps()
    for k, v in pairs(RecycleProps) do
        DeleteEntity(v)
    end

    RecycleProps = {}
end

RegisterNetEvent("fw-misc:Client:GrabRecycle")
AddEventHandler("fw-misc:Client:GrabRecycle", function()
    local Finished = FW.Functions.CompactProgressbar(math.random(5000, 8000), "Pakketje oppakken...", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = "fixing_a_ped", animDict = "mini@repair", flags = 0 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mini@repair" ,"fixing_a_ped", 1.0)

    TriggerEvent("fw-emotes:Client:PlayEmote", "box", false, true)
    HasPackage = true
end)

RegisterNetEvent("fw-misc:Client:DeliverRecycle")
AddEventHandler("fw-misc:Client:DeliverRecycle", function()
    if not HasPackage then return end

    TriggerEvent("fw-emotes:Client:CancelEmote", true)

    local Finished = FW.Functions.CompactProgressbar(math.random(8000, 15000), "Pakketje inleveren...", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = "car_bomb_mechanic", animDict = "mp_car_bomb", flags = 16 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "mp_car_bomb", "car_bomb_mechanic", 1.0)
    SelectRandomRecycle()
    HasPackage = false

    FW.TriggerServer("fw-misc:Server:RecycleReward")
end)

AddEventHandler("onResourceStop", function()
    ClearRecycleProps()
end)