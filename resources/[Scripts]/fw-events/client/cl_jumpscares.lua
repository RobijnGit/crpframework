local Zones = {
    {
        center = vector3(-262.03, -969.98, 31.22),
        length = 2.8,
        width = 5,
        heading = 30,
        minZ = 30.22,
        maxZ = 33.02
    },
    {
        center = vector3(-1670.92, -224.07, 55.03),
        length = 19.2,
        width = 5,
        heading = 340,
        minZ = 54.03,
        maxZ = 58.03
    },
    {
        center = vector3(-545.18, -203.25, 38.21),
        length = 2,
        width = 5,
        heading = 30,
        minZ = 37.21,
        maxZ = 40.01
    },
    {
        center = vector3(383.04, 796.54, 195.0),
        length = 8.8,
        width = 11.8,
        heading = 0,
        minZ = 186.4,
        maxZ = 194.8
    }
}

Citizen.CreateThread(function()
    for k, v in pairs(Zones) do
        exports['PolyZone']:CreateBox({ center = v.center, length = v.length, width = v.width }, {
            name = "jumpscare-" .. k, heading = v.heading,
            minZ = v.minZ, maxZ = v.maxZ,
            debugPoly = false,
        }, function(IsInside, Zone, Point)
            if IsInside and Config.IsEventActive then
                TriggerEvent("fw-ui:Client:DoJumpscare")
            end
        end)
    end
end)