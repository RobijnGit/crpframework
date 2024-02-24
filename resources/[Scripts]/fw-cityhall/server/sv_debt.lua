-- Citizen.CreateThread(function()
--     local CurrentTime = os.time() * 1000
--     local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_debt` WHERE `due_date` < @DueDate", {
--         ['@DueDate'] = CurrentTime - 7886400000 -- 3 months
--     })

--     local ConfiscatedProperties = {}

--     for k, v in pairs(Result) do
--         if ConfiscatedProperties[v.citizenid] == nil then ConfiscatedProperties[v.citizenid] = {} end
--         table.insert(ConfiscatedProperties[v.citizenid], {Data = json.decode(v.debt_data), Type = v.asset_type})

--         exports['ghmattimysql']:executeSync("DELETE FROM `phone_debt` WHERE `id` = @Id", {
--             ['@Id'] = v.id
--         })

--         if v.asset_type == 'Housing' then
--             exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `citizenid` = '1001', `keyholders` = '[]' WHERE `adress` = @Adress", {
--                 ['@Adress'] = json.decode(v.debt_data).Name
--             })
--         else
--             exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `citizenid` = '1001' WHERE `plate` = @Plate", {
--                 ['@Plate'] = json.decode(v.debt_data).Plate
--             })
--         end
--     end

--     if #Result > 0 then 
--         local LogMessage = ""

        
--         for k, Properties in pairs(ConfiscatedProperties) do
--             local Player = exports['ghmattimysql']:executeSync("SELECT `cid` FROM `players` WHERE `citizenid` = @Cid", { ["@Cid"] = k })
--             if Player[1] == nil then goto Skip end

--             exports['ghmattimysql']:executeSync("INSERT INTO `phone_messages` (`from_phone`, `to_phone`, `message`) VALUES (@FromPhone, @ToPhone, @Message)", {
--                 ['@FromPhone'] = '0000000001',
--                 ['@ToPhone'] = FW.Functions.GetPlayerPhoneNumber(k),
--                 ['@Message'] = Config.ConfiscateMessage:format(FW.Functions.GetPlayerCharName(k))
--             })
    
--             for i, j in pairs(Properties) do
--                 LogMessage = LogMessage .. "\nOwner: #" .. k .. " - Type: " .. j.Type .. " - Data: " .. json.encode(j.Data)
--             end

--             ::Skip::
--         end
    
--         TriggerEvent("fw-logs:Server:Log", 'debt', "Property/Vehicles Seized", LogMessage, "red")
--     end
-- end)