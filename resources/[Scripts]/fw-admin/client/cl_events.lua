-- // Menu Events \\ --

RegisterNetEvent('Admin:Toggle:Noclip')
AddEventHandler('Admin:Toggle:Noclip', function(Enable)
    if IsPlayerAdmin() then
        ToggleNoclip(Enable)
        CheckInputRotation()
    end
end)

RegisterNetEvent('Admin:Fix:Vehicle')
AddEventHandler('Admin:Fix:Vehicle', function()
    if IsPlayerAdmin() then
        SetVehicleFixed(GetVehiclePedIsIn(PlayerPedId()))
    end
end)

RegisterNetEvent('Admin:Open:Bennys')
AddEventHandler('Admin:Open:Bennys', function()
    if IsPlayerAdmin() then
        TriggerEvent('fw-admin:Client:Force:Close')
        TriggerEvent('fw-bennys:Client:OpenBennys', true)
    end
end)

RegisterNetEvent('Admin:Delete:Vehicle')
AddEventHandler('Admin:Delete:Vehicle', function(Result)
    if IsPlayerAdmin() then
        TriggerEvent("FW:Command:DeleteVehicle")
    end
end)

RegisterNetEvent('Admin:Spawn:Vehicle')
AddEventHandler('Admin:Spawn:Vehicle', function(Result)
    if IsPlayerAdmin() then
        if not IsModelValid(Result['model']) then
            FW.Functions.Notify("Geen geldig model..", "error")
            return
        end
        local VehicleCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.75, 0)

        local CoordsTable = {x = VehicleCoords.x, y = VehicleCoords.y, z = VehicleCoords.z, a = GetEntityHeading(PlayerPedId()) + 90}

        FW.Functions.TriggerCallback('FW:server:spawn:vehicle', function(Veh)
            while not NetworkDoesEntityExistWithNetworkId(Veh) do Citizen.Wait(1000) end
            local Vehicle = NetToVeh(Veh)
            SetVehicleModKit(Vehicle, 0)

            Citizen.SetTimeout(1000, function()
                exports['fw-vehicles']:SetVehicleKeys(GetVehicleNumberPlateText(Vehicle), true, false)
                exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
            end)
        end, Result['model'], CoordsTable, false, nil)
    end
end)

RegisterNetEvent('Admin:Teleport:Marker')
AddEventHandler('Admin:Teleport:Marker', function()
    if IsPlayerAdmin() then
        TriggerEvent('FW:Command:GoToMarker')
    end
end)

RegisterNetEvent('Admin:Teleport:Coords')
AddEventHandler('Admin:Teleport:Coords', function(Result)
    if IsPlayerAdmin() then
        if Result['x-coord'] ~= '' and Result['y-coord'] ~= '' and Result['z-coord'] ~= '' then
            SetEntityCoords(PlayerPedId(), tonumber(Result['x-coord']) + 0.0, tonumber(Result['y-coord']) + 0.0, tonumber(Result['z-coord']) + 0.0)
        end
    end
end)

RegisterNetEvent('Admin:Teleport')
AddEventHandler('Admin:Teleport', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Teleport:Player', Result['player'], Result['type'])
    end
end)

RegisterNetEvent('Admin:Open:Clothing')
AddEventHandler('Admin:Open:Clothing', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Open:Clothing', Result['player'])
    end
end)

RegisterNetEvent('Admin:Revive')
AddEventHandler('Admin:Revive', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Revive:Target', Result['player'])
    end
end)

RegisterNetEvent('Admin:Remove:Stress')
AddEventHandler('Admin:Remove:Stress', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Remove:Stress', Result['player'])
    end
end)

RegisterNetEvent('Admin:Change:Model')
AddEventHandler('Admin:Change:Model', function(Result)
    if IsPlayerAdmin() and Result['model'] ~= '' then
        local Model = GetHashKey(Result['model'])
        if IsModelValid(Model) then
            TriggerServerEvent('fw-admin:Server:Set:Model', Result['player'], Model)
        end
    end
end)

