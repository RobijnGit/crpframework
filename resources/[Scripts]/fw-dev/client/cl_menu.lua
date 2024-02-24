local IsRaying = false

function InitMenu()
    local IsDev = FW.SendCallback("fw-dev:Server:IsDev")
    if not IsDev then
        return
    end

    FW.AddKeybind("openDevMenu", "DEV", "Open Menu", "", function(IsPressed)
        if not IsPressed then return end
        if FocusingEntity then
            SetNuiFocus(true, true)
            local EntityDetails = GetEntityDetails(FocusingEntity)

            SendUIMessage("Menu/SetEntityType", {Type = CurrentEntityType})
            SendUIMessage("Menu/SetEntityDetails", {EntityDetails = EntityDetails})
            SendUIMessage("Menu/ToggleMenu", {Visibility = true})
        end
    end)

    FW.AddKeybind("devMenuRay", "DEV", "Entity Ray", "", function(IsPressed)
        ToggleRay(IsPressed)
    end)
end

function ToggleRay(IsPressed)
    IsRaying = IsPressed
    if not IsRaying then
        if FocusingEntity and DoesEntityExist(FocusingEntity) then
            SetEntityDrawOutline(FocusingEntity, false)
        end
        return
    end

    if FocusingEntity then return end

    Citizen.CreateThread(function()
        while IsRaying or (FocusingEntity and DoesEntityExist(FocusingEntity)) do
            local Hit, Coords, Entity
            if IsRaying then
                Hit, Coords, Entity = exports['fw-ui']:RayCastGamePlayCamera(75)
                if not Hit then
                    goto Skip
                end
            else
                Entity = FocusingEntity
            end

            if Entity and GetEntityType(Entity) > 0 then
                local Health = GetEntityHealth(Entity)
                local MaxHealth = GetEntityMaxHealth(Entity)

                -- Vehicle
                if IsEntityAVehicle(Entity) then
                    Health = math.floor(GetVehicleEngineHealth(Entity))
                end

                local Hash = GetEntityModel(Entity)
                local Model = Config.Entities[Hash] or Hash
                local EntityCoords = GetEntityCoords(Entity)

                local TextString = "~r~(" .. Health .. "/" .. MaxHealth .. ")~n~~q~" .. Entity .. "   ~o~" .. Model .. "   ~g~" .. round2(EntityCoords.x) .. " " .. round2(EntityCoords.y) .. " " .. round2(EntityCoords.z)
                DrawText3D(EntityCoords.x, EntityCoords.y, EntityCoords.z + 1.0, TextString)

                if IsRaying then
                    DrawMarker(1, EntityCoords.x, EntityCoords.y, EntityCoords.z, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 0, 255, 0, 250, false, false, false, false, false, false, false)
                end

                if FocusingEntity ~= Entity then
                    if FocusingEntity and DoesEntityExist(FocusingEntity) then
                        SetEntityDrawOutline(FocusingEntity, false)
                    end
                    
                    if GetEntityType(Entity) > 1 then
                        SetEntityDrawOutline(Entity, true)
                        SetEntityDrawOutlineColor(0, 255, 0, 255)
                    end
                    FocusingEntity = Entity
                end
            else
                if IsRaying then
                    DrawMarker(1, Coords.x, Coords.y, Coords.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 150, 150, 150, 250, false, false, false, false, false, false, false)
                end

                if FocusingEntity then
                    SetEntityDrawOutline(FocusingEntity, false)
                    FocusingEntity = false
                    SendUIMessage("Menu/ToggleMenu", {Visibility = false})
                    SetNuiFocus(false, false)
                end
            end

            ::Skip::

            Citizen.Wait(1)
        end

        SendUIMessage("Menu/ToggleMenu", {Visibility = false})
        SetNuiFocus(false, false)

        FocusingEntity = false
    end)
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextOutline()
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function round2(val)
    return string.format("%.2f", val)
end

RegisterNUICallback("Menu/Unfocus", function(Data, Cb)
    SendUIMessage("Menu/ToggleMenu", {Visibility = false})
    SetNuiFocus(false, false)
    Cb("ok")
end)

RegisterNUICallback("Menu/ProcessAction", function(Data, Cb)
    Cb("ok")

    local IsDev = FW.SendCallback("fw-dev:Server:IsDev")
    if not IsDev then
        return
    end

    if CurrentEntityType == 'vehicle' then
        OnVehicleAction(Data)
    elseif CurrentEntityType == 'ped' then
        OnPedAction(Data)
    elseif CurrentEntityType == 'player' then
        OnPlayerAction(Data)
    end
end)