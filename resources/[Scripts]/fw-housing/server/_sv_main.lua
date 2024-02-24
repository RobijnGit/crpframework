FW = exports['fw-core']:GetCoreObject()

-- Code

Citizen.CreateThread(function()
    LoadHouses()
end)

-- Events
RegisterNetEvent("fw-housing:Server:SetInteractLocation")
AddEventHandler("fw-housing:Server:SetInteractLocation", function(HouseId, Interaction, Coords, Heading, IsInside)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not HasKeyToHouse(HouseId, Player.PlayerData.citizenid) and not exports['fw-businesses']:HasPlayerBusinessPermission(Config.BusinessName, Source, Config.SellPermission) then
        return
    end

    if Interaction == 'Backdoor' then
        if IsInside then
            Config.Houses[HouseId].Locations.BackdoorIn = vector4(Coords.x, Coords.y, Coords.z, Heading)
        else
            Config.Houses[HouseId].Locations.BackdoorOut = vector4(Coords.x, Coords.y, Coords.z, Heading)
        end
    elseif Interaction == "Garage" then
        if IsInside then return end
        Config.Houses[HouseId].Garage = vector4(Coords.x, Coords.y, Coords.z, Heading)
        TriggerEvent("fw-vehicles:Client:SetHousingGarage", Config.Houses[HouseId].Name, Config.Houses[HouseId].Garage)
    elseif IsInside then
        Config.Houses[HouseId].Locations[Interaction] = Coords
    end

    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, Config.Houses[HouseId])
    SaveHouse(HouseId)
end)

RegisterNetEvent("fw-housing:Server:DeleteHouse")
AddEventHandler("fw-housing:Server:DeleteHouse", function(HouseId)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local IsRealtor = IsPlayerRealtor(Source)
    if not IsRealtor then return end

    if Config.Houses[HouseId] == nil then return end

    exports['ghmattimysql']:executeSync("DELETE FROM `player_houses` WHERE `id` = @Id", {
        ['@Id'] = Config.Houses[HouseId].DbId,
    })

    Config.Houses[HouseId] = nil
    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, nil)
end)

RegisterNetEvent("fw-housing:Server:SellLocation")
AddEventHandler("fw-housing:Server:SellLocation", function(HouseId, Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(tostring(Data.Cid))
    if Target == nil then return end

    local IsRealtor, Business = IsPlayerRealtor(Source)
    if not IsRealtor then return end

    if Config.Houses[HouseId] == nil then return end
    local HouseData = Config.Houses[HouseId]

    TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, "purchase-house-" .. Data.Cid, "fas fa-home", { "white", "rgb(38, 50, 56)" }, "Huis Kopen", exports['fw-businesses']:NumberWithCommas(HouseData.Price + (HouseData.Price * (tonumber(Data.Commission) / 100))) .. " incl. tax", false, true, "fw-housing:Server:PurchaseConfirm", "fw-phone:Client:RemoveNotificationById", { Id = "purchase-house-" .. Data.Cid, Cid = Data.Cid, HouseId = HouseId, Commission = Data.Commission, Business = Business })
end)

RegisterNetEvent("fw-housing:Server:PurchaseConfirm")
AddEventHandler("fw-housing:Server:PurchaseConfirm", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Config.Houses[Data.HouseId] == nil then return end
    local HouseData = Config.Houses[Data.HouseId]

    TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Kopen...", true)

    Citizen.SetTimeout(1000, function()
        if exports['fw-financials']:RemoveMoneyFromAccount("1001", exports['fw-businesses']:GetBusinessAccount(Data.Business), Player.PlayerData.charinfo.account, HouseData.Price + (HouseData.Price * (tonumber(Data.Commission) / 100)), 'PURCHASE', 'Betaling zakelijke dienstverlening: ' .. HouseData.Adress .. ' gekocht.') then
            exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, exports['fw-businesses']:GetBusinessAccount(Data.Business), HouseData.Price * (tonumber(Data.Commission) / 100), 'PURCHASE', 'Betaling zakelijke dienstverlening: ' .. HouseData.Adress .. ' gekocht. (Commissie: ' .. Data.Commission .. ')')
            TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Voltooid!", true)

            local Date = os.date("*t", os.time())
            TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
                Type = 4,
                Title = HouseData.Adress,
                Content = Config.ContractText:format(Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, HouseData.Adress, HouseData.Category, exports['fw-businesses']:NumberWithCommas(HouseData.Price), Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min),
                Signatures = {
                    { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
                    { Signed = true, Name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Timestamp = os.time() * 1000, Cid = Player.PlayerData.citizenid },
                },
                Sharees = { Player.PlayerData.citizenid },
                Finalized = 1,
            })

            Config.Houses[Data.HouseId].Owned = true
            Config.Houses[Data.HouseId].Owner = Player.PlayerData.citizenid
            Config.Houses[Data.HouseId].Selling = false
            TriggerClientEvent("fw-housing:Client:SyncHouse", -1, Data.HouseId, Config.Houses[Data.HouseId])

            local Result = exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `citizenid` = @Cid, `keyholders` = @Keyholders, `selling` = 0 WHERE `id` = @Id", {
                ['@Cid'] = Player.PlayerData.citizenid,
                ['@Keyholders'] = json.encode({Player.PlayerData.citizenid}),
                ['@Id'] = HouseData.DbId
            })
        else
            TriggerClientEvent('fw-phone:Client:UpdateNotification', Source, Data.Id, true, true, false, "Transactie Geweigerd!", true)
        end
    end)