RegisterNetEvent('Admin:Reset:Model')
AddEventHandler('Admin:Reset:Model', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Reset:Skin', Result['player'])
    end
end)

RegisterNetEvent('Admin:Armor')
AddEventHandler('Admin:Armor', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Set:Armor', Result['player'])
    end
end)

RegisterNetEvent('Admin:Food:Drink')
AddEventHandler('Admin:Food:Drink', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Set:Food:Drink', Result['player'])
    end
end)

RegisterNetEvent('Admin:Request:Job')
AddEventHandler('Admin:Request:Job', function(Result)
    if IsPlayerAdmin() then
        if Result['job'] ~= '' then
            TriggerServerEvent('fw-admin:Server:Request:Job', Result['player'], Result['job'], Result['grade'])
        end
    end
end)

RegisterNetEvent('Admin:Fling:Player')
AddEventHandler('Admin:Fling:Player', function(Result)
    if IsPlayerAdmin() then
        TriggerServerEvent('fw-admin:Server:Fling:Player', Result['player'])
    end
end)

-- // Other \\ --

RegisterNetEvent('fw-admin:Client:Teleport:Player')
AddEventHandler('fw-admin:Client:Teleport:Player', function(Coords)
    SetEntityCoords(PlayerPedId(), Coords.x, Coords.y, Coords.z)
end)

RegisterNetEvent('fw-admin:Client:SetModel')
AddEventHandler('fw-admin:Client:SetModel', function(Model)
    RequestModel(Model)
    while not HasModelLoaded(Model) do Citizen.Wait(0) end
    SetPlayerModel(PlayerId(), Model)
    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 0)
end)

RegisterNetEvent('fw-admin:Client:Armor:Up')
AddEventHandler('fw-admin:Client:Armor:Up', function()
    SetPedArmour(PlayerPedId(), 100.0)
end)

RegisterNetEvent('fw-admin:Client:Fling:Player')
AddEventHandler('fw-admin:Client:Fling:Player', function()
    local Ped = PlayerPedId()
    if GetVehiclePedIsUsing(Ped) ~= 0 then
        ApplyForceToEntity(GetVehiclePedIsUsing(Ped), 1, 0.0, 0.0, 100000.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
    else
        ApplyForceToEntity(Ped, 1, 9500.0, 3.0, 7100.0, 1.0, 0.0, 0.0, 1, false, true, false, false)
    end
end)

RegisterNetEvent("fw-admin:Client:Reset:Skin")
AddEventHandler("fw-admin:Client:Reset:Skin", function()
    TriggerEvent('fw-clothes:Client:LoadSkin', nil)
end)

RegisterNetEvent("fw-admin:Client:Remove:Stress")
AddEventHandler("fw-admin:Client:Remove:Stress", function()
    TriggerServerEvent('fw-ui:Server:remove:stress', 100)
end)

RegisterNetEvent("fw-admin:Client:OpenInventory")
AddEventHandler("fw-admin:Client:OpenInventory", function(Cid)
    if not IsPlayerAdmin() then return end
    TriggerEvent('fw-admin:Client:Force:Close')
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Other Player', 'ply-' .. Cid)
end)

RegisterNetEvent("Admin:Copy:Coords")
AddEventHandler("Admin:Copy:Coords", function(Result)    
    local coords = GetEntityCoords(PlayerPedId())
    local x, y, z = round(coords.x, 2), round(coords.y, 2), round(coords.z, 2)

    if Result.type == nil or Result.type == '' or Result.type == 'vector3' then
        SendNUIMessage({
            Action = 'CopyClipboard',
            Text = string.format('vector3(%s, %s, %s)', x, y, z)
        })
        FW.Functions.Notify("Vector3 copied to clipboard!", "success")
    elseif Result.type == 'vector4' then
        local heading = GetEntityHeading(PlayerPedId())
        local h = round(heading, 2)
        SendNUIMessage({
            Action = 'CopyClipboard',
            Text = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
        })
        FW.Functions.Notify("Vector4 copied to clipboard!", "success")
    elseif Result.type == 'table3' then
        SendNUIMessage({
            Action = 'CopyClipboard',
            Text = string.format('{ x: %s, y: %s, z: %s }', x, y, z)
        })
        FW.Functions.Notify("Table copied to clipboard!", "success")
    elseif Result.type == 'table4' then
        local heading = GetEntityHeading(PlayerPedId())
        local h = round(heading, 2)
        SendNUIMessage({
            Action = 'CopyClipboard',
            Text = string.format('{ x: %s, y: %s, z: %s, w: %s }', x, y, z, h)
        })
        FW.Functions.Notify("Table copied to clipboard!", "success")
    end
end)


local ShowCoords = Enable
RegisterNetEvent("Admin:Toggle:Coords")
AddEventHandler("Admin:Toggle:Coords", function(Enable)
    if not IsPlayerAdmin() then return end
    ShowCoords = Enable == nil and not ShowCoords or Enable
    if not ShowCoords then return end

    Citizen.CreateThread(function()
        local c = {}

        while ShowCoords do
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            c.x, c.y, c.z = round(coords.x, 2), round(coords.y, 2), round(coords.z, 2)
            heading = round(heading, 2)

            Draw2DText(string.format('~w~Ped Coordinates:~b~ vector4(~w~%s~b~, ~w~%s~b~, ~w~%s~b~, ~w~%s~b~)', c.x, c.y, c.z, heading), 4, {66, 182, 245}, 0.4, 0.4 + 0.0, 0.025 + 0.0)
            Citizen.Wait(4)
        end
    end)
end)

function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1],colour[2],colour[3], 255)
    SetTextEntry("STRING")
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentString(content)
    DrawText(x, y)
