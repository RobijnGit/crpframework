-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(4)

--         local Players = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `metadata` FROM `players`", {})
--         if Players == nil or Players[1] == nil then goto Skip end

--         for k, v in pairs(Players) do
--             local Player = FW.Functions.GetPlayerByCitizenId(v.citizenid)
--             if Player == nil then
--                 local MetaData = json.decode(v.metadata)
--                 if MetaData ~= nil and MetaData['jailtime'] ~= nil and (MetaData['jailtime'] - 1) > 0 then
--                     MetaData['jailtime'] = MetaData['jailtime'] - 1
--                     exports['ghmattimysql']:execute("UPDATE `players` SET `metadata` = @MetaData WHERE `citizenid` = @Cid", {
--                         ['@MetaData'] = json.encode(MetaData),
--                         ['@Cid'] = v.citizenid,
--                     })
--                 end
--             else
--                 local JailTime = Player.PlayerData.metadata['jailtime']
--                 if (JailTime - 1) > 0 then
--                     JailTime = JailTime - 1
--                     Player.Functions.SetMetaData("jailtime", JailTime)
--                 end
--             end
--         end
    
--         ::Skip::
--         Citizen.Wait(1000 * 60)
--     end
-- end)

-- Citizen.CreateThread(function()
--     while true do
--         Citizen.Wait(4)

--         local Players = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `metadata` FROM `players`", {})
--         if Players == nil or Players[1] == nil then goto Skip end

--         for k, v in pairs(Players) do
--             local Player = FW.Functions.GetPlayerByCitizenId(v.citizenid)
--             if Player == nil then
--                 -- local MetaData = json.decode(v.metadata)
--                 -- if MetaData ~= nil and MetaData['jailtime'] ~= nil and (MetaData['jailtime']) == 0 then
--                 --     if MetaData['paroletime'] ~= nil and (MetaData['paroletime'] - 1) > 0 then
--                 --         MetaData['paroletime'] = MetaData['paroletime'] - 1
--                 --         exports['ghmattimysql']:execute("UPDATE `players` SET `metadata` = @MetaData WHERE `citizenid` = @Cid", {
--                 --             ['@MetaData'] = json.encode(MetaData),
--                 --             ['@Cid'] = v.citizenid,
--                 --         })
--                 --     end
--                 -- end
--             else
--                 if Player.PlayerData.metadata['jailtime'] == 0 then
--                     local paroletime = Player.PlayerData.metadata['paroletime']
--                     if (paroletime - 1) >= 0 then
--                         paroletime = paroletime - 1
--                         Player.Functions.SetMetaData("paroletime", paroletime)
--                     end
--                 end
--             end
--         end
    
--         ::Skip::
--         Citizen.Wait(1000 * 60)
--     end
-- end)

-- FW.Commands.Add("jail", "Stuur een crimineel naar de gevangenis.", {
--     { name = "id", help = "Speler ID" },
--     { name = "tijd", help = "Hoelang de crimineel moet wegrotten" },
--     { name = "voorwaardelijk", help = "Hoeveel maanden voorwaardelijk?" }
-- }, true, function(Source, Args)
--     local Player = FW.Functions.GetPlayer(Source)
--     if Player == nil then return end
--     if Player.PlayerData.job.name ~= "police" or not Player.PlayerData.job.onduty then return Player.Functions.Notify("Alleen de Politie mag crimineeltjes wegsturen..", "error") end

--     local TPlayer = FW.Functions.GetPlayer(tonumber(Args[1]))
--     if TPlayer == nil then return end

--     local Time = tonumber(Args[2])
--     if not Time or Time == 0 then return Player.Functions.Notify("Misschien ietsjes meer dan 0 maandjes?", "error") end

--     if TPlayer.PlayerData.metadata.paroletime > 0 then
--         Time = Time + TPlayer.PlayerData.metadata.paroletime
--     end

--     local Parole = tonumber(Args[3])
--     if not Parole or Parole < 0 then return Player.Functions.Notify("Minstens 0 maanden voorwaardelijk!", "error") end

--     TPlayer.Functions.SetMetaData("paroletime", Parole)
--     TPlayer.Functions.SetMetaData("jailtime", Time)
--     TriggerClientEvent("fw-assets:Client:JailMugshot", TPlayer.PlayerData.source, TPlayer.PlayerData.charinfo.firstname .. " " .. TPlayer.PlayerData.charinfo.lastname, Time, TPlayer.PlayerData.citizenid, os.date('%d-'..'%m-'..'%y'))
-- end)

-- FW.Commands.Add("prison:setTime", "Zet iemand zijn gevangenis staf (ADMIN)", {
--     { name = "id", help = "Speler ID" },
--     { name = "tijd", help = "Hoelang de crimineel moet wegrotten" }
-- }, true, function(Source, Args)
--     local Player = FW.Functions.GetPlayer(Source)
--     if Player == nil then return end

--     local TPlayer = FW.Functions.GetPlayer(tonumber(Args[1]))
--     if TPlayer == nil then return end

--     local Time = tonumber(Args[2])
--     TPlayer.Functions.SetMetaData("jailtime", Time)
-- end, "admin")

-- RegisterNetEvent("fw-police:Server:ResetJailTime")
-- AddEventHandler("fw-police:Server:ResetJailTime", function()
--     local Source = source
--     local Player = FW.Functions.GetPlayer(Source)
--     if Player == nil then return end

--     if Player.PlayerData.metadata.jailtime > 1 then
--         return
--     end
    
--     Player.Functions.SetMetaData("jailtime", 0)
-- end)

-- RegisterNetEvent("fw-police:Server:ReduceJailTime")
-- AddEventHandler("fw-police:Server:ReduceJailTime", function(Reduction)
--     local Source = source
--     local Player = FW.Functions.GetPlayer(Source)
--     if Player == nil then return end

--     if (Player.PlayerData.metadata.jailtime - Reduction) > 1 then
--         Player.Functions.SetMetaData("jailtime", Player.PlayerData.metadata.jailtime - Reduction)
--     end
-- end)

-- RegisterNetEvent("fw-police:Server:ReceiveJailItem")
-- AddEventHandler("fw-police:Server:ReceiveJailItem", function(Item)
--     local Source = source
--     local Player = FW.Functions.GetPlayer(Source)
--     if Player == nil then return end

--     -- Just in case if anyone thinks, 'cool, i can use that event to spawn an item.'.
--     -- They still can - but they would need to be jailed for it, I don't see anyone doing that whilst in jail..
--     -- Not auto-banning, in case of false positives.
--     if Player.PlayerData.metadata.jailtime <= 0 then
--         return
--     end

--     Player.Functions.AddItem(Item, 1, false, nil, true)
-- end)