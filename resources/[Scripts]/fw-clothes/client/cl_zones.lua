local ShowingInteract, NearShop = false, false

function CreateBlip(Pos, Name, Sprite, Color)
    if BlipsCreated then return end
    local Blip = AddBlipForCoord(Pos.x, Pos.y, Pos.z)
    SetBlipSprite(Blip, Sprite)
    SetBlipDisplay(Blip, 4)
    SetBlipScale(Blip, 0.5)
    SetBlipAsShortRange(Blip, true)
    SetBlipColour(Blip, Color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Name)
    EndTextCommandSetBlipName(Blip)
end

function InitZones()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.Stores['Clothing']) do
            exports['PolyZone']:CreateBox({
                center = v.Coords, 
                length = v.Data.Length, 
                width = v.Data.Width,
            }, {
                name = 'clothing_'..k,
                minZ = v.Data.MinZ,
                maxZ = v.Data.MaxZ,
                heading = v.Heading,
                hasMultipleZones = false,
                debugPoly = false,
            }, function() end, function() end)
            if not v.IgnoreBlip then CreateBlip(v.Coords, 'Kledingwinkel', 366, 47) end
        end

        for k, v in pairs(Config.Stores['Barber']) do
            exports['PolyZone']:CreateBox({
                center = v.Coords, 
                length = v.Data.Length, 
                width = v.Data.Width,
            }, {
                name = 'barber_'..k,
                minZ = v.Data.MinZ,
                maxZ = v.Data.MaxZ,
                heading = v.Heading,
                hasMultipleZones = false,
                debugPoly = false,
            }, function() end, function() end)
            if not v.IgnoreBlip then CreateBlip(v.Coords, 'Kapper', 71, 68) end
        end

        for k, v in pairs(Config.Stores['Tattoos']) do
            exports['PolyZone']:CreateBox({
                center = v.Coords, 
                length = v.Data.Length, 
                width = v.Data.Width,
            }, {
                name = 'tattoos_'..k,
                minZ = v.Data.MinZ,
                maxZ = v.Data.MaxZ,
                heading = v.Heading,
                hasMultipleZones = false,
                debugPoly = false,
            }, function() end, function() end)
            if not v.IgnoreBlip then CreateBlip(v.Coords, 'Tattoo Shop', 75, 6) end
        end
    end)
end

-- // Zones \\ --

RegisterNetEvent('PolyZone:OnEnter')
AddEventHandler('PolyZone:OnEnter', function(PolyData, Coords)
    local PolyName = string.sub(PolyData.name, 1, 8)
    if string.sub(PolyData.name, 1, 8) == 'clothing' or string.sub(PolyData.name, 1, 6) == 'barber' or string.sub(PolyData.name, 1, 7) == 'tattoos' then
        local Type = (string.sub(PolyData.name, 1, 8) == 'clothing' and 'Clothes' or string.sub(PolyData.name, 1, 6) == 'barber' and 'Barber' or string.sub(PolyData.name, 1, 7) == 'tattoos' and 'Tattoos')
        if not NearShop then 
            NearShop = true
            if not ShowingInteract then
                ShowingInteract = true
                exports['fw-ui']:ShowInteraction('[E] Kleding', 'primary')
            end
            Citizen.CreateThread(function()
                while NearShop do
                    Citizen.Wait(4)
                    if IsControlJustReleased(0, 38) then OpenClothesMenu(Type) end
                end
            end)
        end
    else
        return
    end
end)

RegisterNetEvent('PolyZone:OnExit')
AddEventHandler('PolyZone:OnExit', function(PolyData, Coords)
    if string.sub(PolyData.name, 1, 8) == 'clothing' or string.sub(PolyData.name, 1, 6) == 'barber' or string.sub(PolyData.name, 1, 7) == 'tattoos' then
        if NearShop then 
            NearShop = false
            if ShowingInteract then
                ShowingInteract = false
                exports['fw-ui']:HideInteraction()
            end
        end
    else
        return
    end
end)