local ShowingInteraction, CurrentHouse, HouseData, InsideHouse, InteriorData = false, false, false, false, false

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("v_res_tre_alarmbox"), {
        Type = 'Model',
        Model = "v_res_tre_alarmbox",
        SpriteDistance = 10.0,
        Distance = 2.2,
        Options = {
            {
                Name = 'house_alarm',
                Icon = 'fas fa-dna',
                Label = 'Alarm Uitschakelen',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:Houses:DisableAlarm',
                EventParams = '',
                Enabled = function(Entity)

                    return exports['fw-jobmanager']:CanDisableAlarm()
                end,
            }
        }
    })

    local StealProps = {
        "prop_tv_07",
        "prop_microwave_1",
        "prop_tv_flat_01",
    }

    for k, v in pairs(StealProps) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
            Type = 'Model',
            Model = v,
            SpriteDistance = 10.0,
            Distance = 2.2,
            Options = {
                {
                    Name = 'pickup',
                    Icon = 'fas fa-circle',
                    Label = 'Oppakken',
                    EventType = 'Client',
                    EventName = 'fw-jobmanager:Client:Houses:StealObject',
                    EventParams = '',
                    Enabled = function(Entity)
                        return exports['fw-jobmanager']:CanStealThisProp(v)
                    end,
                }
            }
        })
    end

    while true do
        -- Add Logged In wait.

        local Coords = GetEntityCoords(PlayerPedId())

        if not InsideHouse then
            local NearestHouse = false
            local NearestDist = 0

            for k, v in pairs(Config.Houses.Houses) do
                local Distance = #(Coords - vector3(v.Coords.x, v.Coords.y, v.Coords.z))
                if not NearestHouse or NearestDist > Distance then
                    NearestHouse = k
                    NearestDist = Distance
                end
            end

            if NearestDist < 1.5 then
                CurrentHouse = NearestHouse
            elseif CurrentHouse then
                CurrentHouse = false

                if ShowingInteraction then
                    ShowingInteraction = false
                    exports['fw-ui']:HideInteraction()
                end
            end
        end

        if not CurrentHouse then
            Citizen.Wait(500)
        end

        if not InsideHouse and CurrentHouse and not Config.Houses.Houses[CurrentHouse].Locked then
            if not ShowingInteraction then
                ShowingInteraction = true
                exports['fw-ui']:ShowInteraction("[E] Naar Binnen")
            end
            
            if IsControlJustReleased(0, 38) then
                ShowingInteraction = false
                exports['fw-ui']:HideInteraction()
                EnterRobHouse()
            end
        end

        Citizen.Wait(1)
    end
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:AlarmBeep")
AddEventHandler("fw-jobmanager:Client:Houses:AlarmBeep", function(HouseId, SoundId)
    if not InsideHouse then return end
    if CurrentHouse ~= HouseId then return end

    TriggerEvent('fw-misc:Client:PlaySound', SoundId)
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:SendAlarm")
AddEventHandler("fw-jobmanager:Client:Houses:SendAlarm", function(HouseId)
    local House = Config.Houses.Houses[HouseId]
    TriggerServerEvent('fw-mdw:Server:SendAlert:HouseAlarm', House.Coords, FW.Functions.GetStreetLabel(House.Coords))
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:DisableAlarm")
AddEventHandler("fw-jobmanager:Client:Houses:DisableAlarm", function()
    TriggerEvent('fw-emotes:Client:PlayEmote', "code", nil, true)
    local Success = exports["minigame-boostinghack"]:StartHack(nil, 10)
    TriggerEvent("fw-emotes:Client:CancelEmote", true)

    if Success then
        TriggerServerEvent('fw-jobmanager:Server:Houses:SetState', CurrentHouse, 'Alarm', false)
    else
        if math.random() <= 0.35 then TriggerServerEvent('fw-mdw:Server:SendAlert:HouseAlarm', GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel()) end
    end
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:StealObject")
AddEventHandler("fw-jobmanager:Client:Houses:StealObject", function(Data, Entity)
    if not CurrentHouse then return end

    local ModelHash = GetEntityModel(Entity)
    if not exports['fw-progressbar']:GetTaskBarStatus() and (Config.Houses.Houses[CurrentHouse].Props[ModelHash] == nil or Config.Houses.Houses[CurrentHouse].Props[ModelHash] == false) then
        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end


        Config.Houses.Houses[CurrentHouse].Props[ModelHash] = 1
        TriggerServerEvent("fw-jobmanager:Server:Houses:SetState", CurrentHouse, 'Props', Config.Houses.Houses[CurrentHouse].Props)
        FW.Functions.Progressbar("bitch", "Oppakken...", 6000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableComat = true,
        }, {
            animDict = 'missexile3',
            anim = 'ex03_dingy_search_case_a_michael',
            flags = 1
        }, {}, {}, function()
            DeleteEntity(Entity)
            StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0)

            FW.TriggerServer("fw-jobmanager:Server:Houses:ReceiveObject", MyJob.CurrentGroup.Id, ModelHash)

            Config.Houses.Houses[CurrentHouse].Props[ModelHash] = 2
            TriggerServerEvent("fw-jobmanager:Server:Houses:SetState", CurrentHouse, 'Props', Config.Houses.Houses[CurrentHouse].Props)
        end, function()
            StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0)
            Config.Houses.Houses[CurrentHouse].Props[ModelHash] = false
            TriggerServerEvent("fw-jobmanager:Server:Houses:SetState", CurrentHouse, 'Props', Config.Houses.Houses[CurrentHouse].Props)
        end)
    else
        FW.Functions.Notify("Je bent al bezig, of iemand heeft dit al opgepakt.", "error")
    end
end)

