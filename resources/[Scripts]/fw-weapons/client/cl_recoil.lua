Citizen.CreateThread( function()
    while true do 
        Citizen.Wait(4)
        if LoggedIn then
            if IsPedArmed(PlayerPedId(), 6) then
                if IsPedShooting(PlayerPedId()) then
                    local PlayerPed = PlayerPedId()
                    local Vehicle = IsPedInAnyVehicle(PlayerPed, false)
                    local GamePlayCam = GetFollowPedCamViewMode()
                    local MovementSpeed = math.ceil(GetEntitySpeed(PlayerPed))
                    if MovementSpeed > 69 then MovementSpeed = 69 end
                    local _, Weapon = GetCurrentPedWeapon(PlayerPed)
                    local Group = GetWeapontypeGroup(Weapon)
                    local GameplayCamPitch = GetGameplayCamRelativePitch()
                    local CameraDistance = #(GetGameplayCamCoord() - GetEntityCoords(PlayerPed))
                    local Recoil = math.random(130, 180 + (math.ceil(MovementSpeed * 1.5))) / 100
                    local Rifle = false
                    if Group == 970310034 or Group == 1159398588 then
                        Rifle = true
                    end
                    if CameraDistance < 5.3 then
                        CameraDistance = 1.5
                    else
                        if CameraDistance < 8.0 then
                            CameraDistance = 4.0
                        else
                            CameraDistance = 7.0
                        end
                    end
                    if Vehicle then
                        Recoil = Recoil + (Recoil * CameraDistance)
                    else
                        Recoil = Recoil * 0.1
                    end
                    if GamePlayCam == 4 then
                        Recoil = Recoil * 0.1
                        if Rifle then
                            Recoil = Recoil * 0.1
                        end
                    end
                    if Rifle then
                        Recoil = Recoil * 0.1
                    end

                    if not exports['fw-hud']:HasBuff('Recoil') then
                        local RightLeft = math.random(4)
                        local H = GetGameplayCamRelativeHeading()
                        local HF = math.random(10, 80 + MovementSpeed) / 100
                        if Vehicle then
                            HF = HF * 2.0
                        end
                        if RightLeft == 1 then
                            SetGameplayCamRelativeHeading(H + HF)
                        elseif RightLeft == 2 then
                            SetGameplayCamRelativeHeading(H - HF)
                        end 
                    end

                    local Set = GameplayCamPitch + Recoil
                    SetGameplayCamRelativePitch(Set, 0.8)
                end
            else
                Citizen.Wait(450)
            end  
        else
            Citizen.Wait(450)
        end
    end
end)

function SetVehicleAiming()
    if not InVehicle then return end

    Citizen.CreateThread( function()
        while InVehicle do
            if IsPedArmed(PlayerPedId(), 6) then
                if IsPedDoingDriveby(PlayerPedId()) then
                    if GetFollowPedCamViewMode() ~= 4 or GetFollowVehicleCamViewMode() ~= 4 then
                        local CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())
                        SetCurrentPedWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'), true)
                        SetCurrentPedVehicleWeapon(PlayerPedId(), GetHashKey('WEAPON_UNARMED'))
                        SetPlayerCanDoDriveBy(PlayerId(), false)
                        SetFollowPedCamViewMode(4) SetFollowVehicleCamViewMode(4)
                        Citizen.Wait(100)
                        SetCurrentPedWeapon(PlayerPedId(), CurrentWeapon, true)
                        SetCurrentPedVehicleWeapon(PlayerPedId(), CurrentWeapon)
                        SetPlayerCanDoDriveBy(PlayerId(), true)
                    end
                else
                    DisableControlAction(0, 36,true)
                    if GetPedStealthMovement(PlayerPedId()) == 1 then
                        SetPedStealthMovement(PlayerPedId(), 0)
                    end
                end
            end
            Citizen.Wait(1)
        end
    end)
end

-- Itensified Vehicle Recoil
local function SetAmplitudeScale(num, base_min, base_max, target_min, target_max)
    local base_range = base_max - base_min
    local target_range = target_max - target_min
    local scaled = (((num - base_min) * target_range) / base_range) + target_min

    return scaled
end

function SetAmplitudeBasedOnStateOrSpeed(Ped, Weapon, Modifier)
    local Speed = GetEntitySpeed(Ped) * 1.5
    local Amplitude = (SetAmplitudeScale(Speed, 0.0, 150.0, 2.0, 8.0)) * Modifier
    print(Amplitude)
    SetWeaponRecoilShakeAmplitude(Weapon, Amplitude)
end

RegisterNetEvent("fw-weapons:Client:SetWeaponData")
AddEventHandler("fw-weapons:Client:SetWeaponData", function(Data)
    Citizen.CreateThread(function()
        while IsHoldingWeapon do

            Citizen.Wait(150)
            local Ped = PlayerPedId()
            local Vehicle = GetVehiclePedIsIn(Ped)
            if IsPedArmed(Ped, 6) then
                local _, Weapon = GetCurrentPedWeapon(Ped, true)

                if DoesEntityExist(Vehicle) then
                    SetAmplitudeBasedOnStateOrSpeed(Ped, Weapon, 3.0)
                else
                    SetWeaponRecoilShakeAmplitude(Weapon, 0.333)
                end
            end

            Citizen.Wait(4)
        end
    end)
end)