local HairTied, HairSyles = false, nil
local CurrentDecal, CurrentDecalTexture, LigherIsHot = nil, nil, false
local UsingStick, WalkstickObject, ParachuteEquiped, UsingLawnchair = false, nil, false, false
local SupportedModels = {[GetHashKey('mp_f_freemode_01')] = 4, [GetHashKey('mp_m_freemode_01')] = 7}
FW, LoggedIn, DoingSomething = exports['fw-core']:GetCoreObject(), false, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function()
        LoggedIn = true
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Citizen.CreateThread(function()
--     Citizen.SetTimeout(1, function()
--         TriggerEvent("FW:GetObject", function(obj) FW = obj end)    
--            Citizen.Wait(250)
--            LoggedIn = true
--     end)
-- end)

-- Code

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("wheelchair"), {
        Type = 'Model',
        Model = "wheelchair",
        SpriteDistance = 10.0,
        Distance = 2.0,
        Options = {
            {
                Name = 'pickup_wheelchair',
                Icon = 'fas fa-wheelchair',
                Label = 'Rolstoel Oppakken',
                EventType = 'Client',
                EventName = 'fw-items:Client:PickupWheelchair',
                EventParams = {},
                Enabled = function()
                    return true
                end,
            },
        }
    })

    exports['fw-ui']:AddEyeEntry(GetHashKey("scootmobile"), {
        Type = 'Model',
        Model = "scootmobile",
        SpriteDistance = 10.0,
        Distance = 2.0,
        Options = {
            {
                Name = 'pickup_wheelchair',
                Icon = 'fas fa-inbox-in',
                Label = 'Scootmobiel Oppakken',
                EventType = 'Client',
                EventName = 'fw-items:Client:PickupScootmobile',
                EventParams = {},
                Enabled = function()
                    return true
                end,
            },
        }
    })
end)

