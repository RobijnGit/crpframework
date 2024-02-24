local ObjectiveTypesLabel = {
    ["shovel"] = "Scheppen",
    ["jackhammer"] = "Drilboren",
    ["drill"] = "Boren",
    ["leanbar"] = "Berekeningen maken",
    ["saw"] = "Zagen",
    ["hammer"] = "Hameren",
    ["planks"] = "Planken",
    ["wheelbarrow"] = "Kruiwagen",
}

local DoPfx = false
local CurrentSite = false
local ShowingInteraction = false
local BusyOnObjective = false
local CarryObjects = {}
local IsCarrying = false
local ConstructionVehicle = false
local ConstructionBlips = {}

local function LoadAnimation(Anim)
    return exports['fw-assets']:RequestAnimationDict(Anim)
end

local function LoadModel(Model)
    return exports['fw-assets']:RequestModelHash(Model)
end

RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'construction' then return end
    CurrentSite = Data.ConstructionSite

    if IsLeader then
        Citizen.CreateThread(function()
            while true do
                DrawMarker(20, 1122.69, -1304.65, 36.5, 0, 0, 0, 180.0, 0, 0, 0.5, 0.5, 0.5, 138, 43, 226, 150, true, true, false, false, false, false, false)

                if #(GetEntityCoords(PlayerPedId()) - vector3(1122.69, -1304.65, 33.72)) < 1.2 then
                    if not ShowingInteraction then
                        exports['fw-ui']:ShowInteraction("[E] Vraag de werkgever om een voertuig.")
                        ShowingInteraction = true
                    end

                    if IsControlJustReleased(0, 38) then
                        if FW.Functions.IsSpawnPointClear(vector3(1129.95, -1299.55, 34.63), 1.85) then
                            exports['fw-ui']:HideInteraction()
                            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
                            TriggerServerEvent('fw-jobmanager:Server:SpawnConstructionVehicle', MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
                            ShowingInteraction = false
                            return
                        else
                            FW.Functions.Notify("De werkgever kan je geen voertuig geven: er staat iets in de weg..", "error")
                        end
                    end
                elseif ShowingInteraction then
                    exports['fw-ui']:HideInteraction()
                end

                Citizen.Wait(4)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'construction' then return end

    if TaskId == 3 then
        SetRouteBlip("Bouwplaats", vector3(CurrentSite.Center.x, CurrentSite.Center.y, CurrentSite.Center.z))

        if IsLeader then
            Citizen.CreateThread(function()
                while CurrentTaskId and CurrentTaskId == 3 do
    
                    if #(GetEntityCoords(PlayerPedId()) - CurrentSite.Center) < 25.0 then
                        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
                        RemoveRouteBlip()
                        return
                    end
    
                    Citizen.Wait(500)
                end
            end)
        end
    elseif TaskId == 4 then
        Citizen.SetTimeout(500, function()
            CreateConstructionTasksBlips()
            StartObjectivesLoop()
        end)
    elseif TaskId == 5 then
        SetRouteBlip("Bouwbedrijf", vector3(1138.02, -1298.12, 34.63))

        if IsLeader then
            Citizen.CreateThread(function()
                while CurrentTaskId and CurrentTaskId == 5 do
    
                    if #(GetEntityCoords(PlayerPedId()) - vector3(1138.02, -1298.12, 34.63)) < 25.0 and GetVehiclePedIsIn(PlayerPedId()) <= 0 then
                        Citizen.SetTimeout(1000, function()
                            FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 5, 1)
                            TriggerServerEvent("fw-jobmanager:Server:DeleteConstructionVehicle", MyJob.CurrentGroup.Activity.Id)
                        end)
                    end
    
                    Citizen.Wait(500)
                end
            end)
        end
    end
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'construction' then return end

    RemoveRouteBlip()

    if IsCarrying then
        UncarryObject(false)
    end

    if ShowingInteraction then
        exports['fw-ui']:HideInteraction()
        ShowingInteraction = false
    end

    DoPfx = false
    CurrentSite = false
    BusyOnObjective = false
    ConstructionVehicle = false

    for k, v in pairs(ConstructionBlips) do
        RemoveBlip(v)
    end

    ConstructionBlips = {}
end)

