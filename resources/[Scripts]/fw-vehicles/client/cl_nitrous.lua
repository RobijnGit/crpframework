local FlameScale, PurgeSprayScale = 1.2, 0.8
local NitrousStages = {5.0, 3.0, 1.0, 0.5, 0.25}
local DoingNitrous, NitrousStage = false, 1
local NitrousType = 'Nitrous'
local VehicleParticles = {}
local ExhaustNames = {
    "exhaust",    "exhaust_2",  "exhaust_3",  "exhaust_4",
    "exhaust_5",  "exhaust_6",  "exhaust_7",  "exhaust_8",
    "exhaust_9",  "exhaust_10", "exhaust_11", "exhaust_12",
    "exhaust_13", "exhaust_14", "exhaust_15", "exhaust_16"
}

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and DoingNitrous then
            DisableControlAction(0, 75, true)
            DisableControlAction(27, 75, true)
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

-- RegisterNetEvent('fw-items:Client:Used:Nitrous')
-- AddEventHandler('fw-items:Client:Used:Nitrous', function()
--     Citizen.SetTimeout(450, function()
--         local Vehicle = GetVehiclePedIsIn(PlayerPedId())
--         local Plate = GetVehicleNumberPlateText(Vehicle)
--         if DoingNitrous then return end
--         if Vehicle == 0 or Vehicle == -1 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() or Config.VehicleData[Plate] == nil then return end
--         if IsPoliceVehicle(Vehicle) then
--             TriggerEvent('fw-ui:Client:Notify', 'nitrous-error', "I don\'t think this vehicle should take some nitrous..", 'error')
--             return
--         end
--         if not IsToggleModOn(Vehicle, 18) then
--             TriggerEvent('fw-ui:Client:Notify', 'nitrous-error', "Looks like this vehicle doesn\'t even have a turbo installed..", 'error')
--             return 
--         end
--         if Config.VehicleData[Plate].Nitrous >= 100 then
--             TriggerEvent('fw-ui:Client:Notify', 'nitrous-error', "Your nitrous tank is full..", 'error')
--             return
--         end

--         exports['fw-inventory']:SetBusyState(true)
--         exports['fw-ui']:ProgressBar('Nitrous..', 3500, false, false, false, true, function(DidComplete)
--             if DidComplete then
--                 SetNitrousLevel(Plate, 100.0)
--                 EventsModule.TriggerServer('fw-inventory:Server:DecayItem', 'nitrous', exports['fw-inventory']:GetSlotForItem('nitrous', ''), 100.0)
--             end
--             exports['fw-inventory']:SetBusyState(false)
--         end)
--     end)
-- end)

RegisterNetEvent('fw-vehicles:Client:Set:Vehicle:Flames')
AddEventHandler('fw-vehicles:Client:Set:Vehicle:Flames', function(Veh, Bool)
    local Vehicle = NetToVeh(Veh)
    if Bool then
        CreateVehicleExhaustBackfire(Vehicle)
    else
        RemoveVehicleExhaustBackfire(Vehicle)
    end
end)

RegisterNetEvent('fw-vehicles:Client:Set:Vehicle:Purge')
AddEventHandler('fw-vehicles:Client:Set:Vehicle:Purge', function(Veh, Bool)
    local Vehicle = NetToVeh(Veh)
    if Bool then
        CreateVehiclePurgeSpray(Vehicle)
    else
        RemoveVehiclePurgeSpray(Vehicle)
    end
end)

RegisterNetEvent('fw-vehicles:Client:Nitrous:Usage')
AddEventHandler('fw-vehicles:Client:Nitrous:Usage', function(IsPressed)
    if IsPressed then return end
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    local Plate = GetVehicleNumberPlateText(Vehicle)
    if Vehicle == 0 or Vehicle == -1 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() then return end
    local Nitrous = GetVehicleMeta(Vehicle, 'Nitrous')
    if Nitrous ~= nil and Nitrous > 0 then
        if NitrousStage + 1 > #NitrousStages then
            NitrousStage = 1
        else
            NitrousStage = NitrousStage + 1
        end
        FW.Functions.Notify("Nitrous gebruik gezet naar: " .. NitrousStages[NitrousStage])
    end
end)

