local MaterialHashes = {-461750719, 930824497, 581794674,  -2041329971,  -309121453,  -913351839,  -1885547121,  -1915425863,  -1833527165,  2128369009,  -124769592,  -840216541,  -2073312001,  627123000,  1333033863,  -1286696947,  -1942898710,  -1595148316,  435688960,  223086562,  1109728704}
local ActivePlants = {}

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            local PlayerCoords = GetEntityCoords(PlayerPedId())

            if Config.WeedPlants == nil then Config.WeedPlants = {} end

            for k, v in ipairs(Config.WeedPlants) do
                if k % 100 == 0 then
                    Citizen.Wait(0)
                end

                if #(PlayerCoords - vector3(v.Coords.X, v.Coords.Y, v.Coords.Z)) < 50.0 then
                    local CurrentStage = GetStageFromPlant(v.Stage)
                    local IsChanged = (ActivePlants[v.Id] and ActivePlants[v.Id].Stage ~= CurrentStage)

                    if IsChanged then RemovePlant(v.Id) end

                    if not ActivePlants[v.Id] or IsChanged then
                        local WeedPlant = CreatePlant(CurrentStage, v.Coords)
                        ActivePlants[v.Id] = {
                            Object = WeedPlant,
                            Stage = CurrentStage
                        }
                    end
                else
                    RemovePlant(v.Id)
                end
            end

            Citizen.Wait(3500)
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-illegal:Client:Plants:Action')
AddEventHandler('fw-illegal:Client:Plants:Action', function(Type, Data)
    if Type == 1 then
        Config.WeedPlants = Data
    end
    if Type == 2 then
        Config.WeedPlants[#Config.WeedPlants + 1] = Data
    end
    if Type == 3 then
        for k, v in ipairs(Config.WeedPlants) do
            if v.Id == Data.Id then
                Config.WeedPlants[k] = Data
                break
            end
        end
    end
    if Type == 4 then
        for k, v in ipairs(Config.WeedPlants) do
            if v.Id == Data.Id then
                table.remove(Config.WeedPlants, k)
                RemovePlant(v.Id)
                break
            end
        end
    end
end)

RegisterNetEvent('fw-items:Client:Used:SeedsFemale')
AddEventHandler('fw-items:Client:Used:SeedsFemale', function()
    exports['fw-core']:DoEntityPlacer('bkr_prop_weed_01_small_01b', 15.0, true, true, nil, function(DidPlace, Coords, Heading)
        if DidPlace then
            local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(Coords.x, Coords.y, Coords.z, Coords.x, Coords.y, Coords.z - 2, 1, 0, 4)
            local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)
            if Hit then
                for k, v in pairs(MaterialHashes) do
                    if MaterialHash == v then
                        FoundPlace = true
                        exports['fw-inventory']:SetBusyState(true)
                        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

                        local Finished = FW.Functions.CompactProgressbar(6000, "Planten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "", anim = "", flags = 1 }, {}, {}, false)
                        if Finished then
                            local DidRemove = FW.SendCallback("FW:RemoveItem", 'weed-seed-female', 1, false, nil)
                            if not DidRemove then return end
                        
                            TriggerServerEvent('fw-illegal:Server:Plants:Plant', vector3(Coords.x, Coords.y, Coords.z - 0.04))
                        end
                        ClearPedTasks(PlayerPedId())
                        exports['fw-inventory']:SetBusyState(false)
                    end
                end
                if not FoundPlace then
                    FW.Functions.Notify("Je kan hier geen plantjes plaatsen..", "error")
                end
            else
                FW.Functions.Notify("Je kan hier geen plantjes plaatsen..", "error")
            end
        else
            FW.Functions.Notify("Je bent gestopt met het plaatsen van een plant..", "error")
        end
    end)
end)

RegisterNetEvent('fw-illegal:Client:Plants:Pick:Plant')
AddEventHandler('fw-illegal:Client:Plants:Pick:Plant', function(Nothing, Entity)
    local PlantId = GetPlantId(Entity)
    local PlantData = GetPlantById(PlantId)
    if PlantData ~= nil then
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

        local Finished = FW.Functions.CompactProgressbar(5000, "Plant Oogsten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "", anim = "", flags = 1 }, {}, {}, false)
        if Finished then
            TriggerServerEvent('fw-illegal:Server:Do:Plant:Stuff', 'Harvest', PlantData.Id)
        end
        exports['fw-inventory']:SetBusyState(false)
        ClearPedTasks(PlayerPedId())
    else
        FW.Functions.Notify("Een error is voorgekomen..", "error")
    end
end)

RegisterNetEvent('fw-illegal:Client:Plants:Water:Plant')
AddEventHandler('fw-illegal:Client:Plants:Water:Plant', function(Data)
    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(5000, "Plant Bewateren...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "weapon@w_sp_jerrycan", anim = "fire", flags = 49 }, {}, {}, false)
    if Finished then
        TriggerServerEvent('fw-inventory:Server:DecayItem', 'farming-wateringcan', nil, 2.0)
        TriggerServerEvent('fw-illegal:Server:Do:Plant:Stuff', 'Water', Data['PlantId'], math.random(40, 45))
    end

    exports['fw-inventory']:SetBusyState(false)
end)

RegisterNetEvent('fw-illegal:Client:Plants:Fertelize:Plant')
AddEventHandler('fw-illegal:Client:Plants:Fertelize:Plant', function(Data)
    -- print("Shit.") Wtf robijn
    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(5000, "Poep...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "weapon@w_sp_jerrycan", anim = "fire", flags = 49 }, {}, {}, false)
    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", 'fertilizer', 1, false, nil)
        if not DidRemove then return end
        
        TriggerServerEvent('fw-illegal:Server:Do:Plant:Stuff', 'Fertilizer', Data['PlantId'], math.random(40, 45))
    end
    exports['fw-inventory']:SetBusyState(false)
end)

RegisterNetEvent('fw-illegal:Client:Plants:Add:Male')
AddEventHandler('fw-illegal:Client:Plants:Add:Male', function(Data)
    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(2000, "Boem Boem...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "weapon@w_sp_jerrycan", anim = "fire", flags = 49 }, {}, {}, false)
    if Finished then
        local DidRemove = FW.SendCallback("FW:RemoveItem", 'weed-seed-male', 1, false, nil)
        if not DidRemove then return end
        
        TriggerServerEvent('fw-illegal:Server:Do:Plant:Stuff', 'Pregnant', Data['PlantId'])
    end
    exports['fw-inventory']:SetBusyState(false)
end)

RegisterNetEvent('fw-illegal:Client:Plants:Destroy')
AddEventHandler('fw-illegal:Client:Plants:Destroy', function(Nothing, Entity)
    local PlantId = GetPlantId(Entity)
    local PlantData = GetPlantById(PlantId)
    if PlantData == nil then return end

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)

    local Finished = FW.Functions.CompactProgressbar(2000, "Verwoesten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "", anim = "", flags = 1 }, {}, {}, false)
    if Finished then
        TriggerServerEvent('fw-illegal:Server:Do:Plant:Stuff', 'Destroy', PlantData.Id)
    end
    exports['fw-inventory']:SetBusyState(false)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('fw-illegal:Client:Plants:Open:Context')
AddEventHandler('fw-illegal:Client:Plants:Open:Context', function(Nothing, Entity)
    local PlantId = GetPlantId(Entity)
    if PlantId and exports['fw-inventory']:CanOpenInventory() then
        ShowPlantMenu(PlantId)
    end
end)

RegisterNetEvent("fw-illegal:Client:Start:Dry:Process")
AddEventHandler("fw-illegal:Client:Start:Dry:Process", function()
    local Success = FW.SendCallback("fw-illegal:Server:Start:Dry:Process")
    if Success then
        TriggerServerEvent("fw-mdw:Server:SendAlert:Oxy", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())
    end
end)

-- // Functions \\ --

function ShowPlantMenu(PlantId)
    local PlantData = GetPlantById(PlantId)
    if PlantData == nil then
        return FW.Functions.Notify("Een error is voorgekomen..", "error")
    end

    local MenuData = {}
    local PlantStage = GetStageFromPlant(PlantData.Stage)
    local HasWater = exports['fw-inventory']:HasEnoughOfItem('farming-wateringcan', 1)
    local HasFertilizer = exports['fw-inventory']:HasEnoughOfItem('fertilizer', 1)
    local HasMaleSeed = exports['fw-inventory']:HasEnoughOfItem('weed-seed-male', 1)

    MenuData[#MenuData + 1] = {
        Icon = 'cannabis',
        Title = 'Wiet Plant #'..PlantId,
        Desc = 'Levens: '..PlantData.Health..'%; Water: '..PlantData.Water..'%; Mest: '..PlantData.Fertilizer..'%; Zwanger: '..PlantData.Pregnant,
    }

    if PlantData.Water < 100 then
        MenuData[#MenuData + 1] = {
            Icon = 'tint',
            Title = 'Voeg water toe',
            Desc = 'Besproei mij met je tuinslang.',
            Data = {
                Event = 'fw-illegal:Client:Plants:Water:Plant',
                Type = 'Client',
                PlantId = PlantId
            },
            Disabled = not HasWater
        }
    end

    if PlantData.Fertilizer < 100 then
        MenuData[#MenuData + 1] = {
            Icon = 'poop',
            Title = 'Bemesten',
            Desc = 'Laat ik even op deze plant poepen joh..',
            Data = {
                Event = 'fw-illegal:Client:Plants:Fertelize:Plant',
                Type = 'Client',
                PlantId = PlantId
            },
            Disabled = not HasFertilizer
        }
    end

    if (PlantData.Pregnant == 'False' and PlantStage <= 2) then -- Only add male in the 2 stages
        MenuData[#MenuData + 1] = {
            Icon = 'seedling',
            Title = 'Voeg mannelijk zaad toe',
            Desc = 'Kinderen?!',
            Data = {
                Event = 'fw-illegal:Client:Plants:Add:Male',
                Type = 'Client',
                PlantId = PlantId
            },
            Disabled = not HasMaleSeed
        }
    end

    FW.Functions.OpenMenu({ MainMenuItems = MenuData })
end

function InitPlants()
    Config.WeedPlants = FW.SendCallback("fw-illegal:Server:Get:Plants")
end

function CreatePlant(Stage, Coords)
    local Model = Config.GrowthObjects[Stage]['Hash']
    exports['fw-assets']:RequestModelHash(Model)

    local PlantObject = CreateObject(Model, Coords.X, Coords.Y, Coords.Z + Config.GrowthObjects[Stage]['Z-Offset'], false, true, false)
    FreezeEntityPosition(PlantObject, true)
    SetEntityHeading(PlantObject, math.random(0, 360) + 0.0)
    -- print('Adding Plant Obj:', PlantObject)

    return PlantObject
end

function RemovePlant(PlantId)
    if ActivePlants[PlantId] == nil then return end

    -- print('Deleting Plant:', PlantId)
    DeleteObject(ActivePlants[PlantId]['Object'])
    ActivePlants[PlantId] = nil
end

function IsPlantPickable(Entity)
    local PlantId = GetPlantId(Entity)
    local PlantData = GetPlantById(PlantId)
    if PlantData ~= nil and type(PlantData.Stage) == 'number' then
        if PlantData.Stage >= 100 then
            return true
        else
            return false
        end
    else
        return false
    end
end
exports("IsPlantPickable", IsPlantPickable)

function GetPlantId(Entity)
    for k, v in pairs(ActivePlants) do
        if v['Object'] == Entity then
            return k
        end
    end
    return false
end

function GetPlantById(PlantId)
    for k, v in pairs(Config.WeedPlants) do
        if v.Id == PlantId then
            return v
        end
    end
    return false
end

function GetStageFromPlant(Stage)
    if Stage <= 20 then
        return 1
    elseif Stage > 20 and Stage <= 40 then
        return 2
    elseif Stage > 40 and Stage <= 60 then
        return 3
    elseif Stage > 60 and Stage <= 80 then
        return 4
    elseif Stage > 80 and Stage <= 100 then
        return 5
    end
end

function RemoveAllPlants()
    for k, v in pairs(ActivePlants) do
        RemovePlant(v.Object) 
    end
    ActivePlants = {}
end