end

local ShowBlips, PlayerBlips = false, {}
RegisterNetEvent("Admin:Toggle:Blips")
AddEventHandler("Admin:Toggle:Blips", function(Enable)
    if not IsPlayerAdmin() then return end
    ShowBlips = Enable == nil and not ShowBlips or Enable
    TriggerServerEvent('fw-admin:Server:SetBlipsState', ShowBlips)

    if ShowBlips then
        DisplayRadar(true)
    elseif not IsPedInAnyVehicle(PlayerPedId()) then
        DisplayRadar(false)
    end
end)

exports("ShowingBlips", function()
    return ShowBlips
end)

RegisterNetEvent('fw-admin:Client:UpdatePlayerBlips')
AddEventHandler('fw-admin:Client:UpdatePlayerBlips', function(BlipData, Clear)
    if not IsPlayerAdmin() then return end

    if Clear then
        for k, Blip in pairs(PlayerBlips) do
            if DoesBlipExist(Blip) then
                RemoveBlip(Blip)
                PlayerBlips[k] = nil
            end
        end

        goto Skip
    end

    local ServerId = GetPlayerServerId(PlayerId())
    for k, v in pairs(BlipData) do
        if PlayerBlips[v.Id] ~= nil then
            SetBlipCoords(PlayerBlips[v.Id], v.Coords.x, v.Coords.y, v.Coords.z)
        else
            local Blip = AddBlipForCoord(v.Coords.x, v.Coords.y, v.Coords.z)
            SetBlipSprite(Blip, 1)
            SetBlipDisplay(Blip, 4)
            SetBlipScale(Blip, 0.8)
            SetBlipAsShortRange(Blip, false)
            SetBlipColour(Blip, 1)
            SetBlipCategory(Blip, 7)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName("[" .. v.Id .. "] " .. v.Name ..  " | " .. v.CharName)
            EndTextCommandSetBlipName(Blip)

            PlayerBlips[v.Id] = Blip
        end
    end

    ::Skip::
end)

