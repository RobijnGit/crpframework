local HeistThermite, HeistBagScene = nil, nil
local HeistProps, ExplosiveAnimTwo = {}, nil
local IsCrouching, IsPointing = false, false
local TimerEnabled, InTackleCooldown = false, false

FW.AddKeybind("toggleCrouch", "Spelers", "Hurken", "LCONTROL", function(IsPressed)
    if not IsPressed or exports['fw-clothes']:IsMenuActive() then return end

    if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then return end
    if IsPedRagdoll(PlayerPedId()) then return end

    IsCrouching = not IsCrouching

    if IsCrouching then
        RequestAnimSet("move_ped_crouched")
        while not HasAnimSetLoaded("move_ped_crouched") do Citizen.Wait(0) end
        SetPedMovementClipset(PlayerPedId(), "move_ped_crouched", 0.25)
    else
        TriggerEvent('animations:client:set:walkstyle')
    end
end)

FW.AddKeybind("tackePlayer", "Spelers", "Tackle een speler", "", function(IsPressed)
    if not IsPressed then return end
    TacklePlayer()
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            if IsControlPressed(0, Config.Keys["B"]) and IsPedOnFoot(PlayerPedId()) then
                if not IsPointing then
                    StartPointing()
                end
                IsPointing = true
            else
                if IsPointing then
                    StopPointing()
                end
                IsPointing = false
            end
            if not IsPedOnFoot(PlayerPedId()) and IsPointing then
                IsPointing = false
                StopPointing()
            end
            if Citizen.InvokeNative(0x921CE12C489C4C41, PlayerPedId()) then
                if IsPedOnFoot(PlayerPedId()) and IsPointing then
                    local CamPitch = GetGameplayCamRelativePitch()
                    if CamPitch < -70.0 then
                        CamPitch = -70.0
                    elseif CamPitch > 42.0 then
                        CamPitch = 42.0
                    end
                    CamPitch = (CamPitch + 70.0) / 112.0
                    local CamHeading = GetGameplayCamRelativeHeading()
                    local CosCamHeading = Cos(CamHeading)
                    local SinCamHeading = Sin(CamHeading)
                    if CamHeading < -180.0 then
                        CamHeading = -180.0
                    elseif CamHeading > 180.0 then
                        CamHeading = 180.0
                    end
                    CamHeading = (CamHeading + 180.0) / 360.0
                    local Blocked, NN = 0, 0
                    local Coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), (CosCamHeading * -0.2) - (SinCamHeading * (0.4 * CamHeading + 0.3)), (SinCamHeading * -0.2) + (CosCamHeading * (0.4 * CamHeading + 0.3)), 0.6)
                    local RayCast = Cast_3dRayPointToPoint(Coords.x, Coords.y, Coords.z - 0.2, Coords.x, Coords.y, Coords.z + 0.2, 0.4, 95, PlayerPedId(), 7);
                    NN, Blocked = GetRaycastResult(RayCast)
                    Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPedId(), "Pitch", CamPitch)
                    Citizen.InvokeNative(0xD5BB4025AE449A4E, PlayerPedId(), "Heading", CamHeading * -1.0 + 1.0)
                    Citizen.InvokeNative(0xB0A6CFD2C69C1088, PlayerPedId(), "isBlocked", Blocked)
                    Citizen.InvokeNative(0xB0A6CFD2C69C1088, PlayerPedId(), "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
                else
                    Citizen.Wait(50)
                end
            else
                Citizen.Wait(100)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-assets:client:lockpick:animation')
AddEventHandler('fw-assets:client:lockpick:animation', function(Bool)
    Lockpicking = Bool
    while Lockpicking do
        Citizen.Wait(4)
        RequestAnimationDict("veh@break_in@0h@p_m_one@")
        TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
        Citizen.Wait(1000)
    end
    if not Bool then
        StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
    end
end)

RegisterNetEvent('fw-assets:client:thermite:anim')
AddEventHandler('fw-assets:client:thermite:anim', function(Coords)
    exports['fw-assets']:RequestModelHash("hei_p_m_bag_var22_arm_s")
    exports['fw-assets']:RequestAnimationDict("anim@heists@ornate_bank@thermal_charge")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end
    Citizen.Wait(100)
    local Rotation = GetEntityRotation(PlayerPedId())
    HeistBagScene = NetworkCreateSynchronisedScene(Coords.x, Coords.y, Coords.z, Rotation.x, Rotation.y, Rotation.z, 2, false, false, 1065353216, 0, 1.3)
    local HeistBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), Coords.x, Coords.y, Coords.z,  true,  true, false)
    table.insert(HeistProps, HeistBag)
    SetEntityCollision(HeistBag, false, true)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), HeistBagScene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(HeistBag, HeistBagScene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(HeistBagScene)
    Citizen.Wait(1500)
    local HeistThermite = CreateObject(GetHashKey("hei_prop_heist_thermite"), Coords.x, Coords.y, Coords.z + 0.2,  true,  true, true)
    table.insert(HeistProps, HeistThermite)
    SetEntityCollision(HeistThermite, false, true)
    AttachEntityToEntity(HeistThermite, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(4000)
    DeleteObject(HeistBag)
    DetachEntity(HeistThermite, 1, 1)
    FreezeEntityPosition(HeistThermite, true)
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
end)

RegisterNetEvent('fw-assets:client:reset:thermite:anim')
AddEventHandler('fw-assets:client:reset:thermite:anim', function()
    ClearPedTasks(PlayerPedId())
    for k, v in pairs(HeistProps) do
        if DoesEntityExist(v) then
            NetworkRequestControlOfEntity(v)
            DeleteEntity(v)
        end
    end
    HeistProps = {}
    NetworkStopSynchronisedScene(HeistBagScene)
    HeistThermite, HeistBagScene = nil, nil
end)

RegisterNetEvent('fw-assets:client:explosion:anim')
AddEventHandler('fw-assets:client:explosion:anim', function(Coords, Rotation)
    exports['fw-assets']:RequestModelHash("ch_prop_ch_explosive_01a")
    exports['fw-assets']:RequestAnimationDict("anim_heist@hs3f@ig8_vault_explosives@right@male@")
    local HeistBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), Coords.x + 0.5, Coords.y, Coords.z,  true,  true, false)
    local HeistExplosive = CreateObject(GetHashKey("ch_prop_ch_explosive_01a"), Coords.x + 0.5, Coords.y, Coords.z,  true,  true, false)
    table.insert(HeistProps, HeistBag)
    table.insert(HeistProps, HeistExplosive)
    SetEntityCollision(HeistBag, false, true)
    SetEntityCollision(HeistExplosive, false, true)
    local EnterAnim = NetworkCreateSynchronisedScene(Coords.x, Coords.y, Coords.z + 0.5, Rotation.x, Rotation.y, Rotation.z, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), EnterAnim, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "player_ig8_vault_explosive_enter", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(HeistBag, EnterAnim, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "bag_ig8_vault_explosive_enter", 1.0, -1.0, 0, 0)
    NetworkAddEntityToSynchronisedScene(HeistExplosive, EnterAnim, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "semtex_a_ig8_vault_explosive_enter", 1.0, -1.0, 0, 0)
    NetworkStartSynchronisedScene(EnterAnim)
    Citizen.Wait(1200)
    local ExplosiveAnimOne = NetworkCreateSynchronisedScene(Coords.x, Coords.y, Coords.z + 0.5, Rotation.x, Rotation.y, Rotation.z, 2, 0, 0, 1065353216, 0, 1.3)	
    NetworkAddPedToSynchronisedScene(PlayerPedId(), ExplosiveAnimOne, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "player_ig8_vault_explosive_plant_a", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(HeistBag, ExplosiveAnimOne, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "bag_ig8_vault_explosive_plant_a", 1.0, -1.0, 0, 0)
    NetworkAddEntityToSynchronisedScene(HeistExplosive, ExplosiveAnimOne, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "semtex_a_ig8_vault_explosive_plant_a", 1.0, -1.0, 0, 0)
    NetworkStartSynchronisedScene(ExplosiveAnimOne)
    Citizen.Wait(2000)
    ExplosiveAnimTwo = NetworkCreateSynchronisedScene(Coords.x, Coords.y, Coords.z + 0.5, Rotation.x, Rotation.y, Rotation.z, 2, 0, 0, 1065353216, 0, 1.3)	
    NetworkAddPedToSynchronisedScene(PlayerPedId(), ExplosiveAnimTwo, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "player_ig8_vault_explosive_plant_b", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(HeistBag, ExplosiveAnimTwo, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "bag_ig8_vault_explosive_plant_b", 1.0, -1.0, 0, 0)
    FreezeEntityPosition(HeistExplosive, true)
    SetEntityCollision(HeistExplosive, false, true)
    local HeistExplosiveTwo = CreateObject(GetHashKey("ch_prop_ch_explosive_01a"), Coords.x + 0.5, Coords.y, Coords.z,  true,  true, false)
    table.insert(HeistProps, HeistExplosiveTwo)
    SetEntityCollision(HeistExplosiveTwo, false, true)
    NetworkAddEntityToSynchronisedScene(HeistExplosiveTwo, ExplosiveAnimTwo, "anim_heist@hs3f@ig8_vault_explosives@right@male@", "semtex_b_ig8_vault_explosive_plant_b", 1.0, -1.0, 0, 0)
    NetworkStartSynchronisedScene(ExplosiveAnimTwo)
    Citizen.Wait(2000)
    FreezeEntityPosition(HeistExplosiveTwo, true)
    SetEntityCollision(HeistExplosiveTwo, false, true)
    DeleteEntity(HeistBag)
    ClearPedTasks(PlayerPedId())
end)

RegisterNetEvent('fw-assets:client:reset:explosion:anim')
AddEventHandler('fw-assets:client:reset:explosion:anim', function()
    ClearPedTasks(PlayerPedId())
    for k, v in pairs(HeistProps) do
        if DoesEntityExist(v) then
            NetworkRequestControlOfEntity(v)
            DeleteEntity(v)
        end
    end
    NetworkStopSynchronisedScene(ExplosiveAnimTwo)
    HeistProps, ExplosiveAnimTwo = {}, nil
end)

RegisterNetEvent('fw-assets:Client:TackleAnim')
AddEventHandler('fw-assets:Client:TackleAnim', function()
	if not FW.Functions.GetPlayerData().metadata['ishandcuffed'] and not IsPedRagdoll(PlayerPedId()) then
        RequestAnimDict("swimming@first_person@diving")
        while not HasAnimDictLoaded("swimming@first_person@diving") do Citizen.Wait(4) end

		if IsEntityPlayingAnim(PlayerPedId(), "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
			ClearPedSecondaryTask(PlayerPedId())
		else
			TaskPlayAnim(PlayerPedId(), "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
			local SecCount = 3
			while SecCount > 0 do
				Citizen.Wait(100)
				SecCount = SecCount - 1
			end
			ClearPedSecondaryTask(PlayerPedId())
			SetPedToRagdoll(PlayerPedId(), 150, 150, 0, 0, 0, 0)
		end
	end
end)

RegisterNetEvent('fw-assets:Client:Get:Tackled')
AddEventHandler('fw-assets:Client:Get:Tackled', function()
    if not InTackleCooldown then
        TimerEnabled, InTackleCooldown = true, true
        SetPedToRagdoll(PlayerPedId(), math.random(3500,5000), math.random(3500,5000), 0, 0, 0, 0)
        Citizen.SetTimeout(10000, function()
            TimerEnabled, InTackleCooldown = false, false
        end)
    end 
end)

-- // Functions \\ --

function TacklePlayer()
    if not LoggedIn then return end
	if not FW.Functions.GetPlayerData().metadata['ishandcuffed'] and GetLastInputMethod(2) then
		if not IsPedInAnyVehicle(PlayerPedId()) and GetEntitySpeed(PlayerPedId()) > 2.5 then
			TryTackle()
		end
	end
end

function TryTackle()
    if not TimerEnabled then
        local Player, Distance = FW.Functions.GetClosestPlayer()

        TimerEnabled = true
        SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, 0, 0, 0)
        Citizen.SetTimeout(1000, function()
            TimerEnabled = false
        end)

        if Player <= 0 then return end

        local PlayerHeading = GetEntityHeading(PlayerPedId())
        local PlayerCoords = GetEntityCoords(PlayerPedId(), true) 
        local TargetCoords = GetEntityCoords(GetPlayerPed(Player), true) 
        local HeadingToTarget = (math.atan2(TargetCoords.y - PlayerCoords.y, TargetCoords.x - PlayerCoords.x) * 180 / math.pi) - 90  
        local Diff = math.abs(((PlayerHeading - HeadingToTarget) + 180) % 360 - 180)  
        if Diff < 40 then
            TimerEnabled = true
            TriggerServerEvent('fw-assets:Server:Tackle:Player', Player)
            TriggerEvent("fw-assets:Client:TackleAnim")
            Citizen.SetTimeout(6000, function()
                TimerEnabled = false
            end)
            return
        end
    end
end

function StartPointing()
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Wait(0)
    end
    SetPedCurrentWeaponVisible(PlayerPedId(), 0, 1, 1, 1)
    SetPedConfigFlag(PlayerPedId(), 36, 1)
    Citizen.InvokeNative(0x2D537BA194896636, PlayerPedId(), "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

function StopPointing()
    Citizen.InvokeNative(0xD01015C7316AE176, PlayerPedId(), "Stop")
    if not IsPedInjured(PlayerPedId()) then
        ClearPedSecondaryTask(PlayerPedId())
    end
    if not IsPedInAnyVehicle(PlayerPedId(), 1) then
        SetPedCurrentWeaponVisible(PlayerPedId(), 1, 1, 1, 1)
    end
    SetPedConfigFlag(PlayerPedId(), 36, 0)
    ClearPedSecondaryTask(PlayerPedId())
end

function ResetAnimSet()
    ResetPedMovementClipset(PlayerPedId())
    ResetPedWeaponMovementClipset(PlayerPedId())
    ResetPedStrafeClipset(PlayerPedId())
    TriggerEvent('animations:client:set:walkstyle')
end

function RequestAnimSetEvent(AnimSet)
    RequestAnimSet(AnimSet)
    while not HasAnimSetLoaded(AnimSet) do
        Citizen.Wait(0)
    end
end
exports("RequestAnimSetEvent", RequestAnimSetEvent)

function RequestAnimationDict(AnimDict)
    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do
        Citizen.Wait(1)
    end
end
exports("RequestAnimationDict", RequestAnimationDict)