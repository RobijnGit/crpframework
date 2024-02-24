local CurrentMotorDamage, CurrentBodyDamage, InVehicle = 0, 0, false
local CurrentBodyEject, InEjectVehicle = 0, false
local Stalled = false

-- Seatbelt
FW.AddKeybind("toggleBelt", "Voertuigen", "Gordel om/af doen", "G", function(IsPressed)
    if not IsPressed then return end

    local Ped = PlayerPedId()
    local Vehicle = GetVehiclePedIsIn(Ped)
    local VehicleClass = GetVehicleClass(Vehicle)
    local HarnessLevel = exports['fw-vehicles']:GetVehicleMeta(Vehicle, "Harness")

    if Vehicle == 0 then return end

    if VehicleClass ~= 8 and VehicleClass ~= 13 and VehicleClass ~= 14 and GetEntityModel(Vehicle) ~= GetHashKey("polmotor") then
        if HarnessLevel and HarnessLevel > 0.0 then
            local Text = HasHarness and "Harnas uittrekken" or "Harnas aantrekken"
            local Duration = HasHarness and 2000 or 5000
            if exports['fw-progressbar']:GetTaskBarStatus() then return end

            FW.Functions.Progressbar("bitch", Text, Duration, false, false, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function() -- Done
                if CurrentVehicle == 0 or CurrentVehicle == -1 then return end

                local CurrentHarnessLevel = GetVehicleMeta(CurrentVehicle, "Harness")
                SetVehicleMeta(CurrentVehicle, "Harness", CurrentHarnessLevel - 1.0)

                HasHarness, HasBelt = not HasHarness, false
                TriggerEvent("fw-misc:Client:PlaySound", HasHarness and 'vehicle.buckle' or 'vehicle.unbuckle')
            end, function()
                -- Can't be canceled
            end)
        else
            HasBelt = not HasBelt
            TriggerEvent("fw-misc:Client:PlaySound", HasBelt and 'vehicle.buckle' or 'vehicle.unbuckle')
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if CurrentVehicle == 0 or CurrentVehicle == -1 or not HasHarness then goto SkipLoop end

            DisableControlAction(0, 75, true)

            if IsDisabledControlJustReleased(1, 75) then
                FW.Functions.Notify("Misschien even je harnas losmaken?", "error")
            end

            ::SkipLoop::
        else
            Citizen.Wait(750)
        end
    end
end)

