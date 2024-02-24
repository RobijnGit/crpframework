local GardenHash = -844411340
local MaterialHashes = { -461750719, 930824497, 581794674, -2041329971, -309121453, -913351839, -1885547121, -1915425863, -1833527165, 2128369009, -124769592, -840216541, -2073312001, 627123000, 1333033863, -1286696947, -1942898710, -1595148316, 435688960, 223086562, 1109728704, 1144315879, -700658213 }
local CreatedPlants, Plants = {}, {}
local UsingHoe, UsingPitchfork = false, false

-- Syncing
Citizen.CreateThread(function()
    while true do
        if LoggedIn then

            for k, v in pairs(CreatedPlants) do
                DeleteObject(v.Object)
                CreatedPlants[k] = nil
            end

            Plants = FW.SendCallback("fw-misc:Server:GetNearbyPlants", GetEntityCoords(PlayerPedId()))
        else
            Citizen.Wait(25000)
        end

        Citizen.Wait((1000 * 60) * 2)
    end
end)

Citizen.CreateThread(function()
    while true do
        local Coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Plants) do
            -- Only process 100 per frame.
            if k % 100 == 0 then
                Citizen.Wait(0)
            end

            if #(Coords - vector3(v.Coords.x, v.Coords.y, v.Coords.z)) < 50.0 then
                local IsChanged = CreatedPlants[v.Id] and CreatedPlants[v.Id].Stage ~= v.Stage or false

                if not CreatedPlants[v.Id] or IsChanged then
                    if CreatedPlants[v.Id] then
                        DeleteObject(CreatedPlants[v.Id].Object)
                        CreatedPlants[v.Id] = nil
                    end

                    local PlantObject = CreatePlant(v.Plant, v.Stage, v.Coords)
                    CreatedPlants[v.Id] = {
                        Object = PlantObject,
                        Stage = v.Stage,
                    }
                end
            elseif CreatedPlants[v.Id] then
                DeleteObject(CreatedPlants[v.Id].Object)
                CreatedPlants[v.Id] = nil
            end
        end

        Citizen.Wait(2000)
    end
end)

RegisterNetEvent("fw-misc:Client:UpdatePlants")
AddEventHandler("fw-misc:Client:UpdatePlants", function(PlantId, Data)
    local Key = GetPlantKey(PlantId)

    if not Key then
        table.insert(Plants, Data)
    else
        Plants[Key] = Data
    end
end)

RegisterNetEvent("fw-misc:Client:RemovePlant")
AddEventHandler("fw-misc:Client:RemovePlant", function(PlantId)
    local Key = GetPlantKey(PlantId)
    if not Key then return end

    if CreatedPlants[PlantId] then
        DeleteObject(CreatedPlants[PlantId].Object)
        CreatedPlants[PlantId] = nil
    end

    table.remove(Plants, Key)
end)

RegisterNetEvent("fw-misc:Client:RefetchPlants")
AddEventHandler("fw-misc:Client:RefetchPlants", function(Data)
    Plants = Data
end)

RegisterNetEvent("fw-misc:Client:Farming:UsedSeed")
AddEventHandler("fw-misc:Client:Farming:UsedSeed", function(Item)
    local SeedModel = Config.FarmCrops[Item.CustomType][1]
    if SeedModel == nil then
        return
    end

    -- Place the seed
    local DidPlace, Coords, Rotation = table.unpack(DoEntityPlacer(SeedModel, 15.0, true, true, nil, true))
    if not DidPlace then return end

    -- Is the seed on a plantable material?
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(Coords.x, Coords.y, Coords.z, Coords.x, Coords.y, Coords.z - 1, 1, 0, 4)
    local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)

    if not IsPlantMaterial(MaterialHash) then
        return FW.Functions.Notify("Hier kan je geen plantje plaatsen..", "error")
    end

    -- Is the plant nearby another plant?
    local IsNearPlant = GetPlantByCoords(Coords)
    if IsNearPlant then
        return FW.Functions.Notify("Hier is al iets geplant..", "error")
    end

    exports['fw-inventory']:SetBusyState(true)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

    local Finished = FW.Functions.CompactProgressbar(5000, "Zaadje plaatsen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    ClearPedTasks(PlayerPedId())

    if not Finished then return end

    local DidRemove = FW.SendCallback("FW:RemoveItem", 'farming-seed', 1, Item.Slot, Item.CustomType)
    if not DidRemove then return end

    FW.TriggerServer("fw-misc:Server:Farming:PlacePlant", Coords, Rotation, Item.CustomType)
end)

