local InsidePowerbox = false

RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if InsidePowerbox then
        if CurrentCops < Config.RequiredVaultCops or DataManager.Get("GlobalCooldown", false) == true then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end

        if DataManager.Get("HeistsDisabled", 0) == 1 then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end    
    
        if not exports['fw-sync']:BlackoutActive() then
            return FW.Functions.Notify("Je ziet een alarm zitten op het kastje die gekoppelt lijkt te zijn met het stroomnetwerk..", "error")
        end
    
        if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) == 1 then
            return FW.Functions.Notify("Ziet er verbrand uit..", "error")
        end
    
        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end

        StartCoordsChecker(vector3(257.11, 223.91, 106.28), 250.0, function()
            FW.TriggerServer("fw-heists:Server:Vault:LeftArea")
        end)
    
        TriggerServerEvent('fw-inventory:Server:DecayItem', 'heavy-thermite', nil, 25.0)
        local Outcome = exports['fw-ui']:StartThermite(7)
        if Outcome then
            local DidRemove = FW.SendCallback("FW:RemoveItem", "heavy-thermite", 1)
            if not DidRemove then return end
    
            DataManager.Set(GetVaultPrefix() .. "powerbox", 1)
    
            TriggerServerEvent("fw-mdw:Server:SendAlert:Vault")
            FW.TriggerServer("fw-heists:Server:Vault:Reset")
            FW.TriggerServer("fw-heists:Server:Vault:SetBoxCoords", vector3(263.99, 216.34, 96.71), 347.81)
            DoThermiteEffect(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.3, 0))
        end
    end
end)

RegisterNetEvent("fw-heists:Client:Vault:OpenLaptop")
AddEventHandler("fw-heists:Client:Vault:OpenLaptop", function(Data)
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end

    local Item = exports["fw-inventory"]:GetItemByName('heist-electronic-kit-hard')
    if Item == nil then return FW.Functions.Notify("Je mist een Hardened Electronic Kit..", "error") end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-electronic-kit-hard', Item.Slot, 25.0)

    local GameData = FW.SendCallback("fw-heists:Server:Vault:GetCodeData", Data.Id)

    exports['fw-laptop']:SetSecureGuardData(GameData)
    TriggerEvent("fw-laptop:Client:Open", "Vault")
end)

RegisterNetEvent("fw-heists:Client:Vault:HackMainOffice")
AddEventHandler("fw-heists:Client:Vault:HackMainOffice", function()
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Ziet er verbrand uit..", "error")
    end

    local Item = exports["fw-inventory"]:GetItemByName('heist-decrypter-hard')
    if Item == nil then return FW.Functions.Notify("Je mist een Hardened Decrypter..", "error") end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-decrypter-hard', Item.Slot, 33.0)

    local Success = exports['fw-ui']:StartUntangle({
        Dots = 10,
        Timeout = 20000,
    })
    if not Success then return end

    TriggerServerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_MAIN_OFFICE_LEFT", 0)
    TriggerServerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_MAIN_OFFICE_RIGHT", 0)
    DataManager.Set(GetVaultPrefix() .. "vault-office", 1)
end)

RegisterNetEvent("fw-heists:Client:Vault:CrackSafe")
AddEventHandler("fw-heists:Client:Vault:CrackSafe", function()
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end
    if DataManager.Get(GetVaultPrefix() .. "vault-office", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "office-safe", 0) == 1 then return end

    local Item = exports["fw-inventory"]:GetItemByName('heist-safecracking')
    if Item == nil then return FW.Functions.Notify("Je mist een Safe Cracking Tool..", "error") end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-safecracking', Item.Slot, 33.0)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    local Success = SafeCrack(5)
    if not Success or Success == 'Escaped' then
        return
    end

    DataManager.Set(GetVaultPrefix() .. "office-safe", 1)
    FW.TriggerServer('fw-heists:Server:Vault:OfficeSafeReward')
end)

RegisterNetEvent("fw-heists:Client:Vault:EnterPassword")
AddEventHandler("fw-heists:Client:Vault:EnterPassword", function()
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end
    if DataManager.Get(GetVaultPrefix() .. "vault-office", 0) ~= 1 then return end

    local Input = {}

    for i = 1, 8, 1 do
        Input[i] = { Label = tostring(i), Icon = 'fas fa-passport', Name = tostring(i), MaxLength = 2, ShowLength = true }
    end

    local Result = exports['fw-ui']:CreateInput(Input)

    local Code = FW.SendCallback("fw-heists:Server:Vault:IsPasswordCorrect", Result)
    exports['fw-ui']:SetTextDisplay(Code)
end)

