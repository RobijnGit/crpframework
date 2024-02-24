local VaultCodes, ShuffledVaultCodes, SecurityCode, SuccessHacks = {}, {}, false, 0
local Box = false

-- Callbacks
FW.Functions.CreateCallback("fw-heists:Server:Vault:GetCodeData", function(Source, Cb, Id)
    Cb(VaultCodes[Id] or false)
end)

FW.Functions.CreateCallback("fw-heists:Server:Vault:IsPasswordCorrect", function(Source, Cb, Result)
    if #ShuffledVaultCodes == 0 then
        Cb("Geen Data Gevonden!")
        return
    end

    for k, v in pairs(ShuffledVaultCodes) do
        if v.Letters ~= Result[tostring(k)] then
            Cb("Toegang Geweigerd!")
            return
        end
    end

    SecurityCode = math.random(11111, 9999999)
    Cb("Beveiligingscode: " .. tostring(SecurityCode))
end)

FW.Functions.CreateCallback("fw-heists:Server:IsVaultBox", function(Source, Cb, NetId)
    if not Box then 
        Cb(false)
        return
    end

    Cb(NetId == NetworkGetNetworkIdFromEntity(Box))
end)

FW.Functions.CreateCallback("fw-heists:Server:Vault:IsSecurityCodeCorrect", function(Source, Cb, Code)
    Cb(SecurityCode == Code)
end)