RegisterNetEvent('fw-jobmanager:Client:SetupJob')
AddEventHandler('fw-jobmanager:Client:SetupJob', function(IsLeader, Tasks, Data)
    if MyJob.CurrentJob ~= 'houses' then return end

    SetRouteBlip("Huis", {GetEntityCoords(PlayerPedId()), Data.House.Coords}, true)
    HouseData = Data.House

    Citizen.CreateThread(function()
        local NearHouse = false
        while not NearHouse do
            if #(GetEntityCoords(PlayerPedId()) - vector3(Data.House.Coords.x, Data.House.Coords.y, Data.House.Coords.z)) <= 25.0 then
                NearHouse = true
            end
            Citizen.Wait(500)
        end

        RemoveRouteBlip()
        FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 1, 1)
    end)
end)

RegisterNetEvent('fw-jobmanager:Client:OnNextTask')
AddEventHandler('fw-jobmanager:Client:OnNextTask', function(IsLeader, TaskId)
    if MyJob.CurrentJob ~= 'houses' then return end

    if IsLeader and TaskId == 3 then
        Citizen.CreateThread(function()
            while HouseData and HouseData.Coords and CurrentTaskId and CurrentTaskId == 3 do
                if not InsideHouse and #(GetEntityCoords(PlayerPedId()) - vector3(HouseData.Coords.x, HouseData.Coords.y, HouseData.Coords.z)) >= 75 then
                    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 3, 1)
                end

                Citizen.Wait(4)
            end
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:JobCleanup')
AddEventHandler('fw-jobmanager:Client:JobCleanup', function(IsLeader, IsForced)
    if MyJob.CurrentJob ~= 'houses' then return end

    RemoveRouteBlip()

    if InsideHouse then
        local Coords = Config.Houses.Houses[CurrentHouse].Coords

        DoScreenFadeOut(250)
        while not IsScreenFadedOut(250) do Citizen.Wait(4) end
        
        ShowingInteraction = false
        exports['fw-ui']:HideInteraction()

        InsideHouse = false
        exports['fw-interiors']:DespawnInteriors()
        SetEntityCoords(PlayerPedId(), Coords.x, Coords.y, Coords.z - 1.0)
        SetEntityHeading(PlayerPedId(), Coords.w)

        exports['fw-sync']:SetClientSync(true)
        DoScreenFadeIn(250)
    end

    HouseData = false
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:SetState")
AddEventHandler("fw-jobmanager:Client:Houses:SetState", function(HouseId, Key, Value)
    Config.Houses.Houses[HouseId][Key] = Value
    if HouseData and HouseData.Id == HouseId then
        HouseData[Key] = Value
    end
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:SetData")
AddEventHandler("fw-jobmanager:Client:Houses:SetData", function(HouseId, Data)
    Config.Houses.Houses[HouseId] = Data
    if HouseData and HouseData.Id == HouseId then
        HouseData = Data
    end
end)

RegisterNetEvent("fw-items:Client:UseLockpick")
AddEventHandler("fw-items:Client:UseLockpick", function(IsAdvanced, Item)
    if not HouseData then return end

    if #(GetEntityCoords(PlayerPedId()) - vector3(HouseData.Coords.x, HouseData.Coords.y, HouseData.Coords.z)) > 1.5 then
        return FW.Functions.Notify("Ik denk niet dat de baas het zo leuk vindt als je huizen leeg trekt zonder zijn toestemming..", "error", 7500)
    end
    
    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerEvent('fw-assets:client:lockpick:animation', true)
    local Outcome = exports['fw-ui']:StartSkillTest(math.random(5, 8), IsAdvanced and { 1, 2 } or { 5, 10 }, IsAdvanced and { 6000, 12000 } or { 1500, 3000 }, true)
    TriggerEvent('fw-assets:client:lockpick:animation', false)

    if not Outcome then
        FW.Functions.Notify("Gefaald..", "error")
        TriggerServerEvent('fw-inventory:Server:DecayItem', Item.Item, Item.Slot, IsAdvanced and 4.5 or 7.5)
        return
    end

    TriggerServerEvent('fw-inventory:Server:DecayItem', Item.Item, Item.Slot, IsAdvanced and 1.0 or 2.0)

    exports['fw-assets']:RemoveLockpickChance(IsAdvanced)

    TriggerServerEvent('fw-jobmanager:Client:Houses:StartAlarm', CurrentHouse)
    TriggerServerEvent('fw-jobmanager:Server:Houses:SetState', HouseData.Id, 'Locked', false)
    FW.TriggerServer('fw-jobmanager:Server:AddTaskProgress', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id, 2, 1)
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:ConcealHouse")
AddEventHandler("fw-jobmanager:Client:Houses:ConcealHouse", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= "police" and not PlayerData.job.onduty then return end

    FW.TriggerServer("fw-jobmanager:Server:ConcealHouse", CurrentHouse)
end)

RegisterNetEvent("fw-jobmanager:Client:Houses:ForceAbandon")
AddEventHandler("fw-jobmanager:Client:Houses:ForceAbandon", function()
    local MyJob = exports['fw-jobmanager']:GetMyJob()
    TriggerServerEvent('fw-jobmanager:Server:AbandonJob', MyJob.CurrentJob, MyJob.CurrentGroup.Id, MyJob.CurrentGroup.Activity.Id)
end)

function EnterRobHouse()
    InsideHouse = true

    local Coords = Config.Houses.Houses[CurrentHouse].Coords
    
    InteriorData = exports['fw-interiors']:CreateInterior(Config.Houses.Houses[CurrentHouse].Shell, vector3(Coords.x, Coords.y, Coords.z - 100.0), true)
    if InteriorData == nil or InteriorData[1] == nil then return FW.Functions.Notify("Kan interieur niet laden..", "error") end

    DoScreenFadeOut(250)
    while not IsScreenFadedOut(250) do Citizen.Wait(4) end

    local ExitCoords = {
        x = Coords.x + InteriorData[2].Exit.x,
        y = Coords.y + InteriorData[2].Exit.y,
        z = (Coords.z - 100.0) + InteriorData[2].Exit.z
    }

    exports['fw-sync']:SetClientSync(false)

    SetEntityCoords(PlayerPedId(), ExitCoords.x, ExitCoords.y, ExitCoords.z)
    SetEntityHeading(PlayerPedId(), GetEntityHeading(InteriorData[1]))

    StartRobHouseLoop()
end

function StartRobHouseLoop()
    local Offsets = {}
    local Coords = Config.Houses.Houses[CurrentHouse].Coords

    for k, v in pairs(InteriorData[2]) do
        Offsets[k] = vector3(Coords.x + v.x, Coords.y + v.y, (Coords.z - 100.0) + v.z + 0.5)
    end

    Citizen.CreateThread(function()
        DoScreenFadeIn(250)
        while InsideHouse do
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            local ShellCoords = GetEntityCoords(InteriorData[1])

            local ExitDistance = #(Offsets.Exit - PlayerCoords)

            local NearAnything = false
            local InteractType = "Exit"
            local InteractData = {}

            for k, v in pairs(Config.Houses.Offsets[Config.Houses.Houses[CurrentHouse].Shell]) do
                if #(vector3(v.Coords.x + ShellCoords.x, v.Coords.y + ShellCoords.y, v.Coords.z + ShellCoords.z) - PlayerCoords) <= 0.8 then
                    NearAnything = true
                    InteractType = "Loot"
                    InteractData = { Type = v.Type, Id = k }
                end
            end

            if ExitDistance <= 0.8 then
                NearAnything = true
                InteractType = "Exit"
            end

            if NearAnything then
                if not ShowingInteraction then
                    ShowingInteraction = true
                    if InteractType == "Exit" then
                        exports['fw-ui']:ShowInteraction("[E] Verlaten", "primary")
                    elseif InteractType == "Loot" then
                        exports['fw-ui']:ShowInteraction("[E] Zoeken", "primary")
                    end
                end

                if IsControlJustReleased(0, 38) then
                    if InteractType == "Exit" then
                        DoScreenFadeOut(250)
                        while not IsScreenFadedOut(250) do Citizen.Wait(4) end
                        
                        ShowingInteraction = false
                        exports['fw-ui']:HideInteraction()

                        InsideHouse = false
                        exports['fw-interiors']:DespawnInteriors()
                        SetEntityCoords(PlayerPedId(), Coords.x, Coords.y, Coords.z - 1.0)
                        SetEntityHeading(PlayerPedId(), Coords.w)

                        exports['fw-sync']:SetClientSync(true)
                        DoScreenFadeIn(250)
                    elseif InteractType == "Loot" then
                        if not exports['fw-progressbar']:GetTaskBarStatus() and not Config.Houses.Houses[CurrentHouse].Loot[InteractData.Id] then

                            if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
                                TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
                            end

                            Config.Houses.Houses[CurrentHouse].Loot[InteractData.Id] = true
                            TriggerServerEvent("fw-jobmanager:Server:Houses:SetState", CurrentHouse, 'Loot', Config.Houses.Houses[CurrentHouse].Loot)
                            FW.Functions.Progressbar("bitch", "Zoeken...", 8000, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableComat = true,
                            }, {
                                animDict = 'missexile3',
                                anim = 'ex03_dingy_search_case_a_michael',
                                flags = 1
                            }, {}, {}, function()
                                StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0)
                                FW.TriggerServer("fw-jobmanager:Server:Houses:ReceiveGoods", MyJob.CurrentGroup.Id, InteractData)
                            end, function()
                                StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0)
                                Config.Houses.Houses[CurrentHouse].Loot[InteractData.Id] = false
                                TriggerServerEvent("fw-jobmanager:Server:Houses:SetState", CurrentHouse, 'Loot', Config.Houses.Houses[CurrentHouse].Loot)
                            end)
                        else
                            FW.Functions.Notify("Je bent al bezig, of de kast is leeg.", "error")
                        end
                    end
                end
            elseif ShowingInteraction then
                ShowingInteraction = false
                exports['fw-ui']:HideInteraction()
            end

            Citizen.Wait(4)
        end
    end)
end

-- RegisterCommand("houses:getOffset", function()
--     local PlayerCoords = GetEntityCoords(PlayerPedId())
--     local ShellCoords = GetEntityCoords(InteriorData[1])

--     print(vector3(PlayerCoords.x - ShellCoords.x, PlayerCoords.y - ShellCoords.y, PlayerCoords.z - ShellCoords.z))
-- end)

exports("CanDisableAlarm", function()
    return CurrentHouse and Config.Houses.Houses[CurrentHouse].Alarm
end)

exports("CanStealThisProp", function(Entity)
    return CurrentHouse and (not Config.Houses.Houses[CurrentHouse].Props[GetEntityModel(Entity)])
end)

exports("GetCurrentHouse", function(Entity)
    return CurrentHouse
end)