RegisterNetEvent('fw-items:client:use:pakjesigaretten')
AddEventHandler('fw-items:client:use:pakjesigaretten', function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
            if not DoingSomething then
            DoingSomething = true
        exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("pakje-sigaretten", "Pakje sigaretten openmaken...", 2500, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'pakjesigaretten', 1, false)
                    FW.Functions.TriggerCallback('FW:AddItem', function() end, 'sigaret', 21, false)
                    FW.Functions.Notify("Je pakje sigaretten is geopend, je hebt er sigaretten voor ontvangen.", "success")
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:use:nightvision')
AddEventHandler('fw-items:client:use:nightvision', function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
		if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("toggle-nightvision", "Nightvision (de-)activeren...", 2500, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    TriggerEvent("fw-nightvision:toggle", source)
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:use:pack:paper')
AddEventHandler('fw-items:client:use:pack:paper', function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
            if not DoingSomething then
            DoingSomething = true
        exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("printer-pack-paper", "Pak papier uitpakken...", 2500, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'printer-pack-paper', 1, false)
                    FW.Functions.TriggerCallback('FW:AddItem', function() end, 'printer-paper', 10, false)
                    FW.Functions.Notify("Het pak papier is geopend, je hebt hiervoor papiervellen ontvangen.", "success")
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:use:welcome')
AddEventHandler('fw-items:client:use:welcome', function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
            if not DoingSomething then
            DoingSomething = true
        exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("welcome", "Openmaken...", 5000, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    local Removed = FW.SendCallback("FW:RemoveItem", 'welcome', 1, false)
                    if Removed then
                        TriggerServerEvent("fw-items:Server:WelcomeReward")
                        FW.Functions.Notify("Je hebt je cadeautje uitgepakt, je hebt hiervoor verschillende spullen ontvangen!", "success")
                    end
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:use:sigaret')
AddEventHandler('fw-items:client:use:sigaret', function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
        DoingSomething = true
        exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("smoke-sigaret", "Sigaret opsteken..", 2500, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'sigaret', 1, false)
                    TriggerServerEvent('fw-ui:Server:remove:stress', math.random(3, 9))
                    TriggerEvent('fw-emotes:Client:PlayEmote', "cigarette")
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:drink')
AddEventHandler('fw-items:client:drink', function(ItemName, PropName)
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                exports['fw-assets']:AddProp(PropName)
                exports['fw-assets']:RequestAnimationDict("amb@world_human_drinking@coffee@male@idle_a")
                TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@male@idle_a', "idle_c", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                FW.Functions.Progressbar("drink", "Drinken..", 6000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@male@idle_a', "idle_c", 1.0)
                        FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                            if DidRemove then
                                TriggerServerEvent("FW:Server:SetMetaData", "thirst", FW.Functions.GetPlayerData().metadata["thirst"] + math.random(7, 12))
                            else
                                FW.Functions.Notify("Hmm volgensmij mis je het item..", "error")
                            end
                        end, ItemName, 1, false)
                    end, function()
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@male@idle_a', "idle_c", 1.0)
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:drink:slushy')
AddEventHandler('fw-items:client:drink:slushy', function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                exports['fw-assets']:AddProp('Cup')
                exports['fw-assets']:RequestAnimationDict("amb@world_human_drinking@coffee@male@idle_a")
                TaskPlayAnim(PlayerPedId(), 'amb@world_human_drinking@coffee@male@idle_a', "idle_c", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                FW.Functions.Progressbar("drink", "Drinken..", 6000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    TriggerServerEvent('fw-ui:Server:remove:stress', math.random(12, 20))
                    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@male@idle_a', "idle_c", 1.0)
                        FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                            if DidRemove then
                                TriggerServerEvent("FW:Server:SetMetaData", "thirst", FW.Functions.GetPlayerData().metadata["thirst"] + math.random(7, 12))
                            else
                                FW.Functions.Notify("Hmm volgensmij mis je het item..", "error")
                            end
                        end, 'slushy', 1, false)
                end, function()
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                    StopAnimTask(PlayerPedId(), 'amb@world_human_drinking@coffee@male@idle_a', "idle_c", 1.0)
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:eat')
AddEventHandler('fw-items:client:eat', function(ItemName, PropName)
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                exports['fw-assets']:AddProp(PropName)
                exports['fw-assets']:RequestAnimationDict("mp_player_inteat@burger")
                TaskPlayAnim(PlayerPedId(), 'mp_player_inteat@burger', 'mp_player_int_eat_burger', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                FW.Functions.Progressbar("eat", "Eten..", 6000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    StopAnimTask(PlayerPedId(), 'mp_player_inteat@burger', 'mp_player_int_eat_burger', 1.0)
                        FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                            if DidRemove then
                                TriggerServerEvent("FW:Server:SetMetaData", "hunger", FW.Functions.GetPlayerData().metadata["hunger"] + math.random(7, 12))
                            else
                                FW.Functions.Notify("Hmm volgensmij mis je het item..", "error")
                            end
                        end, ItemName, 1, false)
                    end, function()
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                    StopAnimTask(PlayerPedId(), 'mp_player_inteat@burger', 'mp_player_int_eat_burger', 1.0)
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:mint')
AddEventHandler('fw-items:client:mint', function(ItemName, PropName)
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                exports['fw-assets']:AddProp(PropName)
                exports['fw-assets']:RequestAnimationDict("mp_suicide")
                TaskPlayAnim(PlayerPedId(), 'mp_suicide', 'pill', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
                FW.Functions.Progressbar("mint", "Mintje slikken", 6000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    StopAnimTask(PlayerPedId(), 'mp_suicide', 'pill', 1.0)
                        FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                            if DidRemove then
                                TriggerServerEvent("FW:Server:SetMetaData", "hunger", FW.Functions.GetPlayerData().metadata["hunger"] + math.random(11, 16))
                            else
                                FW.Functions.Notify("Hmm volgensmij mis je het item..", "error")
                            end
                        end, ItemName, 1, false)
                    end, function()
                    DoingSomething = false
                    exports['fw-assets']:RemoveProp()
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Geannuleerd..", "error")
                    StopAnimTask(PlayerPedId(), 'mp_suicide', 'pill', 1.0)
                end)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:use:armor')
AddEventHandler('fw-items:client:use:armor', function(Item)
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        local CurrentArmor = GetPedArmour(PlayerPedId())

        exports["fw-inventory"]:SetBusyState(true)
        FW.Functions.Progressbar("vest", "Vest aantrekken..", 5000, false, true, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            anim = "idle_c",
            animDict = "amb@world_human_clipboard@male@idle_a",
            flags = 49,
        }, {}, {}, function() -- Done
            exports["fw-inventory"]:SetBusyState(false)
            FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                if not DidRemove then return end
                SetPedArmour(PlayerPedId(), CurrentArmor + 75 > 100 and 100 or CurrentArmor + 75)
                FW.TriggerServer("fw-medical:Server:SaveHealth", GetEntityHealth(PlayerPedId()), GetPedArmour(PlayerPedId()))
            end, Item, 1, false)
        end, function()
            exports["fw-inventory"]:SetBusyState(false)
            FW.Functions.Notify("Geannuleerd..", "error")
        end)
    end
end)

RegisterNetEvent("fw-items:client:use:lighter")
AddEventHandler("fw-items:client:use:lighter", function()
    if not LigherIsHot then
        LigherIsHot = true
        local FireInts = {}
        TriggerEvent("fw-misc:Client:PlaySound", 'items.lighter')
        for i = 1, 4, 1 do
            local FireCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, tonumber(((i*0.5)+ 0.5)), 0)
            local zz, GroundZ = GetGroundZFor_3dCoord(FireCoords.x, FireCoords.y, FireCoords.z, 0)
            table.insert(FireInts, StartScriptFire(FireCoords.x, FireCoords.y, GroundZ, 10, false))
            if i == 2 or 3 then
                local FireCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), -0.5, tonumber(((i*0.5)+ 0.5)), 0)
                local zz, GroundZ = GetGroundZFor_3dCoord(FireCoords.x, FireCoords.y, FireCoords.z, 0)
                table.insert(FireInts, StartScriptFire(FireCoords.x, FireCoords.y, GroundZ, 10, false))
                local FireCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.5, tonumber(((i*0.5)+ 0.5)), 0)
                local zz, GroundZ = GetGroundZFor_3dCoord(FireCoords.x, FireCoords.y, FireCoords.z, 0)
                table.insert(FireInts, StartScriptFire(FireCoords.x, FireCoords.y, GroundZ, 10, false))
            end
        end
        Citizen.Wait(500)
        for k, v in pairs(FireInts) do
            RemoveScriptFire(v)
        end
        Citizen.Wait(1500)
        LigherIsHot = false
    else
        FW.Functions.Notify("Wacht eem met die aansteker..", "error")
    end
end)

RegisterNetEvent('fw-items:client:use:tirekit')
AddEventHandler('fw-items:client:use:tirekit', function()
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        local Hit, Pos, Vehicle = exports['fw-ui']:RayCastGamePlayCamera(5.0)

        if Vehicle ~= -1 then
            exports["fw-inventory"]:SetBusyState(true)
            FW.Functions.Progressbar("repair_vehicle", "Banden verwisselen..", math.random(10000, 15000), false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "mini@repair",
                anim = "fixing_a_player",
                flags = 16,
            }, {}, {}, function() -- Done
                exports["fw-inventory"]:SetBusyState(false)
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
                FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                    if DidRemove then
                        NetworkRequestControlOfEntity(Vehicle)
                        local Wheels = {0,1,4,5}
                        for k, v in pairs(Wheels) do
                            FW.VSync.SetTyreHealth(Vehicle, v, 1000.0)
                            FW.VSync.SetVehicleTyreFixed(Vehicle, v)
                        end
                    end
                end)
            end, function() -- Cancel
                exports["fw-inventory"]:SetBusyState(false)
                StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
                FW.Functions.Notify("Mislukt!", "error")
            end, true)
        end
    end
end)

RegisterNetEvent('fw-items:client:use:repairkit')
AddEventHandler('fw-items:client:use:repairkit', function(IsAdvanced)
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        local PlayerCoords = GetEntityCoords(PlayerPedId())
        local Hit, Pos, Vehicle = exports['fw-ui']:RayCastGamePlayCamera(4.0)
        if GetVehicleEngineHealth(Vehicle) < 1000.0 then
            NewHealth = GetVehicleEngineHealth(Vehicle) + 250.0
            if GetVehicleEngineHealth(Vehicle) + 250.0 > 1000.0 then 
                NewHealth = 1000.0 
            end
            if not IsPedInAnyVehicle(PlayerPedId()) then
                local EnginePos = GetOffsetFromEntityInWorldCoords(Vehicle, 0, 2.5, 0)
                if IsBackEngine(GetEntityModel(Vehicle)) then
                    EnginePos = GetOffsetFromEntityInWorldCoords(Vehicle, 0, -2.5, 0)
                end

                if #(PlayerCoords - EnginePos) < 4.0 then
                    local VehicleDoor = nil
                    if IsBackEngine(GetEntityModel(Vehicle)) then
                        VehicleDoor = 5
                    else
                        VehicleDoor = 4
                    end
                    FW.VSync.SetVehicleDoorOpen(Vehicle, VehicleDoor, false, false)
                    exports["fw-inventory"]:SetBusyState(true)
                    exports['fw-assets']:RequestAnimationDict("mini@repair")
                    TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, 1.0, -1, 49, 0, 0, 0, 0)

                    local Outcome = exports['fw-ui']:StartSkillTest(IsAdvanced and 5 or 2, { 10, 15 }, { 15000, 20000 }, false)
                    if Outcome then
                        FW.VSync.SetVehicleDoorShut(Vehicle, VehicleDoor, false)
                        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
                        FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                            if DidRemove then
                                NetworkRequestControlOfEntity(Vehicle)
                                if IsAdvanced then
                                    FW.VSync.SetVehicleFixed(Vehicle)

                                    for i = 1, 2, 1 do
                                        TriggerServerEvent("fw-businesses:Server:AutoCare:ApplyPartDamage", GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle), 'Body')
                                        TriggerServerEvent("fw-businesses:Server:AutoCare:ApplyPartDamage", GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle), 'Engine')
                                    end
                                else
                                    SetVehicleEngineHealth(Vehicle, NewHealth) 

                                    TriggerServerEvent("fw-businesses:Server:AutoCare:ApplyPartDamage", GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle), 'Body')
                                    TriggerServerEvent("fw-businesses:Server:AutoCare:ApplyPartDamage", GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle), 'Engine')
                                end
                            end
                        end, IsAdvanced and 'big-repair' or 'repairkit', 1, false)
                    else
                        TriggerServerEvent('fw-inventory:Server:DecayItem', IsAdvanced and 'big-repair' or 'repairkit', nil, 10.0)
                        FW.VSync.SetVehicleDoorShut(Vehicle, VehicleDoor, false)
                        StopAnimTask(PlayerPedId(), "mini@repair", "fixing_a_player", 1.0)
                        exports["fw-inventory"]:SetBusyState(false)
                    end
                end
            else
                FW.Functions.Notify("Geen voertuig?!?", "error")
            end
        end    
    end
