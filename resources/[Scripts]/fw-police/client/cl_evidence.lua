local NextMeleeAction, NextStabbingAction, NextShootingAction = GetCloudTimeAsInt(), GetCloudTimeAsInt(), GetCloudTimeAsInt()
local Evidence, EvidenceEnabled, CanCollect, CurrentStatusList = {}, false, true, {}

local StatusList = {
    ['fight'] = { Text = 'Rode Handen', Show = true },
    ['redeyes'] = { Text = 'Rode Ogen', Show = true },
    ['sweat'] = { Text = 'Lichaamszweet', Show = true },
    ['confused'] = { Text = 'Verward', Show = false },
    ['widepupils'] = { Text = 'Brede Pupillen', Show = true },
    ['sworebody'] = { Text = 'Pijnlijk Lichaam', Show = false },
    ['wellfed'] = { Text = 'Ziet er gevoed uit', Show = true },
    ['huntbleed'] = { Text = 'Bloederige Handen', Show = true },
    ['gasoline'] = { Text = 'Ruikt naar Benzine', Show = true },
    ['heavybreath'] = { Text = 'Moeizame Ademhaling', Show = false },
    ['chemicals'] = { Text = 'Geuren van Chemicaliën', Show = false },
    ['weedsmell'] = { Text = 'Ruikt naar Marihuana', Show = true },
    ['gunpowder'] = { Text = 'Buskruit Residu', Show = false },
    ['alcohol'] = { Text = 'Adem ruikt naar Alcohol', Show = false },
    ['heavyalcohol'] = { Text = 'Adem ruikt heel erg naar Alcohol', Show = true },
    ['explosive'] = { Text = 'Sporen van plastic en explosievenresten', Show = false }
}

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and PlayerData ~= nil and PlayerData.job ~= nil then
            if (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity') and PlayerData.job.onduty then
                if exports['fw-items']:IsInPDCam() or (exports['fw-weapons']:IsFreeAiming() and GetSelectedPedWeapon(PlayerPedId()) == GetHashKey("WEAPON_FLASHLIGHT")) then
                    if not EvidenceEnabled then
                        EvidenceEnabled = true
                        DoEvidenceLoop()
                    end
                else
                    if EvidenceEnabled then
                        EvidenceEnabled = false
                    end
                    Citizen.Wait(450)
                end
            else
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn and CurrentStatusList ~= nil then
            for k, v in pairs(CurrentStatusList) do
                if v.Time - 5 > 0 then
                    v.Time = v.Time - 5
                else
                    table.remove(CurrentStatusList, k)
                end
                TriggerServerEvent('fw-police:Server:SetStatus', CurrentStatusList)
            end
            Citizen.Wait(5000)
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

AddEventHandler('gameEventTriggered', function(Name, Args)
    if not LoggedIn then return end

    local IsSelfAttacker = (Args[2] == PlayerPedId() and true or false)
    local IsMeleeAttack = (Args[7] == GetHashKey('weapon_unarmed') and true or false)
    if Name == "CEventNetworkEntityDamage" and IsMeleeAttack and IsSelfAttacker and GetCloudTimeAsInt() > NextMeleeAction then
        local VictimIsPlayer = IsPedAPlayer(Args[1])
        if math.random() < 0.15 then
            -- TriggerServerEvent('fw-mdw:Server:SendAlert:Fighting', GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), false) Uitgezet voor de nerds
            NextMeleeAction = GetCloudTimeAsInt() + 135
        end
    end
    if Name == "CEventNetworkEntityDamage" and IsPedArmed(PlayerPedId(), 1) and IsSelfAttacker and GetCloudTimeAsInt() > NextStabbingAction then
        if math.random() < 0.15 then
            -- TriggerServerEvent('fw-mdw:Server:SendAlert:Fighting', GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), true) Uitgezet voor de nerds
            NextStabbingAction = GetCloudTimeAsInt() + 135
        end
    end
    if Name == "CEventNetworkEntityDamage" and IsPedArmed(PlayerPedId(), 6) and not IgnoreWeapon(Args[7]) and IsSelfAttacker and GetCloudTimeAsInt() > NextShootingAction then
        local PlayerData = FW.Functions.GetPlayerData()

        if PlayerData and (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity' or PlayerData.job.name == 'doc') and PlayerData.job.onduty then
            return
        end

        if exports['fw-arcade']:IsInTDM() then return end
        if exports['fw-jobmanager']:InsideHuntingZone() then return end
        if #(GetEntityCoords(PlayerPedId()) - vector3(5016.16, -5046.74, -0.47)) < 1250 then return end

        local IsInVehicle, StreetLabel = IsPedInAnyVehicle(PlayerPedId()) or false, FW.Functions.GetStreetLabel()
        local VehicleDesc = {}
        if IsInVehicle then
            local Vehicle = GetVehiclePedIsIn(PlayerPedId())
            VehicleDesc = {
                Name = FW.Shared.HashVehicles[GetEntityModel(Vehicle)] ~= nil and FW.Shared.HashVehicles[GetEntityModel(Vehicle)].Name or GetDisplayNameFromVehicleModel(GetEntityModel(Vehicle)),
                Plate = GetVehicleNumberPlateText(Vehicle),
                Colors = FW.Functions.GetVehicleColorLabel(Vehicle)
            }
        end
        
        TriggerServerEvent('fw-mdw:Server:SendAlert:Gunshots', GetEntityCoords(PlayerPedId()), StreetLabel, IsInVehicle, VehicleDesc)
        NextShootingAction = GetCloudTimeAsInt() + 100
    end
end)

