local BaitLastPlaced, BaitLocation, CanSell = 0, nil, true
local HuntingAnimals = {
    { Animal = 'Pig',            Model = GetHashKey('a_c_pig'),        Illegal = false },
    { Animal = 'Cow',            Model = GetHashKey('a_c_cow'),        Illegal = false },
    { Animal = 'Boar',           Model = GetHashKey('a_c_boar'),       Illegal = false },
    { Animal = 'Deer',           Model = GetHashKey('a_c_deer'),       Illegal = false },
    { Animal = 'Coyote',         Model = GetHashKey('a_c_coyote'),     Illegal = false },
    { Animal = 'Mountain-Lion',  Model = GetHashKey('a_c_mtlion'),     Illegal = true },
    { Animal = 'Retriever',      Model = GetHashKey('a_c_retriever'),  Illegal = true },
    { Animal = 'Rottweiler',     Model = GetHashKey('a_c_rottweiler'), Illegal = true },
}

DecorRegister("HuntingSpawn", 2)
DecorRegister("HuntingIllegal", 2)

-- Loops
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if not LoggedIn or InsideHuntingZone() then goto Skip end

        if IsPedArmed(PlayerPedId(), 6) then
            if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey('weapon_huntingrifle') then
                TriggerEvent('fw-inventory:Client:ResetWeapon')
            end
        end

        ::Skip::
        Citizen.Wait(2500)
    end
end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(4)
--         if not LoggedIn then goto Skip end

--         if not InsideHuntingZone() then
--             exports['fw-assets']:SetDensity('Peds', 0.55)
--             exports['fw-assets']:SetDensity('Scenarios', 0.55)
--         else
--             PopulateNow()
--             exports['fw-assets']:SetDensity('Peds', 1.0)
--             exports['fw-assets']:SetDensity('Scenarios', 1.0)
--         end
--         ::Skip::
--         Citizen.Wait(15000)
--     end
-- end)

-- Events
RegisterNetEvent('fw-jobmanager:Client:HuntingSell')
AddEventHandler('fw-jobmanager:Client:HuntingSell', function()
    if not CanSell then return end

    TriggerServerEvent('fw-jobmanager:Server:HuntingSell')
    CanSell = false
    Citizen.SetTimeout(10000, function()
        CanSell = true
    end)
end)

