local CurrentHat, CurrentHatTexture = nil, nil

FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

local Carrying, AttatchedEntity = false, nil
HasBelt, HasHarness = false, false
CurrentVehicle = nil

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function()
        LoggedIn = true

        Config.VehicleKeys = FW.SendCallback("fw-vehicles:Server:GetVehicleKeys")
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

Citizen.CreateThread(function()
    InitNitrous()
end)

RegisterNetEvent("FW:Vehicle:OnThreadChange")
AddEventHandler("FW:Vehicle:OnThreadChange", function(Vehicle)
    CurrentVehicle = Vehicle
    local VehicleClass = 0
    if DoesEntityExist(Vehicle) then VehicleClass = GetVehicleClass(Vehicle) end

    if Vehicle == 0 or Vehicle == -1 then
        HasBelt, HasHarness = false, false
    -- elseif VehicleClass == 8 or VehicleClass == 13 or VehicleClass == 14 or GetEntityModel(Vehicle) == GetHashKey("polmotor") then
    --     exports['fw-ui']:SetSeatbelt(true) -- Hide on motorcycle
    end
end)

RegisterNetEvent("fw-vehicles:Client:SetPoliceCallsign")
AddEventHandler("fw-vehicles:Client:SetPoliceCallsign", function(Callsign)
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if Vehicle == nil then return end

    SetVehicleModKit(Vehicle, 0)
    SetVehicleMod(Vehicle, 42, tonumber(Callsign:sub(1, 1)), false)
    Citizen.Wait(50)
    SetVehicleMod(Vehicle, 44, tonumber(Callsign:sub(2, 2)), false)
    Citizen.Wait(50)
    SetVehicleMod(Vehicle, 45, tonumber(Callsign:sub(3, 3)), false)
end)

RegisterNetEvent('fw-vehicles:Client:Switch:Seat')
AddEventHandler('fw-vehicles:Client:Switch:Seat', function(SeatNumber)
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if IsVehicleSeatFree(Vehicle, SeatNumber) then
        TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, SeatNumber)
    else
        FW.Functions.Notify("Hier zit al iemand met z'n dikke reet..", "error")
    end
end)

RegisterNetEvent('fw-vehicle:client:clean:vehicle', function()
    local vehicle = FW.Functions.GetClosestVehicle()
    if vehicle ~= nil and vehicle ~= 0 then
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehpos = GetEntityCoords(vehicle)
        if #(pos - vehpos) < 3.0 and not IsPedInAnyVehicle(ped) then
            CleanVehicle(vehicle)
        else
            FW.Functions.Notify("Je staat niet in de buurt van een voertuig en/of zit in een voertuig...", "error")
        end
    end
end)

function CleanVehicle(vehicle)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_MAID_CLEAN", 0, true)
    FW.Functions.Progressbar("cleaning_vehicle", "Voertuig poetsen...", math.random(10000, 20000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        SetVehicleDirtLevel(vehicle, 0.1)
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'car-polish', 1, false)
        ClearAllPedProps(ped)
        ClearPedTasks(ped)
        FW.Functions.Notify("Je hebt je voertuig schoon gemaakt...", "success")
    end, function() -- Cancel
        FW.Functions.Notify("Geannuleerd..", "error")
        ClearAllPedProps(ped)
        ClearPedTasks(ped)
    end)
end

function IsPoliceVehicle(Vehicle)
    local Model = GetEntityModel(Vehicle)
    for k, v in pairs(Config.PoliceVehicles) do
        if Model == GetHashKey(v) then
            return true
        end
    end

    return false
end
exports('IsPoliceVehicle', IsPoliceVehicle)

function IsGovVehicle(Vehicle)
    local Model = GetEntityModel(Vehicle)
    for k, v in pairs(Config.PoliceVehicles) do
        if Model == GetHashKey(v) then
            return true
        end
    end

    local Model = GetEntityModel(Vehicle)
    for k, v in pairs(Config.EmsVehicles) do
        if Model == GetHashKey(v) then
            return true
        end
    end

    return false
end
exports('IsGovVehicle', IsGovVehicle)

function GetBoneDistanceFromVehicle(EntityType, BoneName)
    local PeekingEntity = exports['fw-ui']:GetPeekingEntity()
    if PeekingEntity ~= nil and DoesEntityExist(PeekingEntity) then
        if GetEntityType(PeekingEntity) == EntityType then
            local Bone = GetEntityBoneIndexByName(PeekingEntity, BoneName)

            local BoneCoords = GetWorldPositionOfEntityBone(PeekingEntity, Bone)
            local PlayerCoords = GetEntityCoords(PlayerPedId())

            return #(BoneCoords - PlayerCoords)
        end
    end

    return 99999.0
end

