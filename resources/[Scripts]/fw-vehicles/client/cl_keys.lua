local HijackingVehicle, Lockpicking, LastCartheftAlert, InVehicle = false, false, nil, false

-- Loops

Citizen.CreateThread(function()
    FW.AddKeybind("vehicleEngineOn", "Voertuig", "Zet Motor Aan", "IOM_WHEEL_UP", false, "fw-vehicles:Client:SetEngineOn", false, "MOUSE_WHEEL")
    FW.AddKeybind("vehicleEngineOff", "Voertuig", "Zet Motor Uit", "IOM_WHEEL_DOWN", false, "fw-vehicles:Client:SetEngineOff", false, "MOUSE_WHEEL")
    FW.AddKeybind("vehicleToggleLock", "Voertuig", "Voertuig Vergrenden/Ontgrendelen", "L", false, "fw-vehicles:Client:ToggleVehicleLock", false)

    while true do
        if LoggedIn then
            DisableControlAction(0, 332, true)
            DisableControlAction(0, 333, true)
            DisableControlAction(0, 332, true)
            DisableControlAction(0, 333, true)
            DisableControlAction(0, 14, true)
            DisableControlAction(0, 15, true)
            DisableControlAction(0, 16, true)
            DisableControlAction(0, 17, true)
            DisableControlAction(0, 81, true)
            DisableControlAction(0, 82, true)
            DisableControlAction(0, 99, true)
            DisableControlAction(0, 100, true)
            DisableControlAction(0, 115, true)
            DisableControlAction(0, 116, true)
        else
            Citizen.Wait(500)
        end

        Citizen.Wait(4)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
		if LoggedIn then
			local Vehicle = GetVehiclePedIsTryingToEnter(PlayerPedId())
			if Vehicle == -1 or Vehicle == 0 then goto SkipLoop end
			if GetVehicleDoorLockStatus(Vehicle) == 7 then
				SetVehicleDoorsLocked(Vehicle, 2)
			end
	
			local TargetPed = GetPedInVehicleSeat(Vehicle, -1)
			if TargetPed == -1 or TargetPed == 0 then goto SkipLoop end
			SetPedCanBeDraggedOut(TargetPed, false)
			::SkipLoop::
		else
			Citizen.Wait(450)
		end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and IsPedInAnyVehicle(PlayerPedId()) then
            local Vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
            if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
                if IsControlPressed(2, 75) and GetIsVehicleEngineRunning(Vehicle) then
                    local Plate = GetVehicleNumberPlateText(Vehicle)
                    if HasKeysToVehicle(Plate) then
                        TaskLeaveVehicle(PlayerPedId(), Vehicle, 0)
                        SetVehicleEngineOn(Vehicle, true, true, true)
                        Citizen.Wait(95)
                        SetVehicleEngineOn(Vehicle, true, true, true)
                    else
                        TaskLeaveVehicle(PlayerPedId(), Vehicle, 0)
                    end
                end
            else
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and not StealingKeys then
            if GetVehiclePedIsTryingToEnter(PlayerPedId()) ~= 0 and GetSeatPedIsTryingToEnter(PlayerPedId()) == -1 then
                local Vehicle = GetVehiclePedIsTryingToEnter(PlayerPedId())
                local Driver = GetPedInVehicleSeat(Vehicle, -1)
                if Driver ~= 0 and not IsPedAPlayer(Driver) and IsEntityDead(Driver) then
                    StealingKeys = true
                    FW.Functions.Progressbar("bitch", "Sleutels nakken...", 3000, false, false, {}, {}, {}, {}, function() -- Done
                        TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Vehicle, true)
                        SetVehicleKeys(GetVehicleNumberPlateText(Vehicle), true)
                        exports['fw-vehicles']:SetVehicleTampering(Vehicle, 'Blood', true)
                        exports['fw-vehicles']:SetVehicleTampering(Vehicle, 'Lockpicked', true)
                        StealingKeys = false
                    end, function()
                        StealingKeys = false
                    end, true)
                end
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- Functions
function HasKeysToVehicle(Plate)
    return Config.VehicleKeys[Plate] ~= nil and Config.VehicleKeys[Plate][FW.Functions.GetPlayerData().citizenid]
end
exports("HasKeysToVehicle", HasKeysToVehicle)

function SetVehicleKeys(Plate, State, Cid)
    TriggerServerEvent('fw-vehicles:Server:SetVehicleKeys', Plate, State, Cid ~= nil and Cid or false)
