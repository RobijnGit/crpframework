FW = exports['fw-core']:GetCoreObject()

Citizen.CreateThread(function()
    LoadSprays()
end)

local ContestedSprays, Contesters = {}, {}

-- Functions
function GetSpraysByGang(GangId)
    local Retval = {}

    for k, v in pairs(Config.Graffitis) do
        if v.Gang and v.Gang == GangId then
            Retval[#Retval + 1] = v
        end
    end

    return Retval
end
exports("GetSpraysByGang", GetSpraysByGang)

function LoadSprays()
    Config.Graffitis = {}

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `laptop_sprays`")
    for k, v in pairs(Result) do
        local Coords = json.decode(v.position)
        local Rotation = json.decode(v.rotation)
        table.insert(Config.Graffitis, {
            Id = v.id,
            Gang = v.gang_id,
            Type = v.type,
            Coords = vector3(Coords.x, Coords.y, Coords.z),
            Rotation = vector3(Rotation.x, Rotation.y, Rotation.z)
        })
    end
end

FW.Functions.CreateUsableItem("gang-spray", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-graffiti:Client:PlaceSpray', Source, Item.CustomType)
    end
end)

-- Callbacks
FW.Functions.CreateCallback("fw-graffiti:Server:IsGraffitiContested", function(Source, Cb, SprayId)
    Cb(Config.Graffitis[SprayId].Contested)
end)

FW.Functions.CreateCallback("fw-graffiti:Server:GetSprays", function(Source, Cb)
    Cb(Config.Graffitis)
end)

FW.Functions.CreateCallback("fw-graffiti:Server:IsGangOnline", function(Source, Cb, GangId)
    local Gang = exports['fw-laptop']:GetGangById(GangId)
    if not Gang then return Cb(false) end

    local Online = 0
    local Leader = FW.Functions.GetPlayerByCitizenId(Gang.Leader.Cid)
    if Leader then
        Online = Online + 1
    end

    for k, v in pairs(Gang.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Target then
            Online = Online + 1
            if Online >= 3 then
                return Cb(true)
            end
        end
    end

    Cb(false)
end)

-- Events
FW.RegisterServer("fw-graffiti:Server:CreateSpray", function(Source, Type, Coords, Rotation, IgnoreItem)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- local Gang = exports['fw-laptop']:GetGangByPlayer(Player.PlayerData.citizenid)
    local Gang = Config.Sprays[Type].IsGang and Type or false

    if IgnoreItem or Player.Functions.RemoveItemByName('gang-spray', 1, true, Type) then
        local SprayId = #Config.Graffitis + 1
        local GraffitisSprayedToday = exports['fw-laptop']:GetGangMetadata(Gang.Id, "GraffitisSprayedToday")

        if not IgnoreItem and (GraffitisSprayedToday or 0) + 1 > Config.DailyLimit then
            return Player.Functions.Notify("Nice try!", "error")
        end

        local Result = exports['ghmattimysql']:executeSync("INSERT INTO `laptop_sprays` (`gang_id`, `type`, `position`, `rotation`) VALUES (@GangId, @SprayId, @Coords, @Rot)", {
            ['@GangId'] = Gang or "",
            ['@SprayId'] = Type,
            ["@Coords"] = json.encode(Coords),
            ["@Rot"] = json.encode(Rotation),
        })

        Config.Graffitis[SprayId] = {
            Id = Result.insertId,
            Gang = Gang or "",
            Type = Type,
            Coords = Coords,
            Rotation = Rotation
        }

        if Gang and Type == Gang then
            TriggerEvent("fw-laptop:Server:AddDiscovered", Gang, Result.insertId)
            exports['fw-laptop']:SetGangMetadata(Gang, "LastSprayTimestamp", os.time())
            exports['fw-laptop']:SetGangMetadata(Gang, "GraffitisSprayedToday", (GraffitisSprayedToday or 0) + 1)
            
        end

        TriggerClientEvent("fw-graffiti:Client:AddSpray", -1, SprayId, Config.Graffitis[SprayId])
    else
        Player.Functions.Notify("Waar is je spray gebleven?", "error")
    end
end)

FW.RegisterServer("fw-graffiti:Server:DestroySpray", function(Source, GraffitiId)
    if Config.Graffitis[GraffitiId] == nil then return end

    local SprayId = Config.Graffitis[GraffitiId].Id
    exports['ghmattimysql']:executeSync("DELETE FROM `laptop_sprays` WHERE `id` = @SprayId", {
        ['@SprayId'] = SprayId,
    })

    if ContestedSprays[Config.Graffitis[GraffitiId].Type] then
        ContestedSprays[Config.Graffitis[GraffitiId].Type] = false
    end

    table.remove(Config.Graffitis, GraffitiId)
    TriggerClientEvent("fw-graffiti:Client:DestroyGraffiti", -1, GraffitiId)

    local Result = exports['ghmattimysql']:executeSync("SELECT `gang_id`, `discovered_sprays` FROM `laptop_gangs` WHERE `discovered_sprays` LIKE @SprayId", {
        ["@SprayId"] = "%"..SprayId .. "%",
    })

    for k, v in pairs(Result) do
        local DiscoveredSprays = json.decode(v.discovered_sprays)
        for i = 1, #DiscoveredSprays, 1 do
            local DiscoveredSprayId = DiscoveredSprays[i]
            if DiscoveredSprayId == SprayId then
                table.remove(DiscoveredSprays, i)
            end
        end
        exports['ghmattimysql']:executeSync("UPDATE `laptop_gangs` SET `discovered_sprays` = @DiscoveredSprays WHERE `gang_id` = @GangId", {
            ['@GangId'] = v.gang_id,
            ["@DiscoveredSprays"] = json.encode(DiscoveredSprays),
        })
        exports['fw-laptop']:TriggerGangEvent(v.gang_id, "fw-graffiti:Client:UpdateDiscovered", DiscoveredSprays)
    end
end)

FW.RegisterServer("fw-graffiti:Server:AlertSprayer", function(Source, GangId, Type, StreetName)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Sprayers = exports['fw-laptop']:GetGangById(GangId)
    if not Sprayers then return end

    local Gang = exports['fw-laptop']:GetGangByPlayer(Player.PlayerData.citizenid)
    if Gang and Gang.Id == Sprayers.Id then return end

    local Content = ""
    if Type == "Scrub" then
        Content = "Iemand is onze graffiti aan het schrobben! " .. StreetName
    elseif Type == "Contest" then
        Content = Gang.Label .. " is onze graffiti aan het veroveren! Toggle Contested Sprays in de app!"
    end

    -- ToDo: Use fw-laptop `TriggerGangEvent` export.

    local Leader = FW.Functions.GetPlayerByCitizenId(Sprayers.Leader.Cid)
    if Leader then
        TriggerClientEvent("fw-phone:Client:Notification", Leader.PlayerData.source, "gang-action-" .. Leader.PlayerData.citizenid, "fas fa-exclamation-triangle", { "white", "transparent" }, "GANG", "LEES EMAIL APP", false, true, "fw-phone:Client:RemoveNotificationById", "fw-phone:Client:RemoveNotificationById", { Id = "gang-action-" .. Leader.PlayerData.citizenid })
        TriggerEvent("fw-phone:Server:Mails:AddMail", "Unknown", "IMPORTANT!", Content, Leader.PlayerData.source)
    end

    for k, v in pairs(Sprayers.Members) do
        local Target = FW.Functions.GetPlayerByCitizenId(v.Cid)
        if Target then
            TriggerClientEvent("fw-phone:Client:Notification", Target.PlayerData.source, "gang-action-" .. Target.PlayerData.citizenid, "fas fa-exclamation-triangle", { "white", "transparent" }, "GANG", "LEES EMAIL APP", false, true, "fw-phone:Client:RemoveNotificationById", "fw-phone:Client:RemoveNotificationById", { Id = "gang-action-" .. Target.PlayerData.citizenid })
            TriggerEvent("fw-phone:Server:Mails:AddMail", "Unknown", "IMPORTANT!", Content, Target.PlayerData.source)
        end
    end
end)

FW.Functions.CreateCallback("fw-graffiti:Server:SetSprayContested", function(Source, Cb, Clear, SprayId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    if not Config.Graffitis[SprayId] then return end

    if Clear then
        Config.Graffitis[SprayId].Contested = false
        ContestedSprays[Config.Graffitis[SprayId].Type] = false
        Contesters[Player.PlayerData.citizenid] = false
        return Cb(false)
    end

    local Gang = exports['fw-laptop']:GetGangByPlayer(Player.PlayerData.citizenid)
    if not Gang then return end

    if Config.Graffitis[SprayId].Contested then
        Player.Functions.Notify("Graffiti wordt al veroverd door iemand anders..")
        return Cb(false)
    end

    if ContestedSprays[Config.Graffitis[SprayId].Type] then
        Player.Functions.Notify("Dit kan nu niet..")
        return Cb(false)
    end

    if ContestedSprays[Config.Graffitis[SprayId].Type] == nil then ContestedSprays[Config.Graffitis[SprayId].Type] = {} end
    table.insert(ContestedSprays[Config.Graffitis[SprayId].Type], Config.Graffitis[SprayId].Id)

    Config.Graffitis[SprayId].ContestTimestamp = os.time()
    Config.Graffitis[SprayId].Contested = Gang.Id
    Contesters[Player.PlayerData.citizenid] = SprayId
    exports['fw-laptop']:SetGangMetadata(Gang.Id, "LastSprayContest", os.time())
    exports['fw-laptop']:SetGangMetadata(Gang.Id, "SpraysContested", (exports['fw-laptop']:GetGangMetadata(Gang.Id, "SpraysContested") or 0) + 1)

    Cb(true)
end)

FW.Functions.CreateCallback("fw-graffiti:Server:GetContestedSprays", function(Source, Cb, GangId)
    Cb(ContestedSprays[GangId] or {})
end)

FW.Functions.CreateCallback("fw-graffiti:Server:CanClaimGraffiti", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Contesters[Player.PlayerData.citizenid] then
        return Cb(false)
    end

    local SprayId = Contesters[Player.PlayerData.citizenid]
    Cb(os.time() >= Config.Graffitis[SprayId].ContestTimestamp + (60 * 15))
end)

FW.Functions.CreateCallback("fw-laptop:Server:Unknown:HasGangReachedLimit", function(Source, Cb, GangId)
    local Gang = exports['fw-laptop']:GetGangById(GangId)
    if Gang == nil then
        return Cb(false)
    end

    local TimestampOfToday = os.time({ hour = 0, min = 0, sec = 0, day = os.date("%d"), month = os.date("%m"), year = os.date("%Y") })
    local LastSpray = exports['fw-laptop']:GetGangMetadata(GangId, "LastSprayTimestamp")

    if not LastSpray then
        return Cb(false)
    end

    -- Compare CurrentTimestamp and LastSprayTimestamp, check if they are on different dates, if so then the daily limit has been reset.
    local DateNow = os.date("%Y-%m-%d", os.time())
    local DateSpray = os.date("%Y-%m-%d", LastSpray)
    local YearNow, MonthNow, DayNow = DateNow:match("(%d+)-(%d+)-(%d+)")
    local YearSpray, MonthSpray, DaySpray = DateSpray:match("(%d+)-(%d+)-(%d+)")

    -- if the year, month or day is different, reset 'GraffitisSprayedToday' and return false.
    if YearSpray ~= YearNow or MonthSpray ~= MonthNow or DaySpray ~= DayNow then
        exports['fw-laptop']:SetGangMetadata(GangId, "GraffitisSprayedToday", 0)
        return Cb(false)
    else
        local GraffitisSprayedToday = exports['fw-laptop']:GetGangMetadata(GangId, "GraffitisSprayedToday")
        Cb(GraffitisSprayedToday >= Config.DailyLimit)
    end
end)

FW.Functions.CreateCallback("fw-graffiti:Server:CanContestSpray", function(Source, Cb, GangId)
    local Gang = exports['fw-laptop']:GetGangById(GangId)
    if Gang == nil then
        return Cb(false)
    end

    local TimestampOfToday = os.time({ hour = 0, min = 0, sec = 0, day = os.date("%d"), month = os.date("%m"), year = os.date("%Y") })
    local LastSpray = exports['fw-laptop']:GetGangMetadata(GangId, "LastSprayContest")

    if not LastSpray then
        return Cb(true)
    end

    -- Compare CurrentTimestamp and LastSprayContest, check if they are on different dates, if so then the daily limit has been reset.
    local DateNow = os.date("%Y-%m-%d", os.time())
    local DateSpray = os.date("%Y-%m-%d", LastSpray)
    local YearNow, MonthNow, DayNow = DateNow:match("(%d+)-(%d+)-(%d+)")
    local YearSpray, MonthSpray, DaySpray = DateSpray:match("(%d+)-(%d+)-(%d+)")

    -- if the year, month or day is different, reset 'SpraysContested' and allow contest.
    if YearSpray ~= YearNow or MonthSpray ~= MonthNow or DaySpray ~= DayNow then
        exports['fw-laptop']:SetGangMetadata(GangId, "SpraysContested", 0)
        return Cb(true)
    end

    Cb(false)
end)

RegisterNetEvent("fw-graffiti:Server:PurchaseSpray")
AddEventHandler("fw-graffiti:Server:PurchaseSpray", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Config.Sprays[Data.Spray] == nil then return end
    local Cost = Config.Sprays[Data.Spray].IsGang and Config.GangSprayPrice or Config.SprayPrice

    if Config.Sprays[Data.Spray].IsGang then
        local Gang = exports['fw-laptop']:GetGangByPlayer(Player.PlayerData.citizenid)
        if not Gang or Gang.Id ~= Data.Spray then
            return Player.Functions.Notify("Deze spray lijkt niet geschikt voor jou..", "error")
        end
    end

    if not Player.Functions.RemoveMoney('cash', Cost) then
        return Player.Functions.Notify("Niet genoeg cash", "error")
    end

    Player.Functions.AddItem('gang-spray', 1, false, false, true, Data.Spray)
end)

RegisterNetEvent("fw-graffiti:Server:PurchaseScrubCloth")
AddEventHandler("fw-graffiti:Server:PurchaseScrubCloth", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.Functions.RemoveMoney('cash', Config.ScrubPrice) then
        return Player.Functions.Notify("Niet genoeg cash", "error")
    end

    Player.Functions.AddItem('scrubbingcloth', 1, false, false, true)
end)