RegisterNetEvent("fw-jobmanager:Client:SetObjectiveData")
AddEventHandler("fw-jobmanager:Client:SetObjectiveData", function(ObjectiveId, Busy, Completed)
    CurrentSite.Objectives[ObjectiveId].IsBusy = Busy
    CurrentSite.Objectives[ObjectiveId].Completed = Completed
    CreateConstructionTasksBlips()
end)

RegisterNetEvent('fw-jobmanager:Client:SetConstructionVehicle')
AddEventHandler('fw-jobmanager:Client:SetConstructionVehicle', function(NetId)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    local Vehicle = NetToVeh(NetId)

    Citizen.SetTimeout(500, function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
        exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
        ConstructionVehicle = Vehicle
    end)
end)

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    local Model = GetEntityModel(Vehicle)
    if Model ~= GetHashKey("tiptruck2") then return end

    if not MyJob.CurrentJob or MyJob.CurrentJob ~= 'construction' then return end

    if CurrentTaskId ~= 2 then return end
    if Vehicle ~= ConstructionVehicle then return end

    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
end)

function StartObjectivesLoop()
    while CurrentTaskId and CurrentTaskId == 4 do
        local CurrentObjective = false
        local MyCoords = GetEntityCoords(PlayerPedId())

        if not BusyOnObjective then
            for k, v in pairs(CurrentSite.Objectives) do
                if not v.Completed and not v.IsBusy then
                    local Pos = v.Coords
                    if type(v.Coords) == "table" then Pos = v.Coords[1] end

                    local Dist = #(MyCoords - vector3(Pos.x, Pos.y, Pos.z))
                    if Dist < 15.0 then
                        DrawMarker(2, Pos.x, Pos.y, Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 100, 200, 100, 180, false, true, false, false, false, false, false)
                    end

                    if Dist < 0.8 then
                        CurrentObjective = k
                    end
                end
            end
        end

        if CurrentObjective and not ShowingInteraction then
            ShowingInteraction = true
            if CurrentSite.Objectives[CurrentObjective].Type == "planks" or CurrentSite.Objectives[CurrentObjective].Type == "wheelbarrow" then
                exports['fw-ui']:ShowInteraction("[E] " .. ObjectiveTypesLabel[CurrentSite.Objectives[CurrentObjective].Type] .. " verplaatsen")
            else
                exports['fw-ui']:ShowInteraction("[E] " .. ObjectiveTypesLabel[CurrentSite.Objectives[CurrentObjective].Type])
            end
        elseif not CurrentObjective and ShowingInteraction then
            exports['fw-ui']:HideInteraction()
            ShowingInteraction = false
        end

        if CurrentObjective and ShowingInteraction and IsControlJustReleased(0, 38) then
            StartObjective(CurrentObjective)
        end

        Citizen.Wait(4)
    end
end