local ShowNames = false
RegisterNetEvent("Admin:Toggle:Names")
AddEventHandler("Admin:Toggle:Names", function(Enable)
    if not IsPlayerAdmin() then return end

    ShowNames = Enable == nil and not ShowNames or Enable
    if not ShowNames then return end

    local NearbyPlayers = {}
    Citizen.CreateThread(function()
        while ShowNames do

            FW.Functions.TriggerCallback("fw-admin:Server:GetNearbyPlayers", function(Players)
                NearbyPlayers = Players
            end)

            Citizen.Wait(2000)
        end
    end)


    Citizen.CreateThread(function()
        while ShowNames do
            Citizen.Wait(1)
            
            local MyCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(NearbyPlayers) do
                local PlayerPed = GetPlayerPed(GetPlayerFromServerId(v.ServerId))
                local PlayerCoords = GetPedBoneCoords(PlayerPed, 0x796e)

                if #(PlayerCoords - MyCoords) < 20.0 then
                    DrawText3D(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.45, v.CharName .. '\n' .. '['..v.ServerId..'] ' .. v.Name)
                end
            end
        end
    end)
end)

function GetPlayers()
    local players = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            table.insert(players, player)
        end
    end
    return players
end

function GetPlayersFromCoords(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}
    if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
    end
    if distance == nil then
        distance = 5.0
    end
    for _, player in pairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = GetDistanceBetweenCoords(targetCoords, coords.x, coords.y, coords.z, true)
        if targetdistance <= distance then
            table.insert(closePlayers, player)
        end
    end
    return closePlayers
end

local DeleteLazer = false
RegisterNetEvent("Admin:Toggle:DeteLazer")
AddEventHandler("Admin:Toggle:DeteLazer", function(Enable)
    if not IsPlayerAdmin() then return end

    DeleteLazer = Enable == nil and not DeleteLazer or Enable
    if not DeleteLazer then return end

    Citizen.CreateThread(function()
        local LastEntity = nil
        while DeleteLazer do
            local color = {r = 255, g = 255, b = 255, a = 200}
            local position = GetEntityCoords(PlayerPedId())
            local hit, coords, entity = RayCastGamePlayCamera(100.0)

            if entity ~= LastEntity then
                if DoesEntityExist(LastEntity) then SetEntityDrawOutline(LastEntity, false) end
                LastEntity = entity
                if DoesEntityExist(LastEntity) then SetEntityDrawOutline(LastEntity, true) end
            end

            if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity) or IsEntityAnObject(entity)) then
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                Draw2DText('Obj: ~b~' .. entity .. '~w~ Model: ~b~' .. GetEntityModel(entity), 4, {255, 255, 255}, 0.4, 0.55, 0.888)
                Draw2DText('Vec3: ~b~' .. tostring(GetEntityCoords(entity)), 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.025)
                Draw2DText('Delete Object: ~r~E', 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.05)
                Draw2DText('Copy Model & Vec3: ~r~G', 4, {255, 255, 255}, 0.4, 0.55, 0.888 + 0.075)

                if IsControlJustReleased(0, 38) then
                    SetEntityAsMissionEntity(entity, true, true)
                    DeleteEntity(entity)
                end

                if IsControlJustReleased(0, 47) then
                    local Coords = GetEntityCoords(entity)
                    SendNUIMessage({
                        Action = 'CopyClipboard',
                        Text = string.format('%s - vector3(%s, %s, %s)', GetEntityModel(entity), string.format("%.2f", Coords.x), string.format("%.2f", Coords.y), string.format("%.2f", Coords.z))
                        -- Text = string.format('vector3(%s, %s, %s)', string.format("%.2f", Coords.x), string.format("%.2f", Coords.y), string.format("%.2f", Coords.z))
                    })
                end
            elseif coords.x ~= 0.0 and coords.y ~= 0.0 then
                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false)
            end
            Citizen.Wait(5)
        end
        if DoesEntityExist(LastEntity) then SetEntityDrawOutline(LastEntity, false) end
    end)
end)