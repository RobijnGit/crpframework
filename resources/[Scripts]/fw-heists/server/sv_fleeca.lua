FW.RegisterServer("fw-heists:Server:Fleeca:Reset", function(Source, FleecaId)
    if Config.Fleeca[FleecaId] == nil then return end

    local CidToAdd = nil
    local Player = FW.Functions.GetPlayer(Source)
    if Player then
        CidToAdd = Player.PlayerData.citizenid
    end

    Config.Fleeca[FleecaId].Robber = CidToAdd
    
    StartGlobalCooldown()
    Citizen.SetTimeout((60 * 1000) * 90, function()
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "powerbox", 0)
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "vault", 0)
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "vault-gate", 0)
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "door-lockpicked", 0)

        for i = 1, 5, 1 do
            DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. i, 0)
        end

        for k, v in pairs(Config.Fleeca[FleecaId].DoorIds) do
            TriggerEvent('fw-doors:Server:SetLockStateById', v, 1)
        end

        if CidToAdd then
            IncreaseProgression(CidToAdd, 5)
            Config.Fleeca[FleecaId].Robber = nil
        end

        print("[HEISTS]: Fleeca " .. tostring(FleecaId) .. " Reset")
    end)
end)

FW.RegisterServer("fw-heists:Server:Fleeca:GetLoot", function(Source, FleecaId, LootId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemByName('heist-drill-basic')
    if Item == nil then return end

    if DataManager.Get(GetFleecaPrefix(FleecaId) .. "loot-" .. LootId, 0) ~= 2 then
        return
    end

    if math.random() < 0.3 then
        Player.Functions.AddItem("heist-loot-usb", 1, nil, nil, true)
    end

    local UntrackedChance = math.random(1, 100)
    Player.Functions.AddItem("heist-loot", 1, nil, { Serial = FW.Shared.RandomInt(3) .. "-" .. FW.Shared.RandomStr(3) .. "-" .. FW.Shared.RandomInt(6) .. "-" .. FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(1), Encryption = Config.LootHacks[math.random(1, #Config.LootHacks)] }, true, (UntrackedChance >= 45 and UntrackedChance <= 50) and "" or "tracked")
end)

-- FW.RegisterServer("fw-heists:Server:Fleeca:ForceReset", function(Source, FleecaId)
--     if Config.Fleeca[FleecaId] == nil then return end

--     local Player = FW.Functions.GetPlayer(Source)
--     if Player == nil then return end

--     if Player.PlayerData.job.name ~= 'police' then return end

--     for i = 1, 5, 1 do
--         DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. i, 2)
--     end

--     local RobberCid = Config.Fleeca[FleecaId].Robber
--     if RobberCid then
--         DecreaseProgression(Config.Fleeca[FleecaId].Robber, 15)
--         Config.Fleeca[FleecaId].Robber = nil
--     end

--     Player.Functions.Notify("Bankalarm ingeschakeld.", "success")

--     print(("[HEISTS]: Fleeca " .. tostring(FleecaId) .. " Reset (Forced by %s)"):format(Player.PlayerData.citizenid))
--     TriggerEvent('fw-logs:Server:Log', 'police', 'Fleeca Reset', ("User: [%s] - %s - %s %s\nFleeca ID: %s\nRobber: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, FleecaId, RobberCid or 'unknown'), 'error')
-- end)

FW.RegisterServer("fw-heists:Server:Fleeca:LeftArea", function(Source, FleecaId)
    if Config.Fleeca[FleecaId] == nil then return end

    for i = 1, 5, 1 do
        DataManager.Set(GetFleecaPrefix(FleecaId) .. "loot-" .. i, 2)
    end
end)