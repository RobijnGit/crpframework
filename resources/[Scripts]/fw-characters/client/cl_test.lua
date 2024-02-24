-- thanks chatgpt :)
-- local peds = {}
-- local radius = 5.0 -- The radius of the circle
-- local pedDistance = 0.25 * (2 * math.pi * radius) -- Distance between each ped (25% of the circle)
-- local playerPed = nil

-- -- Function to create a ped at the specified coordinates
-- local function createPed(x, y, z)
--     local ped = CreatePed(4, GetHashKey("a_m_m_skater_01"), x, y, z, 0.0, false, true)
--     SetPedRandomComponentVariation(ped, true)
--     SetPedDefaultComponentVariation(ped)
--     return ped
-- end

-- -- Event triggered when the resource stops
-- AddEventHandler("onResourceStop", function(resourceName)
--     if GetCurrentResourceName() ~= resourceName then
--         return
--     end
    
--     -- Delete all peds
--     for i = 1, #peds do
--         DeletePed(peds[i])
--     end
--     peds = {}
-- end)

-- -- Function to update the ped positions in a loop
-- Citizen.CreateThread(function()
--     playerPed = PlayerPedId()
    
--     while true do
--         Citizen.Wait(0)
--         local playerCoords = GetEntityCoords(playerPed)
--         local playerHeading = GetEntityHeading(playerPed)
        
--         -- Calculate the angle range for the front side of the circle
--         local angleRange = 0.22 * 2 * math.pi -- Angle range for the front side
--         local startAngle = playerHeading - (angleRange / 2)
--         local endAngle = playerHeading + (angleRange / 2)
        
--         -- Update the positions of the peds in the front side of the circle around the player
--         local pedCount = 6 -- Number of peds to spawn
--         local angleStep = angleRange / (pedCount + 1) -- Add 1 to distribute the peds evenly within the range
--         for i = 1, pedCount do
--             local angle = startAngle + (angleStep * i)
--             local x = playerCoords.x + radius * math.cos(angle)
--             local y = playerCoords.y + radius * math.sin(angle)
--             local z = playerCoords.z
--             if peds[i] ~= nil then
--                 SetEntityCoordsNoOffset(peds[i], x, y, z, false, false, false)
--                 SetEntityHeading(peds[i], GetHeadingFromVector_2d(playerCoords.x - x, playerCoords.y - y))

--             else
--                 local ped = createPed(x, y, z)
--                 table.insert(peds, ped)
--             end
--         end

--         if IsControlJustPressed(0, 38) then
--             for i = 1, pedCount do
--                 local angle = startAngle + (angleStep * i)
--                 local x = playerCoords.x + radius * math.cos(angle)
--                 local y = playerCoords.y + radius * math.sin(angle)
--                 local z = playerCoords.z
--                 print(vector4(x, y, z, GetHeadingFromVector_2d(playerCoords.x - x, playerCoords.y - y)))
--             end
--         end
--     end
-- end)
