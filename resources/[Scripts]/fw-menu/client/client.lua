-- Code

RegisterNetEvent('animations:client:set:walkstyle')
AddEventHandler('animations:client:set:walkstyle', function(Walkstyle)
    local PlayerData = FW.Functions.GetPlayerData()
    if Walkstyle then
        TriggerServerEvent("fw-menu:Server:SaveWalkstyle", Walkstyle)

        if Walkstyle == 'default' then
            ResetPedMovementClipset(PlayerPedId(), 0.2)
            return
        end

        exports['fw-assets']:RequestAnimSetEvent(Walkstyle)
        SetPedMovementClipset(PlayerPedId(), Walkstyle, 0.2) 
    else
        if PlayerData.metadata.walkstyle ~= nil and PlayerData.metadata.walkstyle ~= false then
            TriggerEvent('animations:client:set:walkstyle', PlayerData.metadata.walkstyle)
        else
            TriggerEvent('animations:client:set:walkstyle', 'default')
        end
    end

    local Expression = PlayerData.metadata.expression and PlayerData.metadata.expression or ""
    SetFacialIdleAnimOverride(PlayerPedId(), Expression, 0)
end)

RegisterNetEvent("expressions")
AddEventHandler("expressions", function(pArgs)
    if #pArgs ~= 1 then return end
    local expressionName = pArgs[1]
    SetFacialIdleAnimOverride(PlayerPedId(), expressionName, 0)
    TriggerServerEvent("fw-menu:Server:SaveExpression", expressionName)
    return
end)

RegisterNetEvent("expressions:clear")
AddEventHandler("expressions:clear",function() 
    ClearFacialIdleAnimOverride(PlayerPedId()) 
    TriggerServerEvent("fw-menu:Server:SaveExpression", "")
end)

--  // Main Functions \\ --

RegisterNetEvent('fw-menu:client:flip:vehicle')
AddEventHandler('fw-menu:client:flip:vehicle', function()
    if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then return end

    local Vehicle, Distance = FW.Functions.GetClosestVehicle()
    if Vehicle ~= 0 and Distance < 1.7 then
        FW.Functions.Progressbar("flip-vehicle", "Voertuig omduwen..", math.random(10000, 15000), false, true, {
            disableMovement = true,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "random@mugging4",
            anim = "struggle_loop_b_thief",
            flags = 49,
        }, {}, {}, function() -- Done
            SetVehicleOnGroundProperly(Vehicle)
            FW.Functions.Notify("Gelukt", "success")
        end, function()
            FW.Functions.Notify("Geannuleerd..", "error")
        end, true)
    else
        FW.Functions.Notify("Geen voertuig gevonden..", "error")
    end
end)

RegisterNetEvent("fw-menu:client:send:panic:button")
AddEventHandler("fw-menu:client:send:panic:button",function()
    local HasRadio = FW.SendCallback('FW:HasItem', "radio")
    local HasPDRadio = FW.SendCallback('FW:HasItem', "pdradio")
    if not HasRadio and not HasPDRadio then
        return FW.Functions.Notify("Je hebt geen portofoon op zak.. Een noodknop is nu niet mogelijk..", "error")
    end

    local Player = FW.Functions.GetPlayerData()
    local Info = {Callsign = Player.metadata['callsign']}
    local StreetLabel = FW.Functions.GetStreetLabel()
    TriggerServerEvent('fw-mdw:Server:SendAlert:DistressSignal', GetEntityCoords(PlayerPedId()), StreetLabel, Info)
end)

RegisterNetEvent("fw-menu:client:send:down")
AddEventHandler("fw-menu:client:send:down",function(Type)
    local HasPDRadio = FW.SendCallback('FW:HasItem', "pdradio")
    if not HasPDRadio then
        return FW.Functions.Notify("Je hebt geen portofoon op zak.. een noodknop is nu niet mogelijk..", "error")
    end

    local Player = FW.Functions.GetPlayerData()
    local Info = {['Firstname'] = Player.charinfo.firstname, ['Lastname'] = Player.charinfo.lastname, ['Callsign'] = Player.metadata['callsign']}
    local StreetLabel = FW.Functions.GetStreetLabel()
    local Priority = 2
    if Type == 'Urgent' then
        Priority = 3
    end
    TriggerServerEvent('fw-mdw:Server:SendAlert:OfficerDown', GetEntityCoords(PlayerPedId()), StreetLabel, Info, Priority)  
end)

RegisterNetEvent("fw-menu:client:open:door")
AddEventHandler("fw-menu:client:open:door",function(DoorNumber)
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if GetVehicleDoorAngleRatio(Vehicle, DoorNumber) > 0.0 then
        FW.VSync.SetVehicleDoorShut(Vehicle, DoorNumber, false)
    else
        FW.VSync.SetVehicleDoorOpen(Vehicle, DoorNumber, false, false)
    end
end)

RegisterNetEvent('fw-menu:client:setExtra')
AddEventHandler('fw-menu:client:setExtra', function(data)
    local extra = tonumber(data)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
 
    if veh ~= nil then
        if GetPedInVehicleSeat(veh, -1) == ped then
            SetVehicleAutoRepairDisabled(veh, true)
            if DoesExtraExist(veh, extra) then 
                if IsVehicleExtraTurnedOn(veh, extra) then
                    SetVehicleExtra(veh, extra, 1)
                    FW.Functions.Notify('Extra ' .. extra .. ' is uitgezet op dit voertuig', 'error', 2500)
                else
                    SetVehicleExtra(veh, extra, 0)
                    FW.Functions.Notify('Extra ' .. extra .. ' is aangezet op dit voertuig', 'success', 2500)
                end
            else
                FW.Functions.Notify('Extra ' .. extra .. ' is niet beschikbaar op dit voertuig', 'error', 2500)
            end
        else
            FW.Functions.Notify("Je bent niet de bestuurder van dit voertuig.", 'error', 2500)
        end
    end
end)