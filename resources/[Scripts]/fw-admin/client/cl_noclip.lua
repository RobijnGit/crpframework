local NoclipCam = nil
local IsInNoclip = false
local MinY, MaxY = -89.0, 89.0
local Speed, MaxSpeed = 1.0, 32.0

function ToggleNoclip(Enable)
    IsInNoclip = Enable == nil and not IsInNoclip or Enable
    if IsInNoclip then
        local Vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local InVehicle = false
        if Vehicle ~= 0 then
            InVehicle = true
            Entity = Vehicle
        else
            Entity = PlayerPedId()
        end
        local EntityCoords = GetEntityCoords(Entity)
        local EntityRotation = GetEntityRotation(Entity)
        NoclipCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", EntityCoords, 0.0, 0.0, EntityRotation.z, 75.0, true, 2)
        AttachCamToEntity(NoclipCam, Entity, 0.0, 0.0, 0.0, true)
        RenderScriptCams(true, false, 500, true, false)
        FreezeEntityPosition(Entity, true)
        SetEntityCollision(Entity, false, false)
        SetEntityAlpha(Entity, 0)
        SetPedCanRagdoll(Entity, false)
        SetEntityVisible(Entity, false)
        ClearPedTasksImmediately(PlayerPedId())
        if InVehicle then
            FreezeEntityPosition(PlayerPedId(), true)
            SetEntityCollision(PlayerPedId(), false, false)
            SetEntityAlpha(PlayerPedId(), 0)
            SetEntityVisible(PlayerPedId(), false)
        end
        Citizen.CreateThread(function()
            while IsInNoclip do
                Citizen.Wait(4)
                local Rv, Fv, Uv, Campos = GetCamMatrix(NoclipCam)
                if IsDisabledControlPressed(2, 17) then
                    Speed = math.min(Speed + 0.1, MaxSpeed)
                elseif IsDisabledControlPressed(2, 16) then
                    Speed = math.max(0.1, Speed - 0.1)
                end
                
                local Multiplier = 1.0;
                if IsDisabledControlPressed(2, 209) then
                    Multiplier = 2.0
                elseif IsDisabledControlPressed(2, 19) then
                    Multiplier = 4.0
                elseif IsDisabledControlPressed(2, 36) then
                    Multiplier = 0.25
                end
                if IsDisabledControlPressed(2, 32) then -- W
                    local Setpos = GetEntityCoords(Entity) + Fv * (Speed * Multiplier)
                    SetEntityCoordsNoOffset(Entity, Setpos)
                    if InVehicle then
                        SetEntityCoordsNoOffset(PlayerPedId(), Setpos)
                    end
                elseif IsDisabledControlPressed(2, 33) then -- S
                    local Setpos = GetEntityCoords(Entity) - Fv * (Speed * Multiplier)
                    SetEntityCoordsNoOffset(Entity, Setpos)
                    if InVehicle then
                        SetEntityCoordsNoOffset(PlayerPedId(), Setpos)
                    end
                end
                if IsDisabledControlPressed(2, 34) then -- A
                    local Setpos = GetOffsetFromEntityInWorldCoords(Entity, -Speed * Multiplier, 0.0, 0.0)
                    SetEntityCoordsNoOffset(Entity, Setpos.x, Setpos.y, GetEntityCoords(Entity).z)
                    if InVehicle then
                        SetEntityCoordsNoOffset(PlayerPedId(), Setpos.x, Setpos.y, GetEntityCoords(Entity).z)
                    end
                elseif IsDisabledControlPressed(2, 35) then -- D
                    local Setpos = GetOffsetFromEntityInWorldCoords(Entity, Speed * Multiplier, 0.0, 0.0)
                    SetEntityCoordsNoOffset(Entity, Setpos.x, Setpos.y, GetEntityCoords(Entity).z)
                    if InVehicle then
                        SetEntityCoordsNoOffset(PlayerPedId(), Setpos.x, Setpos.y, GetEntityCoords(Entity).z)
                    end
                end
                if IsDisabledControlPressed(2, 51) then -- E
                    local Setpos = GetOffsetFromEntityInWorldCoords(Entity, 0.0, 0.0, Multiplier * Speed / 2)
                    SetEntityCoordsNoOffset(Entity, Setpos)
                    if InVehicle then
                        SetEntityCoordsNoOffset(PlayerPedId(), Setpos)
                    end
                elseif IsDisabledControlPressed(2, 52) then
                    local Setpos = GetOffsetFromEntityInWorldCoords(Entity, 0.0, 0.0, Multiplier * - Speed / 2) -- Q
                    SetEntityCoordsNoOffset(Entity, Setpos)
                    if InVehicle then
                        SetEntityCoordsNoOffset(PlayerPedId(), Setpos)
                    end
                end
                local CameraRotation = GetCamRot(NoclipCam, 2)
                SetEntityHeading(Entity, (360 + CameraRotation.z) % 360.0)
                SetEntityVisible(Entity, false)
                if InVehicle then
                    SetEntityVisible(PlayerPedId(), false)
                end
                DisableControlAction(2, 32, true)
                DisableControlAction(2, 33, true)
                DisableControlAction(2, 34, true)
                DisableControlAction(2, 35, true)
                DisableControlAction(2, 36, true)
                DisableControlAction(2, 12, true)
                DisableControlAction(2, 13, true)
                DisableControlAction(2, 14, true)
                DisableControlAction(2, 15, true)
                DisableControlAction(2, 16, true)
                DisableControlAction(2, 17, true)
                DisablePlayerFiring(PlayerId(), true)
            end
            DestroyCam(NoclipCam, false)
            NoclipCam = nil
            RenderScriptCams(false, false, 500, true, false)
            FreezeEntityPosition(Entity, false)
            ApplyForceToEntityCenterOfMass(Entity, 0, 0.0, 0.0, 0.0, 0, 0, 0, 0)
            SetEntityCollision(Entity, true, true)
            ResetEntityAlpha(Entity)
            SetPedCanRagdoll(Entity, true)
            SetEntityVisible(Entity, true)
            ClearPedTasksImmediately(PlayerPedId())
            if InVehicle then
                FreezeEntityPosition(PlayerPedId(), false)
                SetEntityCollision(PlayerPedId(), true, true)
                ResetEntityAlpha(PlayerPedId())
                SetEntityVisible(PlayerPedId(), true)
                SetPedIntoVehicle(PlayerPedId(), Entity, -1)
            end

            if Cloaked then
                SetEntityVisible(PlayerPedId(), false, false)
                SetEntityAlpha(PlayerPedId(), 100, false)
            end
        end)
    end
end

function CheckInputRotation()
    Citizen.CreateThread(function()
        while NoclipCam ~= nil do
            Citizen.Wait(4)
            local RightAxisX = GetDisabledControlNormal(0, 220)
            local RightAxisY = GetDisabledControlNormal(0, 221)
            if (math.abs(RightAxisX) > 0) and (math.abs(RightAxisY) > 0) then
                local Rotation = GetCamRot(NoclipCam, 2)
                local RotZ, RotX = Rotation.z + RightAxisX * -10.0, Rotation.x
                local YValue = RightAxisY * -5.0
                if RotX + YValue > MinY and RotX + YValue < MaxY then
                    RotX = Rotation.x + YValue
                end
                SetCamRot(NoclipCam, RotX, Rotation.y, RotZ, 2)
            end
        end
    end)
end

exports("ToggleNoclip", function(Bool)
    ToggleNoclip(Bool)
    if Bool then CheckInputRotation() end
end)