-- Engine / Body
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if IsPedInAnyVehicle(PlayerPedId()) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
                local Vehicle = GetVehiclePedIsIn(PlayerPedId())
                local VehicleClass = GetVehicleClass(Vehicle)
                local CurrentMotor, CurrentBody = GetVehicleEngineHealth(Vehicle), GetVehicleBodyHealth(Vehicle)
                if not InVehicle then
                    InVehicle = true
                    CurrentBodyDamage = GetVehicleBodyHealth(Vehicle)
                    CurrentMotorDamage = GetVehicleEngineHealth(Vehicle)
                    if CurrentMotorDamage <= Config.EngineSafeGuard then
                        SetVehicleUndriveable(Vehicle, true)
                    else
                        SetVehicleUndriveable(Vehicle, false)
                    end
                end
                if CurrentBody < CurrentBodyDamage or CurrentBody > CurrentBodyDamage and CurrentBody ~= CurrentBodyDamage then
                    if CurrentBody < Config.BodySafeGuard then
                        SetVehicleBodyHealth(Vehicle, Config.BodySafeGuard)
                        CurrentBodyDamage = Config.BodySafeGuard
                    else
                        if (CurrentBodyDamage - CurrentBody) > 45.0 and VehicleClass ~= 15 and VehicleClass ~= 13 then
                            TriggerServerEvent("fw-businesses:Server:AutoCare:ApplyPartDamage", GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle), 'Body')
                        end
                        CurrentBodyDamage = CurrentBody
                    end
                end
                if CurrentMotor < CurrentMotorDamage or CurrentMotor > CurrentMotorDamage and CurrentMotor ~= CurrentMotorDamage then
                    if CurrentMotor < Config.EngineSafeGuard then
                        SetVehicleEngineHealth(Vehicle, Config.EngineSafeGuard)
                        SetVehicleUndriveable(Vehicle, true)
                        CurrentMotorDamage = Config.EngineSafeGuard
                    else
                        if ((CurrentMotorDamage - CurrentMotor) > 32.0 and VehicleClass ~= 15 and VehicleClass ~= 13) and not Stalled then
                            SetVehicleEngineHealth(Vehicle, CurrentMotorDamage - 100.0)
                            SetVehicleUndriveable(Vehicle, true)
                            SetVehicleEngineOn(Vehicle, false, true, true)
                            FW.Functions.Notify("Motor is afgeslagen..", "error")
                            Stalled = true

                            local CurrentHarnessLevel = GetVehicleMeta(Vehicle, "Harness")
                            TriggerServerEvent("fw-businesses:Server:AutoCare:ApplyPartDamage", GetVehicleNumberPlateText(Vehicle), GetEntityModel(Vehicle), 'Engine')
                            if CurrentHarnessLevel and CurrentHarnessLevel > 0.0 then
                                SetVehicleMeta(Vehicle, "Harness", CurrentHarnessLevel - 1.5)
                            end

                            Citizen.SetTimeout(math.random(1500, 2500), function()
                                SetVehicleUndriveable(Vehicle, false)
                                Stalled = false
                            end)
                        end
                        CurrentMotorDamage = CurrentMotor
                    end
                end
                if InVehicle and CurrentMotor <= Config.EngineSafeGuard then
                    SetVehicleUndriveable(Vehicle, true)
                    Citizen.Wait(150)
                end
                Citizen.Wait(250)
            else
                InVehicle, CurrentMotorDamage, CurrentBodyDamage = false, 0, 0
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- Wheels & Ejecting
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if IsPedInAnyVehicle(PlayerPedId()) then
                local Vehicle = GetVehiclePedIsIn(PlayerPedId())
                local VehicleClass = GetVehicleClass(Vehicle)
                local CurrentVehicleSpeed, CurrentBody = GetEntitySpeed(Vehicle) * 2.236936, GetVehicleBodyHealth(Vehicle)
                if not InEjectVehicle then
                    InEjectVehicle = true
                    CurrentBodyEject = GetVehicleBodyHealth(Vehicle)
                end
                if CurrentBody < CurrentBodyEject or CurrentBody > CurrentBodyEject and CurrentBody ~= CurrentBodyEject then
                    if not HasHarness and math.ceil(CurrentBodyEject - CurrentBody) > 35.0 then
                        if CurrentHarnessLevel then SetVehicleMeta(Vehicle, "Harness", CurrentHarnessLevel - 1.0) end
                        if (not HasBelt and CurrentVehicleSpeed > math.random(60, 80)) or (HasBelt and CurrentVehicleSpeed > math.random(100, 120)) then
                            if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() and VehicleClass ~= 15 and VehicleClass ~= 16 then
                                DoWheelDamage(Vehicle)
                            end
                            EjectFromVehicle(Vehicle, GetEntityVelocity(Vehicle))  
                        end
                    end
                    CurrentBodyEject = CurrentBody
                end
            else
                if InEjectVehicle then
                    InEjectVehicle, CurrentBodyEject = false, 0
                end
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Functions \\ --
function EjectFromVehicle(Vehicle, Velocity)
    local Coords = GetOffsetFromEntityInWorldCoords(Vehicle, 1.0, 0.0, 1.0)
    local EjectSpeed = math.ceil(GetEntitySpeed(PlayerPedId()) * 8)
    SetEntityCoords(PlayerPedId(), Coords)
    SetPedToRagdoll(PlayerPedId(), 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(PlayerPedId(), Velocity.x * 4, Velocity.y * 4, Velocity.z * 4)
end

function DoWheelDamage(Vehicle)
    local Wheels = {0, 1, 4, 5}
    for i = 1, math.random(4) do
        local Wheel = math.random(#Wheels)
        -- FW.VSync.SetVehicleTyreBurst(Vehicle, Wheels[Wheel], true, 1000.0)
        SetVehicleTyreBurst(Vehicle, Wheels[Wheel], true, 1000.0)
        table.remove(Wheels, Wheel)
    end
end

function GetBeltStatus()
    return HasBelt or HasHarness
end
exports("GetBeltStatus", GetBeltStatus)

function IsVehicleStalled()
    return Stalled
end
exports("IsVehicleStalled", IsVehicleStalled)