-- Events
FW.RegisterServer("fw-heists:Server:Vault:Reset", function()
    -- Entrances
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_ROOF_ENTRANCE_LEFT', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_ROOF_ENTRANCE_RIGHT', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_SIDE_ENTRANCE_STAFF', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_SIDE_ENTRANCE_STAFF_2ND_FLOOR', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_ROOF_ENTRANCE_TO_COUNTER', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_ROOF_ENTRANCE_TO_2ND_FLOOR', 0)

    -- Counter
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_COUNTER_LEFT', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_COUNTER_RIGHT', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_COUNTER_LEFT_FRONT', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_COUNTER_RIGHT_FRONT', 0)

    -- Offices
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_01', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_02', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_03', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_04', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_05', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_06', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_07', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_OFFICE_08', 0)

    -- Stairs to second level
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_STAIRS_UPPER_LEFT', 0)
    TriggerEvent('fw-doors:Server:SetLockStateById', 'PACIFIC_STAIRS_UPPER_RIGHT', 0)

    math.randomseed(os.time())

    -- Generate Codes for Laptops
    local Codes = GenerateVaultCodes()
    VaultCodes = {}

    for i = 1, 8, 1 do
        local Letters = GenerateRandomVaultLetters()
        VaultCodes[i] = {
            Code = Codes[i] .. '-' .. Letters,
            Numbers = Codes[i],
            Letters = Letters,
        }
    end

    local CidToAdd = nil
    local Player = FW.Functions.GetPlayer(Source)
    if Player then
        CidToAdd = Player.PlayerData.citizenid
    end

    Citizen.SetTimeout((60 * 1000) * 360, function()
        DataManager.Set(GetVaultPrefix() .. "powerbox", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-office", 0)
        DataManager.Set(GetVaultPrefix() .. "office-safe", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-upper", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-hacking-simultaneously", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-gate-hacked", 0)
        DataManager.Set(GetVaultPrefix() .. "lasers-hacked", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-left-hacked", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-right-hacked", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-center-hacked", 0)

        VaultCodes, ShuffledVaultCodes, SecurityCode = {}, {}, false

        if Box then
            DeleteEntity(Box)
            Box = false
        end

        for i = 1, #Config.Vault.Loot, 1 do
            DataManager.Set(GetVaultPrefix() .. "loot-" .. i, 0)
        end

        for k, v in pairs(Config.Vault.DoorIds) do
            TriggerEvent('fw-doors:Server:SetLockStateById', v, 1)
        end

        if CidToAdd then
            IncreaseProgression(CidToAdd, 5)
        end

        print("[HEISTS]: City Vault Reset")
    end)
end)

FW.RegisterServer("fw-heists:Server:Vault:LeftArea", function()
    for i = 1, #Config.Vault.Loot, 1 do
        DataManager.Set(GetVaultPrefix() .. "loot-" .. i, 2)
    end
end)

FW.RegisterServer("fw-heists:Server:Vault:OfficeSafeReward", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    ShuffledVaultCodes = table.shuffle(VaultCodes)
    local Desc = ""

    for k, v in pairs(ShuffledVaultCodes) do
        Desc = Desc .. tostring(k) .. " = " .. tostring(v.Numbers) .. "<br/>"
    end

    Player.Functions.AddItem("heist-safe-codes", 1, false,{
        _Description = Desc
    }, true, nil)
end)

FW.RegisterServer("fw-heists:Server:SuccessGateHack", function(Source)
    SuccessHacks = SuccessHacks + 1

    -- Are hacks simultaneously?
    if DataManager.Get(GetVaultPrefix() .. "vault-hacking-simultaneously", 0) ~= 1 then
        return
    end

    -- Are both hacks done succesfully?
    if SuccessHacks == 2 then
        SuccessHacks = 0
        TriggerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_STAIRS_TO_VAULT_LEFT", 0)
        TriggerEvent("fw-doors:Server:SetLockStateById", "PACIFIC_STAIRS_TO_VAULT_RIGHT", 0)
        DataManager.Set(GetVaultPrefix() .. "vault-gate-hacked", 1)
    else
        DataManager.Set(GetVaultPrefix() .. "vault-gate-hacked", 0)
    end
end)

FW.RegisterServer("fw-heists:Server:Vault:SetBoxCoords", function(Source, Coords, Heading, RemoveItem)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not DoesEntityExist(Box) then
        Box = CreateObjectNoOffset("hei_prop_heist_wooden_box", Coords.x, Coords.y, Coords.z + 0.3, true, true, false)
        FreezeEntityPosition(Box, true)
        SetEntityHeading(Box, Heading)
        return
    end
    
    SetEntityCoords(Box, Coords.x, Coords.y, Coords.z + 0.3)
    SetEntityHeading(Box, Heading)

    print(Coords.x, Coords.y, Coords.z + 0.3)
    print(Heading)

    if RemoveItem then
        Player.Functions.RemoveItem('heist-box', 1, false, true, nil)
    end
end)

FW.RegisterServer("fw-heists:Server:Vault:GetLoot", function(Source, Type, LootId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemByName('heist-drill-hard')
    if Item == nil then return end

    if DataManager.Get(GetVaultPrefix() .. "loot-" .. LootId, 0) ~= 2 then
        return
    end

    if math.random() < 0.6 then
        Player.Functions.AddItem("heist-loot-usb", 1, nil, nil, true)
    end

    local UntrackedChance = math.random(1, 100)
    Player.Functions.AddItem("heist-loot", 1, nil, { Serial = FW.Shared.RandomInt(3) .. "-" .. FW.Shared.RandomStr(3) .. "-" .. FW.Shared.RandomInt(6) .. "-" .. FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(1), Encryption = Config.LootHacks[math.random(1, #Config.LootHacks)] }, true, "tracked")
end)

FW.RegisterServer("fw-heists:Server:Vault:StartLasers", function()
    Citizen.SetTimeout((60 * 1000) * 10, function()
        DataManager.Set(GetVaultPrefix() .. "lasers-hacked", 0)
    end)
end)

RegisterNetEvent("fw-heists:Server:Vault:GrabBox")
AddEventHandler("fw-heists:Server:Vault:GrabBox", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddItem("heist-box", 1, false, false, true, nil)
    local Coords = GetEntityCoords(Box)
    SetEntityCoords(Box, Coords.x, Coords.y, Coords.z - 50.0)
end)

RegisterNetEvent("fw-heists:Server:RegisterVaultHack")
AddEventHandler("fw-heists:Server:RegisterVaultHack", function(Id)
    -- Check if the hacks were started at the same time (with 500ms margin)
    -- If so, the hack is somewhat simultaneously, and will unlock the doors if succeeded.

    if FW.Throttled("heist-vault", 500) then
        DataManager.Set(GetVaultPrefix() .. "vault-hacking-simultaneously", 1)
        SuccessHacks = 0
    end
end)

RegisterNetEvent("fw-heists:Server:Vault:GrabKeycard")
AddEventHandler("fw-heists:Server:Vault:GrabKeycard", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if DataManager.Get(GetVaultPrefix() .. "vault-hacking-simultaneously", 0) ~= 1 then
        return
    end

    if DataManager.Get(GetVaultPrefix() .. "vault-gate-hacked", 0) ~= 1 then
        return
    end

    if DataManager.Get(GetVaultPrefix() .. "keycard-" .. Data.Type, 0) == 1 then
        return
    end

    Player.Functions.AddItem("heist-keycard-vault", 1, false, false, true, nil)
    DataManager.Set(GetVaultPrefix() .. "keycard-" .. Data.Type, 1)
end)


-- Functions
function GenerateVaultCodes()
    local Retval = {}
    local Count = 0

    while Count < 8 do
        local NewCode = ""

        for i = 1, 8 do
            local RandomBit = math.random(0, 1)
            NewCode = NewCode .. tostring(RandomBit)
        end

        local IsUnique = true
        for k, v in ipairs(Retval) do
            if v == NewCode then
                IsUnique = false
                break
            end
        end

        if IsUnique then
            table.insert(Retval, NewCode)
            Count = Count + 1
        end

        Citizen.Wait(0)
    end

    return Retval
end

function GenerateRandomVaultLetters()
    local Alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    local Retval = ''

    for i = 1, 2, 1 do
        local RandomBit = math.random(Alphabet:len())
        local Letter = Alphabet:sub(RandomBit, RandomBit)
        Retval = Retval .. Letter
    end

    return Retval
end

AddEventHandler("onResourceStop", function()
    if Box then
        DeleteEntity(Box)
    end
end)