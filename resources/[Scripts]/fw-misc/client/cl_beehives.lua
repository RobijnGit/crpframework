local CreatedBeehives = {}

Citizen.CreateThread(function()
    while true do
        local Coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Beehives) do
            -- Only process 100 per frame.
            if k % 100 == 0 then
                Citizen.Wait(0)
            end

            local HivePercentage = GetHivePercentage(v)
            if #(Coords - v.Coords) < (50.0 + HivePercentage) then
                local HiveStage = GetHiveStage(HivePercentage)
                local IsChanged = CreatedBeehives[v.Id] and CreatedBeehives[v.Id].Stage ~= HiveStage or false

                if not CreatedBeehives[v.Id] or IsChanged then
                    if CreatedBeehives[v.Id] then
                        DeleteObject(CreatedBeehives[v.Id].Object)
                        CreatedBeehives[v.Id] = nil
                    end

                    local HiveObject = CreateHive(HiveStage, v.Coords, v.Rotation)

                    CreatedBeehives[v.Id] = {
                        Object = HiveObject,
                        Stage = HiveStage
                    }
                end
            elseif CreatedBeehives[v.Id] then
                DeleteObject(CreatedBeehives[v.Id].Object)
                CreatedBeehives[v.Id] = nil
            end
        end

        Citizen.Wait(2000)
    end
end)

RegisterNetEvent("fw-misc:Client:SetHiveData")
AddEventHandler("fw-misc:Client:SetHiveData", function(Type, HiveId, HiveData)
    if not LoggedIn then return end
    if Type == "Set" then
        for k, v in pairs(Config.Beehives) do
            if v.Id == HiveId then
                Config.Beehives[k] = HiveData
                return
            end
        end

        table.insert(Config.Beehives, HiveData)

    elseif Type == "Remove" then
        for k, v in pairs(Config.Beehives) do
            if v.Id == HiveId then
                table.remove(Config.Beehives, k)
                break
            end
        end

        if CreatedBeehives[HiveId] and CreatedBeehives[HiveId].Object then
            DeleteObject(CreatedBeehives[HiveId].Object)
            CreatedBeehives[HiveId] = nil
        end
    end
end)

RegisterNetEvent("fw-misc:Client:PlaceBeehive")
AddEventHandler("fw-misc:Client:PlaceBeehive", function()
    if exports['fw-core']:IsPlacingEntity() then
        return
    end

    -- if not IsInBeehiveZone() then
    --     return FW.Functions.Notify("Ik denk dat ik maar een betere plek moet gaan vinden om een bijenkorf op te bouwen..")
    -- end

    local DidPlace, Coords, Rotation = table.unpack(DoEntityPlacer('beehive', 15.0, true, true, nil, false))
    if not DidPlace then return end

    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(Coords.x, Coords.y, Coords.z, Coords.x, Coords.y, Coords.z - 2, 1, 0, 4)
    local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)
    if not Config.BeehivesMaterial[MaterialHash] then
        return FW.Functions.Notify("Ik denk dit stuk grond niet geschikt is voor een bijenkorf..")
    end

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_HAMMERING", 0, true)
    local Finished = FW.Functions.CompactProgressbar(1500, "Bijenkorf opbouwen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())

    if not Finished then return end
    local DidRemove = FW.SendCallback("FW:RemoveItem", "beehive", 1)
    if not DidRemove then return end

    FW.TriggerServer("fw-misc:Server:PlaceBeehive", Coords, Rotation)
end)

RegisterNetEvent("fw-misc:Client:CheckHive")
AddEventHandler("fw-misc:Client:CheckHive", function(Data, Entity)
    local HiveData = GetHiveByEntity(Entity)
    if not HiveData then return end

    local HivePercentage = GetHivePercentage(HiveData)
    local MenuItems = {}

    MenuItems[#MenuItems + 1] = {
        Icon = 'info-circle',
        Title = "Oogst Percentage: " .. string.format("%.1f", HivePercentage) .. "%",
        Desc = "Bijen Koningin: " .. (HiveData.HasQueen and "Ja" or "Nee"),
        Data = { Event = '', Type = ''  },
        CloseMenu = false,
    }

    if GetHiveStage(HivePercentage) < 2 and not HiveData.HasQueen then
        MenuItems[#MenuItems + 1] = {
            Icon = 'chess-queen',
            Title = "Bijen Koningin toevoegen",
            Desc = "Maak de bijenkorf blij.",
            Disabled = not exports['fw-inventory']:HasEnoughOfItem('bee-queen', 1),
            Data = { Event = 'fw-misc:Client:AddQueenToHive', Type = 'Client', HiveId = HiveData.Id },
        }
    end

    local PlayerJob = FW.Functions.GetPlayerData().job
    if HivePercentage >= 95 or (PlayerJob.name == "police" or PlayerJob.name == "judge") then
        MenuItems[#MenuItems + 1] = {
            Icon = 'trash',
            Title = "Bijenkorf Slopen",
            Desc = "Opgerot met die kut beesten..",
            Data = { Event = 'fw-misc:Client:DestroyHive', Type = 'Client', HiveId = HiveData.Id },
        }
    end

    Citizen.SetTimeout(50, function()
        FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
    end)
end)