end)

RegisterNetEvent('fw-items:client:walkstick')
AddEventHandler('fw-items:client:walkstick', function()
    if not UsingStick then
        UsingStick = true
        RequestAnimSet('move_heist_lester')
        while not HasAnimSetLoaded('move_heist_lester') do
        Citizen.Wait(1)
        end
        SetPedMovementClipset(PlayerPedId(), 'move_heist_lester', 1.0) 
        WalkstickObject = CreateObject(GetHashKey("prop_cs_walking_stick"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(WalkstickObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.16, 0.06, 0.0, 335.0, 300.0, 120.0, true, true, false, true, 5, true)
    else
        UsingStick = false
        DetachEntity(WalkstickObject, 0, 0)
        DeleteEntity(WalkstickObject)
        ResetPedMovementClipset(PlayerPedId())
    end
end)

RegisterNetEvent('fw-items:Client:Used:Wheelchair')
AddEventHandler('fw-items:Client:Used:Wheelchair', function()
    if not IsPedInAnyVehicle(PlayerPedId()) then
        FW.Functions.Progressbar("remove-armor", "Rolstoel plaatsen..", 1500, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_common",
            anim = "givetake1_a",
            flags = 8,
        }, {}, {}, function() -- Done
            local PlayerCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.75, 0) GetEntityCoords(PlayerPedId())
            local CoordTable = {x = PlayerCoords.x, y = PlayerCoords.y, z = PlayerCoords.z, a = GetEntityHeading(PlayerPedId())}
            FW.Functions.TriggerCallback('FW:server:spawn:vehicle', function(Veh)
                while not NetworkDoesEntityExistWithNetworkId(Veh) do
                    Citizen.Wait(1000)
                end
                local Vehicle = NetToVeh(Veh)
                exports['fw-vehicles']:SetVehicleKeys(GetVehicleNumberPlateText(Vehicle), true, false)
                exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
            end, 'wheelchair', CoordTable, false, false)
            FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'wheelchair', 1, false)
        end, function() -- Cancel
            FW.Functions.Notify("Mislukt!", "error")
        end)
    end
