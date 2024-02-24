local FleecaPowerBox = false

RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if FleecaPowerBox then
        if DataManager.Get(GetFleecaPrefix(FleecaPowerBox) .. "powerbox", 0) == 1 then
            return FW.Functions.Notify("Ziet er verbrand uit..", "error")
        end

        if DataManager.Get("HeistsDisabled", 0) == 1 then
            returnFW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if CurrentCops < Config.RequiredCopsFleeca or DataManager.Get("GlobalCooldown", false) == true then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end

        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end

        TriggerServerEvent('fw-inventory:Server:DecayItem', 'heavy-thermite', nil, 25.0)
        local _FleecaPowerBox = FleecaPowerBox
        local Outcome = DoThermite(5, GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.3, 0))
        if Outcome then
            DataManager.Set(GetFleecaPrefix(_FleecaPowerBox) .. "powerbox", 1)
            TriggerServerEvent("fw-mdw:Server:SendAlert:FleecaBank", GetEntityCoords(PlayerPedId()))
            FW.TriggerServer("fw-heists:Server:Fleeca:Reset", _FleecaPowerBox)

            local FleecaId, BankData = GetCurrentFleeca()
            StartCoordsChecker(BankData.Center, 100.0, function()
                FW.TriggerServer("fw-heists:Server:Fleeca:LeftArea", FleecaId)
            end)
        end
    else
        print("Not near Fleeca Powerbox (" .. tostring(FleecaPowerBox) .. ")")
    end
end)

RegisterNetEvent("fw-heists:Client:HeistLaptopUsed")
AddEventHandler("fw-heists:Client:HeistLaptopUsed", function(Laptop)
    local FleecaId, BankData = GetCurrentFleeca()
    if not FleecaId then
        return
    end

    local Coords = GetEntityCoords(PlayerPedId())
    if #(BankData.Vault - Coords) > 1.5 then
        return
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault", 0) == 1 then
        return FW.Functions.Notify("Iemand is al aan het hacken!", "error")
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault", 0) == 2 then
        return FW.Functions.Notify("Beveiligingssysteem is al gehackt!", "error")
    end

    local Item = exports["fw-inventory"]:GetItemByName('heist-laptop', 'green')
    if Item == nil or Laptop ~= "green" then return FW.Functions.Notify("Dit lijkt niet de goeie laptop te zijn..", "error") end

    -- Is the power box outside hacked?
    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "powerbox", 0) == 0 then
        return FW.Functions.Notify("Schakel eerst het elektriciteitskastje uit!", "error")
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "door-lockpicked", 0) == 0 then
        return
    end

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-laptop', Item.Slot, 33.33)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    DataManager.Set(GetFleecaPrefix(FleecaId) .. "vault", 1)

    local Outcome = ShapeMinigame(12, 3, 4)
    DataManager.Set(GetFleecaPrefix(FleecaId) .. "vault", Outcome and 2 or 0)
    if not Outcome then
        return
    end
end)

RegisterNetEvent("fw-items:Client:UseLockpick")
AddEventHandler("fw-items:Client:UseLockpick", function(IsAdvanced)
    local FleecaId, BankData = GetCurrentFleeca()
    if not FleecaId then
        return
    end

    local Coords = GetEntityCoords(PlayerPedId())
    if #(BankData.StaffDoor - Coords) > 1.5 then
        return
    end

    exports['fw-vehicles']:LoopAnimation(true, "veh@break_in@0h@p_m_one@", "low_force_entry_ds")

    local Outcome = exports['fw-ui']:StartSkillTest(IsAdvanced and math.random(2, 5) or math.random(5, 8), IsAdvanced and { 1, 2 } or { 5, 10 }, IsAdvanced and { 6000, 12000 } or { 1500, 3000 }, true)
    exports['fw-vehicles']:LoopAnimation(false)

    if not Outcome then
        FW.Functions.Notify("Gefaald..", "error")
        exports['fw-assets']:RemoveLockpickChance(IsAdvanced)
        return
    end

    DataManager.Set(GetFleecaPrefix(FleecaId) .. "door-lockpicked", 1)
    TriggerServerEvent("fw-doors:Server:SetLockStateById", BankData.DoorIds[2], 0)
end)

RegisterNetEvent("fw-heists:Client:Fleeca:HackGate")
AddEventHandler("fw-heists:Client:Fleeca:HackGate", function()
    local FleecaId, BankData = GetCurrentFleeca()
    if not FleecaId then
        return
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault", 0) ~= 2 then
        return
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "powerbox", 0) == 0 then
        return
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault-gate", 0) == 1 then
        return FW.Functions.Notify("Iemand is al aan het hacken!", "error")
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault-gate", 0) == 2 then
        return FW.Functions.Notify("Beveiligingssysteem is al gehackt!", "error")
    end

    if not exports['fw-inventory']:HasEnoughOfItem('heist-decrypter-basic', 1) then
        return FW.Functions.Notify("Je mist een Basic Decrypter!", "Error")
    end

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-decrypter-basic', nil, 33.33)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    DataManager.Set(GetFleecaPrefix(FleecaId) .. "vault-gate", 1)
    local Success = exports['fw-ui']:StartUntangle({
        Dots = 8,
        Timeout = 15000,
    })

    DataManager.Set(GetFleecaPrefix(FleecaId) .. "vault-gate", Success and 2 or 0)
    if not Success then
        return
    end

    TriggerServerEvent("fw-doors:Server:SetLockStateById", BankData.DoorIds[3], 0)