end)

RegisterNetEvent("fw-housing:Server:SetKeyState")
AddEventHandler("fw-housing:Server:SetKeyState", function(HouseId, Target, State)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Config.Houses[HouseId] then
        return
    end

    if Config.Houses[HouseId].Owner ~= Player.PlayerData.citizenid then
        return
    end

    local Keyholders = {}
    if State then
        Keyholders = Config.Houses[HouseId].Keyholders
        Keyholders[#Keyholders + 1] = Target
    else
        for k, v in pairs(Config.Houses[HouseId].Keyholders) do
            if v ~= Target then
                Keyholders[#Keyholders + 1] = v
            end
        end
    end

    Config.Houses[HouseId].Keyholders = Keyholders
    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, Config.Houses[HouseId])

    exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `keyholders` = @Keyholders WHERE `id` = @Id", {
        ['@Id'] = Config.Houses[HouseId].DbId,
        ['@Keyholders'] = json.encode(Keyholders),
    })
end)

-- Callbacks
FW.Functions.CreateCallback('fw-housing:Server:GetHouses', function(Source, Cb)
    Cb(Config.Houses)
end)

FW.Functions.CreateCallback('fw-housing:Server:CreateHouse', function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local IsRealtor, Business = IsPlayerRealtor(Source)
    if not IsRealtor then return end

    local PlyCoords = GetEntityCoords(GetPlayerPed(Source))
    local Coords = vector4(PlyCoords.x, PlyCoords.y, PlyCoords.z, GetEntityHeading(GetPlayerPed(Source)))

    local AccountId = exports['fw-businesses']:GetBusinessAccount(Business)

    if exports['fw-financials']:RemoveMoneyFromAccount("1001", Player.PlayerData.charinfo.account, exports['fw-businesses']:GetBusinessAccount(Business), Config.PricesPerClass[tonumber(Data.Class) or 0], 'PURCHASE', 'Huis aangekocht: ' .. Data.Class .. ' [' .. Data.Adress .. ']') then
        exports['ghmattimysql']:executeSync("INSERT INTO `player_houses` (`selling`, `name`, `adress`, `class`, `coords`) VALUES ('0', ?, ?, ?, ?)", {
            Data.Name,
            Data.Adress,
            Data.Class,
            json.encode(Coords),
        })

        LoadHouses()
        TriggerClientEvent("fw-housing:Client:SyncHouse", -1, #Config.Houses, Config.Houses[#Config.Houses])
        Cb(true)
    else
        Cb(false)
    end
end)

FW.Functions.CreateCallback('fw-housing:Server:EditHouse', function(Source, Cb, Data, House)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local IsRealtor = IsPlayerRealtor(Source)
    if not IsRealtor then return end

    exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `tier` = ?, `price` = ? WHERE `id` = ?", {
        Data.Tier,
        FW.Shared.CalculateTax("Property Tax", Data.Price),
        House.DbId
    })

    LoadHouses()
    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, #Config.Houses, Config.Houses[#Config.Houses])

    Cb(true)
end)

FW.Functions.CreateCallback('fw-housing:Server:LockProperty', function(Source, Cb, HouseId, IsDetcord)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Config.Houses[HouseId].Locked and not IsDetcord and not HasKeyToHouse(HouseId, Player.PlayerData.citizenid) then
        Cb(false)
        return
    end

    Config.Houses[HouseId].Locked = not Config.Houses[HouseId].Locked
    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, Config.Houses[HouseId])

    Cb(true)
end)