end)

RegisterNetEvent('fw-items:Client:PickupWheelchair')
AddEventHandler('fw-items:Client:PickupWheelchair', function(Data, Entity)
    if IsVehicleSeatFree(Entity, -1) then
        FW.Functions.Progressbar("remove-armor", "Rolstoel Oppakken..", 1500, false, false, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_common",
            anim = "givetake1_a",
            flags = 8,
        }, {}, {}, function() -- Done
            FW.VSync.DeleteVehicle(Entity)
            TriggerServerEvent('fw-items:Server:ReturnWheelchair')
        end, function() -- Cancel
            FW.Functions.Notify("Mislukt!", "error")
        end)
    else
        FW.Functions.Notify("er zit nog iemand in de rolstoel joh...", "error")
    end
end)

RegisterNetEvent('fw-items:Client:Used:Scootmobile')
AddEventHandler('fw-items:Client:Used:Scootmobile', function()
    if not IsPedInAnyVehicle(PlayerPedId()) then
        FW.Functions.Progressbar("remove-armor", "Scootmobiel uitpakkenm..", 2000, false, false, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_common",
            anim = "givetake1_a",
            flags = 8,
        }, {}, {}, function() -- Done
            local PlayerCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.25, 0) GetEntityCoords(PlayerPedId())
            local CoordTable = {x = PlayerCoords.x, y = PlayerCoords.y, z = PlayerCoords.z, a = GetEntityHeading(PlayerPedId())}
            FW.Functions.TriggerCallback('FW:server:spawn:vehicle', function(Veh)
                while not NetworkDoesEntityExistWithNetworkId(Veh) do
                    Citizen.Wait(1000)
                end
                local Vehicle = NetToVeh(Veh)
                exports['fw-vehicles']:SetVehicleKeys(GetVehicleNumberPlateText(Vehicle), true, false)
                exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
            end, 'scootmobile', CoordTable, false, false)
            FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'scootmobile', 1, false)
        end, function() -- Cancel
            FW.Functions.Notify("Mislukt!", "error")
        end)
    end