RegisterNetEvent("fw-heists:Client:Vault:HackVaultGate")
AddEventHandler("fw-heists:Client:Vault:HackVaultGate", function()
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end

    local Item = exports["fw-inventory"]:GetItemByName('heist-laptop', 'red')
    if Item == nil then return FW.Functions.Notify("Dit lijkt niet de goeie laptop te zijn..", "error") end

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-laptop', Item.Slot, 33.33)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    local Success = ShapeMinigame(13, 6, 6)
    if not Success then return end

    TriggerServerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_STAIRS_TO_VAULT_UPPER", 0)
    DataManager.Set(GetVaultPrefix() .. "vault-upper", 1)
end)

RegisterNetEvent("fw-heists:Client:Vault:DecryptBottomVault")
AddEventHandler("fw-heists:Client:Vault:DecryptBottomVault", function(Data)
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end
    if DataManager.Get(GetVaultPrefix() .. "vault-upper", 0) ~= 1 then return end

    local Item = exports["fw-inventory"]:GetItemByName('heist-decrypter-hard')
    if Item == nil then return FW.Functions.Notify("Je mist een Hardened Decrypter..", "error") end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-decrypter-hard', Item.Slot, 33.0)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    TriggerServerEvent("fw-heists:Server:RegisterVaultHack", Data.Id)
    local Success = exports['fw-ui']:StartUntangle({
        Dots = 10,
        Timeout = 20000,
    })

    if not Success then
        DataManager.Set(GetVaultPrefix() .. "vault-hacking-simultaneously", 0)
        return
    end

    if DataManager.Get(GetVaultPrefix() .. "vault-hacking-simultaneously", 0) == 1 then
        FW.TriggerServer('fw-heists:Server:SuccessGateHack')
    end
end)

RegisterNetEvent("fw-heists:Client:HeistBoxUsed")
AddEventHandler("fw-heists:Client:HeistBoxUsed", function()
    exports['fw-core']:DoEntityPlacer("hei_prop_heist_wooden_box", 10.0, true, true, nil, function(DidPlace, Coords, Heading)
        if not DidPlace then return end
        FW.TriggerServer("fw-heists:Server:Vault:SetBoxCoords", Coords, Heading, true)
    end)
end)

RegisterNetEvent("fw-heists:Client:Vault:HackEletrical")
AddEventHandler("fw-heists:Client:Vault:HackEletrical", function()
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end
    if DataManager.Get(GetVaultPrefix() .. "vault-upper", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "vault-gate-hacked", 0) ~= 1 then return end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Success = exports['fw-minigames']:StartKeystrokeMinigame('Hard', 30, 6)
    if not Success then return end

    DataManager.Set(GetVaultPrefix() .. "lasers-hacked", 1)
    TriggerServerEvent("fw-phone:Server:Mails:AddMail", "Dark Market", "#Vault-90", "Je hebt 10 minuten voordat de generator weer werkt en de lasers weer aan staan!")
    FW.TriggerServer("fw-heists:Server:Vault:StartLasers")
end)

RegisterNetEvent("fw-heists:Client:Vault:HackVault")
AddEventHandler("fw-heists:Client:Vault:HackVault", function(Data)
    if IsVaultTripped() then
        return
    end

    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end

    if DataManager.Get(GetVaultPrefix() .. "vault-upper", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "vault-gate-hacked", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "lasers-hacked", 0) ~= 1 then return end

    local Item = exports["fw-inventory"]:GetItemByName('heist-decrypter-hard')
    if Item == nil then return FW.Functions.Notify("Je mist een Hardened Decrypter..", "error") end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-decrypter-hard', Item.Slot, 33.0)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    local Item = exports["fw-inventory"]:GetItemByName('heist-keycard-vault')
    if Item == nil then return FW.Functions.Notify("Je mist een Keycard..", "error") end

    local Success = exports['fw-ui']:StartUntangle({
        Dots = 10,
        Timeout = 20000,
    })

    if not Success then
        return
    end

    local DidRemove = FW.SendCallback("FW:RemoveItem", "heist-keycard-vault", 1)
    if not DidRemove then return end

    DataManager.Set(GetVaultPrefix() .. "vault-" .. Data.Type .. "-hacked", 1)
    TriggerServerEvent("fw-doors:Server:SetLockStateById", Data.DoorId, 0)
end)