RegisterNetEvent("fw-misc:Client:Farming:PlantMenu")
AddEventHandler("fw-misc:Client:Farming:PlantMenu", function(Data, Entity)
    local Key = GetPlantByObject(Entity)
    if not Key then return end

    local PlantData = Plants[Key]
    local MenuItems = {}

    local IsProtectedPlant, GardenEntity = IsThisPlantProtected(Entity)
    local GardenId = IsProtectedPlant and GetGardenIdByCoords(GetEntityCoords(GardenEntity)) or false

    if IsProtectedPlant and GardenId then
        local GardenRenter = FW.SendCallback("fw-misc:Server:GetGardenRenter", GardenId)
        if not GardenRenter or GardenRenter == FW.Functions.GetPlayerData().citizenid then
            goto Skip
        end

        return FW.Functions.Notify("Dit moestuintje is niet van jou..", "error")
    end

    ::Skip::

    local TotalStages = #Config.FarmCrops[PlantData.Plant] - 1
    local CurrentStage = PlantData.Stage
    local Percentage = math.floor((100 / TotalStages) * CurrentStage)

    MenuItems[#MenuItems + 1] = {
        Icon = "seedling",
        Title = Config.CropLabels[PlantData.Plant],
        Desc = "Water: " .. PlantData.Water .. "%; Stage: " .. (Percentage > 100 and "Dood" or (Percentage .. "%"))
    }

    MenuItems[#MenuItems + 1] = {
        Icon = "tint",
        Title = "Water",
        Desc = "Geef je plant wat water.",
        Disabled = not exports['fw-inventory']:HasEnoughOfItem('farming-wateringcan', 1),
        Data = {
            Event = 'fw-misc:Client:Farming:WaterPlant',
            Type = 'Client',
            PlantId = PlantData.Id,
            Entity = Entity
        },
    }

    if CurrentStage == TotalStages then
        MenuItems[#MenuItems + 1] = {
            Icon = "shovel",
            Title = "Oogsten",
            Desc = CurrentStage < TotalStages and "Je plant is nog klaar om te oogsten!" or "",
            Disabled = CurrentStage < TotalStages,
            Data = {
                Event = 'fw-misc:Client:Farming:HarvestPlant',
                Type = 'Client',
                PlantId = PlantData.Id,
                Entity = Entity
            },
        }
    else
        MenuItems[#MenuItems + 1] = {
            Icon = "angry",
            Title = "Verwoesten",
            Data = {
                Event = 'fw-misc:Client:Farming:DestroyPlant',
                Type = 'Client',
                PlantId = PlantData.Id,
                Entity = Entity
            },
        }
    end

    FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
end)