end)

RegisterNetEvent('fw-items:Client:PickupScootmobile')
AddEventHandler('fw-items:Client:PickupScootmobile', function(Data, Entity)
    if IsVehicleSeatFree(Entity, -1) then
        FW.Functions.Progressbar("remove-armor", "Scootmobiel inpakken..", 2500, false, false, {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_common",
            anim = "givetake1_a",
            flags = 8,
        }, {}, {}, function() -- Done
            FW.VSync.DeleteVehicle(Entity)
            TriggerServerEvent('fw-items:Server:ReturnScootmobile')
        end, function() -- Cancel
            FW.Functions.Notify("Mislukt!", "error")
        end)
    else
        FW.Functions.Notify("Er zit nog iemand in de scootmobiel joh...", "error")
    end
end)

RegisterNetEvent("fw-items:client:use:parachute")
AddEventHandler("fw-items:client:use:parachute", function()
    exports['fw-assets']:RequestAnimationDict("clothingshirt")
    TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    FW.Functions.Progressbar("use_parachute", "Parachute omdoen..", 5000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        GiveWeaponToPed(PlayerPedId(), GetHashKey("GADGET_PARACHUTE"), 1, false)
        SetPedComponentVariation(PlayerPedId(), 5, 7, 0, 0)
        TaskPlayAnim(PlayerPedId(), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
        FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'parachute', 1, false)
        ParachuteEquiped = true
    end, function()end, true)
end)

