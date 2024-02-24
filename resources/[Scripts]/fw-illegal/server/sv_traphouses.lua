local RobbedPedIds = {}

Citizen.CreateThread(function()
    while true do

        local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
        local AmountOfTraphouses = #Data.traphouses

        for i = 1, AmountOfTraphouses, 1 do
            local Result = exports['ghmattimysql']:executeSync("SELECT count(item_name) as Amount, item_name as ItemName, custom_type as CustomType, id as Id, info as Info, slot as Slot, MIN(createdate) as CreateDate FROM `player_inventories` WHERE `inventory` = ? GROUP BY SLOT", {"traphouse-" .. i})
            local TraphouseData = Data.traphouses[i]

            for k, ItemData in pairs(Result) do
                if not ItemData then
                    goto Skip
                end

                if ItemData.ItemName == 'markedbills' then
                    local RemoveAmount = math.min(ItemData.Amount, 6)
                    exports['ghmattimysql']:executeSync("DELETE FROM `player_inventories` WHERE `item_name` = ? AND `inventory` = ? LIMIT " .. RemoveAmount, {
                        'markedbills',
                        'traphouse-' .. i
                    })

                    TraphouseData.cash = TraphouseData.cash + (415 * RemoveAmount)
                elseif ItemData.ItemName == 'money-roll' then
                    local RemoveAmount = math.min(ItemData.Amount, 9)
                    exports['ghmattimysql']:executeSync("DELETE FROM `player_inventories` WHERE `item_name` = ? AND `inventory` = ? LIMIT " .. RemoveAmount, {
                        'money-roll',
                        'traphouse-' .. i
                    })

                    TraphouseData.cash = TraphouseData.cash + (250 * RemoveAmount)
                end

                ::Skip::
            end

            Citizen.Wait(1000)
        end

        exports['fw-config']:SetConfigValue("traphouses", "traphouses", Data.traphouses)

        Citizen.Wait((60 * 1000) * 5)
    end
end)

FW.Functions.CreateCallback("fw-illegal:Server:CanDoTraphouseTakeover", function(Source, Cb, TraphouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return Cb(false) end

    local TraphouseData = Data.traphouses[TraphouseId]
    if not TraphouseData then return Cb(false) end

    if Player.PlayerData.money.cash < 5000 then
        return Cb(false)
    end

    -- if the traphouse is unclaimed, return true.
    if TraphouseData.owner == "Unclaimed" then
        return Cb(true)
    end

    -- If the traphouse is claimed, return true if the owner is online.
    local Target = FW.Functions.GetPlayerByCitizenId(TraphouseData.owner)
    if Target == nil then
        return Cb(false)
    end

    -- Send a mail to the traphouse owner about the takeover.
    TriggerEvent('fw-phone:Server:Mails:AddMail', "Dark Market", "Traphouse Takeover", "Er probeert iemand een van je traphouses over te nemen!", Target.PlayerData.source)
    Cb(true)
end)

FW.Functions.CreateCallback("fw-illegal:Server:CheckTraphouseCode", function(Source, Cb, TraphouseId, Code)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return Cb(false) end

    local TraphouseData = Data.traphouses[TraphouseId]
    if not TraphouseData then return Cb(false) end

    Cb(TraphouseData.code == Code)
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetTraphouseData", function(Source, Cb, TraphouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return Cb(false) end

    local TraphouseData = Data.traphouses[TraphouseId]
    if not TraphouseData then return Cb(false) end

    Cb(TraphouseData)
end)

FW.RegisterServer("fw-illegal:Server:RobTraphouseCode", function(Source, TraphouseId, PedNetId)
    if RobbedPedIds[PedNetId] ~= nil then
        return
    end

    RobbedPedIds[PedNetId] = true

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return end

    local TraphouseData = Data.traphouses[TraphouseId]
    if not TraphouseData then return end

    if math.random(100) > 95 then
        return Player.Functions.Notify("De persoon kijkt je bang aan en zegt dat hij niks heeft..", "error")
    end

    local MyCoords = GetEntityCoords(GetPlayerPed(Source))
    local DistanceToTraphouse = #(MyCoords - vector3(TraphouseData.x, TraphouseData.y, TraphouseData.z))

    if DistanceToTraphouse > 50.0 then
        local Reward = math.random(5, 100)
        Player.Functions.AddMoney("cash", Reward, "Traphouse NPC Robbery")

        return Player.Functions.Notify("De persoon kijkt je bang aan en zegt dat hij niks heeft..", "error")
    end

    Player.Functions.Notify("De persoon kijkt je bang aan en overhandigt je een briefje met '" .. TraphouseData.code .. "' erop..", "primary", 12000)
end)

FW.RegisterServer("fw-illegal:Server:RobNPC", function(Source, PedNetId)
    if RobbedPedIds[PedNetId] ~= nil then
        return
    end

    RobbedPedIds[PedNetId] = true

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Reward = math.random(10, 200)
    Player.Functions.AddMoney("cash", Reward, "Traphouse NPC Robbery")
end)

FW.RegisterServer("fw-illegal:Server:TakeoverTraphouse", function(Source, TraphouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return end

    Data.traphouses[TraphouseId].owner = Player.PlayerData.citizenid

    exports['fw-config']:SetConfigValue("traphouses", "traphouses", Data.traphouses)
end)

FW.RegisterServer("fw-illegal:Server:TakeTraphouseCash", function(Source, TraphouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return end

    if Data.traphouses[TraphouseId].owner ~= Player.PlayerData.citizenid then
        return
    end

    Player.Functions.AddMoney("cash", Data.traphouses[TraphouseId].cash)

    Data.traphouses[TraphouseId].cash = 0
    exports['fw-config']:SetConfigValue("traphouses", "traphouses", Data.traphouses)
end)

FW.RegisterServer("fw-illegal:Server:ChangeTraphouseCode", function(Source, TraphouseId, Code)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return end

    if Data.traphouses[TraphouseId].owner ~= Player.PlayerData.citizenid then
        return
    end

    Data.traphouses[TraphouseId].code = Code
    exports['fw-config']:SetConfigValue("traphouses", "traphouses", Data.traphouses)
end)