RegisterNetEvent('fw-vehicles:Client:Nitrous:Type')
AddEventHandler('fw-vehicles:Client:Nitrous:Type', function(IsPressed)
    if IsPressed then return end
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    local Plate = GetVehicleNumberPlateText(Vehicle)
    if Vehicle == 0 or Vehicle == -1 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() then return end
    if GetVehicleMeta(Vehicle, 'Nitrous') > 0 then
        if NitrousType == 'Nitrous' then
            NitrousType = 'Purge'
        else
            NitrousType = 'Nitrous'
        end
        FW.Functions.Notify("Nitrous type: "..NitrousType)
    end
end)

RegisterNetEvent('fw-vehicles:Client:Nitrous')
AddEventHandler('fw-vehicles:Client:Nitrous', function(OnPress)
    if OnPress then
        local Vehicle = GetVehiclePedIsIn(PlayerPedId())
        local Plate = GetVehicleNumberPlateText(Vehicle)
        if Vehicle == 0 or Vehicle == -1 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() then return end
        local NitrousLevel = GetVehicleMeta(Vehicle, 'Nitrous')
        if NitrousLevel ~= nil and NitrousLevel > 0 then
            if not exports['fw-racing']:IsNitrousAllowed() then
                return FW.Functions.Notify("Je zit in een race waar nitrous niet is toegestaan!", "error")
            end

            DoingNitrous = true
            if NitrousType == 'Nitrous' then
                SetVehicleBoostActive(Vehicle, true)
                TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Flames', VehToNet(Vehicle), true)
            elseif NitrousType == 'Purge' then
                TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), true)
            end
            DoNitrousLoop(Vehicle, Plate)
        end
    else
        if DoingNitrous then
            local Vehicle = GetVehiclePedIsIn(PlayerPedId())
            local Plate = GetVehicleNumberPlateText(Vehicle)
            DoingNitrous = false
            if NitrousType == 'Nitrous' then
                SetVehicleBoostActive(Vehicle, false)
                SetVehicleEnginePowerMultiplier(Vehicle, 1.0)
                SetVehicleEngineTorqueMultiplier(Vehicle, 1.0)
                TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Flames', VehToNet(Vehicle), false)
                Citizen.SetTimeout(100, function()
                    TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), true)
                    Citizen.Wait(1500)
                    TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), false)
                end)
            elseif NitrousType == 'Purge' then
                TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), false)
            end
        end
    end
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('Nitrous'), 0)
    if DoingNitrous then
        DoingNitrous = false
        local Plate = GetVehicleNumberPlateText(Vehicle)
        if NitrousType == 'Nitrous' then
            SetVehicleBoostActive(Vehicle, false)
            SetVehicleEnginePowerMultiplier(Vehicle, 1.0)
            SetVehicleEngineTorqueMultiplier(Vehicle, 1.0)
            TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Flames', VehToNet(Vehicle), false)
            Citizen.SetTimeout(100, function()
                TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), true)
                Citizen.Wait(1500)
                TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), false)
            end)
        elseif NitrousType == 'Purge' then
            TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), false)
        end
    end
end)

-- // Functions \\ --

-- Nitrous Loop

function DoNitrousLoop(Vehicle, Plate)
    Citizen.CreateThread(function()
        while DoingNitrous do
            Citizen.Wait(4)
            if GetVehicleMeta(Vehicle, 'Nitrous') - NitrousStages[NitrousStage] > 0 then
                if NitrousType == 'Nitrous' then
                    local CurrentSpeed, MaximumSpeed = GetEntitySpeed(Vehicle), GetVehicleModelMaxSpeed(GetEntityModel(Vehicle))
                    local Multiplier = NitrousStages[NitrousStage] * MaximumSpeed / CurrentSpeed                      
                    SetVehicleEnginePowerMultiplier(Vehicle, Multiplier)
                    SetVehicleEngineTorqueMultiplier(Vehicle, Multiplier)
                end
                local NewNitrous = GetVehicleMeta(Vehicle, 'Nitrous') - NitrousStages[NitrousStage]
                SetVehicleMeta(Vehicle, "Nitrous", NewNitrous)
                exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('Nitrous'), NewNitrous)
            else
                DoingNitrous = false
                SetVehicleMeta(Vehicle, "Nitrous", 0)
                exports['fw-hud']:SetHudValue(exports['fw-hud']:GetHudId('Nitrous'), 0)
                if NitrousType == 'Nitrous' then
                    SetVehicleBoostActive(Vehicle, false)
                    SetVehicleEnginePowerMultiplier(Vehicle, 1.0)
                    SetVehicleEngineTorqueMultiplier(Vehicle, 1.0)
                    TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Flames', VehToNet(Vehicle), false)
                    Citizen.SetTimeout(100, function()
                        TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), true)
                        Citizen.Wait(1500)
                        TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), false)
                    end)
                elseif NitrousType == 'Purge' then
                    TriggerServerEvent('fw-vehicles:Server:Set:Vehicle:Purge', VehToNet(Vehicle), false)
                end
            end
            Citizen.Wait(1000)
        end
    end)