end
exports("SetVehicleKeys", SetVehicleKeys)

function LoopAnimation(Bool, AnimDict, AnimName)
    Lockpicking = Bool
    if not Lockpicking then return end

    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do Citizen.Wait(4) end

    Citizen.CreateThread(function()
        while Lockpicking do
            Citizen.Wait(4)
            TaskPlayAnim(PlayerPedId(), AnimDict, AnimName, 3.0, 3.0, -1, 16, 0, false, false, false)
            Citizen.Wait(1000)
        end
        StopAnimTask(PlayerPedId(), AnimDict, AnimName, 1.0)
    end)
end
exports("LoopAnimation", LoopAnimation)

-- Events
RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = true
    if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
        SetVehicleRadioLoud(Vehicle, true)
        -- SetVehRadioStation(Vehicle, "OFF")
        -- SetVehicleRadioEnabled(Vehicle, false)
    end

    if GetVehicleClass(Vehicle) == 15 then
        SetAudioFlag("DisableFlightMusic", true)
    elseif GetVehicleClass(Vehicle) == 8 or GetEntityModel(Vehicle) == GetHashKey('polmotor') or GetEntityModel(Vehicle) == GetHashKey('wheelchair') or GetEntityModel(Vehicle) == GetHashKey('scootmobile') then
        SetPedHelmet(PlayerPedId(), false)
    end

    local IsEngineRunning = GetIsVehicleEngineRunning(Vehicle)
    local Plate = GetVehicleNumberPlateText(Vehicle)

    Citizen.SetTimeout(500, function()
        local HasKeys = HasKeysToVehicle(Plate)
        if HasKeys then
            SetVehicleUndriveable(Vehicle, false)
        end

        if not IsEngineRunning and not HasKeys then
            SetVehicleEngineOn(Vehicle, false, true, true)
        end
    
        Citizen.CreateThread(function()
            while InVehicle do
                if IsVehicleEngineStarting(Vehicle) or GetIsVehicleEngineRunning(Vehicle) ~= IsEngineRunning then
                    local HasKeys = HasKeysToVehicle(Plate)
                    if HasKeys then break end
                    SetVehicleEngineOn(Vehicle, false, true, true)
                end
    
                Citizen.Wait(300)
            end

            Citizen.SetTimeout(300, function()
                SetVehicleUndriveable(Vehicle, false)
            end)
        end)
    end)
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = false
end)

RegisterNetEvent("fw-vehicles:Client:SetVehicleKeys")
AddEventHandler("fw-vehicles:Client:SetVehicleKeys", function(Plate, Keyholders)
    Config.VehicleKeys[Plate] = Keyholders
end)

RegisterNetEvent("fw-vehicles:Client:GiveKeys")
AddEventHandler("fw-vehicles:Client:GiveKeys", function()
    local InVehicle = IsPedInAnyVehicle(PlayerPedId())
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())

    if InVehicle then
        Entity = GetVehiclePedIsIn(PlayerPedId())
        EntityType = GetEntityType(Entity)
        EntityCoords = GetEntityCoords(Entity)
    end

    if Entity == 0 or Entity == -1 or EntityType ~= 2 then return end

    local Plate = GetVehicleNumberPlateText(Entity)
    if not HasKeysToVehicle(Plate) then return end    

    if InVehicle and GetPedInVehicleSeat(Entity, -1) ~= PlayerPedId() then
        local ServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(Entity, -1)))
        if ServerId ~= GetPlayerServerId(PlayerId()) then
            SetVehicleKeys(Plate, true, FW.GetCitizenIdFromPlayer(ServerId))
        end
    else
        local ClosestPlayer, ClosestDistance = FW.Functions.GetClosestPlayer(nil)

        if ClosestPlayer <= 0 or ClosestDistance > 2.0 then
            FW.Functions.Notify("Niemand in de buurt..", "error")
            return
        end

        SetVehicleKeys(Plate, true, FW.GetCitizenIdFromPlayer(ClosestPlayer))
    end
end)

