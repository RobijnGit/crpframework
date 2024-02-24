local FW = exports['fw-core']:GetCoreObject()

-- Code

FW.Commands.Add("logout", "Ga terug naar het karakterscherm.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    FW.Player.Logout(Source)
    Citizen.Wait(550)
    TriggerClientEvent('fw-characters:Client:ShowSelector', Source)
end, "admin")

FW.Functions.CreateCallback("fw-characters:Server:GetCharacters", function(Source, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `charinfo`, `skin` FROM `players` WHERE `steam` = @Steam ORDER BY `citizenid` ASC", {
        ['@Steam'] = GetPlayerIdentifierByType(Source, "steam"),
    })

    local Retval = {}

    for k, v in pairs(Result) do
        local CharInfo = json.decode(v.charinfo)
        Retval[#Retval + 1] = {
            Cid = v.citizenid,
            Name = CharInfo.firstname .. " " .. CharInfo.lastname,
            Skin = json.decode(v.skin),
        }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-character:Server:CreateCharacter", function(Source, Cb, Data)
    local CharInfo = { firstname = Data.Firstname, lastname = Data.Lastname, birthdate = Data.Birthdate, nationality = 'Los Santos', gender = Data.Gender == 'Vrouw' and 1 or 0, isLifer = Data.Type == "Lifer" }
    if FW.Player.Login(Source, true, false, CharInfo) then
        local Player = FW.Functions.GetPlayer(Source)
        if Data.Type == "Lifer" then
            exports['ghmattimysql']:executeSync("INSERT INTO `mdw_profiles` (citizenid, name, notes, image, tags, wanted) VALUES (?, ?, '', '', '[]', '0')", {
                Player.PlayerData.citizenid,
                Data.Firstname .. " " .. Data.Lastname
            })
        end

        FW.Commands.Refresh(Source)
        TriggerClientEvent('fw-apartments:Client:CreateCharacter', Source)
        TriggerEvent("fw-logs:Server:Log", 'joinleave', "Character Created", ("User: [%s] - %s\nData: ```json\n%s```"):format(Source, GetPlayerName(Source), json.encode(CharInfo, {indent=4})), "green")
	end
end)

FW.RegisterServer("fw-characters:Server:DeleteCharacter", function(Source, Data)
    if FW.Player.DeleteCharacter(Source, Data.Cid) then
        TriggerClientEvent("fw-characters:Client:RefreshCharacters", Source)
    end
end)

FW.RegisterServer("fw-characters:Server:PlayCharacter", function(Source, Data)
    if FW.Player.Login(Source, false, Data.Cid) then
        local Player = FW.Functions.GetPlayer(Source)
        while Player == nil do
            Player = FW.Functions.GetPlayer(Source)
            Citizen.Wait(250)
        end
        TriggerClientEvent('fw-charachters:Client:OpenSpawn', Source, Player.PlayerData)
        TriggerEvent("fw-logs:Server:Log", 'joinleave', "Character Loaded", ("User: [%s] - %s\nLoaded CID#: %s"):format(Source, GetPlayerName(Source), Data.Cid), "green")
    end
end)

FW.Functions.CreateCallback("fw-characters:Server:AllowOverride", function(Source, Cb)
    Cb(Config.LimitOverride[GetPlayerIdentifierByType(Source, "steam")])
end)

RegisterNetEvent("fw-characters:Server:GiveStarterItems")
AddEventHandler("fw-characters:Server:GiveStarterItems", function()
    local src = source
    local Player = FW.Functions.GetPlayer(src)
    if Player == nil then return end

    Player.Functions.AddItem("welcome", 1, false, nil, true)
    Player.Functions.AddItem("phone", 1, false, nil, true)

    local Date = os.date("*t", os.time())
    TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
        Type = 1,
        Title = 'Rijbewijs - ' .. Player.PlayerData.citizenid,
        Content = exports['fw-cityhall']:GetLicenseTemplate():format((Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname), Player.PlayerData.citizenid, Player.PlayerData.charinfo.gender == 0 and "Man" or "Vrouw", "De Staat", Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min),
        Signatures = {
            { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
        },
        Sharees = { Player.PlayerData.citizenid },
        Finalized = 1,
    })

    local Model = GetRandomVehicle()
    if not Model then
        return
    end

    local SharedData = FW.Shared.HashVehicles[GetHashKey(Model)]

    local Plate = FW.Functions.GeneratePlate()
    local VIN = FW.Functions.GenerateVin()

    exports['ghmattimysql']:executeSync("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `vinnumber`, `garage`, `state`, `metadata`) VALUES (?, ?, ?, ?, ?, ?, ?)", {
        Player.PlayerData.citizenid,
        Model,
        Plate,
        VIN,
        'apartment_1',
        'in',
        json.encode({ Body = 1000.0, Engine = 1000.0, Fuel = 100.0, Gifted = true }),
    })

    exports['ghmattimysql']:executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", {
        "1001",
        Player.PlayerData.citizenid,
        Plate,
        0,
        os.time() * 1000
    })

    local Date = os.date("*t", os.time())
    TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
        Type = 3,
        Title = SharedData.Name .. ' - ' .. Plate,
        Content = (exports['fw-businesses']:GetVehicleRegistration()):format(SharedData.Name, Model, Plate, VIN, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, "De Staat", Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min, "Gratis"),
        Signatures = {
            { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
            { Signed = true, Name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Timestamp = os.time() * 1000, Cid = Player.PlayerData.citizenid },
        },
        Sharees = { Player.PlayerData.citizenid },
        Finalized = 1,
    })

    Citizen.SetTimeout(5000, function()
        TriggerEvent('fw-phone:Server:Mails:AddMail', "De Staat", "Welkom in Los Santos!", ("Welkom in de Staat van San Andreas, %s. Je hebt een gloednieuw voertuig ontvangen als welkomstcadeau door de Staat van San Andreas.<br/><br/>We begrijpen dat de onderhoudskosten van een voertuig een uitdaging kunnen zijn, daarom zal de Staat de onderhoudskosten veroorloven voor dit voertuig."):format(Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname), Player.PlayerData.source)
    end)
end)

function GetRandomVehicle()
    math.randomseed(os.time() + math.random(1, 100))

    local TotalChance = 0
    for _, Item in ipairs(Config.WelcomeVehicles) do
        TotalChance = TotalChance + Item.Chance
    end

    local RandomValue = math.random() * TotalChance
    local CumulativeChance = 0

    for _, Item in ipairs(Config.WelcomeVehicles) do
        CumulativeChance = CumulativeChance + Item.Chance
        if RandomValue <= CumulativeChance then
            return Item.Model
        end
    end

    return false
end