RegisterNetEvent("fw-items:client:use:hairtie")
AddEventHandler("fw-items:client:use:hairtie", function()
    local HairValue = SupportedModels[GetEntityModel(PlayerPedId())]
    if HairValue ~= nil then
        exports['fw-assets']:RequestAnimationDict("amb@code_human_wander_idles@female@idle_a")
        TaskPlayAnim(PlayerPedId(), "amb@code_human_wander_idles@female@idle_a", "idle_a_hairtouch", 4.0, 3.0, -1, 49, 1.0, 0, 0, 0)
        Citizen.Wait(1000)
        if not HairTied then
            local HairDraw = GetPedDrawableVariation(PlayerPedId(), 2)
            local HairTexture = GetPedTextureVariation(PlayerPedId(), 2)
            local HairPallete = GetPedPaletteVariation(PlayerPedId(), 2)
            HairSyles = {HairDraw, HairTexture, HairPallete}
            SetPedComponentVariation(PlayerPedId(), 2, HairValue, HairTexture, HairPallete)
            HairTied = true
        else
            SetPedComponentVariation(PlayerPedId(), 2, HairSyles[1], HairSyles[2], HairSyles[3])
            HairTied, HairSyles = false, nil
        end
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent('fw-items:client:dobbel')
AddEventHandler('fw-items:client:dobbel', function(Amount, Sides)
    local DiceResult = {}
    for i = 1, Amount do
        table.insert(DiceResult, math.random(1, Sides))
    end
    local RollText = CreateRollText(DiceResult, Sides)
    TriggerEvent('fw-items:client:dice:anim')
    Citizen.SetTimeout(1900, function()
        TriggerEvent("fw-misc:Client:PlaySoundEntity", 'items.dice', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, GetPlayerServerId(PlayerId()))
        TriggerServerEvent('fw-assets:Server:DrawMeText', RollText)
    end)
end)

RegisterNetEvent('fw-items:client:coinflip')
AddEventHandler('fw-items:client:coinflip', function()
    local CoinFlip = {}
    local Random = math.random(1,2)
    if Random <= 1 then
        CoinFlip = 'Coinflip: ~g~Kop'
    else
        CoinFlip = 'Coinflip: ~y~Munt'
    end
    TriggerEvent('fw-items:client:dice:anim')
    Citizen.SetTimeout(1900, function()
        TriggerEvent("fw-misc:Client:PlaySoundEntity", 'items.coinflip', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, GetPlayerServerId(PlayerId()))
        TriggerServerEvent('fw-assets:Server:DrawMeText', CoinFlip)
    end)
end)

RegisterNetEvent('fw-items:client:dice:anim')
AddEventHandler('fw-items:client:dice:anim', function()
    exports['fw-assets']:RequestAnimationDict("anim@mp_player_intcelebrationmale@wank")
    TaskPlayAnim(PlayerPedId(), "anim@mp_player_intcelebrationmale@wank", "wank", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(1500)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent("fw-items:Client:OpenBag")
AddEventHandler("fw-items:Client:OpenBag", function(BagId, Type)
    local Slots, Weight = 5, 10
    if Type == "policeduffel" then
        Slots, Weight = 20, 500
    elseif Type == "duffel" then
        Slots, Weight = 10, 150
    elseif Type == "SeedBag" then
        Slots, Weight = 40, 5
    elseif Type == "ProduceBasket" then
        Slots, Weight = 40, 100
    elseif Type == "Teddy" then
        Slots, Weight = 3, 10
    elseif Type == "cassettebox" then
        Slots, Weight = 20, 0
    end
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Bag', BagId, Slots, Weight)
end)

RegisterNetEvent('fw-items:Client:OpenMoneyCase')
AddEventHandler('fw-items:Client:OpenMoneyCase', function(Slot, IsAdv)
    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Code', Icon = 'fas fa-ellipsis-h', Name = 'Code', Type = 'password' },
    })

    if Result then
        TriggerServerEvent('fw-items:Server:OpenMoneycase', Slot, IsAdv, Result.Code)
    end
end)

RegisterNetEvent('fw-items:Client:SetMoneyCase')
AddEventHandler('fw-items:Client:SetMoneyCase', function(Slot, IsAdv)
    local MaxWorth = IsAdv and 100000 or 50000
    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Geldbedrag', Icon = 'fas fa-dollar-sign', Name = 'Worth', Type = 'number' },
        { Label = 'Code (optioneel)', Icon = 'fas fa-ellipsis-h', Name = 'Code', Type = 'password' },
    })

    if Result then
        if tonumber(Result.Worth) <= 0 then FW.Functions.Notify("Stop er ten minste een eurotje in, arme sloeber.", "error") return end
        if tonumber(Result.Worth) > MaxWorth then FW.Functions.Notify("Rijke jongen jij, maar helaas past er maar €" .. (IsAdv and "100.000" or "50.000") .. " in..", "error") return end

        TriggerServerEvent('fw-items:Server:GiveMoneyCase', Slot, IsAdv, tonumber(Result.Worth), Result.Code)
    end