RegisterNetEvent("fw-items:Client:Used:SecurityHackingDevice")
AddEventHandler("fw-items:Client:Used:SecurityHackingDevice", function(Item)
    local InVehicle = IsPedInAnyVehicle(PlayerPedId())
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())

    if InVehicle then
        Entity = GetVehiclePedIsIn(PlayerPedId())
        EntityType = GetEntityType(Entity)
        EntityCoords = GetEntityCoords(Entity)
    end

    if Entity == 0 or Entity == -1 or EntityType ~= 2 then return end

    -- if GetVehicleClass(Entity) ~= 18 then return end

    local Plate = GetVehicleNumberPlateText(Entity)
    if HasKeysToVehicle(Plate) then return end

    RequestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    while not HasAnimDictLoaded("anim@amb@clubhouse@tutorial@bkr_tut_ig3@") do Citizen.Wait(4) end

    TaskPlayAnim(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0, 1.0, -1, 1, 1.0, false, false, false)
    local Success = exports["minigame-boostinghack"]:StartHack()
    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)

    if Success then
        if InVehicle then
            TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Entity, true)
            FW.Functions.Notify("Voertuig gelockpicked!", "success")
            SetVehicleKeys(Plate, true)
            exports['fw-vehicles']:SetVehicleTampering(Entity, 'Hacked', true)
        else
            TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Entity, false)
            FW.Functions.Notify("Deur open gebroken..", "success")
            FW.VSync.SetVehicleDoorsLocked(Entity, 1)
            exports['fw-vehicles']:SetVehicleTampering(Entity, 'ForcedEntry', true)
        end
    end
end)

RegisterNetEvent("fw-items:Client:UseLockpick")
AddEventHandler("fw-items:Client:UseLockpick", function(IsAdvanced)
    local InVehicle = IsPedInAnyVehicle(PlayerPedId())
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())

    if InVehicle then
        Entity = GetVehiclePedIsIn(PlayerPedId())
        EntityType = GetEntityType(Entity)
        EntityCoords = GetEntityCoords(Entity)
    end

    if Entity == 0 or Entity == -1 or EntityType ~= 2 then return end

    local Plate = GetVehicleNumberPlateText(Entity)
    if HasKeysToVehicle(Plate) then return end

    if GetVehicleClass(Entity) == 18 then
        return FW.Functions.Notify("Het lijkt erop dat je hier een zwaarder apperaat voor nodig hebt..", "error")
    end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    if math.random() < 0.7 then
        if LastCartheftAlert ~= Entity then
            TriggerServerEvent('fw-mdw:Server:SendAlert:CarTheft', GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), FW.Functions.GetCardinalDirection(), GetDisplayNameFromVehicleModel(GetEntityModel(Entity)), Plate, FW.Functions.GetVehicleColorLabel(Entity))
            LastCartheftAlert = Entity
            Citizen.SetTimeout(60000 * 5, function()
                if LastCartheftAlert == Entity then
                    LastCartheftAlert = false
                end
            end)
        end
    end

    TriggerEvent('fw-vehicles:Client:OnLockpickStart', Entity)
    if InVehicle then
        LoopAnimation(true, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer')
        local Outcome = exports['fw-ui']:StartSkillTest(IsAdvanced and math.random(2, 5) or math.random(5, 8), IsAdvanced and { 1, 5 } or { 10, 20 }, IsAdvanced and { 6000, 12000 } or { 1500, 3000 }, true)
        LoopAnimation(false)
        if not Outcome then
            FW.Functions.Notify("Gefaald..", "error")
            exports['fw-assets']:RemoveLockpickChance(IsAdvanced)
            return
        end

        TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Entity, true)
        FW.Functions.Notify("Voertuig gelockpicked!", "success")
        SetVehicleKeys(Plate, true)
        exports['fw-vehicles']:SetVehicleTampering(Entity, 'Lockpicked', true)
    else
        if GetVehicleDoorLockStatus(Entity) ~= 2 then return end

        LoopAnimation(true, "veh@break_in@0h@p_m_one@", "low_force_entry_ds")
        local Outcome = exports['fw-ui']:StartSkillTest(IsAdvanced and math.random(2, 5) or math.random(5, 8), IsAdvanced and { 1, 5 } or { 10, 20 }, IsAdvanced and { 6000, 12000 } or { 1500, 3000 }, true)
        LoopAnimation(false)
        if not Outcome then
            FW.Functions.Notify("Gefaald..", "error")
            exports['fw-assets']:RemoveLockpickChance(IsAdvanced)
            return
        end

        TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Entity, false)
        FW.Functions.Notify("Deur open gebroken..", "success")
        FW.VSync.SetVehicleDoorsLocked(Entity, 1)
        exports['fw-vehicles']:SetVehicleTampering(Entity, 'ForcedEntry', true)
    end
end)

