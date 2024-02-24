local LastTruckPlateAlert = ""

RegisterNetEvent('fw-items:Clent:Used:HeavyThermite')
AddEventHandler('fw-items:Clent:Used:HeavyThermite', function()
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(2.0, 0.2, 286, PlayerPedId())
    if GetEntityType(Entity) == 2 and GetEntityModel(Entity) == GetHashKey("stockade") then
        if CurrentCops < Config.RequiredBanktruckCops or DataManager.Get("GlobalCooldown", false) == true then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end

        if DataManager.Get("HeistsDisabled", 0) == 1 then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if not exports['fw-inventory']:HasEnoughOfItem("gruppe6", 1) then
            return FW.Functions.Notify("Je mist een Gruppe 6 kaart..", "error")
        end
    
        local NetId = NetworkGetNetworkIdFromEntity(Entity)
    
        local CanRob = FW.SendCallback("fw-heists:Server:Banktruck:CanRobTruck", NetId)
        if not CanRob then return FW.Functions.Notify("De deuren zijn al opengebrand..", "error") end
    
        if LastTruckPlateAlert ~= GetVehicleNumberPlateText(Entity) then
            TriggerServerEvent('fw-mdw:Server:SendAlert:Banktruck', GetEntityCoords(PlayerPedId()))
            LastTruckPlateAlert = GetVehicleNumberPlateText(Entity)
        end
    
        Citizen.SetTimeout(450, function()
            local DidRemove = FW.SendCallback("FW:RemoveItem", "heavy-thermite", 1)
            if DidRemove then
                local Coords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -3.65, 0.55)
                local Success = DoThermite(7, Coords)
    
                if Success then
                    local DidRemoveCard = FW.SendCallback("FW:RemoveItem", "gruppe6", 1)
                    if not DidRemoveCard then return end
                    FW.TriggerServer("fw-heists:Server:Banktruck:SetTruckState", NetId, true)
                end
            end
        end)
    end
end)

RegisterNetEvent("fw-heists:Client:Banktruck:Setup")
AddEventHandler("fw-heists:Client:Banktruck:Setup", function(NetId)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    exports['fw-assets']:RequestModelHash('s_m_m_armoured_01')

    SetVehicleDoorsLocked(Vehicle, 3)
    SetVehicleDoorBroken(Vehicle, 2, 0)
    SetVehicleDoorBroken(Vehicle, 3, 0)

    for i = -1, 4 do
        local Protection = CreatePedInsideVehicle(Vehicle, 5, "s_m_m_armoured_01", i, 1, 1)
        SetPedShootRate(Protection, 750)
        SetPedCombatAttributes(Protection, 46, true)
        SetPedFleeAttributes(Protection, 0, 0)
        SetPedAsEnemy(Protection, true)
        SetPedArmour(Protection, 200.0)
        SetPedMaxHealth(Protection, 2000.0)
        SetPedAlertness(Protection, 3)
        SetPedCombatRange(Protection, 0)
        SetPedCombatMovement(Protection, 3)
        TaskCombatPed(Protection, PlayerPedId(), 0, 16)
        TaskLeaveVehicle(Protection, Vehicle, 0)
        GiveWeaponToPed(Protection, GetHashKey("WEAPON_CARBINERIFLE_MK2"), 9999, true, true)
        SetCurrentPedWeapon(Protection, GetHashKey("WEAPON_CARBINERIFLE_MK2"), true)
        SetPedRelationshipGroupHash(Protection, GetHashKey("HATES_PLAYER"))
        SetPedDropsWeaponsWhenDead(Protection, false)
    end

    local CanRobTruck = true
    Citizen.SetTimeout(60000 * 3, function()
        CanRobTruck = true
    end)

    Citizen.CreateThread(function()
        local RobbingTruck = true
        local ShowingInteraction = false
        while RobbingTruck do
            local PlayerCoords = GetEntityCoords(GetPlayerPed(-1))
            local TruckCoords = GetOffsetFromEntityInWorldCoords(Vehicle, 0.0, -3.5, 0.5)
            local Distance = #(PlayerCoords - TruckCoords)

            if Distance < 3.0 then
                if not ShowingInteraction then
                    ShowingInteraction = true
                    exports['fw-ui']:ShowInteraction('[E] Leegroven')
                end

                if IsControlJustPressed(0, 38) then
                    if not CanRobTruck then
                        FW.Functions.Notify("Nog even wachten...", "error")
                        goto Skip
                    end

                    if not exports['fw-progressbar']:GetTaskBarStatus() then
                        local Stealing = true
                        RobbingTruck = false
                        ShowingInteraction = false

                        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
                            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
                        end

                        exports['fw-ui']:HideInteraction()
                        exports['fw-assets']:AddProp('HeistBag')

                        FW.Functions.Progressbar("rob", "Stelen..", 60000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {
                            animDict = "anim@heists@ornate_bank@grab_cash_heels",
                            anim = "grab",
                            flags = 16
                        }, {}, {}, function()
                            Stealing = false
                            FW.TriggerServer("fw-heists:Server:Banktruck:ReceiveGoods", NetId)
                        end, function()
                            Stealing = false
                        end)

                        Citizen.CreateThread(function()
                            while Stealing do
                                TriggerServerEvent('fw-ui:Server:gain:stress', math.random(2, 3))
                                Citizen.Wait(6500)
                            end

                            StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
                            exports['fw-assets']:RemoveProp()
                        end)
                    end

                    ::Skip::
                end
            else
                if ShowingInteraction then
                    ShowingInteraction = false
                    exports['fw-ui']:HideInteraction()
                end
            end

            Citizen.Wait(4)
        end
    end)
end)

RegisterNetEvent("fw-heists:Client:Backtruck:TrackerBlip")
AddEventHandler("fw-heists:Client:Backtruck:TrackerBlip", function(x, y, z)
    local PlayerData = FW.Functions.GetPlayerData()

    if LoggedIn and PlayerData.job.name == 'police' and PlayerData.job.onduty then
        local Alpha = 250
        local Blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(Blip, 477)
        SetBlipColour(Blip, 1)
        SetBlipScale(Blip, 1.5)
        SetBlipAsShortRange(Blip, false)
        SetBlipDisplay(Blip, 2)
        SetBlipFlashes(Blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("10-90D - GPS-locatie")
        EndTextCommandSetBlipName(Blip)

        while Alpha > 50 do
            Citizen.Wait(120 * 4)

            Alpha = Alpha - 10
            SetBlipAlpha(Blip, Alpha)
        end

        RemoveBlip(Blip)
    end
end)