RegisterNetEvent("fw-misc:Client:Farming:WaterPlant")
AddEventHandler("fw-misc:Client:Farming:WaterPlant", function(Data)
    local Key = GetPlantKey(Data.PlantId)
    if not Key then return end

    local PlantData = Plants[Key]

    local HasWateringCan = exports['fw-inventory']:HasEnoughOfItem("farming-wateringcan", 1)
    if not HasWateringCan then return FW.Functions.Notify("Je mist een gieter..", "error") end

    local WateringCan = exports['fw-inventory']:GetItemByName("farming-wateringcan")
    if WateringCan == nil then return end

    if WateringCan.Info.Capacity ~= nil and WateringCan.Info.Capacity < 1.0 then
        return FW.Functions.Notify("De gieter is leeg..", "error")
    end

    if PlantData.Water > 50 then
        return FW.Functions.Notify("Dit plantje heeft al genoeg water..", "error")
    end

    TaskTurnPedToFaceEntity(PlayerPedId(), Data.Entity, 1000)
    Citizen.Wait(1000)
    exports['fw-inventory']:SetBusyState(true)
    exports['fw-assets']:AddProp('wateringcan')

    local Finished = FW.Functions.CompactProgressbar(7000, "Plantje water geven...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = 'fire', animDict = 'weapon@w_sp_jerrycan', flags = 49 }, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    exports['fw-assets']:RemoveProp()

    if Finished then
        TriggerServerEvent("fw-misc:Server:Farming:SetWateringCanCapacity", WateringCan.Slot, (WateringCan.Info.Capacity ~= nil and WateringCan.Info.Capacity or 100.0) - 1.0)
        TriggerServerEvent("fw-misc:Server:Farming:WaterPlant", PlantData.Id)
    end
end)

RegisterNetEvent("fw-misc:Client:Farming:HarvestPlant")
AddEventHandler("fw-misc:Client:Farming:HarvestPlant", function(Data)
    local Key = GetPlantKey(Data.PlantId)
    if not Key then return end

    exports['fw-inventory']:SetBusyState(true)

    TaskTurnPedToFaceEntity(PlayerPedId(), Data.Entity, 1000)
    Citizen.Wait(1000)

    ClearPedTasks(PlayerPedId())
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

    local Finished = FW.Functions.CompactProgressbar(7000, "Plantje oogsten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())

    exports['fw-inventory']:SetBusyState(false)
    exports['fw-assets']:RemoveProp()

    if Finished then
        TriggerServerEvent("fw-misc:Server:Farming:HarvestPlant", Data.PlantId)
    end
end)

RegisterNetEvent("fw-misc:Client:Farming:DestroyPlant")
AddEventHandler("fw-misc:Client:Farming:DestroyPlant", function(Data)
    local Key = GetPlantKey(Data.PlantId)
    if not Key then return end

    exports['fw-inventory']:SetBusyState(true)

    TaskTurnPedToFaceEntity(PlayerPedId(), Data.Entity, 1000)
    Citizen.Wait(1000)

    ClearPedTasks(PlayerPedId())
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

    local Finished = FW.Functions.CompactProgressbar(7000, "Plantje verwoesten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())

    exports['fw-inventory']:SetBusyState(false)
    exports['fw-assets']:RemoveProp()

    if Finished then
        TriggerServerEvent("fw-misc:Server:Farming:DestroyCrop", Data.PlantId)
    end
end)

RegisterNetEvent("fw-misc:Client:Farming:RentGarden")
AddEventHandler("fw-misc:Client:Farming:RentGarden", function(Data, Entity)
    local GardenId = GetGardenIdByCoords(GetEntityCoords(Entity))
    if not GardenId then
        return FW.Functions.Notify("Dit tuintje kan niet gehuurd worden..", "error")
    end

    local IsGardenRentable = FW.SendCallback("fw-misc:Server:IsGardenRentable", GardenId)
    if not IsGardenRentable then
        return FW.Functions.Notify("Je kan dit tuintje momenteel niet huren..", "error")
    end

    FW.TriggerServer("fw-misc:Server:Farming:RentGarden", GardenId, Data.RentPrice, Data.RentHours)
end)

RegisterNetEvent("fw-misc:Client:Farming:UsedWateringcan")
AddEventHandler("fw-misc:Client:Farming:UsedWateringcan", function(Item)
    if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then return end
    if not IsEntityInWater(PlayerPedId()) then return end
    if IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId()) then return end

    local Quality = exports['fw-inventory']:CalculateQuality(Item.Item, Item.CreateDate)
    if Quality <= 10 then return FW.Functions.Notify("Dat ding is lekker verroest.. Weg ermee!", "error") end

    exports['fw-inventory']:SetBusyState(true)
    exports['fw-assets']:AddProp('wateringcan')

    local Finished = FW.Functions.CompactProgressbar(8500, "Gieter vullen met water...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = 'fire', animDict = 'weapon@w_sp_jerrycan', flags = 49 }, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    exports['fw-assets']:RemoveProp()

    if Finished then
        TriggerServerEvent("fw-misc:Server:Farming:SetWateringCanCapacity", Item.Slot, 100.0)
        FW.Functions.Notify("Die gieter zit weer vol!", "success")
    else
        FW.Functions.Notify("Je water viel eruit..", "error")
    end
end)

RegisterNetEvent("fw-misc:Client:Farming:UsedPitchfork")
AddEventHandler("fw-misc:Client:Farming:UsedPitchfork", function(Item)
    if UsingPitchfork then
        return FW.Functions.Notify("Je gebruikt je hooivork al!", "error")
    end

    local Hit, Pos, Entity = nil, nil, nil
    local FarmId = CurrentFarm

    UsingPitchfork = true
    Citizen.CreateThread(function()
        while true do
            Hit, Pos, Entity = exports['fw-ui']:RayCastGamePlayCamera(10.0)
            DrawMarker(43, Pos.x, Pos.y, Pos.z - 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 255, 0, 200, false, true, 2, nil, nil, false)

            if IsControlJustReleased(0, 38) then
                break
            end

            if IsControlJustReleased(0, 202) then
                UsingPitchfork = false
                return
            end

            Citizen.Wait(4)
        end

        local PlantIds = GetPlantsInSquare(Pos, 2.0)
        exports['fw-inventory']:SetBusyState(true)

        local CanHarvestPlant = true
        for k, v in pairs(PlantIds) do
            if not exports['fw-inventory']:HasEnoughOfItem('farming-pitchfork', 1) then
                FW.Functions.Notify("Je hooivork is kapot gegaan..", "error")
                break
            end

            local Key = GetPlantKey(v)
            if not Key then return end

            local IsProtectedPlant, GardenEntity = IsThisPlantProtected(CreatedPlants[v].Object)
            local GardenId = IsProtectedPlant and GetGardenIdByCoords(GetEntityCoords(GardenEntity)) or false

            if IsProtectedPlant and GardenId then
                local GardenRenter = FW.SendCallback("fw-misc:Server:GetGardenRenter", GardenId)
                if GardenRenter and GardenRenter ~= FW.Functions.GetPlayerData().citizenid then
                    CanHarvestPlant = false
                    FW.Functions.Notify("Er kon een plant niet geoogst worden! (Dit moestuintje is niet van jou..)")
                end
            end

            if CanHarvestPlant then
                TaskTurnPedToFaceEntity(PlayerPedId(), CreatedPlants[v].Object, 1000)
                Citizen.Wait(1000)

                ClearPedTasks(PlayerPedId())
                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

                local Finished = FW.Functions.CompactProgressbar(5000, "Plantje oogsten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
                ClearPedTasks(PlayerPedId())

                if Finished then
                    TriggerServerEvent("fw-misc:Server:Farming:HarvestPlant", v)
                end

                Citizen.Wait(1000)
                ClearPedTasksImmediately(PlayerPedId())
                TriggerServerEvent('fw-inventory:Server:DecayItem', 'farming-pitchfork', nil, 0.5)
            end
        end

        exports['fw-inventory']:SetBusyState(false)
        UsingPitchfork = false
    end)
end)

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
    if FromItem.Item ~= 'farming-seed' then return end
    if ToItem.Item ~= 'farming-hoe' then return end

    if UsingHoe then
        return FW.Functions.Notify("Je gebruikt je schoffel al!", "error")
    end

    UsingHoe = true
    local StartingPoint, EndingPoint = false, false

    local MaxSeedsToPlant = math.min(exports['fw-inventory']:GetItemCount('farming-seed', FromItem.CustomType), 12)
    local CropPreviewObjects = {}
    local CameraCrop = CreatePlant(FromItem.CustomType, 1, vector3(0.0, 0.0, 0.0))
    SetEntityCollision(CameraCrop, false, false)
    SetEntityDrawOutline(CameraCrop, true)
    SetEntityDrawOutlineColor(0, 255, 0, 255)
    SetEntityAlpha(CameraCrop, 0.3, true)

    Citizen.CreateThread(function()
        while true do
            local Hit, Pos, Entity = exports['fw-ui']:RayCastGamePlayCamera(10.0)
            if CameraCrop then
                SetEntityCoords(CameraCrop, Pos.x, Pos.y, Pos.z)
            end

            if #(vector3(0.0, 0.0, 0.0) - Pos) > 1.0 then
                if IsControlJustReleased(0, 38) then
                    if StartingPoint == false then
                        StartingPoint = Pos
                        DeleteObject(CameraCrop)
                        CameraCrop = 0
                    else
                        EndingPoint = Pos
                        break
                    end
                end

                if IsControlJustReleased(0, 202) then
                    UsingHoe = false
                    break
                end

                local CropCoords = StartingPoint and GetCoordsAlongLine(StartingPoint, Pos, MaxSeedsToPlant) or {}
                for k, v in pairs(CropPreviewObjects) do
                    DeleteObject(v)
                end

                CropPreviewObjects = {}
                for k, v in pairs(CropCoords) do
                    local CropEntity = CreatePlant(FromItem.CustomType, 1, vector3(v.x, v.y, v.z))
                    SetEntityCollision(CropEntity, false, false)
                    SetEntityDrawOutline(CropEntity, true)
                    SetEntityDrawOutlineColor(0, 255, 0, 255)
                    SetEntityAlpha(CropEntity, 0.3, true)
                    PlaceObjectOnGroundProperly(CropEntity)
                    table.insert(CropPreviewObjects, CropEntity)
                end
            elseif #CropPreviewObjects > 0 then
                for k, v in pairs(CropPreviewObjects) do
                    DeleteObject(v)
                end
                CropPreviewObjects = {}
            end

            Citizen.Wait(4)
        end

        DeleteObject(CameraCrop)
        for k, v in pairs(CropPreviewObjects) do
            DeleteObject(v)
        end

        if not UsingHoe then return end

        local CropCoords = GetCoordsAlongLine(StartingPoint, EndingPoint, MaxSeedsToPlant)
        if #CropCoords == 0 then
            return
        end

        exports['fw-inventory']:SetBusyState(true)

        local IsPlacingCrops = true
        Citizen.CreateThread(function()
            while IsPlacingCrops do
                DisableAllControlActions(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                EnableControlAction(0, 22, true)
                EnableControlAction(0, 38, true)
                EnableControlAction(0, 245, true)
                EnableControlAction(0, 249, true)
                EnableControlAction(0, 322, true)
                Citizen.Wait(4)
            end
        end)

        for k, PlantCoords in pairs(CropCoords) do
            if not exports['fw-inventory']:HasEnoughOfItem('farming-seed', 1, FromItem.CustomType) then
                FW.Functions.Notify("Je zaadjes zijn op..", "error")
                break
            end

            if not exports['fw-inventory']:HasEnoughOfItem('farming-hoe', 1) then
                FW.Functions.Notify("Je schoffel is kapot gegaan..", "error")
                break
            end

            local CanPlacePlant = true

            local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(PlantCoords.x, PlantCoords.y, PlantCoords.z, PlantCoords.x, PlantCoords.y, PlantCoords.z - 1, 1, 0, 4)
            local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)

            if not IsPlantMaterial(MaterialHash) then
                FW.Functions.Notify("Er kon een plant niet geplaats worden! (Hier kan je geen plantje plaatsen..)")
                CanPlacePlant = false
            end

            local DummyHash = GetHashKey("fw_scene_dummy")
            exports['fw-assets']:RequestModelHash(DummyHash)

            local TempObj = CreateObjectNoOffset(DummyHash, PlantCoords.x, PlantCoords.y, PlantCoords.z, 0, 0, 0)
            SetEntityCollision(TempObj, false, false)
            FreezeEntityPosition(TempObj, true)
            SetEntityAlpha(TempObj, 0)

            local IsProtectedPlant, GardenEntity = IsThisPlantProtected(TempObj)
            local GardenId = IsProtectedPlant and GetGardenIdByCoords(GetEntityCoords(GardenEntity)) or false

            if IsProtectedPlant and GardenId then
                local GardenRenter = FW.SendCallback("fw-misc:Server:GetGardenRenter", GardenId)
                if GardenRenter and GardenRenter ~= FW.Functions.GetPlayerData().citizenid then
                    CanPlacePlant = false
                    FW.Functions.Notify("Er kon een plant niet geplaats worden! (Dit moestuintje is niet van jou..)")
                end
            end

            local IsNearPlant = GetPlantByCoords(PlantCoords)
            if IsNearPlant then
                FW.Functions.Notify("Er kon een plant niet geplaats worden! (Hier is al iets geplant..)")
                CanPlacePlant = false
            end

            if CanPlacePlant then
                TaskGoToEntity(PlayerPedId(), TempObj, 5500.0, 0.1, 1.0, 1073741824, 0)
                local DistanceChecked = 0
                while #(GetEntityCoords(PlayerPedId()) - vector3(PlantCoords.x, PlantCoords.y, PlantCoords.z)) > 1.5 and DistanceChecked < 60 do
                    Citizen.Wait(250)
                    DistanceChecked = DistanceChecked + 1
                end
                Citizen.Wait(1000)
                TaskTurnPedToFaceEntity(PlayerPedId(), TempObj, 1000.0)
                Citizen.Wait(1000)

                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

                local Finished = FW.Functions.CompactProgressbar(5000, "Zaadje plaatsen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
                ClearPedTasks(PlayerPedId())

                if Finished then
                    local DidRemove = FW.SendCallback("FW:RemoveItem", 'farming-seed', 1, nil, FromItem.CustomType)
                    if DidRemove then
                        FW.TriggerServer("fw-misc:Server:Farming:PlacePlant", PlantCoords, GetEntityHeading(PlayerPedId()), FromItem.CustomType)
                    end
                end

                Citizen.Wait(1000)
                ClearPedTasksImmediately(PlayerPedId())
                TriggerServerEvent('fw-inventory:Server:DecayItem', 'farming-hoe', nil, 0.5)
            end

            ::Skip::

            DeleteObject(TempObj)
        end

        UsingHoe, IsPlacingCrops = false, false
        exports['fw-inventory']:SetBusyState(false)
    end)
end)

-- Utils

function IsThisPlantProtected(Entity)
    local EntityBelow = GetEntityBelow(Entity)
    if EntityBelow and DoesEntityExist(EntityBelow) and GetEntityType(EntityBelow) ~= 0 and GetEntityModel(EntityBelow) == GardenHash then
        return true, EntityBelow
    end

    return false, 0
end

function CreatePlant(PlantType, Stage, Coords)
    local Model = Config.FarmCrops[PlantType][Stage]
    if not Model then return end

    exports['fw-assets']:RequestModelHash(Model)

    local PlantObject = CreateObject(Model, Coords.x, Coords.y, Coords.z, false, false, false)
    FreezeEntityPosition(PlantObject, true)
    SetEntityHeading(PlantObject, Coords.w)

    return PlantObject
end

function IsPlantMaterial(MaterialHash)
    for k, v in pairs(MaterialHashes) do
        if v == MaterialHash then
            return true
        end
    end
    return false
end

function GetGardenIdByCoords(Coords)
    for k, GardenCoords in pairs(Config.FarmingGardens) do
        if #(Coords - GardenCoords) < 1.0 then
            return k
        end
    end
    return false
end

function GetPlantKey(PlantId)
    for k, v in pairs(Plants) do
        if v.Id == PlantId then
            return k
        end
    end
    return false
end

function GetPlantByCoords(Coords)
    for k, v in pairs(Plants) do
        local Distance = #(Coords - vector3(v.Coords.x, v.Coords.y, v.Coords.z))
        if Distance < 0.7 then
            return k
        end
    end
    return false
end

function GetPlantByObject(Object)
    for k, v in pairs(CreatedPlants) do
        if v and v.Object == Object then
            return GetPlantKey(k)
        end
    end
    return false
end

function GetEntityBelow(TargetEntity)
    local TargetCoords = GetEntityCoords(TargetEntity)
    local EndCoords = TargetCoords - vector3(0, 0, 10.0)
    local rayHandle = StartShapeTestRay(TargetCoords.x, TargetCoords.y, TargetCoords.z + 0.5, EndCoords.x, EndCoords.y, EndCoords.z, -1, TargetEntity, 0)
    local _, hit, _, _, hitEntity = GetShapeTestResult(rayHandle)
    return hit and hitEntity or false
end

function GetCoordsAlongLine(StartCoord, EndCoord, MaxSteps)
    local StepSize, Retval = 0.95, {}
    local Direction = vector3(EndCoord.x - StartCoord.x, EndCoord.y - StartCoord.y, EndCoord.z - StartCoord.z)
    local Dist = #(EndCoord - StartCoord)
    local Steps = math.floor(Dist / StepSize)

    if Steps == 0 then
        return { StartCoord }
    end

    for i = 0, math.min(Steps, MaxSteps - 1) do
        local Fraction = i / Steps
        table.insert(Retval,
            vector3(
                StartCoord.x + Direction.x * Fraction,
                StartCoord.y + Direction.y * Fraction,
                StartCoord.z + Direction.z * Fraction
            )
        )
    end

    return Retval
end

function GetPlantsInSquare(Center, Size)
    local Retval = {}
    local HalfSize = Size / 2.0

    for k, v in ipairs(Plants) do
        local DiffX = math.abs(Center.x - v.Coords.x)
        local DiffY = math.abs(Center.y - v.Coords.y)

        if DiffX <= HalfSize and DiffY <= HalfSize then
            table.insert(Retval, v.Id)
        end
    end

    return Retval
end

AddEventHandler("onResourceStop", function()
    for k, v in pairs(CreatedPlants) do
        if v and v.Object then
            DeleteEntity(v.Object)
        end
    end
end)

-- Zones
RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("np_garden_001"), {
        Type = 'Model',
        Model = "np_garden_001",
        SpriteDistance = 10.0,
        Distance = 3.0,
        Options = {
            {
                Name = 'rent_3',
                Icon = 'fas fa-dollar-sign',
                Label = 'Tuintje huren voor 3 uur (€ 250,00)',
                EventType = 'Client',
                EventName = 'fw-misc:Client:Farming:RentGarden',
                EventParams = { RentHours = 3, RentPrice = 250 },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'rent_6',
                Icon = 'fas fa-dollar-sign',
                Label = 'Tuintje huren voor 6 uur (€ 500,00)',
                EventType = 'Client',
                EventName = 'fw-misc:Client:Farming:RentGarden',
                EventParams = { RentHours = 6, RentPrice = 500 },
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'rent_12',
                Icon = 'fas fa-dollar-sign',
                Label = 'Tuintje huren voor 12 uur (€ 1.000,00)',
                EventType = 'Client',
                EventName = 'fw-misc:Client:Farming:RentGarden',
                EventParams = { RentHours = 12, RentPrice = 1000 },
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    for i, j in pairs(Config.FarmCrops) do
        for k, v in pairs(j) do
            exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
                Type = 'Model',
                Model = v,
                SpriteDistance = 10.0,
                Distance = 2.0,
                Options = {
                    {
                        Name = 'details',
                        Icon = 'fas fa-seedling',
                        Label = 'Controleer',
                        EventType = 'Client',
                        EventName = 'fw-misc:Client:Farming:PlantMenu',
                        EventParams = {},
                        Enabled = function(Entity)
                            return true
                        end,
                    },
                }
            })
        end
    end
end)