RegisterNetEvent("fw-vehicles:Client:SlimJim")
AddEventHandler("fw-vehicles:Client:SlimJim", function()
    local InVehicle = IsPedInAnyVehicle(PlayerPedId())
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())

    if InVehicle then
        Entity = GetVehiclePedIsIn(PlayerPedId())
        EntityType, EntityCoords = GetEntityType(Entity), GetEntityCoords(Entity)
    end

    if Entity == 0 or Entity == -1 or EntityType ~= 2 then return end

    local Plate = GetVehicleNumberPlateText(Entity)
    if HasKeysToVehicle(Plate) then return end

    if InVehicle then
        LoopAnimation(true, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer')
        local Outcome = exports['fw-ui']:StartSkillTest(math.random(2, 5), { 1, 5 }, { 6000, 12000 }, true)
        LoopAnimation(false)
        if not Outcome then
            FW.Functions.Notify("Gefaald..", "error")
            return
        end

        TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Entity, true)
        FW.Functions.Notify("Slimjim succesvol", "success")
        SetVehicleKeys(Plate, true)
    else
        if GetVehicleDoorLockStatus(Entity) ~= 2 then return end

        LoopAnimation(true, "veh@break_in@0h@p_m_one@", "low_force_entry_ds")
        local Outcome = exports['fw-ui']:StartSkillTest(math.random(2, 5), { 1, 5 }, { 6000, 12000 }, true)
        LoopAnimation(false)
        if not Outcome then
            FW.Functions.Notify("Gefaald..", "error")
            return
        end

        TriggerEvent('fw-vehicles:Client:OnLockpickSuccess', Entity, false)
        FW.Functions.Notify("Deuren geopend..", "success")
        FW.VSync.SetVehicleDoorsLocked(Entity, 1)
    end
end)

RegisterNetEvent("fw-vehicles:Client:SetEngineOn")
AddEventHandler("fw-vehicles:Client:SetEngineOn", function(IsPressed)
    if not IsPressed then return end

    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if Vehicle <= 0 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() then return end
    if exports['fw-vehicles']:IsVehicleStalled() then return end

    local Plate = GetVehicleNumberPlateText(Vehicle)
    if HasKeysToVehicle(Plate) then
        SetVehicleEngineOn(Vehicle, true, false, true)
    end
end)

RegisterNetEvent("fw-vehicles:Client:SetEngineOff")
AddEventHandler("fw-vehicles:Client:SetEngineOff", function(IsPressed)
    if not IsPressed then return end

    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if Vehicle <= 0 or GetPedInVehicleSeat(Vehicle, -1) ~= PlayerPedId() then return end

    local Plate = GetVehicleNumberPlateText(Vehicle)
    SetVehicleEngineOn(Vehicle, false, false, true)
end)

RegisterNetEvent("fw-vehicles:Client:ToggleVehicleLock")
AddEventHandler("fw-vehicles:Client:ToggleVehicleLock", function(IsPressed)
    if not IsPressed then return end

    local InVehicle = IsPedInAnyVehicle(PlayerPedId())
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())

    if InVehicle then
        Entity = GetVehiclePedIsIn(PlayerPedId())
        EntityType = GetEntityType(Entity)
        EntityCoords = GetEntityCoords(Entity)
    end

    if Entity == 0 or Entity == -1 or EntityType ~= 2 then return end

    local Plate = GetVehicleNumberPlateText(Entity)
    if not HasKeysToVehicle(Plate) then return end

    local Distance = #(GetEntityCoords(PlayerPedId()) - EntityCoords)
    if Distance > 1.1 then return end

    if GetVehicleDoorLockStatus(Entity) == 1 then
        FW.VSync.SetVehicleDoorsLocked(Entity, 2)
        FW.Functions.Notify("Voertuig vergrendeld.", 'error')
        TriggerEvent("fw-misc:Client:PlaySoundEntity", 'vehicle.lock', NetworkGetNetworkIdFromEntity(Entity), true, nil)
    else
        FW.VSync.SetVehicleDoorsLocked(Entity, 1)
        FW.Functions.Notify("Voertuig ontgrendeld.", 'success')
        TriggerEvent("fw-misc:Client:PlaySoundEntity", 'vehicle.unlock', NetworkGetNetworkIdFromEntity(Entity), true, nil)
    end

    RequestAnimDict("anim@heists@keycard@")
    while not HasAnimDictLoaded("anim@heists@keycard@") do Citizen.Wait(4) end

    TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@", "exit", 8.0, 1.0, -1, 48, 0, 0, 0, 0)
    Citizen.Wait(500)
    StopAnimTask(PlayerPedId(), "anim@heists@keycard@", "exit", 1.0)
end)