function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoGloves[armIndex] ~= nil and Config.MaleNoGloves[armIndex] then
            return false
        end
    else
        if Config.FemaleNoGloves[armIndex] ~= nil and Config.FemaleNoGloves[armIndex] then
            return false
        end
    end
    return math.random() > 0.15
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if Carrying then
                if IsControlJustReleased(0, 38) then
                    DetachEntity(AttatchedEntity, nil, nil)
                    SetVehicleOnGroundProperly(AttatchedEntity)
                    Carrying, AttatchedEntity = false, nil
                    Citizen.Wait(150)
                    ClearPedTasks(PlayerPedId())
                    exports['fw-ui']:HideInteraction()
                end
                if IsEntityDead(PlayerPedId()) then
                    DetachEntity(AttatchedEntity, nil, nil)
                    SetVehicleOnGroundProperly(AttatchedEntity)
                    Carrying, AttatchedEntity = false, nil
                    Citizen.Wait(150)
                    ClearPedTasks(PlayerPedId())
                    exports['fw-ui']:HideInteraction()
                end
            else
                Citizen.Wait(500)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if Carrying then
                if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
                    exports['fw-assets']:RequestAnimationDict("anim@heists@box_carry@")
                    TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 2.0, 2.0, -1, 51, 0, false, false, false)
                else
                    Citizen.Wait(50)
                end
            else
                Citizen.Wait(500)
            end
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('fw-vehicles:client:carry:bicycle')
AddEventHandler('fw-vehicles:client:carry:bicycle', function(Nothing, Entity)
    if not Carrying then
        local PlayerBone = GetPedBoneIndex(PlayerPedId(), 0xE5F3)
        NetworkRequestControlOfEntity(Entity)
        exports['fw-ui']:ShowInteraction('[E] Fiets Droppen', 'primary')
        AttachEntityToEntity(Entity, PlayerPedId(), PlayerBone, 0.0, 0.24, 0.10, 340.0, 330.0, 330.0, true, true, false, true, 1, true)
        exports['fw-assets']:RequestAnimationDict("anim@heists@box_carry@")
        TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 2.0, 2.0, -1, 51, 0, false, false, false)
        AttatchedEntity = Entity
        Carrying = true
    else
        FW.Functions.Notify('Je hebt al wat in je handen..', 'error', 5500)
    end
end)

RegisterNetEvent("fw-vehicles:Client:StealRim")
AddEventHandler("fw-vehicles:Client:StealRim", function(Data, Entity)

    local ClosestWheel = false
    if GetBoneDistanceFromVehicle(2, "wheel_lf") < 1.0 then ClosestWheel = 0 end
    if GetBoneDistanceFromVehicle(2, "wheel_rf") < 1.0 then ClosestWheel = 1 end
    if GetBoneDistanceFromVehicle(2, "wheel_lr") < 1.0 then ClosestWheel = 4 end
    if GetBoneDistanceFromVehicle(2, "wheel_rr") < 1.0 then ClosestWheel = 5 end

    if ClosestWheel == false then return end

    if IsVehicleTyreBurst(Entity, ClosestWheel, true) then
        return
    end

    if not IsWearingHandshoes() then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Outcome = exports['fw-ui']:StartSkillTest(math.random(5, 8), { 5, 10 }, { 1500, 3000 }, true)
    if not Outcome then
        TriggerServerEvent('fw-inventory:Server:DecayItem', 'screwdriver', nil, 5.0)
        return FW.Functions.Notify("Noob..", "error")
    end

    if math.random() < 0.35 then
        TriggerServerEvent("fw-mdw:Server:SendAlert:Oxy", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())
    end

    local Finished = FW.Functions.CompactProgressbar(30000, "Zwieber niet stelen...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", anim = "machinic_loop_mechandplayer", flags = 1 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    if not Finished then return end

    FW.VSync.BreakOffVehicleWheel(Entity, ClosestWheel, true, true, true, false)
    FW.TriggerServer("FW:AddItem", "stolen-vehicle-rim", 1, false, false, true)
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'screwdriver', nil, 15.0)
end)

RegisterNetEvent('fw-vehicles:Client:InspectVIN')
AddEventHandler('fw-vehicles:Client:InspectVIN', function(Data, Entity)
    local VIN = FW.SendCallback("fw-vehicles:Server:GetVIN", GetVehicleNumberPlateText(Entity))

    if not VIN then
        return FW.Functions.Notify("Het VIN lijkt doorgekrast te zijn..", "error")
    end

    FW.Functions.Notify("VIN: " .. VIN)
end)

function HasOverdueDebts(Owner)
    local Debts = FW.SendCallback("fw-misc:Server:GetOverdueDebtsByCid", "Maintenance", "Vehicle", Owner)
    return #Debts > 0
end

function HasHousingOverdueDebts(HouseName)
    local Debts = FW.SendCallback("fw-misc:Server:GetOverdueDebts", "Maintenance", "Housing")
    for k, v in pairs(Debts) do
        if json.decode(v.debt_data).Name == HouseName then
            return true
        end
    end
    return false
end

function GetPoliceVehicles()
    return Config.PoliceVehicles
end
exports("GetPoliceVehicles", GetPoliceVehicles)
