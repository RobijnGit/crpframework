local CreatedBarricades = {}
local SpeedZones = {}

Citizen.CreateThread(function()
    while true do
        local Coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Barricades) do
            -- Only process 100 per frame.
            if k % 100 == 0 then
                Citizen.Wait(0)
            end

            if #(Coords - v.Coords) < 200.0 then
                if not CreatedBarricades[v.Id] then
                    local BarricadeObject = CreateBarricade(v.Model, v.Coords, v.Rotation)
                    if v.Static then
                        FreezeEntityPosition(BarricadeObject, true)
                    end

                    if v.Traffic then
                        CreateSpeedZone(v.Id, v.Coords)
                    end

                    CreatedBarricades[v.Id] = BarricadeObject
                end
            elseif CreatedBarricades[v.Id] then
                DeleteObject(CreatedBarricades[v.Id])
                DeleteSpeedZone(v.Id)
                CreatedBarricades[v.Id] = nil
            end
        end

        Citizen.Wait(2000)
    end
end)

function CreateBarricade(Model, Coords, Heading)
    exports['fw-assets']:RequestModelHash(Model)

    local BarricadeObject = CreateObject(Model, Coords.x, Coords.y, Coords.z, false, false, false)
    SetEntityHeading(BarricadeObject, Heading + 0.0)
    PlaceObjectOnGroundProperly(BarricadeObject)

    return BarricadeObject
end

function CreateSpeedZone(Id, Coords)
    if SpeedZones[Id] ~= nil then
        DeleteSpeedZone(Id)
    end

    local Node = AddRoadNodeSpeedZone(Coords.x, Coords.y, Coords.z, 4.0, 0.0, false)
    SpeedZones[Id] = Node

    print("Created speed zone 10 radius.")
end

function DeleteSpeedZone(Id)
    RemoveRoadNodeSpeedZone(SpeedZones[Id])
    SpeedZones[Id] = nil
end

RegisterNetEvent("fw-police:Client:OpenBarricadeMenu")
AddEventHandler("fw-police:Client:OpenBarricadeMenu", function(Props, ClosestData)
    local PlayerData = FW.Functions.GetPlayerData()
    if (PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'ems' and PlayerData.job.name ~= 'storesecurity') or not PlayerData.job.onduty then
        return
    end

    local MenuItems = {}

    for k, v in pairs(Props) do
        table.insert(MenuItems, {
            Title = v.Label,
            Desc = v.Desc,
            Data = { Event = 'fw-police:Client:PlaceBarricade', Type = 'Client', Prop = v.Prop },
        })
    end

    if ClosestData and PlayerData.metadata.ishighcommand then
        table.insert(MenuItems, {
            Icon = "info-circle",
            Title = "Prop Info (" .. ClosestData.Label .. ")",
            Desc = "Barricade Id: " .. ClosestData.Id .. ";<br/>Geplaats door: " .. ClosestData.PlacedBy .. ";<br/>Geplaats op: " .. ClosestData.PlacedAt .. ";",
            Disabled = true,
        })
    end

    FW.Functions.OpenMenu({
        MainMenuItems = MenuItems
    })
end)

RegisterNetEvent("fw-police:Client:PlaceBarricade")
AddEventHandler("fw-police:Client:PlaceBarricade", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if (PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'ems' and PlayerData.job.name ~= 'storesecurity') or not PlayerData.job.onduty then
        return
    end

    if Data.Prop == "delete_closest" then
        FW.TriggerServer("fw-police:Server:DeleteBarricade")
        return
    end

    exports['fw-core']:DoEntityPlacer(Data.Prop, 10.0, true, true, nil, function(DidPlace, Coords, Heading)
        if not DidPlace then return end
        
        local Finished = FW.Functions.CompactProgressbar(1000, "Barricade plaatsen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", anim = "plant_floor", flags = 49 }, {}, {}, false)
        if not Finished then return end

        FW.TriggerServer("fw-police:Server:PlaceBarricade", Data.Prop, Coords, Heading)
    end)
end)

RegisterNetEvent("fw-police:Client:SetPropData")
AddEventHandler("fw-police:Client:SetPropData", function(Type, BarricadeId, Data)
    if not LoggedIn then return end

    if Type == "Add" then
        table.insert(Config.Barricades, Data)
    elseif Type == "Remove" then
        for k, v in pairs(Config.Barricades) do
            if v.Id == BarricadeId then
                table.remove(Config.Barricades, k)
                break
            end
        end

        if CreatedBarricades[BarricadeId] and DoesEntityExist(CreatedBarricades[BarricadeId]) then
            DeleteSpeedZone(BarricadeId)
            DeleteObject(CreatedBarricades[BarricadeId])
            CreatedBarricades[BarricadeId] = nil
        end
    end
end)

exports("IsEntityLookingAtBarricade", function()
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(3.0, 0.2, 286, PlayerPedId())
    if not Entity or EntityType == 0 then
        return false, nil
    end

    for BarricadeId, Object in pairs(CreatedBarricades) do
        if Object == Entity then
            return true, BarricadeId
        end
    end

    return false, nil
end)