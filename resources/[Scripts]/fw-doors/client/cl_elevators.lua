-- // Events \\ --
RegisterNetEvent('fw-doors:Client:Open:Elevator:Menu')
AddEventHandler('fw-doors:Client:Open:Elevator:Menu', function(Data, Entity)
    if Config.Elevators[Data.ElevatorId] ~= nil then
        local MenuItems = {}
        for k, v in pairs(Config.Elevators[Data.ElevatorId]) do
            local Disabled, AtLocation = not HasAccesToElevator(v), false
            if Data.AtLocation == v.IdName then
                Disabled, AtLocation = true, true
            end
            local MenuData = {}     
            MenuData['Icon'] = 'sort-circle'
            MenuData['Title'] = AtLocation and Disabled and v.Name..' (Je bent hier)' or v.Name
            MenuData['Desc'] = not AtLocation and Disabled and 'Geen Toegang!' or v.Desc
            MenuData['Data'] = { Event = 'fw-doors:Client:Use:Elevator', Type = 'Client', CurrentElevator = Data, ElevatorData = v }
            MenuData['Disabled'] = Disabled
            table.insert(MenuItems, MenuData)
        end
        if #MenuItems > 0 then
            FW.Functions.OpenMenu({MainMenuItems = MenuItems})
        end
    end
end)

RegisterNetEvent('fw-doors:Client:Use:Elevator')
AddEventHandler('fw-doors:Client:Use:Elevator', function(Data)
    if Data.ElevatorData.Coords ~= nil then
        FW.Functions.Progressbar("", 'Wachten op de lift..', 3500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "amb@world_human_hang_out_street@female_hold_arm@idle_a",
            anim = "idle_a",
            flags = 8,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(),  "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
            ElevatorToCoords(Data.CurrentElevator.AtLocation, Data.ElevatorData.IdName, Data.ElevatorData.Coords)
        end, function()
            StopAnimTask(PlayerPedId(),  "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
        end, true)
    end
end)

-- // Functions \\ --
function InitElevator()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.ElevatorZones) do
            for Elevator, ElevatorData in pairs(Config.ElevatorZones[k]) do
                exports['fw-ui']:AddEyeEntry("elevator_"..k..'-'..Elevator, {
                    Type = 'Zone',
                    SpriteDistance = 5.0,
                    Distance = 3.0,
                    ZoneData = {
                        Center = ElevatorData.Coords,
                        Length = ElevatorData.Data.Length,
                        Width = ElevatorData.Data.Width,
                        Data = {
                            debugPoly = false,
                            heading = ElevatorData.Data.Heading,
                            minZ = ElevatorData.Data.MinZ,
                            maxZ = ElevatorData.Data.MaxZ
                        },
                    },
                    Options = {
                        {
                            Name = 'elevator_option',
                            Icon = 'fas fa-chevron-circle-up',
                            Label = 'Lift',
                            EventType = 'Client',
                            EventName = 'fw-doors:Client:Open:Elevator:Menu',
                            EventParams = {ElevatorId = k, AtLocation = ElevatorData.IdName},
                            Enabled = function(Entity)
                                return true
                            end,
                        }
                    }
                })
            end
        end
    end)
end

function HasAccesToElevator(ElevatorData)
    local PlayerData = FW.Functions.GetPlayerData()
    if ElevatorData ~= nil then
        for k, Job in pairs(ElevatorData.Access.Job) do
            if PlayerData.job.name == Job then
                return true
            end
        end
        for k, Cid in pairs(ElevatorData.Access.CitizenId) do
            if PlayerData.CitizenId == Cid then
                return true
            end
        end
        for k, Business in pairs(ElevatorData.Access.Business) do
            if exports['fw-businesses']:HasRolePermission(Business, 'PropertyKeys') then
                return true
            end
        end

        if not ElevatorData.Locked then
            return true
        end

        if #ElevatorData.Access.Job == 0 and #ElevatorData.Access.CitizenId == 0 and #ElevatorData.Access.Business == 0 then
            return true
        end
    end

    return false
end

function ElevatorToCoords(FromElevatorId, ToElevatorId, Coords)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Citizen.Wait(1) end

    TriggerEvent('fw-doors:Client:On:Elevator:Leave', FromElevatorId)    
    TriggerEvent("fw-misc:Client:PlaySoundCoords", 'general.elevator', vector3(Coords.x, Coords.y, Coords.z), 25.0, true)

    NetworkFadeOutEntity(PlayerPedId(), true, true)
    Citizen.Wait(300)

    SetGameplayCamRelativeHeading(0.0)
    RequestCollisionAtCoord(Coords.x, Coords.y, Coords.z)
    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        SetEntityCoords(PlayerPedId(), Coords.x + 0.0, Coords.y + 0.0, Coords.z + 0.0)
        Citizen.Wait(100)
    end

    TriggerEvent('fw-doors:Client:On:Elevator:Enter', ToElevatorId)
    SetEntityCoords(PlayerPedId(), Coords.x + 0.0, Coords.y + 0.0, Coords.z + 0.0)
    SetEntityHeading(PlayerPedId(), Coords.w)
    NetworkFadeInEntity(PlayerPedId(), true)

    Citizen.Wait(500)
    DoScreenFadeIn(500)
end

-- AddEventHandler('fw-doors:Client:On:Elevator:Enter', function(Entering)
--     print('Entering..', Entering)
-- end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", InitElevator)