RegisterNetEvent('fw-police:Client:CheckStatus')
AddEventHandler('fw-police:Client:CheckStatus', function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(3000, "Status controleren...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = false}, {}, {}, {}, false)
    if not Finished then return end
    TriggerServerEvent('fw-police:Server:GetTargetStatus', Player)
end)

RegisterNetEvent('fw-police:Client:TakeGSRTest')
AddEventHandler('fw-police:Client:TakeGSRTest', function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'storesecurity' then
        return
    end

    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    if IsPedInAnyVehicle(PlayerPedId()) or IsPedInAnyVehicle(GetPlayerPed(Player)) then
        FW.Functions.Notify("Dit kan je niet in een voertuig doen..", "error")
    end

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, 1)
    local Finished = FW.Functions.CompactProgressbar(5000, "GSR-test afnemen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())

    if not Finished then return end
    TriggerServerEvent('fw-police:Server:GSRResult', Player)
end)

RegisterNetEvent('fw-police:Client:SetStatus')
AddEventHandler('fw-police:Client:SetStatus', function(StatusName, Time)
    if Time > 0 and StatusList[StatusName] ~= nil and not IsStatusAlreadyActive(StatusName) then
        if CurrentStatusList == nil then
            CurrentStatusList = {}
        end
        table.insert(CurrentStatusList, {
            Status = StatusName,
            Text = StatusList[StatusName].Text,
            Time = Time
        })
        if StatusList[StatusName].Show then
            TriggerEvent('chatMessage', "Status", "warning", StatusList[StatusName].Text)
        end
    end
    TriggerServerEvent('fw-police:Server:Evidence:SetStatus', CurrentStatusList)
end)

RegisterNetEvent('fw-items:Client:Used:Evidence')
AddEventHandler('fw-items:Client:Used:Evidence', function()
    if EvidenceEnabled then
        if CanCollect then
            CanCollect = false
            local ClosestEvidence = GetClosestEvidence()
            if ClosestEvidence ~= false then
                FW.TriggerServer('fw-police:Server:Receive:Evidence', ClosestEvidence)
            end
        end
    else
        TriggerEvent('fw-ui:Client:Notify', 'evidence-error', "An error occured! (You can\'t use this in this state)", 'error')
    end
end)

RegisterNetEvent('fw-police:Client:SetEvidence')
AddEventHandler('fw-police:Client:SetEvidence', function(EvidenceId, EvidenceData)
    Evidence[EvidenceId] = EvidenceData
end)

RegisterNetEvent('fw-police:Client:ResetCollectCooldown')
AddEventHandler('fw-police:Client:ResetCollectCooldown', function()
    CanCollect = true
end)

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
    if FromItem.Item ~= 'evidence-collected' or FromItem.CustomType ~= 'Blood' then return end
    if ToItem.Item ~= 'dna-reader' then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'ems' then
        return FW.Functions.Notify("Je kan dit apperaat niet gebruiken..", "error")
    end

    exports['fw-assets']:AddProp('Tablet')
    exports['fw-assets']:RequestAnimationDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)

    local Finished = FW.Functions.CompactProgressbar(15000, "DNA uitlezen...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = false}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())

    if not Finished then return end

    exports['fw-assets']:RemoveProp()
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0)
    TriggerEvent('chatMessage', "DNA-lezer resultaat", "error", FromItem.Info._EvidenceData.BloodId)
end)

-- // Functions \\ --

function DoEvidenceLoop()
    Citizen.CreateThread(function()
        while EvidenceEnabled do
            Citizen.Wait(3)
            local NearEvidence = false
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Evidence) do
                if Evidence[k] ~= nil then
                    local Distance = #(PlayerCoords - v.Coords)
                    if Distance < 15.0 then
                        NearEvidence = true
                        if v.Type == 'Blood' then
                            DrawMarker(28, v.Coords.x, v.Coords.y, v.Coords.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 202, 22, 22, 141, 0, 0, 0, 0)
                        elseif v.Type == 'Fingerprint' then
                            DrawMarker(21, v.Coords.x, v.Coords.y, v.Coords.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 14, 227, 60, 91, 0, 0, 0, 0)
                        elseif v.Type == 'Bullet' then
                            DrawMarker(41, v.Coords.x, v.Coords.y, v.Coords.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 242, 152, 7, 141, 0, 0, 0, 0)
                        end
                        DrawText3D(v.Coords.x, v.Coords.y, v.Coords.z, k)
                    end
                end
            end
            if not NearEvidence then
                Citizen.Wait(450)
            end
        end
    end)
end

function GetClosestEvidence()
    local ReturnData, Count = {}, 0
    local PlayerCoords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(Evidence) do
        local Distance = #(PlayerCoords - v.Coords)
        if Distance < 2.5 and Count < 6 then
            Count = Count + 1
            table.insert(ReturnData, v)
        end
    end
    if Count <= 6 then
        return ReturnData
    else
        return false
    end
end

function IsExemptWeapon(Weapon)
    for k, v in pairs(Config.ExemptWeapons) do
        if GetHashKey(v) == Weapon then
            return true
        end
    end
    return false
end

function IsStatusAlreadyActive(StatusName)
    for k, v in pairs(CurrentStatusList) do
        if v.Status == StatusName then
            return true
        end
    end
    return false
end
exports('IsStatusAlreadyActive', IsStatusAlreadyActive)

function DrawText3D(X, Y, Z, Text)
    local OnScreen, _X, _Y = World3dToScreen2d(X, Y, Z)
    local PX, PY, PZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)
    SetTextOutline(true)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(Text)
    DrawText(_X, _Y)
end