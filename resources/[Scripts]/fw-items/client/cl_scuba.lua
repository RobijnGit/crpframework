local MaskModel = GetHashKey("p_d_scuba_mask_s")
local TankModel = GetHashKey("p_s_scuba_tank_s")
local ScubaProps = {}
local HasScubaOn = false
local CurrentAir = nil

LoggedIn = true

RegisterNetEvent('fw-items:client:put:scuba:on')
AddEventHandler('fw-items:client:put:scuba:on', function(AirAmount)
    if not HasScubaOn and AirAmount >= 10 then
        if not exports['fw-progressbar']:GetTaskBarStatus() then
            if not DoingSomething then
                DoingSomething = true
                exports["fw-inventory"]:SetBusyState(true)
                FW.Functions.Progressbar("equip_gear", "Duikpak aantrekken..", 5000, false, true, {}, {}, {}, {}, function() -- Done
                    CurrentAir = AirAmount
                    HasScubaOn = true
                    exports['fw-assets']:RequestModelHash(TankModel)
                    exports['fw-assets']:RequestModelHash(MaskModel)
                    local TankObject = CreateObject(TankModel, 1.0, 1.0, 1.0, 1, 1, 0)
                    AttachEntityToEntity(TankObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 24818), -0.25, -0.25, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)
                    table.insert(ScubaProps, TankObject)
                    local MaskObject = CreateObject(MaskModel, 1.0, 1.0, 1.0, 1, 1, 0)
                    AttachEntityToEntity(MaskObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 12844), 0.0, 0.0, 0.0, 180.0, 90.0, 0.0, 1, 1, 0, 0, 2, 1)
                    table.insert(ScubaProps, MaskObject)
                    SetPedDiesInWater(PlayerPedId(), false)
                    SetEnableScuba(PlayerPedId(), true)
                    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'scuba-gear', 1, false)
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.Notify("Doe /duikpakuit om je duikpak uit tte doen", "error")
                    DoingSomething = false
                end, function()
                end, true)
            end
        end
    else
        FW.Functions.Notify("Actie niet mogelijk..", "error")
    end
end)

RegisterNetEvent('fw-items:client:takeoff:scuba')
AddEventHandler('fw-items:client:takeoff:scuba', function()
    if HasScubaOn then
        FW.Functions.Progressbar("remove_gear", "Duikpak uittrekken..", 5000, false, true, {}, {}, {}, {}, function() -- Done
            for k, v in pairs(ScubaProps) do
                NetworkRequestControlOfEntity(v)
                SetEntityAsMissionEntity(v, true, true)
                DetachEntity(v, 1, 1)
                DeleteEntity(v)
                DeleteObject(v)
            end
            FW.TriggerServer('fw-items:Server:Receive:Scuba', CurrentAir)
            SetPedDiesInWater(PlayerPedId(), true)
            SetEnableScuba(PlayerPedId(), false)
            CurrentAir, HasScubaOn = nil, false
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if not LoggedIn or not HasScubaOn then goto Skip end

        if CurrentAir > 10 then
            CurrentAir = CurrentAir - 10
            Citizen.Wait(30000)
            if HasScubaOn and IsPedSwimmingUnderWater(PlayerPedId()) then
                if CurrentAir < 10 then
                    SetPedDiesInWater(PlayerPedId(), true)
                    SetEnableScuba(PlayerPedId(), false)

                    FW.Functions.Notify("Je lucht tank is leeg je verdrinkt..", "error")
                end
            end
        end

        ::Skip::
        Citizen.Wait(1500)
    end
end)