RegisterNetEvent('fw-items:Client:Used:HuntingBait')
AddEventHandler('fw-items:Client:Used:HuntingBait', function()
    if not InsideHuntingZone() then 
        FW.Functions.Notify("Je zit niet in het jaaggebied..", 'error')
        return 
    end

    if BaitLastPlaced == 0 or GetGameTimer() > (BaitLastPlaced + (60000 * 5)) then
        ClearPedTasks(PlayerPedId())
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
        exports['fw-inventory']:SetBusyState(true)
        
        local Finished = FW.Functions.CompactProgressbar(5000, "Lokaas plaatsen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
        if Finished then
            local DidRemove = FW.SendCallback("FW:RemoveItem", 'hunting-bait', 1, false, false)
            if DidRemove then
                BaitLocation = GetEntityCoords(PlayerPedId())
                BaitLastPlaced = GetGameTimer()
                ClearPedTasks(PlayerPedId())
                BaitDown()
            end
        end
        exports['fw-inventory']:SetBusyState(false)
    else
        FW.Functions.Notify("Je neus kan het nog niet hebben..", 'error')
    end
end)

RegisterNetEvent('fw-items:Client:Used:HuntingKnife')
AddEventHandler('fw-items:Client:Used:HuntingKnife', function()
    local TargetEntity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())
    local IsAnimal = GetPedType(TargetEntity) == 28

    if TargetEntity == nil then return end
    if EntityType ~= 1 then return end
    if not DoesEntityExist(TargetEntity) then return end

    if IsAnimal and IsPedDeadOrDying(TargetEntity) then
        local AnimalName = GetAnimalName(TargetEntity)
        local BaitAnimal = DecorExistOn(TargetEntity, "HuntingSpawn") and DecorGetBool(TargetEntity, "HuntingSpawn")
        local IllegalAnimal = DecorExistOn(TargetEntity, "HuntingIllegal") and DecorGetBool(TargetEntity, "HuntingIllegal")
        TaskTurnPedToFaceEntity(PlayerPedId(), TargetEntity, -1)
        Citizen.Wait(1500)
        ClearPedTasksImmediately(PlayerPedId())
        TriggerEvent('fw-inventory:Client:ResetWeapon')
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

        local Finished = FW.Functions.CompactProgressbar(5000, "Dier ontleden...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
        ClearPedTasks(PlayerPedId())
        if not Finished then
            return FW.Functions.Notify("Ontleden geannuleerd..", "error")
        end

        if not exports['fw-police']:IsStatusAlreadyActive('huntbleed') then
            TriggerEvent('fw-police:Client:SetStatus', 'huntbleed', 300)
        end

        NetworkRequestControlOfEntity(TargetEntity)
        DeleteEntity(TargetEntity)

        -- temp fix???????????
        if DoesEntityExist(TargetEntity) then
            SetEntityCoords(TargetEntity, 0.0, 0.0, 0.0)
        end
        TriggerServerEvent('fw-jobmanager:Server:HuntingReceiveGoods', AnimalName, BaitAnimal, IllegalAnimal)
    else
        FW.Functions.Notify("Dat is geen dier dud..", 'error')
    end
end)

-- Functions
Citizen.CreateThread(function()
    local HuntingBlip = AddBlipForCoord(Config.HuntingLocation)
    SetBlipSprite(HuntingBlip, 141)
    SetBlipDisplay(HuntingBlip, 4)
    SetBlipScale(HuntingBlip, 0.43)
    SetBlipAsShortRange(HuntingBlip, true)
    SetBlipColour(HuntingBlip, 26)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Jaaggebied")
    EndTextCommandSetBlipName(HuntingBlip)

    local HuntingSales = AddBlipForCoord(569.4, 2796.63, 42.02)
    SetBlipSprite(HuntingSales, 442)
    SetBlipDisplay(HuntingSales, 4)
    SetBlipScale(HuntingSales, 0.43)
    SetBlipAsShortRange(HuntingSales, true)
    SetBlipColour(HuntingSales, 26)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Jaag Verkoop")
    EndTextCommandSetBlipName(HuntingSales)

    local HuntingArea = AddBlipForRadius(Config.HuntingLocation, 700.0)        
    SetBlipRotation(HuntingArea, 0)
    SetBlipColour(HuntingArea, 0)
    SetBlipAlpha(HuntingArea, 100)

    exports['fw-ui']:AddEyeEntry("hunting-sells", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 5.0,
        Distance = 1.0,
        Position = vector4(569.25, 2796.69, 41.35, 270.65),
        Model = 'csb_chef',
        Anim = {},
        Props = {},
        Options = {
            {
                Name = 'hunting_sell',
                Icon = 'fas fa-dollar-sign',
                Label = 'Verkopen',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:HuntingSell',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })
end)

function BaitDown()
    Citizen.CreateThread(function()
        if BaitLocation ~= nil then
            local SpawnCoords = GetAnimalSpawnCoords(BaitLocation)
            local RandomAnimal = HuntingAnimals[math.random(1, #HuntingAnimals)]
            Citizen.SetTimeout(math.random(15000, 60000), function()
                RequestModel(RandomAnimal.Model)
                while not HasModelLoaded(RandomAnimal.Model) do Citizen.Wait(4) end

                local SpawnedAnimal = CreatePed(28, RandomAnimal.Model, SpawnCoords.x, SpawnCoords.y, SpawnCoords.z, true, true, true)
                SetNewWaypoint(SpawnCoords.x, SpawnCoords.y)
                DecorSetBool(SpawnedAnimal, "HuntingSpawn", true)
                DecorSetBool(spawnedAnimal, "HuntingIllegal", RandomAnimal.Illegal)
    
                if RandomAnimal.Illegal and math.random() < 0.33 then
                    TriggerServerEvent('fw-mdw:Server:SendAlert:IllegalHunting', GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())
                end

                TaskGoStraightToCoord(SpawnedAnimal, BaitLocation, 20.0, -1, 0.0, 0.0)
                Citizen.CreateThread(function()
                    local Finished = false
                    while not Finished and not IsPedDeadOrDying(SpawnedAnimal) and not IsPedFleeing(SpawnedAnimal) do
                        Citizen.Wait(0)
                        local AnimalCoords = GetEntityCoords(SpawnedAnimal)
                        if #(BaitLocation - AnimalCoords) < 1.5 then
                            ClearPedTasks(SpawnedAnimal)
                            Citizen.Wait(350)
                            TaskStartScenarioInPlace(SpawnedAnimal, "WORLD_DEER_GRAZING", 0, true)
                            Citizen.SetTimeout(7500, function()
                                ClearPedTasks(SpawnedAnimal)
                                TaskSmartFleePed(SpawnedAnimal, PlayerPedId(), 10.0, -1)
                                Finished, BaitLocation = true, nil
                            end)
                        end
                        if #(AnimalCoords - GetEntityCoords(PlayerPedId())) < 15.0 then
                            ClearPedTasks(SpawnedAnimal)
                            TaskSmartFleePed(SpawnedAnimal, PlayerPedId(), 600.0, -1)
                            Finished, BaitLocation = true, nil
                        end
                        if IsPedDeadOrDying(SpawnedAnimal) then
                            ClearPedTasks(SpawnedAnimal)
                            TaskSmartFleePed(SpawnedAnimal, PlayerPedId(), 600.0, -1)
                            Finished, BaitLocation = true, nil
                        end
                    end
                end)
            end)
        end
    end)
end

function GetAnimalSpawnCoords(Coords)
    local RandomX = math.random(-50, 50)
    local RandomY = math.random(-50, 50)
    local NewCoords = vector3(Coords.x + RandomX, Coords.y + RandomY, Coords.z)
    local Nothing, ResultZ = GetGroundZAndNormalFor_3dCoord(NewCoords.x, NewCoords.y, 1023.9)
    return vector3(NewCoords.x, NewCoords.y, ResultZ)
end

function InsideHuntingZone()
    local Coords = GetEntityCoords(PlayerPedId())
    local Distance = #(Coords - Config.HuntingLocation)
    if Distance < 700.0 then
        return true
    else
        return false
    end
end

function GetAnimalName(Ped)
    local AnimalHash = GetEntityModel(Ped)
    local AnimalDNA = "Unknown-Animal"
    for k, v in pairs(HuntingAnimals) do
        if v.Model == AnimalHash then
            AnimalDNA = v.Animal
        end
    end
    return AnimalDNA
end

exports("InsideHuntingZone", InsideHuntingZone)