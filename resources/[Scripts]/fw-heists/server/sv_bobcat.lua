local WeaponCrates = {
    'weapon_heavypistol',
    'weapon_fn502',
    'weapon_diamond',
    'weapon_beretta',
    'weapon_mac10'
    -- 'weapon_m70',
}

FW.RegisterServer("fw-heists:Server:Bobcat:Reset", function(Source)
    local CidToAdd = nil
    local Player = FW.Functions.GetPlayer(Source)
    if Player then
        CidToAdd = Player.PlayerData.citizenid
    end

    StartGlobalCooldown()
    Citizen.SetTimeout((60 * 1000) * 300, function()
        DataManager.Set(GetBobcatPrefix() .. "front-doors", 0)
        DataManager.Set(GetBobcatPrefix() .. "vault", 0)
        for i = 1, 3, 1 do
            DataManager.Set(GetBobcatPrefix() .. "crate-" .. i, 0)
        end
        
        for k, v in pairs(Config.Bobcat.DoorIds) do
            TriggerEvent('fw-doors:Server:SetLockStateById', v, 1)
        end

        if CidToAdd then
            IncreaseProgression(CidToAdd, 5)
        end

        print("[HEISTS]: Bobcat Reset")
    end)
end)

RegisterNetEvent("fw-heists:Server:Bobcat:Explosion")
AddEventHandler("fw-heists:Server:Bobcat:Explosion", function()
    DataManager.Set(GetBobcatPrefix() .. "vault", 1)
    TriggerClientEvent("fw-heists:Client:BobcatVaultExplosion", -1)
    TriggerClientEvent("fw-heists:Client:SetBobcatEntityset", -1, true)
end)

RegisterNetEvent("fw-heists:Server:SpawnBobcatSecurity")
AddEventHandler("fw-heists:Server:SpawnBobcatSecurity", function()
    local Source = source
    local NetIds = {}

    for k, v in pairs(Config.Bobcat.Security) do
        local Ped = CreatePed(7, 'ig_casey', v.x, v.y, v.z, v.w, true, false)
        while not DoesEntityExist(Ped) do Citizen.Wait(4) end

        local NetId = NetworkGetNetworkIdFromEntity(Ped)
        NetIds[#NetIds + 1] = NetId

        SetEntityHeading(Ped, v.w)
    end

    TriggerClientEvent("fw-heists:Client:SetBobcatSecurityAttrs", -1, NetIds, Source)
end)

FW.RegisterServer("fw-heists:Server:Bobcat:Loot", function(Source, CrateId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if DataManager.Get(GetBobcatPrefix() .. "vault", 0) == 0 then
        return
    end

    if DataManager.Get(GetBobcatPrefix() .. "crate-" .. CrateId, 0) ~= 2 then
        return
    end

    for i = 1, math.random(1, 4), 1 do
        local Info = {
            Serial = FW.Shared.RandomInt(4) .. '-' .. FW.Shared.RandomStr(4) .. '-' .. FW.Shared.RandomInt(3),
            Ammo = 0
        }
        Player.Functions.AddItem(WeaponCrates[math.random(1, #WeaponCrates)], 1, false, Info, true)
    end

    math.randomseed(os.time())
    if math.random() > 0.5 then
        if math.random(1, 100) > 76 and math.random(1, 100) < 77 then
            local Info = {
                Serial = FW.Shared.RandomInt(4) .. '-' .. FW.Shared.RandomStr(4) .. '-' .. FW.Shared.RandomInt(3),
                Ammo = 0
            }
            Player.Functions.AddItem("weapon_stickybomb", 1, false, Info, true)
        end
    end
end)