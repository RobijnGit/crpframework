local StageInterval = 8 -- Interval in minutes.
local Plants = {}

-- RegisterCommand("getSeeds", function(Source)
--     local Player = FW.Functions.GetPlayer(Source)

--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Cabbage")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Carrot")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Corn")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Cucumber")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Garlic")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Onion")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Potato")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Pumpkin")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Radish")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "RedBeet")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Sunflower")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Tomato")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Watermelon")
--     Player.Functions.AddItem("farming-seed", 10, nil, nil, true, "Wheat")
-- end)

Citizen.CreateThread(function()
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_crops`")
    for k, v in pairs(Result) do
        local Pos = json.decode(v.coords)
        table.insert(Plants, {
            Id = v.id,
            Cid = v.cid,
            Plant = v.plant,
            Coords = vector4(Pos.x, Pos.y, Pos.z, Pos.w),
            Stage = v.stage,
            Water = v.water,
        })
    end

    while true do
        Citizen.Wait((1000 * 60) * StageInterval)

        local Changes = 0
        for k, v in pairs(Plants) do
            local TotalStages = #Config.FarmCrops[v.Plant]

            if (v.Water > 10 or v.Stage + 1 == TotalStages) and Config.FarmCrops[v.Plant][v.Stage + 1] ~= nil then
                v.Stage = v.Stage + 1
                Changes = Changes + 1

                exports['ghmattimysql']:executeSync("UPDATE player_crops SET stage = ? WHERE id = ?", {v.Stage, v.Id})
            end
        end

        -- if Changes > 0 then
        --     TriggerClientEvent("fw-misc:Client:RefetchPlants", -1, Plants)
        -- end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait((1000 * 60) * 2)

        local Changes = 0
        for k, v in pairs(Plants) do
            local TotalStages = #Config.FarmCrops[v.Plant]

            if v.Water > 0 then
                v.Water = math.max(v.Water - 10, 0)
                Changes = Changes + 1
                exports['ghmattimysql']:executeSync("UPDATE player_crops SET water = ? WHERE id = ?", {v.Water, v.Id})
            end
        end

        -- if Changes > 0 then
        --     TriggerClientEvent("fw-misc:Client:RefetchPlants", -1, Plants)
        -- end
    end
end)

function CreatePlant(Cid, Coords, Rotation, PlantType)
    local Result = exports['ghmattimysql']:executeSync("INSERT INTO `player_crops` (`cid`, `plant`, `coords`, `stage`, `water`) VALUES (?, ?, ?, ?, ?)", {
        Cid,
        PlantType,
        json.encode({x = Coords.x, y = Coords.y, z = Coords.z, w = Rotation}),
        1,
        10
    })

    if not Result.insertId or Result.insertId <= 0 then return end

    local PlantData = {
        Id = Result.insertId,
        Cid = Cid,
        Plant = PlantType,
        Coords = vector4(Coords.x, Coords.y, Coords.z, Rotation),
        Stage = 1,
        Water = 10,
    }
    table.insert(Plants, PlantData)

    TriggerClientEvent("fw-misc:Client:UpdatePlants", -1, Result.insertId, PlantData)
end

function RemovePlant(PlantId)
    exports['ghmattimysql']:executeSync("DELETE FROM `player_crops` WHERE `id` = ?", {PlantId})

    local Key = GetPlantKey(PlantId)
    if not Key then return end
    table.remove(Plants, Key)

    TriggerClientEvent("fw-misc:Client:RemovePlant", -1, PlantId)
end

FW.Functions.CreateCallback("fw-misc:Server:GetNearbyPlants", function(Source, Cb, Coords)
    local Retval = {}

    for k, v in pairs(Plants) do
        local Distance = #(vector3(v.Coords.x, v.Coords.y, v.Coords.z) - Coords)
        if Distance < 65.0 then
            table.insert(Retval, v)
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-misc:Server:Farming:GetStock", function(Source, Cb, Category)
    Cb(Config.FarmStock[Category].Stock)
end)

FW.Functions.CreateCallback("fw-misc:Server:GetPlants", function(Source, Cb)
    Cb(Plants)
end)

FW.Functions.CreateCallback("fw-misc:Server:GetGardenRenter", function(Source, Cb, GardenId)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `farms_gardens` WHERE `garden_id` = ?", {GardenId})
    if not Result[1] or Result[1].cid == nil then
        Cb(false)
        return
    end

    if os.time() > Result[1].timestamp then
        Cb(false)
        return
    end

    Cb(Result[1].cid)
end)

FW.Functions.CreateCallback("fw-misc:Server:IsGardenRentable", function(Source, Cb, GardenId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `farms_gardens` WHERE `garden_id` = ?", {GardenId})
    if not Result[1] or Result[1].cid == nil then
        Cb(true)
        return
    end

    if os.time() > Result[1].timestamp then
        Cb(true)
        return
    end

    Cb(false)
end)

FW.RegisterServer("fw-misc:Server:Farming:PlacePlant", function(Source, Coords, Rotation, PlantType)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    CreatePlant(Player.PlayerData.citizenid, Coords, Rotation, PlantType)
end)

FW.RegisterServer("fw-misc:Server:Farming:RentGarden", function(Source, GardenId, RentPrice, Hours)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- Does the player have 2 gardens claimed?
    local PlayerGardens = exports['ghmattimysql']:executeSync("SELECT * FROM `farms_gardens` WHERE `cid` = ? AND `timestamp` > ?", {Player.PlayerData.citizenid, os.time()})
    if #PlayerGardens + 1 > 2 then
        return Player.Functions.Notify("Je kan maar maximaal 2 moestuintjes huren tegelijkertijd!", "error")
    end

    if not exports['fw-financials']:RemoveMoneyFromAccount('1001', '1', Player.PlayerData.charinfo.account, RentPrice, "PURCHASE", "Tuin (#" .. GardenId .. ") gehuurd voor " .. Hours .. " uur.") then
        return Player.Functions.Notify("Je hebt niet genoeg banksaldo..", "error")
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `farms_gardens` WHERE `garden_id` = ?", {GardenId})
    if not Result[1] then
        exports['ghmattimysql']:executeSync("INSERT INTO `farms_gardens` VALUES (?, ?, ?)", {
            GardenId,
            Player.PlayerData.citizenid,
            os.time() + (3600 * Hours)
        })
    else
        exports['ghmattimysql']:executeSync("UPDATE `farms_gardens` SET `cid` = ?, `timestamp` = ? WHERE `garden_id` = ?", {
            Player.PlayerData.citizenid,
            os.time() + (3600 * Hours),
            GardenId
        })
    end

    Player.Functions.Notify("Moestuintje gehuurd voor " .. Hours .. " uur!")
end)

RegisterNetEvent("fw-misc:Server:PurchaseStock")
AddEventHandler("fw-misc:Server:PurchaseStock", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Stock = Config.FarmStock[Data.Category].Stock < 40 and Config.FarmStock[Data.Category].Stock or 40

    if Data.IsPrison or Player.Functions.RemoveMoney('cash', Stock * 8, 'Farming Stock') then
        if Data.Category == "cream" or Data.Category == "beans" or Data.Category == "dairy" then
            Player.Functions.AddItem('ingredient', Stock, nil, nil, true, Config.FarmStock[Data.Category].Item)
        else
            Player.Functions.AddItem('farming-seed', Stock, nil, nil, true, Config.FarmStock[Data.Category].Item)
        end

        if not Data.IsPrison then
            Config.FarmStock[Data.Category].Stock = Config.FarmStock[Data.Category].Stock - Stock
        end
    else
        Player.Functions.Notify("Niet genoeg cash..", "error")
    end
end)

RegisterNetEvent("fw-misc:Server:Farm:PurchaseSeedbag")
AddEventHandler("fw-misc:Server:Farm:PurchaseSeedbag", function(args)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Price = 1180
    if #(GetEntityCoords(GetPlayerPed(Source)) - vector3(1706.82, 2552.14, 44.55)) < 10.0 then
        Price = 80
    end

    if Player.Functions.RemoveMoney('cash', Price, 'Farming Stock') then
        Player.Functions.AddItem('farming-seedbag', 1, nil, nil, true)
    else
        Player.Functions.Notify("Niet genoeg cash..", "error")
    end
end)

RegisterNetEvent("fw-misc:Server:Farm:PurchaseProduceBasket")
AddEventHandler("fw-misc:Server:Farm:PurchaseProduceBasket", function(args)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Price = 1325
    if #(GetEntityCoords(GetPlayerPed(Source)) - vector3(1706.82, 2552.14, 44.55)) < 10.0 then
        Price = 80
    end

    if Player.Functions.RemoveMoney('cash', Price, 'Farming Stock') then
        Player.Functions.AddItem('producebasket', 1, nil, nil, true)
    else
        Player.Functions.Notify("Niet genoeg cash..", "error")
    end
end)

RegisterNetEvent("fw-misc:Server:Farm:PurchaseWateringCan")
AddEventHandler("fw-misc:Server:Farm:PurchaseWateringCan", function(args)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Price = 720
    if #(GetEntityCoords(GetPlayerPed(Source)) - vector3(1706.82, 2552.14, 44.55)) < 10.0 then
        Price = 50
    end

    if Player.Functions.RemoveMoney('cash', Price, 'Farming Stock') then
        Player.Functions.AddItem('farming-wateringcan', 1, nil, nil, true)
    else
        Player.Functions.Notify("Niet genoeg cash..", "error")
    end
end)

RegisterNetEvent("fw-misc:Server:Farm:PurchasePitchfork")
AddEventHandler("fw-misc:Server:Farm:PurchasePitchfork", function(args)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Price = 1000
    if #(GetEntityCoords(GetPlayerPed(Source)) - vector3(1706.82, 2552.14, 44.55)) < 10.0 then
        Price = 300
    end

    if Player.Functions.RemoveMoney('cash', Price, 'Farming Stock') then
        Player.Functions.AddItem('farming-pitchfork', 1, nil, nil, true)
    else
        Player.Functions.Notify("Niet genoeg cash..", "error")
    end
end)

RegisterNetEvent("fw-misc:Server:Farm:PurchaseHoe")
AddEventHandler("fw-misc:Server:Farm:PurchaseHoe", function(args)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Price = 1000
    if #(GetEntityCoords(GetPlayerPed(Source)) - vector3(1706.82, 2552.14, 44.55)) < 10.0 then
        Price = 300
    end

    if Player.Functions.RemoveMoney('cash', Price, 'Farming Stock') then
        Player.Functions.AddItem('farming-hoe', 1, nil, nil, true)
    else
        Player.Functions.Notify("Niet genoeg cash..", "error")
    end
end)

RegisterNetEvent("fw-misc:Server:Farming:WaterPlant")
AddEventHandler("fw-misc:Server:Farming:WaterPlant", function(PlantId)
    local Key = GetPlantKey(PlantId)
    if not Key then return end

    local PlantData = Plants[Key]
    PlantData.Water = PlantData.Water + 25
    exports['ghmattimysql']:executeSync("UPDATE player_crops SET water = ? WHERE id = ?", {PlantData.Water, PlantData.Id})
    TriggerClientEvent("fw-misc:Client:UpdatePlants", -1, PlantId, PlantData)
end)

RegisterNetEvent("fw-misc:Server:Farming:DestroyCrop")
AddEventHandler("fw-misc:Server:Farming:DestroyCrop", function(PlantId)
    RemovePlant(PlantId)
end)

RegisterNetEvent("fw-misc:Server:Farming:HarvestPlant")
AddEventHandler("fw-misc:Server:Farming:HarvestPlant", function(PlantId)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Key = GetPlantKey(PlantId)
    if not Key then return end

    local PlantData = Plants[Key]
    RemovePlant(PlantId)

    local TotalStages = #Config.FarmCrops[PlantData.Plant] - 1
    if PlantData.Stage == TotalStages then
        Player.Functions.AddItem("ingredient", math.random(50, 70), false, nil, true, PlantData.Plant)
        if math.random(1, 100) >= 65 then
            Player.Functions.AddItem("farming-seed", math.random(1, 2), false, nil, true, PlantData.Plant)
        end
    end
end)

RegisterNetEvent("fw-misc:Server:Farming:SetWateringCanCapacity")
AddEventHandler("fw-misc:Server:Farming:SetWateringCanCapacity", function(Slot, Capacity)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.SetItemKV('farming-wateringcan', Slot, "Capacity", Capacity)
end)

-- Utils

function GetPlantKey(PlantId)
    for k, v in pairs(Plants) do
        if v.Id == PlantId then
            return k
        end
    end
    return false
end