RegisterNetEvent("fw-heists:Client:Vault:HackBigVault")
AddEventHandler("fw-heists:Client:Vault:HackBigVault", function(Data)
    if IsVaultTripped() then
        return
    end
    
    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end
    
    if DataManager.Get(GetVaultPrefix() .. "vault-upper", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "vault-gate-hacked", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "lasers-hacked", 0) ~= 1 then return end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Item = exports["fw-inventory"]:GetItemByName('heist-laptop', 'red')
    if Item == nil then return FW.Functions.Notify("Dit lijkt niet de goeie laptop te zijn..", "error") end

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-laptop', Item.Slot, 33.33)

    local Result = exports['fw-ui']:CreateInput({
        { Label = "Beveiligingscode", Icon = 'fas fa-code', Name = "Code" }
    })

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    local IsCodeCorrect = FW.SendCallback("fw-heists:Server:Vault:IsSecurityCodeCorrect", Result.Code)
    if not IsCodeCorrect then
        return FW.Functions.Notify("Toegang geweigerd.", "error")
    end

    local Success = ShapeMinigame(13, 6, 6)
    if not Success then return end

    SpawnTrolley("vault-1", "Cash", vector4(229.25, 225.11, 96.58, 14.80))
    SpawnTrolley("vault-2", "Cash", vector4(227.91, 225.63, 96.58, -38.90))
    SpawnTrolley("vault-3", "Cash", vector4(226.05, 226.07, 96.58, 14.80))
    SpawnTrolley("vault-4", "Cash", vector4(224.66, 226.66, 96.58, -38.90))

    DataManager.Set(GetVaultPrefix() .. "vault-center-hacked", 1)
end)

RegisterNetEvent("fw-heists:Client:Vault:UseKeycard")
AddEventHandler("fw-heists:Client:Vault:UseKeycard", function()
    local Item = exports["fw-inventory"]:GetItemByName('heist-entrykeycard')
    if Item == nil then return FW.Functions.Notify("Je mist een Keycard..", "error") end

    local DidRemove = FW.SendCallback("FW:RemoveItem", "heist-entrykeycard", 1)
    if not DidRemove then return end

    TriggerServerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_VAULT_INNER_GATE_LEFT", 0)
    TriggerServerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_VAULT_INNER_GATE_RIGHT", 0)
end)

RegisterNetEvent("fw-heists:Client:Vault:Loot")
AddEventHandler("fw-heists:Client:Vault:Loot", function(Data)
    local Type = "left"

    -- Is the safe behind the gate and is the gate not opened, return.
    if Data.Id > 5 and Data.Id <= 10 then
        Type = "right"
    elseif Data.Id > 10 then
        Type = "vault"
    end

    if DataManager.Get(GetVaultPrefix() .. "powerbox", 0) ~= 1 then
        return FW.Functions.Notify("Schakel eerst de elektriciteitskast uit..", "error")
    end
    if DataManager.Get(GetVaultPrefix() .. "vault-upper", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "vault-gate-hacked", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "lasers-hacked", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "vault-"..Type.."-hacked", 0) ~= 1 then return end
    if DataManager.Get(GetVaultPrefix() .. "loot-"..Data.Id, 0) ~= 0 then return end

    if not exports['fw-inventory']:HasEnoughOfItem('heist-drill-hard', 1) then
        return FW.Functions.Notify("Je mist een boormachine..", "error")
    end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    DataManager.Set(GetVaultPrefix() .. "loot-" .. Data.Id, 1)

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-drill-hard', nil, math.random(15, 25) + 0.0)

    local GridOutcome = exports['fw-ui']:StartGridMinigame(4)
    if not GridOutcome then
        DataManager.Set(GetVaultPrefix() .. "loot-" .. Data.Id, 0)
        return
    end

    local DrillOutcome = DrillMinigame()
    if not DrillOutcome then
        DataManager.Set(GetVaultPrefix() .. "loot-" .. Data.Id, 0)
        return
    end

    DataManager.Set(GetVaultPrefix() .. "loot-" .. Data.Id, 2)
    FW.TriggerServer("fw-heists:Server:Vault:GetLoot", Type, Data.Id)
end)

Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({
        center = vector3(285.73, 264.89, 105.59),
        length = 1.2,
        width = 1.6,
    }, {
        name = "heist-vault-powerbox",
        heading = 340,
        minZ = 104.59,
        maxZ = 106.79
    }, function(IsInside, Zone, Points)
        InsidePowerbox = IsInside

        if IsInside then
            exports['fw-ui']:ShowInteraction('Elektriciteitskast')
        else
            exports['fw-ui']:HideInteraction()
        end
    end)
end)