FW.Functions.CreateCallback("fw-housing:Server:SellHouse", function(Source, Cb, HouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Config.Houses[HouseId] then
        return Cb(false)
    end

    if Config.Houses[HouseId].Owner ~= Player.PlayerData.citizenid then
        return Cb(false)
    end

    Config.Houses[HouseId].Owner = false
    Config.Houses[HouseId].Owned = false
    Config.Houses[HouseId].Selling = true
    Config.Houses[HouseId].Keyholders = {}
    Config.Houses[HouseId].Locked = true
    Config.Houses[HouseId].Business = ''
    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, Config.Houses[HouseId])

    local ReceiveMoney = math.floor(Config.Houses[HouseId].Price / 2)
    exports['fw-financials']:AddMoneyToAccount('1001', "1", Player.PlayerData.charinfo.account, ReceiveMoney, 'SELL', 'Huis te koop gezet: ' .. Config.Houses[HouseId].Adress)

    local Result = exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `citizenid` = NULL, `keyholders` = '[]', `business` = '[]', `selling` = 1 WHERE `id` = @Id", {
        ['@Id'] = Config.Houses[HouseId].DbId
    })

    local Result = exports['ghmattimysql']:executeSync("DELETE FROM `phone_documents` WHERE `title` = @Title", {
        ['@Title'] = Config.Houses[HouseId].Adress
    })

    Cb(Result.affectedRows > 0)
end)

FW.Functions.CreateCallback("fw-housing:Server:PurchaseHouse", function(Source, Cb, HouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Config.Houses[HouseId] then
        return Cb({Success = false, Msg = "Ongeldig Huis" })
    end

    if not Config.Houses[HouseId].Selling then
        return Cb({Success = false, Msg = "Huis staat niet te koop" })
    end

    if exports['fw-financials']:RemoveMoneyFromAccount("1001", exports['fw-businesses']:GetBusinessAccount("Dynasty 8"), Player.PlayerData.charinfo.account, Config.Houses[HouseId].Price, 'PURCHASE', 'Huis gekocht: ' .. Config.Houses[HouseId].Adress) then
        Config.Houses[HouseId].Owned = true
        Config.Houses[HouseId].Owner = Player.PlayerData.citizenid
        Config.Houses[HouseId].Selling = false
        TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, Config.Houses[HouseId])
        exports['fw-financials']:AddMoneyToAccount(Player.PlayerData.citizenid, Player.PlayerData.charinfo.account, exports['fw-businesses']:GetBusinessAccount("Dynasty 8"), Config.Houses[HouseId].Price * 0.25, 'PURCHASE', 'Huis gekocht: ' .. Config.Houses[HouseId].Adress)

        local Result = exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `citizenid` = @Cid, `keyholders` = @Keyholders, `selling` = 0 WHERE `id` = @Id", {
            ['@Cid'] = Player.PlayerData.citizenid,
            ['@Keyholders'] = json.encode({Player.PlayerData.citizenid}),
            ['@Id'] = Config.Houses[HouseId].DbId
        })

        local Date = os.date("*t", os.time())
        TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
            Type = 4,
            Title = Config.Houses[HouseId].Adress,
            Content = Config.ContractText:format(Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Config.Houses[HouseId].Adress, Config.Houses[HouseId].Category, exports['fw-businesses']:NumberWithCommas(Config.Houses[HouseId].Price), Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min),
            Signatures = {
                { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
                { Signed = true, Name = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Timestamp = os.time() * 1000, Cid = Player.PlayerData.citizenid },
            },
            Sharees = { Player.PlayerData.citizenid },
            Finalized = 1,
        })

        Cb({Success = Result.affectedRows > 0, Msg = "Kon data niet opslaan.", House = Config.Houses[HouseId]})
    else
        Cb({Success = false, Msg = "Niet Genoeg Balans" })
    end
end)