end)

RegisterNetEvent('fw-items:Client:Used:Lawnchair')
AddEventHandler('fw-items:Client:Used:Lawnchair', function()
    if IsPedFalling(PlayerPedId()) or IsPedRagdoll(PlayerPedId()) then return end

    if IsEntityPlayingAnim(PlayerPedId(), "timetable@ron@ig_3_couch", "base", 3) then
        UsingLawnchair = false
        exports['fw-assets']:RemoveProp()
        StopAnimTask(PlayerPedId(), "timetable@ron@ig_3_couch", "base", 1.0)
    else
        UsingLawnchair = true

        RequestAnimDict("timetable@ron@ig_3_couch")
        while not HasAnimDictLoaded("timetable@ron@ig_3_couch") do Citizen.Wait(4) end

        exports['fw-assets']:AddProp('lawnchair')

        Citizen.CreateThread(function()
            while UsingLawnchair do
                if not IsEntityPlayingAnim(PlayerPedId(), "timetable@ron@ig_3_couch", "base", 3) then
                    TaskPlayAnim(PlayerPedId(), "timetable@ron@ig_3_couch", "base", 1.0, 1.0, -1, 1, 0, false, false, false)
                end

                Citizen.Wait(450)
            end
        end)
    end
end)

RegisterNetEvent("animations:EmoteCancel")
AddEventHandler("animations:EmoteCancel", function()
    if not UsingLawnchair then return end
    UsingLawnchair = false
    exports['fw-assets']:RemoveProp()
    StopAnimTask(PlayerPedId(), "timetable@ron@ig_3_couch", "base", 1.0)
end)

--  // Functions \\ --

function IsBackEngine(Vehicle)
    for _, model in pairs(Config.BackEngineVehicles) do
        if GetHashKey(model) == Vehicle then
            return true
        end
    end
    return false
end

function CreateRollText(Table, Sides)
    local String = "~g~Gedobbeld~s~: "
    local Total = 0
    for k, v in pairs(Table) do
        Total = Total + v
        if k == 1 then
            String = String .. v .. "/" .. Sides
        else
            String = String .. " | " .. v .. "/" .. Sides
        end
    end
    String = String .. " | (Totaal: ~g~"..Total.."~s~)"
    return String
end

function DrinkEffect()
    RequestAnimSet("move_m@drunk@slightlydrunk")
    while not HasAnimSetLoaded("move_m@drunk@slightlydrunk") do
        Citizen.Wait(0)
    end
    SetPedMovementClipset(PlayerPedId(), "move_m@drunk@slightlydrunk", true)
    AnimSet = "move_m@drunk@slightlydrunk";

    SetTimecycleModifier("spectator5")
    ShakeGameplayCam('DRUNK_SHAKE', 1.0)  
    Citizen.Wait(math.random(6000, 10000))
    ClearTimecycleModifier()
    ShakeGameplayCam('DRUNK_SHAKE', 0.0)  

    Citizen.Wait(math.random(5000, 15000))

    ResetPedMovementClipset(PlayerPedId(), 0)
    AnimSet = "default";
end