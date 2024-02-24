local Camera, CamHeading, CurrentCamStage, IsSwitchingStage = nil, nil, 2, false

function CreateClothingCamera(Bool, WithBlur, ForceStage)
    exports['fw-inventory']:SetBusyState(Bool)
    TriggerEvent('fw-assets:Client:Toggle:Items', Bool)

    if Bool then
        local CamRot = GetGameplayCamRot(2)
        SetEntityHeading(PlayerPedId(), CamRot[3] + 180.0)

        CamHeading = GetEntityHeading(PlayerPedId()) + 90
        SetFollowPedCamViewMode(0)
        SetPedCanPlayAmbientIdles(PlayerPedId(), true, true)

        CurrentCamStage = ForceStage ~= nil and ForceStage or 2
        Camera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

        local Coords = GetEntityCoords(PlayerPedId())
        SetCamCoord(Camera, Coords.x, Coords.y, Coords.z)

        local CamSettings = Config.CameraSettings[CurrentCamStage]
        SetCamFov(Camera, CamSettings.Fov)
        SetCameraParams(PlayerPedId(), Camera, 0.0, CamHeading)
        Citizen.Wait(3)
        SetCameraParams(PlayerPedId(), Camera, 0.1)

        RenderScriptCams(true, false, 500, true, true)

        CameraController()
    else
        RenderScriptCams(false, false, 500, false, false)
        DestroyCam(Camera, true)

        SetGameplayCamRelativeHeading(0)
        SetGameplayCamRelativePitch(0, 1)

        Camera = nil
        StopAnimTask(PlayerPedId(), 'mp_sleep', 'bind_pose_180', 3.0)
        SetFocusEntity(PlayerPedId())
    end
end

function SetCameraParams(Ped, Camera, Increasement, Heading)
    CamHeading = (CamHeading + Increasement) % 360
    local _Heading = Heading ~= nil and Heading or CamHeading
    local CamSettings = Config.CameraSettings[CurrentCamStage]

    local EntityCos = math.cos(_Heading * math.pi / 180) * CamSettings.AttachOffset
    local EntitySin = math.sin(_Heading * math.pi / 180) * CamSettings.AttachOffset
    AttachCamToEntity(Camera, Ped, EntityCos, EntitySin, CamSettings.AttachZ, false)

    local ScreenSin = math.sin(CamHeading * math.pi / 180) * CamSettings.WidthOffset
    local ScreenCos = math.cos(CamHeading * math.pi / 180) * CamSettings.WidthOffset
    PointCamAtEntity(Camera, Ped, ScreenCos, ScreenSin, CamSettings.AttachZ, false)
end

function UpdateCameraPosition(Ped, Upwards)
    if not Camera or IsSwitchingStage then return end
    IsSwitchingStage = true

    if CurrentCamStage == #Config.CameraSettings and Upwards then
        Upwards = false
    end

    CurrentCamStage = Upwards and math.min(CurrentCamStage + 1, #Config.CameraSettings) or math.max(CurrentCamStage - 1, 1)
    local CamSettings = Config.CameraSettings[CurrentCamStage]

    local TempCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamFov(TempCam, CamSettings.Fov)
    SetCameraParams(Ped, TempCam, 0.0, PedHeading)
    SetCamActiveWithInterp(TempCam, Camera, 500, true, true)

    if CurrentCamStage == 1 then
        exports['fw-assets']:RequestAnimationDict("mp_sleep")
        TaskPlayAnim(Ped, 'mp_sleep', 'bind_pose_180', 8.0, -8.0, -1, 49, 0, false, false, false)
    else
        ClearPedTasks(Ped)
    end

    SetTimeout(500, function()
        IsSwitchingStage = false
        DestroyCam(Camera, false)
        Camera = TempCam
    end)
end

function CameraController()
    local IsMouseInField = false
    while DoesCamExist(Camera) do
        local CursorX, CursorY = GetNuiCursorPosition()

        -- Disable the controls.
        DisableAllControlActions(0)
        DisableAllControlActions(1)
        DisableAllControlActions(2)

        EnableControlAction(0, 249, true) -- PUSH_TO_TALK

        -- Camera Rotation
        local ScreenX, ScreenY = GetActiveScreenResolution()
        if CursorX < (ScreenX * 0.72) then
            if IsDisabledControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 25) then
                IsMouseInField = true
            end

            if IsMouseInField then
                -- Ped
                local Direction = GetDisabledControlNormal(0, 220)
                if IsDisabledControlPressed(0, 24) then
                    SetEntityHeading(PlayerPedId(), GetEntityHeading(PlayerPedId()) + (Direction * ScreenX * 0.0125))
                end

                -- Camera
                if IsDisabledControlPressed(0, 25) then
                    SetCameraParams(PlayerPedId(), Camera, Direction * ScreenX * 0.0125)
                end
            end

            -- Camera Position
            if IsDisabledControlPressed(0, 16) then
                UpdateCameraPosition(PlayerPedId(), true)
            end

            if IsDisabledControlPressed(0, 17) then
                UpdateCameraPosition(PlayerPedId(), false)
            end
        elseif IsMouseInField then
            IsMouseInField = false
        end

        Citizen.Wait(0)
    end
end