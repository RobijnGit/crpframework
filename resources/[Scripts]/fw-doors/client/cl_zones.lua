NearBollards = nil

function InitZones()
    Citizen.CreateThread(function()
        exports['PolyZone']:CreateBox({
            center = vector3(410.9, -1028.66, 29.2), 
            length = 5.2, 
            width = 12.6,
        }, {
            name = 'police_bollards_01',
            minZ = 28.2,
            maxZ = 32.2,
            heading = 0.0,
            debugPoly = false,
        }, function(IsInside, Zone, Points)
            if IsInside then
                NearBollards = 'MRPD_Bollars_1'
            else
                NearBollards = nil
            end
        end)

        exports['PolyZone']:CreateBox({
            center = vector3(412.76, -1020.29, 29.35), 
            length = 5.0, 
            width = 14.2,
        }, {
            name = 'police_bollards_02',
            minZ = 28.35,
            maxZ = 32.35,
            heading = 0.0,
            debugPoly = false,
        }, function(IsInside, Zone, Points)
            if IsInside then
                NearBollards = 'MRPD_Bollars_2'
            else
                NearBollards = nil
            end
        end)

        exports['PolyZone']:CreateBox({
            center = vector3(-453.24, 6028.62, 31.34), 
            length = 5.6, 
            width = 15.8,
        }, {
            name = 'police_bollards_03',
            minZ = 30.34,
            maxZ = 33.74,
            heading = 45.0,
            debugPoly = false,
        }, function(IsInside, Zone, Points)
            if IsInside then
                NearBollards = 'PBSO_BOLLARDS_01'
            else
                NearBollards = nil
            end
        end)

        exports['PolyZone']:CreateBox({
            center = vector3(452.39, -1003.15, 26.56),
            length = 18.0,
            width = 4.8,
        }, {
            name = 'mrpd_garage_1',
            minZ = 24.56,
            maxZ = 29.56,
            heading = 0,
            debugPoly = false,
        }, function(IsInside, Zone, Points)
            if IsInside then
                NearBollards = 'MRPD_Garage_Out_1'
            else
                NearBollards = nil
            end
        end)

        exports['PolyZone']:CreateBox({
            center = vector3(431.39, -1003.53, 25.72),
            length = 18.0,
            width = 4.8,
        }, {
            name = 'mrpd_garage_2',
            minZ = 24.72,
            maxZ = 29.52,
            heading = 0.0,
            debugPoly = false,
        }, function(IsInside, Zone, Points)
            if IsInside then
                NearBollards = 'MRPD_Garage_Out_2'
            else
                NearBollards = nil
            end
        end)

        exports['PolyZone']:CreateBox({
            center = vector3(-1072.96, -851.01, 4.88),
            length = 17.2,
            width = 8.8,
        }, {
            name = 'vbpd_garage_1',
            heading = 35,
            minZ = 3.88,
            maxZ = 7.68,
            debugPoly = false,
        }, function(IsInside, Zone, Points)
            if IsInside then
                NearBollards = 'VBPD_GARAGE_DOOR'
            else
                NearBollards = nil
            end
        end)
    end)
end