function StartObjective(CurrentObjective)
    if not CurrentObjective then return end

    local Objective = CurrentSite.Objectives[CurrentObjective]
    if not Objective then return end

    Citizen.Wait(math.random(100, 500))

    if Objective.IsBusy or Objective.Completed then return end

    local Ped = PlayerPedId()
    local Coords = GetEntityCoords(Ped)
    BusyOnObjective = true

    FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, true, false)

    if Objective.Type == "shovel" then
        LoadModel("prop_tool_shovel2")
        local Shovel = CreateObject(GetHashKey("prop_tool_shovel2"), Coords.x, Coords.y, Coords.z - 10.0, true, true, true)
        AttachEntityToEntity(Shovel, Ped, GetPedBoneIndex(Ped, 57005), 0.45, 0.0, -1.1, 2.0, 340.0, 230.0, true, true, false, true, 1, true)

        LoadAnimation('random@burial')
        TaskPlayAnim(Ped, "random@burial", "a_burial", 1.0, 1.0, -1, 49, 0, 0, 0, 0)

        local Outcome = exports['fw-ui']:StartSkillTest(3, { 10, 15 }, { 3500, 5500 }, false)
        DeleteObject(Shovel)
        BusyOnObjective = false
        StopAnimTask(Ped, "random@burial", "a_burial", 1.0)

        if not Outcome then return FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, false) end
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
    elseif Objective.Type == "jackhammer" then
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CONST_DRILL", 0, false)

        local Outcome = exports['fw-ui']:StartSkillTest(3, { 10, 15 }, { 3500, 5500 }, false)
        ClearPedTasks(PlayerPedId())
        BusyOnObjective = false

        if not Outcome then return FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, false) end
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
    elseif Objective.Type == "drill" then
        local Drill = CreateObject(GetHashKey("hei_prop_heist_drill"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(Drill, Ped, GetPedBoneIndex(Ped, 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)

        RequestNamedPtfxAsset('core')
        while not HasNamedPtfxAssetLoaded('core') do
            Citizen.Wait(0)
        end
        UseParticleFxAssetNextCall('core')
        StartParticleFxLoopedOnEntity("liquid_splash_water", Ped, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, false, false, false)
        
        LoadAnimation('anim@heists@fleeca_bank@drilling')
        TaskPlayAnim(Ped, "anim@heists@fleeca_bank@drilling", "drill_right", 1.0, 1.0, -1, 49, 0, 0, 0, 0)

        local Outcome = exports['fw-ui']:StartSkillTest(5, { 10, 15 }, { 3500, 5500 }, false)
        DeleteObject(Drill)
        BusyOnObjective = false
        StopAnimTask(Ped, "anim@heists@fleeca_bank@drilling", "drill_right", 1.0)
        
        if not Outcome then return FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, false) end
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
    elseif Objective.Type == "leanbar" then
        TriggerEvent("fw-emotes:Client:PlayEmote", "leanbar2", nil, true)
        local Finished = FW.Functions.CompactProgressbar(17000, "Berekenen...", false, true, {disableMovement = true, disableCarMovement = false, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
        TriggerEvent("fw-emotes:Client:CancelEmote", true)
        BusyOnObjective = false

        if not Finished then return FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, false) end
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
    elseif Objective.Type == "saw" then
        local Saw = CreateObject(GetHashKey("prop_tool_consaw"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(Saw, Ped, GetPedBoneIndex(Ped, 57005), 0.18, 0.05, -0.03, 257.0, 190.0, 10.0, true, true, false, true, 1, true)
        PfxLoop()

        LoadAnimation('anim@heists@fleeca_bank@drilling')
        TaskPlayAnim(Ped, "anim@heists@fleeca_bank@drilling", "drill_right", 1.0, 1.0, -1, 49, 0, 0, 0, 0)
        local Outcome = exports['fw-ui']:StartSkillTest(4, { 10, 15 }, { 3500, 5500 }, false)
        DeleteObject(Saw)
        BusyOnObjective, DoPfx = false, false
        StopAnimTask(Ped, "anim@heists@fleeca_bank@drilling", "drill_right", 1.0)

        if not Outcome then return FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, false) end
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
    elseif Objective.Type == "hammer" then
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_HAMMERING", 0, false)

        local Outcome = exports['fw-ui']:StartSkillTest(2, { 10, 15 }, { 3500, 5500 }, false)
        ClearPedTasks(PlayerPedId())
        BusyOnObjective = false

        if not Outcome then return FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, false) end
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
    elseif Objective.Type == "planks" or Objective.Type == "wheelbarrow" then
        CarryObject(Objective, Objective.Type)
    end
end

function PfxLoop()
    DoPfx = true
    Citizen.CreateThread(function()
        while DoPfx do
            local ped = PlayerPedId()
            local ObjCoords = GetOffsetFromEntityInWorldCoords(ped, 0.1, 1.0, 0.0)
            RequestNamedPtfxAsset('core')
            while not HasNamedPtfxAssetLoaded('core') do
                Citizen.Wait(0)
            end
            UseParticleFxAssetNextCall('core')
            local particleHandle = StartParticleFxLoopedAtCoord('ent_dst_wood_splinter', ObjCoords.x, ObjCoords.y, ObjCoords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
            SetParticleFxLoopedColour(particleHandle, 0, 255, 0 ,0)
            Citizen.Wait(100)
            StopParticleFxLooped(particleHandle, false)
            Citizen.Wait(100)
        end
    end)
end

function CarryObject(Objective)
    IsCarrying = true

    for k, v in pairs(CarryObjects) do
        DeleteObject(v)
    end
    CarryObjects = {}

    local Ped = PlayerPedId()
    LoadAnimation('anim@heists@box_carry@')
    TaskPlayAnim(Ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 1.0, 0, 0, 0)

    if Objective.Type == "wheelbarrow" then
        CarryObjects[1] = CreateObject(GetHashKey("prop_wheelbarrow01a"), 0, 0, 0, true, true, true)
        CarryObjects[2] = CreateObject(GetHashKey("prop_wallbrick_02"), 0, 0, 0, true, true, true)
    
        AttachEntityToEntity(CarryObjects[1], Ped, GetPedBoneIndex(Ped, 57005), 0.9, -0.5, 0.2, 257.0, 340.0, 10.0, true, true, false, true, 1, true)
        AttachEntityToEntity(CarryObjects[2], Ped, GetPedBoneIndex(Ped, 57005), 0.7, -0.1, 0.1, 257.0, 340.0, 10.0, true, true, false, true, 1, true)
    elseif Objective.Type == "planks" then
        CarryObjects[1] = CreateObject(GetHashKey("prop_fncwood_16d"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(CarryObjects[1], Ped, GetPedBoneIndex(Ped, 57005), 0.1, 0.07, -0.9, 355.0, 355.0, 350.0, true, true, false, true, 1, true)
    end

    SetRouteBlip(ObjectiveTypesLabel[Objective.Type], vector3(Objective.Coords[2].x, Objective.Coords[2].y, Objective.Coords[2].z))

    Citizen.CreateThread(function()
        while IsCarrying do

            if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 49) then
                TaskPlayAnim(Ped, 'anim@heists@box_carry@', 'idle', 6.0, -6.0, -1, 49, 1.0, 0, 0, 0)
            end

            local Pos = Objective.Coords[2]
            DrawMarker(2, Pos.x, Pos.y, Pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.15, 255, 80, 80, 180, false, true, false, false, false, false, false)

            local Dist = #(GetEntityCoords(PlayerPedId()) - vector3(Pos.x, Pos.y, Pos.z))

            if Dist < 1.5 and IsControlJustReleased(0, 38) then
                UncarryObject(Objective)
            end

            if Dist <= 1.5 and not ShowingInteraction then
                ShowingInteraction = true
                exports['fw-ui']:ShowInteraction("[E] " .. ObjectiveTypesLabel[Objective.Type] .. " neerzetten")
            elseif Dist > 1.6 and ShowingInteraction then
                ShowingInteraction = false
                exports['fw-ui']:HideInteraction()
            end

            Citizen.Wait(4)
        end
    end)
end

function UncarryObject(Objective)
    IsCarrying, BusyOnObjective = false, false

    for k, v in pairs(CarryObjects) do
        DeleteObject(v)
    end
    CarryObjects = {}

    StopAnimTask(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 1.0)

    RemoveRouteBlip()

    if Objective then
        FW.TriggerServer('fw-jobmanager:Server:SetConstrucionObjective', MyJob.CurrentGroup.Id, Objective.Id, false, true)
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 4, 1)
    end
end

function CreateConstructionTasksBlips()
    for k, v in pairs(ConstructionBlips) do
        RemoveBlip(v)
    end

    ConstructionBlips = {}

    for k, v in pairs(CurrentSite.Objectives) do
        local Coords = v.Coords
        if type(v.Coords) == "table" then Coords = v.Coords[1] end

        if v.Completed then
            goto Skip
        end

        local Blip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
        SetBlipSprite(Blip, 1)
        SetBlipColour(Blip, 5)
        SetBlipScale(Blip, 0.5)
        SetBlipRouteColour(Blip, 5)
        SetBlipAsShortRange(Blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bouwtaak")
        EndTextCommandSetBlipName(Blip)

        table.insert(ConstructionBlips, Blip)

        ::Skip::
    end
end