RegisterNetEvent("fw-misc:Client:AddQueenToHive")
AddEventHandler("fw-misc:Client:AddQueenToHive", function(Data)
    if not Data.HiveId then return end

    local HiveData = GetHiveById(Data.HiveId)
    if not HiveData then return end

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local Finished = FW.Functions.CompactProgressbar(15000, "Bijen Koningin toevoegen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())
    
    if not Finished then return end
    local DidRemove = FW.SendCallback("FW:RemoveItem", "bee-queen", 1)
    if not DidRemove then return end

    FW.TriggerServer("fw-misc:Server:AddQueenToHive", Data.HiveId)
end)

RegisterNetEvent("fw-misc:Client:DestroyHive")
AddEventHandler("fw-misc:Client:DestroyHive", function(Data)
    if not Data.HiveId then return end

    local HiveData = GetHiveById(Data.HiveId)
    if not HiveData then return end

    local Finished = FW.Functions.CompactProgressbar(15000, "Slopen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = "plant_floor", animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", flags = 48 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)
    
    if not Finished then return end
    FW.TriggerServer("fw-misc:Server:DestroyHive", Data.HiveId)
end)

RegisterNetEvent("fw-misc:Client:HarvestHive")
AddEventHandler("fw-misc:Client:HarvestHive", function(Data, Entity)
    local HiveData = GetHiveByEntity(Entity)
    if not HiveData then return end

    local HivePercentage = GetHivePercentage(HiveData)

    if HivePercentage < 100.0 or (GetCloudTimeAsInt() - HiveData.LastHarvest <= (180 * 60)) then
        return FW.Functions.Notify("Ik denk dat de ik nog maar even moet wachten met oogsten..", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(5000, "Oogsten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = "plant_floor", animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", flags = 48 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)

    if not Finished then return end

    FW.TriggerServer("fw-misc:Server:HarvestHive", HiveData.Id)
end)

AddEventHandler("onResourceStop", function()
    for k, v in pairs(CreatedBeehives) do
        if v.Object then
            DeleteObject(v.Object)
        end
    end
end)

function InitBeehives()
    Config.Beehives = FW.SendCallback("fw-misc:Server:GetBeehives")

    local HiveModels = {"beehive", "beehive02", "beehive03"}
    for k, v in pairs(HiveModels) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
            Type = 'Model',
            Model = v,
            SpriteDistance = 5.0,
            Distance = 2.0,
            Options = {
                {
                    Name = 'check',
                    Icon = 'fas fa-archive',
                    Label = 'Controleren',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:CheckHive',
                    EventParams = '',
                    Enabled = function(Entity)
                        return true
                    end,
                },
                {
                    Name = 'harvest',
                    Icon = 'fas fa-hand-holding-water',
                    Label = 'Oogsten',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:HarvestHive',
                    EventParams = '',
                    Enabled = function(Entity)
                        return true
                    end,
                }
            }
        })
    end
end

function IsInBeehiveZone()
    local Coords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(Config.BeehivesZones) do
        if #(Coords - v.Coords) <= v.Size then
            return true
        end
    end

    return false
end

-- 180 / 60 = 3 (hours)
-- So at max 3 hours before its done, BUT! When a Queen is added: 2.3 hours (2 hours and 18 minutes)
function GetHivePercentage(Data)
    local TimeDifference = (GetCloudTimeAsInt() - math.max(Data.LastHarvest, Data.Timestamp)) / 60
    local QueenFactor = Data.HasQueen and 1.3 or 1.0 -- make it grow faster if it has a queen bee
    local GrowthFactors = 180 / QueenFactor
    return math.min((TimeDifference / GrowthFactors) * 100, 100.0)
end

function GetHiveStage(HivePercentage)
    return HivePercentage < 50.0 and 1 or (HivePercentage >= 50.0 and HivePercentage < 100.0) and 2 or 3
end

function HiveStageToModel(Stage)
    if Stage == 1 then
        return 'beehive'
    elseif Stage == 2 then
        return 'beehive02'
    end
    return 'beehive03'
end

function GetHiveByEntity(Entity)
    for k, v in pairs(CreatedBeehives) do
        if v.Object and v.Object == Entity then
            for i, j in pairs(Config.Beehives) do
                if j.Id == k then
                    return j
                end
            end
        end
    end
    return false
end

function GetHiveById(HiveId)
    for k, v in pairs(Config.Beehives) do
        if v.Id == HiveId then
            return v
        end
    end
    return false
end

function CreateHive(Stage, Coords, Rotation)
    local Model = HiveStageToModel(Stage)
    exports['fw-assets']:RequestModelHash(Model)

    local HiveObject = CreateObject(Model, Coords.x, Coords.y, Coords.z, false, false, false)
    FreezeEntityPosition(HiveObject, true)
    SetEntityHeading(HiveObject, Rotation + 0.0)

    return HiveObject
end

function DoEntityPlacer(Model, MaxDistance, StickToGround, PlayerHeading, ZMin, ShowOutline)
    local Promise = promise.new()
    exports['fw-core']:DoEntityPlacer(Model, MaxDistance, StickToGround, PlayerHeading, ZMin, function(...)
        Citizen.Wait(100)
        Promise:resolve({...})
    end, ShowOutline)
    return Citizen.Await(Promise)
end