end

-- Flames

function CreateVehicleExhaustBackfire(Vehicle)
    Citizen.CreateThread(function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        if Vehicle ~= -1 and Plate ~= nil then
            if VehicleParticles[Plate] == nil then VehicleParticles[Plate] = {} end
            for k, v in pairs(ExhaustNames) do
                if GetEntityBoneIndexByName(Vehicle, v) ~= -1 then
                    SetPtfxAssetNextCall('veh_xs_vehicle_mods')
                    Citizen.InvokeNative(0x6C38AF3693A69A91, 'veh_xs_vehicle_mods')
                    table.insert(VehicleParticles[Plate], StartNetworkedParticleFxLoopedOnEntityBone('veh_nitrous', Vehicle, 0.0, -0.02, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(Vehicle, v), FlameScale, 0.0, 0.0, 0.0))
                end
            end
        end
    end)
end

function RemoveVehicleExhaustBackfire(Vehicle)
    Citizen.CreateThread(function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        if Vehicle ~= -1 and Plate ~= nil then
            if VehicleParticles[Plate] ~= nil then
                for k, v in pairs(VehicleParticles[Plate]) do
                    StopParticleFxLooped(v, 1)
                end
                VehicleParticles[Plate] = {}
            end
        end
    end)
end

-- Spray

function CreateVehicleSpray(Vehicle, X, Y, Z, XRot, YRot, ZRot)
    UseParticleFxAssetNextCall('core')
    return StartParticleFxLoopedOnEntity('ent_sht_steam', Vehicle, X, Y, Z, XRot, YRot, ZRot, PurgeSprayScale, false, false, false)
end

function CreateVehiclePurgeSpray(Vehicle)
    Citizen.CreateThread(function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        if Vehicle ~= -1 and Plate ~= nil then
            local Position = GetWorldPositionOfEntityBone(Vehicle, GetEntityBoneIndexByName(Vehicle, 'bonnet'))
            local OffSets = GetOffsetFromEntityGivenWorldCoords(Vehicle, Position.x, Position.y, Position.z)
            if VehicleParticles[Plate] == nil then VehicleParticles[Plate] = {} end
            table.insert(VehicleParticles[Plate], CreateVehicleSpray(Vehicle, OffSets.x - 0.5, OffSets.y + 0.05, OffSets.z, 40.0, -40.0, 0.0))
            table.insert(VehicleParticles[Plate], CreateVehicleSpray(Vehicle, OffSets.x + 0.5, OffSets.y + 0.05, OffSets.z, 40.0, 40.0, 0.0))
        end
    end)
end

function RemoveVehiclePurgeSpray(Vehicle)
    Citizen.CreateThread(function()
        local Plate = GetVehicleNumberPlateText(Vehicle)
        if Vehicle ~= -1 and Plate ~= nil then
            if VehicleParticles[Plate] ~= nil then
                for k, v in pairs(VehicleParticles[Plate]) do
                    StopParticleFxLooped(v, 1)
                end
                VehicleParticles[Plate] = {}
            end
        end
    end)
end

-- Nitrous Data

-- function SetNitrousLevel(Plate, Amount)
--     local Amount = Amount + 0.0
--     TriggerServerEvent('fw-vehicles:Server:Set:Nitrous', Plate, Amount)
-- end
-- exports("SetNitrousLevel", SetNitrousLevel)

function InitNitrous()
    RequestNamedPtfxAsset('core')
    RequestNamedPtfxAsset('veh_xs_vehicle_mods')

    FW.AddKeybind('useNitrous', 'Voertuig', 'Gebruik Nitrous', '', false, 'fw-vehicles:Client:Nitrous')
    FW.AddKeybind('setNitrous', 'Voertuig', 'Zet Nitrous Gebruik', '', false, 'fw-vehicles:Client:Nitrous:Usage')
    FW.AddKeybind('swapNitrousMode', 'Voertuig', 'Zet Nitrous Type', '', false, 'fw-vehicles:Client:Nitrous:Type')
end