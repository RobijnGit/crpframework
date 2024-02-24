-- // Startup \\ --

Citizen.CreateThread(function()
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_plants`", {})
    if Result ~= nil and Result[1] ~= nil then
        for k, v in pairs(Result) do
            local Coords = json.decode(v.coords)
            table.insert(Config.WeedPlants, {
                Id = v.id, 
                Type = v.type, 
                Stage = v.stage, 
                Health = v.health, 
                Water = v.water, 
                Fertilizer = v.fertilizer, 
                Pregnant = v.pregnant,
                Coords = {
                    X = Coords.X, 
                    Y = Coords.Y, 
                    Z = Coords.Z
                }
            })
        end
    end
end)

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        UpdateAllPlants(false)
        Citizen.Wait((1000 * 60) * 3) -- 3 Mins update all plants to db
    end
end)

-- Update Config to players.
-- Citizen.CreateThread(function()
--     while true do
--         TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 1, Config.WeedPlants)
--         Citizen.Wait((1000 * 60) * 1.5) -- 3 Mins update all plants to db
--     end
-- end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        for k, v in pairs(Config.WeedPlants) do
            if v.Water - 2 > 0 then
                v.Water = v.Water - math.random(1,3)
            else
                v.Water = 0
            end 
            if v.Fertilizer - 2 > 0 then
                v.Fertilizer = v.Fertilizer - math.random(1,3)
            else
                v.Fertilizer = 0
            end 
            if v.Stage + 1 < 100 then
                v.Stage = v.Stage + 1
            else
                v.Stage = 100
            end
            if v.Water == 0 then
                if v.Health - math.random(1,5) > 0 then
                    v.Health = v.Health - math.random(1,5)
                else
                    v.Health = 0
                end
            elseif v.Water > 55 then
                if  v.Health < 40 then
                    v.Health = v.Health + math.random(1,5)
                end
            end
        end
        UpdateAllPlants(true)
        Citizen.Wait((1000 * 60) * 4.2) -- 5 Mins update every plant
    end
end)

-- // Events \\ --

RegisterServerEvent('fw-illegal:Server:Do:Plant:Stuff')
AddEventHandler('fw-illegal:Server:Do:Plant:Stuff', function(Type, PlantId, Data)
    local PlantKey = GetPlantKeyByPlantId(PlantId)
    local PlantData = Config.WeedPlants[PlantKey]
    if PlantData ~= nil then
        if Type == 'Water' then
            if PlantData.Water + Data < 100 then
                PlantData.Water = PlantData.Water + Data
            else
                PlantData.Water = 100
            end
            TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 3, PlantData)
        elseif Type == 'Fertilizer' then
            if PlantData.Fertilizer + Data < 100 then
                PlantData.Fertilizer = PlantData.Fertilizer + Data
            else
                PlantData.Fertilizer = 100
            end
            TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 3, PlantData)
        elseif Type == 'Pregnant' then
            PlantData.Pregnant = 'True'
            TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 3, PlantData)
        elseif Type == 'Harvest' then
            local Player = FW.Functions.GetPlayer(source)
            local CalculatedWeedQuality = CalculateWeedQuality(PlantData.Health)
            if Player.Functions.AddItem('weed-branch', 1, false, {WeedQuality = CalculatedWeedQuality}, true) then
                if PlantData.Pregnant == 'True' and math.random(1,100) <= math.random(1,45) then
                    if math.random(1,2) == 1 then
                        Player.Functions.AddItem('weed-seed-female', math.random(1,3), false, nil, true)
                    else
                        Player.Functions.AddItem('weed-seed-male', math.random(1,3), false, nil, true)
                    end
                end
                exports['ghmattimysql']:executeSync('DELETE FROM `player_plants` WHERE `id` = @Id', {['@Id'] = PlantData.Id})
                TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 4, PlantData)
                Config.WeedPlants[PlantKey] = nil
                TriggerEvent('fw-logs:Server:Log', 'weed', 'Plant Harvested', ("User: [%s] - %s - %s\nPlant ID: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, PlantId), 'orange')
            end
        elseif Type == 'Destroy' then
            local Player = FW.Functions.GetPlayer(source)

            exports['ghmattimysql']:executeSync('DELETE FROM `player_plants` WHERE `id` = @Id', {['@Id'] = PlantData.Id})
            TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 4, PlantData)
            Config.WeedPlants[PlantKey] = nil
            
            TriggerEvent('fw-logs:Server:Log', 'weed', 'Plant Destroyed', ("User: [%s] - %s - %s\nPlant ID: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, PlantId), 'red')
        end
    end
end)

RegisterNetEvent("fw-illegal:Server:Plants:Plant")
AddEventHandler("fw-illegal:Server:Plants:Plant", function(Coords)
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    local NewPlantData = { Id = math.random(11111,99999), Type = 'Weed', Stage = 1, Health = 100, Water = 50, Fertilizer = 50, Coords = {['X'] = Coords.x, ['Y'] = Coords.y, ['Z'] = Coords.z}, Pregnant = 'False' }
    exports['ghmattimysql']:executeSync("INSERT INTO `player_plants` (id, type, coords, stage, water, fertilizer, pregnant) VALUES (@Id, @Type, @Coords, @Stage, @Water, @Fertilizer, @Pregnant)", {
        ['@Id'] = NewPlantData.Id,
        ['@Type'] = NewPlantData.Type,
        ['@Coords'] = json.encode(NewPlantData.Coords),
        ['@Stage'] = NewPlantData.Stage,
        ['@Water'] = NewPlantData.Water,
        ['@Fertilizer'] = NewPlantData.Fertilizer,
        ['@Pregnant'] = NewPlantData.Pregnant,
    })

    TriggerEvent('fw-logs:Server:Log', 'weed', 'Plant Planted', ("User: [%s] - %s - %s\nPlant ID: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, NewPlantData.Id), 'green')

    table.insert(Config.WeedPlants, NewPlantData)
    TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 2, NewPlantData)
    TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 1, Config.WeedPlants)
end)

-- // Callbacks \\ --
FW.Functions.CreateCallback("fw-illegal:Server:Get:Plants", function(Source, Cb)
    Cb(Config.WeedPlants)
end)

-- // Functions \\ --
function UpdateAllPlants(UpdateClient)
    for k, v in pairs(Config.WeedPlants) do
        exports['ghmattimysql']:executeSync("UPDATE `player_plants` SET `stage` = @Stage, `health` = @Health, `water` = @Water, `fertilizer` = @Fertilizer, `pregnant` = @Pregnant WHERE `id` = @Id", {
            ['@Id'] = v.Id,
            ['@Stage'] = v.Stage,
            ['@Health'] = v.Health,
            ['@Water'] = v.Water,
            ['@Fertilizer'] = v.Fertilizer,
            ['@Pregnant'] = v.Pregnant,
        })
    end
    if UpdateClient then
        TriggerClientEvent('fw-illegal:Client:Plants:Action', -1, 1, Config.WeedPlants)
    end
end

function CalculateWeedQuality(Health)
    if Health <= 20 then
        return math.random(10, 30)
    elseif Health >= 21 and Health < 50 then
        return math.random(30, 50)
    elseif Health >= 50 and Health < 80 then
        return math.random(50, 80)
    elseif Health >= 80 and Health <= 100 then
        return math.random(80, 100)
    end
end

function GetPlantKeyByPlantId(PlantId)
    for k, v in pairs(Config.WeedPlants) do
        if v.Id == PlantId then
            return k
        end
    end
    return false
end