end)

RegisterNetEvent("fw-heists:Client:Fleeca:Loot")
AddEventHandler("fw-heists:Client:Fleeca:Loot", function(Data)
    local FleecaId, BankData = GetCurrentFleeca()
    if not FleecaId then
        return
    end

    -- Is the Vault Door hacked?
    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault", 0) ~= 2 then
        return
    end

    -- Is the Power Box hacked?
    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "powerbox", 0) == 0 then
        return
    end

    -- Is the safe behind the gate and is the gate not opened, return.
    if Data.SafeId > 2 and DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault-gate", 0) ~= 2 then
        return
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "loot-" .. Data.SafeId, 0) ~= 0 then
        return FW.Functions.Notify("Iemand is al aan het looten!")
    end

    if not exports['fw-inventory']:HasEnoughOfItem('heist-drill-basic', 1) then
        return
    end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. Data.SafeId, 1)

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-drill-basic', nil, math.random(10, 20) + 0.0)

    local GridOutcome = exports['fw-ui']:StartGridMinigame(4)
    if not GridOutcome then
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. Data.SafeId, 0)
        return
    end

    local DrillOutcome = DrillMinigame()
    if not DrillOutcome then
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. Data.SafeId, 0)
        return
    end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "loot-" .. Data.SafeId, 0) == 2 then
        return FW.Functions.Notify("Loot is al beroofd!")
    end

    DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. Data.SafeId, 2)
    FW.TriggerServer("fw-heists:Server:Fleeca:GetLoot", FleecaId, Data.SafeId)
end)

function GetCurrentFleeca()
    local Coords = GetEntityCoords(PlayerPedId())

    for k, v in pairs(Config.Fleeca) do
        if #(v.Center - Coords) < 50.0 then
            return k, v
        end
    end

    return false, nil
end

-- Doors
function CheckFleecaVaultDoor(FleecaId)
    if AnimatingDoor then
        return
    end

    local BankData = Config.Fleeca[FleecaId]
    local VaultCoords = BankData.Vault

    local PlyCoords = GetEntityCoords(PlayerPedId())
    local Distance = #(PlyCoords - VaultCoords)
    if Distance > 30.0 then
        return
    end

    local Object = GetClosestObjectOfType(VaultCoords.x, VaultCoords.y, VaultCoords.z, 5.0, GetHashKey("v_ilev_gb_vauldr"), false, false, false)
    local Heading = GetEntityHeading(Object)

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "vault", 0) == 2 then
        if Heading ~= BankData.VaultDoor.Open then
            AnimateObjectHeading(Object, BankData.VaultDoor.Open)
        end
    else
        if Heading ~= BankData.VaultDoor.Closed then
            AnimateObjectHeading(Object, BankData.VaultDoor.Closed)
        end
    end
end


Citizen.CreateThread(function()
    for FleecaId, Bank in pairs(Config.Fleeca) do
        exports['PolyZone']:CreateBox({
            center = Bank.PowerBox[1],
            length = Bank.PowerBox[2],
            width = Bank.PowerBox[3],
            data = { FleecaId = FleecaId },
        }, {
            name = "fleeca-heist-powerbox-" .. FleecaId,
            heading = Bank.PowerBox[4],
            minZ = Bank.PowerBox[5],
            maxZ = Bank.PowerBox[6],
        }, function(IsInside, Zone, Points)
            if IsInside then
                FleecaPowerBox = Zone.data.FleecaId
                exports['fw-ui']:ShowInteraction('Elektriciteitskast')
            else
                FleecaPowerBox = false
                exports['fw-ui']:HideInteraction()
            end
        end)

        for k, v in pairs(Bank.Zones) do
            exports['fw-ui']:AddEyeEntry('fleeca-heist-' .. FleecaId .. '_' .. k, {
                Type = 'Zone',
                SpriteDistance = 5.0,
                Distance = 0.6,
                State = false,
                ZoneData = {
                    Center = v.Center,
                    Length = v.Length,
                    Width = v.Width,
                    Data = {
                        heading = v.Heading,
                        maxZ = v.MaxZ,
                        minZ = v.MinZ,
                        Data = v.Data
                    },
                },
                Options = v.Options
            })
        end
    end

    while true do
        Citizen.Wait(5000)

        for k, v in pairs(Config.Fleeca) do
            CheckFleecaVaultDoor(k, v.Vault)
        end
    end
end)

exports("IsFleecaRobbed", function()
    local FleecaId, BankData = GetCurrentFleeca()
    if not FleecaId then return false end

    return DataManager.Get(GetFleecaPrefix(FleecaId) .. "powerbox", 0) ~= 0
end)