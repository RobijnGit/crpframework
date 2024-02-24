RegisterNetEvent("fw-config:configLoaded")
AddEventHandler("fw-config:configLoaded", function(Module)
    if Module ~= "polychairs" then return end
    InitPolychairs()
end)

RegisterNetEvent("fw-config:configReady")
AddEventHandler("fw-config:configReady", function()
    InitPolychairs()
end)

function InitPolychairs()
    while not exports['fw-config']:IsConfigReady() do Citizen.Wait(4) end
    local Chairs = exports['fw-config']:GetModuleConfig("polychairs", {})

    for k, v in pairs(Chairs) do
        exports['fw-ui']:AddEyeEntry("polychair-" .. v.Id .. "-" .. k, {
            Type = 'Zone',
            SpriteDistance = 3.0,
            Distance = 1.5,
            ZoneData = {
                Center = vector3(v.Center.x, v.Center.y, v.Center.z),
                Length = v.Length,
                Width = v.Width,
                Data = {
                    heading = v.Center.w,
                    minZ = v.MinZ,
                    maxZ = v.MaxZ,
                },
            },
            Options = {
                {
                    Name = 'sit',
                    Icon = 'fas fa-chair',
                    Label = 'Zitten',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:SitOnPolyChair',
                    EventParams = { Center = v.Center, zOffset = v.zOffset, Anim = v.Anim },
                    Enabled = function(Entity)
                        return true
                    end,
                },
            }
        })
    end
end

-- 

local IsSitting = false
local PreviousPosition = nil
RegisterNetEvent("fw-misc:Client:SitOnPolyChair")
AddEventHandler("fw-misc:Client:SitOnPolyChair", function(Data)
    if IsSitting then
        return
    end

    if Data.Center == nil then return end
    local Offset = vector3((Data.xOffset or 0) * 1.0, (Data.yOffset or 0) * 1.0, (Data.zOffset or 0) * 1.0)
    local Center = vector3(Data.Center.x, Data.Center.y, Data.Center.z)
    local Heading = Data.Center.w * 1.0

    SetEntityHeading(PlayerPedId(), Heading)
    PreviousPosition = GetEntityCoords(PlayerPedId())

    IsSitting = true

    if Data.Anim then
        -- todo
    else
        TaskStartScenarioAtPosition(PlayerPedId(), "PROP_HUMAN_SEAT_CHAIR_UPRIGHT", Center.x - Offset.x, Center.y - Offset.y, Center.z - Offset.z, Heading, -1, true, true)
    end

    Citizen.Wait(1500)

    Citizen.CreateThread(function()
        while IsSitting and IsPedUsingScenario(PlayerPedId(), "PROP_HUMAN_SEAT_CHAIR_UPRIGHT") do
            if IsControlJustReleased(0, 73) then
                if PreviousPosition ~= nil and IsPedUsingScenario(PlayerPedId(), "PROP_HUMAN_SEAT_CHAIR_UPRIGHT") then
                    SetEntityCoords(PlayerPedId(), PreviousPosition.x, PreviousPosition.y, PreviousPosition.z - 0.8, 0, 0, 0, false)
                end
    
                PreviousPosition = nil
                IsSitting = false
            end

            Citizen.Wait(4)
        end
    end)
end)