FW.Functions.CreateCallback("fw-housing:Server:GetHousingKeys", function(Source, Cb, HouseId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Config.Houses[HouseId] then
        return Cb({})
    end

    if Config.Houses[HouseId].Owner ~= Player.PlayerData.citizenid then
        return Cb({})
    end

    local Retval = {}
    for k, v in pairs(Config.Houses[HouseId].Keyholders) do
        Retval[#Retval + 1] = { Text = FW.Functions.GetPlayerCharName(v), Value = v }
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-housing:Server:HasKeys", function(Source, Cb, HouseName)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `keyholders` FROM `player_houses` WHERE `name` = @Name", {
        ['@Name'] = HouseName
    })

    if Result[1].citizenid == Player.PlayerData.citizenid then
        return Cb(true)
    end

    if Result[1] == nil then return Cb(false) end

    for k, v in pairs(json.decode(Result[1].keyholders)) do
        if v == Player.PlayerData.citizenid then
            return Cb(true)
        end
    end

    Cb(false)
end)

-- Functions
function HasKeyToHouse(HouseId, Cid)
    if Cid == nil then return false end
    if Config.Houses[HouseId] == nil then return false end
    if not Config.Houses[HouseId].Owned then
        local Player = FW.Functions.GetPlayerByCitizenId(Cid)
        if IsPlayerRealtor(Player.PlayerData.source) then return true end
    end

    if Config.Houses[HouseId].Owner == Cid then return true end

    local HasKey = false
    for k, v in pairs(Config.Houses[HouseId].Keyholders) do
        if v == Cid then
            HasKey = true
            break
        end
    end

    return HasKey
end
exports("HasKeyToHouse", HasKeyToHouse)

function LoadHouses()
    local Houses = exports['ghmattimysql']:executeSync("SELECT * FROM `player_houses`")
    local NewHouses = {}

    for k, v in pairs(Houses) do
        local Coords = json.decode(v.coords)
        local Garage = json.decode(v.garage)
        local Locations = json.decode(v.locations)
        local HouseId = #NewHouses + 1

        NewHouses[HouseId] = {
            Id = HouseId,
            DbId = v.id,
            Owner = v.citizenid ~= nil and v.citizenid or false,
            Owned = v.citizenid ~= nil,
            Keyholders = json.decode(v.keyholders),
            Business = json.decode(v.business),
            Selling = v.selling == 1,
            Locked = true,
            Name = v.name,
            Adress = v.adress,
            Class = v.class,
            Tier = v.tier,
            Category = Config.TierCategory[v.tier] or "housing",
            Price = v.price,
            Coords = vector4(Coords.x, Coords.y, Coords.z, Coords.w),
            Garage = Garage.x and vector4(Garage.x, Garage.y, Garage.z, Garage.w) or false,
            Locations = {
                Stash = Locations.Stash and vector3(Locations.Stash.x, Locations.Stash.y, Locations.Stash.z) or false,
                Wardrobe = Locations.Wardrobe and vector3(Locations.Wardrobe.x, Locations.Wardrobe.y, Locations.Wardrobe.z) or false,
                BackdoorIn = Locations.BackdoorIn and vector4(Locations.BackdoorIn.x, Locations.BackdoorIn.y, Locations.BackdoorIn.z, Locations.BackdoorIn.w) or false,
                BackdoorOut = Locations.BackdoorOut and vector4(Locations.BackdoorOut.x, Locations.BackdoorOut.y, Locations.BackdoorOut.z, Locations.BackdoorOut.w) or false,
            },
            Decorations = json.decode(v.decorations)
        }
    end

    print("Loaded " .. #NewHouses .. " houses.")

    Config.Houses = NewHouses
end

function SaveHouse(HouseId)
    local HouseData = Config.Houses[HouseId]
    exports['ghmattimysql']:executeSync("UPDATE `player_houses` SET `locations` = @Locations, `garage` = @Garage, `decorations` = @Decorations WHERE `id` = @Id", {
        ['@Locations'] = json.encode(HouseData.Locations),
        ['@Garage'] = HouseData.Garage and json.encode(HouseData.Garage) or '{}',
        ['@Decorations'] = json.encode(HouseData.Decorations),
        ["@Id"] = HouseData.DbId,
    })
end

function GetHouses()
    return Config.Houses
end
exports("GetHouses", GetHouses)

function SetHousingDecorations(HouseId, Objects)
    print("Setting house decorations for " .. HouseId)
    print(json.encode(Objects))
    Config.Houses[HouseId].Decorations = Objects
    TriggerClientEvent("fw-housing:Client:SyncHouse", -1, HouseId, Config.Houses[HouseId])
    SaveHouse(HouseId)
end
exports("SetHousingDecorations", SetHousingDecorations)

function GetHouseIdByAdress(Adress)
    for k, v in pairs(Config.Houses) do
        if v.Name == Adress then
            return v.Id
        end
    end

    return false
end
exports("GetHouseIdByAdress", GetHouseIdByAdress)

function IsPlayerRealtor(Source)
    for k, v in pairs(Config.BusinessNames) do
        if exports['fw-businesses']:HasPlayerBusinessPermission(v, Source, 'ChargeExternal') then
            return true, v
        end
    end

    return false, ""
end