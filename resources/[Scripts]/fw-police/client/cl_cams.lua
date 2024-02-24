local InsideCam = false

RegisterNetEvent('fw-police:Client:ShowCameraInput')
AddEventHandler('fw-police:Client:ShowCameraInput', function()
	local PlayerData = FW.Functions.GetPlayerData()
    if (PlayerData.job.name ~= "police" and PlayerData.job.name ~= "storesecurity") or not PlayerData.job.onduty then return end

	if InsideCam then
		return FW.Functions.Notify("Je zit al in een camera..", "error")
	end

	Citizen.Wait(100)

	local Result = exports['fw-ui']:CreateInput({
        { Label = 'Camera ID (1-' .. (#Config.SecurityCams - 1) .. ')', Icon = 'fas fa-camera', Name = 'CamId', Type = 'number' },
    })

    if Result then
        if Config.SecurityCams[tonumber(Result.CamId)] ~= nil then
			TriggerEvent('fw-police:Client:OpenCamera', tonumber(Result.CamId))
		else
			FW.Functions.Notify("Deze camera bestaat niet..", 'error')
			-- TriggerEvent('fw-police:Client:OpenCamera', tonumber(Result.CamId))
		end
    end
end)

RegisterNetEvent("fw-police:Client:OpenCamera")
AddEventHandler("fw-police:Client:OpenCamera", function(CamId)
    local Coords = Config.SecurityCams[CamId]['Coords']
	CamId = tonumber(CamId)

	SetTimecycleModifier("heliGunCam")
	SetTimecycleModifierStrength(1.0)

	local Scaleform = RequestScaleformMovie("TRAFFIC_CAM")
	while not HasScaleformMovieLoaded(Scaleform) do
		Citizen.Wait(0)
	end

	SecurityCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamCoord(SecurityCam, Coords.x, Coords.y, (Coords.z + 1.2))
	SetCamRot(SecurityCam, -15.0, 0.0, Coords.w)
	SetCamFov(SecurityCam, 110.0)
	RenderScriptCams(true, false, 0, 1, 0)
	PushScaleformMovieFunction(Scaleform, "PLAY_CAM_MOVIE")
	SetFocusArea(Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0)
	PopScaleformMovieFunctionVoid()

    InsideCam = true

	exports['fw-ui']:ShowInteraction('[ESC/BACKSPACE] Camera afsluiten', 'error')
	exports['fw-assets']:AddProp('Tablet')
    exports['fw-assets']:RequestAnimationDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)

	while InsideCam do
		SetCamCoord(SecurityCam, Coords.x, Coords.y, (Coords.z + 1.2))
		PushScaleformMovieFunction(Scaleform, "SET_ALT_FOV_HEADING")
		PushScaleformMovieFunctionParameterFloat(1.0)
		PushScaleformMovieFunctionParameterFloat(GetCamRot(SecurityCam, 2).z)
		PopScaleformMovieFunctionVoid()
		DrawScaleformMovieFullscreen(Scaleform, 255, 255, 255, 255)

		local CamRot = GetCamRot(SecurityCam, 2)
		if IsControlPressed(1, 108) then --N4
			SetCamRot(SecurityCam, CamRot.x, 0.0, CamRot.z + 0.7, 2)
		end

		if IsControlPressed(1, 107) then --N6
			SetCamRot(SecurityCam, CamRot.x, 0.0, CamRot.z - 0.7, 2)
		end

		if IsControlPressed(1, 61) then -- N8
			SetCamRot(SecurityCam, CamRot.x + 0.7, 0.0, CamRot.z, 2)
		end

		if IsControlPressed(1, 60) then -- N5
			SetCamRot(SecurityCam, CamRot.x - 0.7, 0.0, CamRot.z, 2)
		end

		if IsControlJustPressed(1, 177) then -- ESC / Backspace
			InsideCam = false
		end

		Citizen.Wait(1)
	end

	exports['fw-ui']:HideInteraction()
	exports['fw-assets']:RemoveProp()
	ClearPedTasks(PlayerPedId())
	ClearTimecycleModifier()
	ClearFocus()
	RenderScriptCams(false, false, 0, 1, 0)
	SetScaleformMovieAsNoLongerNeeded(Scaleform)
	DestroyCam(SecurityCam, true)
end)