FW.RegisterServer('fw-heists:Server:Jewelry:Reset', function(Source, VitrineId)
    local CidToAdd = nil
    local Player = FW.Functions.GetPlayer(Source)
    if Player then
        CidToAdd = Player.PlayerData.citizenid
    end

    StartGlobalCooldown()
    Citizen.SetTimeout((60 * 1000) * 90, function()
        DataManager.Set(GetJewelryPrefix() .. "powerbox", 0)
        DataManager.Set(GetJewelryPrefix() .. "sec-system", 0)
        for i = 1, 13, 1 do
            DataManager.Set(GetJewelryPrefix() .. "vitrine-" .. i, 0)
        end

        for k, v in pairs(Config.Jewelry.DoorIds) do
            TriggerEvent('fw-doors:Server:SetLockStateById', v, 1)
        end

        if CidToAdd then
            IncreaseProgression(CidToAdd, 5)
        end

        print("[HEISTS]: Jewelry Reset")
    end)
end)

FW.RegisterServer('fw-heists:Server:Jewelry:LeftArea', function(Source)
    for i = 1, 13, 1 do
        DataManager.Set(GetJewelryPrefix() .. "vitrine-" .. i, 2)
    end
end)

FW.RegisterServer('fw-heists:Server:Jewelry:Reward', function(Source, VitrineId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if DataManager.Get(GetJewelryPrefix() .. "powerbox", 0) ~= 1 then return end
    if DataManager.Get(GetJewelryPrefix() .. "sec-system", 0) ~= 1 then return end
    if DataManager.Get(GetJewelryPrefix() .. "vitrine-" .. VitrineId, 0) ~= 2 then return end

    local Random = math.random()
    if Random < 0.15 then
        Player.Functions.AddItem("goldbar", math.random(1, 5), false, nil, true)
        Citizen.Wait(300)
        Player.Functions.AddItem("rolex", math.random(8, 13), false, nil, true)
    elseif Random > 0.15 and Random < 0.25 then
        Player.Functions.AddItem("rolex", math.random(10, 17), false, nil, true)
    else
        Player.Functions.AddItem("rolex", math.random(30, 40), false, nil, true)
    end
end)