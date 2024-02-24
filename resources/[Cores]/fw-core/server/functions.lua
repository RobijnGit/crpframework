FW.Functions = {}

local Throttles = {}
function FW.Throttled(Name, Time)
    if not Throttles[Name] then
        Throttles[Name] = true
        Citizen.SetTimeout(Time or 500, function() Throttles[Name] = false end)
        return false
    end

    return true
end

FW.Functions.GetIdentifier = function(source, idtype)
    local idtype = idtype ~=nil and idtype or Config.IdentifierType
    for _, identifier in pairs(GetPlayerIdentifiers(source)) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end

FW.Functions.GetSource = function(identifier)
    for src, player in pairs(FW.Players) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

FW.Functions.GetPlayer = function(source)
    if type(source) == "number" then
        return FW.Players[source]
    else
        return FW.Players[FW.Functions.GetSource(source)]
    end
end

FW.Functions.GetPlayerByCitizenId = function(citizenid)
    for src, player in pairs(FW.Players) do
        local cid = citizenid
        if FW.Players[src].PlayerData.citizenid == cid then
            return FW.Players[src]
        end
    end
    return nil
end

FW.Functions.GetPlayerByPhone = function(number)
    for src, player in pairs(FW.Players) do
        local cid = citizenid
        if FW.Players[src].PlayerData.charinfo.phone == number then
            return FW.Players[src]
        end
    end
    return nil
end

FW.Functions.GetPlayerPhoneNumber = function(CitizenId)
    local ReturnValue = promise:new()
    exports['ghmattimysql']:execute("SELECT `charinfo` FROM `players` WHERE `citizenid` = @Cid", { ['@Cid'] = CitizenId }, function(result)
        if result[1] ~= nil then
            local CharData = json.decode(result[1].charinfo)
            ReturnValue:resolve(CharData.phone)
        else
            ReturnValue:resolve(nil)
        end
    end)
    return Citizen.Await(ReturnValue)
end

FW.Functions.GetPlayerCharName = function(CitizenId)
    local ReturnValue = promise:new()
    exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `citizenid` = @Cid", { ['@Cid'] = CitizenId }, function(result)
        if result[1] ~= nil then
            local CharData = json.decode(result[1].charinfo)
            ReturnValue:resolve(CharData.firstname .. ' ' .. CharData.lastname)
        else
            ReturnValue:resolve(nil)
        end
    end)
    return Citizen.Await(ReturnValue)
end

FW.Functions.GetPlayerCharNameByPhone = function(PhoneNumber)
    local ReturnValue = promise:new()
    exports['ghmattimysql']:execute("SELECT * FROM `players` WHERE `charinfo` LIKE @Number", { ['@Number'] = '%' .. PhoneNumber .. '%' }, function(result)
        if result[1] ~= nil then
            local CharData = json.decode(result[1].charinfo)
            if CharData.phone == PhoneNumber then
                ReturnValue:resolve(CharData.firstname .. ' ' .. CharData.lastname)
            else
                ReturnValue:resolve(nil)
            end
        else
            ReturnValue:resolve(nil)
        end
    end)
    return Citizen.Await(ReturnValue)
end

FW.Functions.GetAddictionLevel = function(Source, Type)
    local Player = FW.Functions.GetPlayer(Source)
    if Player.PlayerData.addiction[Type] >= 10 then
        return 1
    elseif Player.PlayerData.addiction[Type] >= 20 then
        return 2
    elseif Player.PlayerData.addiction[Type] >= 30 then
        return 3
    elseif Player.PlayerData.addiction[Type] >= 40 then
        return 4
    end
end

FW.Functions.GetPlayers = function()
    local sources = {}
    for k, v in pairs(FW.Players) do
        table.insert(sources, k)
    end
    return sources
end

FW.Functions.CreateCallback = function(name, cb)
    FW.ServerCallbacks[name] = cb
end

FW.Functions.TriggerCallback = function(name, source, cb, ...)
    if FW.ServerCallbacks[name] ~= nil then
        FW.ServerCallbacks[name](source, cb, ...)
    end
end

FW.Functions.CreateUsableItem = function(item, cb)
    FW.UseableItems[item] = cb
end

FW.Functions.CanUseItem = function(item)
    return FW.UseableItems[item] ~= nil
end

FW.Functions.UseItem = function(Source, Item)
    FW.UseableItems[Item.Item](Source, Item)
end

FW.Functions.Kick = function(source, reason, setKickReason, deferrals)
    local src = source
    reason = "\n"..reason.."\n🔸 Kijk op onze discord voor meer informatie!"
    if(setKickReason ~=nil) then
        setKickReason(reason)
    end
    Citizen.CreateThread(function()
        if(deferrals ~= nil)then
            deferrals.update(reason)
            Citizen.Wait(2500)
        end
        if src ~= nil then
            DropPlayer(src, reason)
        end
        local i = 0
        while (i <= 4) do
            i = i + 1
            while true do
                if src ~= nil then
                    if(GetPlayerPing(src) >= 0) then
                        break
                    end
                    Citizen.Wait(100)
                    Citizen.CreateThread(function() 
                        DropPlayer(src, reason)
                    end)
                end
            end
            Citizen.Wait(5000)
        end
    end)
end

FW.Functions.AddPermission = function(source, permission)
    local Player = FW.Functions.GetPlayer(source)
    if Player ~= nil then 
        FW.Config.Server.PermissionList[FW.Functions.GetIdentifier(source, "steam")] = {
            steam = FW.Functions.GetIdentifier(source, "steam"),
            license = FW.Functions.GetIdentifier(source, "license"),
            permission = permission:lower(),
        }

        local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_extra` WHERE `steam` = ?", {
            FW.Functions.GetIdentifier(source, "steam")
        })

        if Result[1] then
            exports['ghmattimysql']:execute("UPDATE `server_extra` SET `permission` = @Permission WHERE `steam` = @Steam", {
                ['@Permission'] = permission:lower(),
                ['@Steam'] = FW.Functions.GetIdentifier(source, "steam")
            })
        else
            exports['ghmattimysql']:execute("INSERT INTO `server_extra` (steam, license, name, permission, priority) VALUES (?, ? ,?, ?, ?)", {
                FW.Functions.GetIdentifier(source, "steam"),
                FW.Functions.GetIdentifier(source, "license"),
                GetPlayerName(source),
                permission,
                5
            })
        end

        Player.Functions.UpdatePlayerData()
    end
end

FW.Functions.RemovePermission = function(source)
    local Player = FW.Functions.GetPlayer(source)
    if Player ~= nil then 
        FW.Config.Server.PermissionList[FW.Functions.GetIdentifier(source, "steam")] = nil
        exports['ghmattimysql']:executeSync("UPDATE `server_extra` SET `permission`= 'user' WHERE `steam` = @Steam", { ['@Steam'] = FW.Functions.GetIdentifier(source, "steam") })
        Player.Functions.UpdatePlayerData()
    end
end

FW.Functions.HasPermission = function(source, permission)
    local retval = false
    local steamid = FW.Functions.GetIdentifier(source, "steam")
    local licenseid = FW.Functions.GetIdentifier(source, "license")
    local permission = tostring(permission:lower())
    if permission == "user" then
        retval = true
    else
        if FW.Config.Server.PermissionList[steamid] ~= nil then 
            if FW.Config.Server.PermissionList[steamid].steam == steamid then
                if FW.Config.Server.PermissionList[steamid].permission == permission or FW.Config.Server.PermissionList[steamid].permission == "god" then
                    retval = true
                end
            end
        end
    end
    return retval
end

FW.Functions.GetPermission = function(source)
    local retval = "user"
    Player = FW.Functions.GetPlayer(source)
    local steamid = FW.Functions.GetIdentifier(source, "steam")
    local licenseid = FW.Functions.GetIdentifier(source, "license")
    if Player ~= nil then
        if FW.Config.Server.PermissionList[Player.PlayerData.steam] ~= nil then 
            if FW.Config.Server.PermissionList[Player.PlayerData.steam].steam == steamid and FW.Config.Server.PermissionList[Player.PlayerData.steam].license == licenseid then
                retval = FW.Config.Server.PermissionList[Player.PlayerData.steam].permission
            end
        end
    end
    return retval
end

FW.Functions.IsOptin = function(source)
    local retval = false
    local steamid = FW.Functions.GetIdentifier(source, "steam")
    if FW.Functions.HasPermission(source, "admin") then
        retval = FW.Config.Server.PermissionList[steamid].optin
    end
    return retval
end

FW.Functions.ToggleOptin = function(source)
    local steamid = FW.Functions.GetIdentifier(source, "steam")
    if FW.Functions.HasPermission(source, "admin") then
        FW.Config.Server.PermissionList[steamid].optin = not FW.Config.Server.PermissionList[steamid].optin
    end
end

FW.Functions.RefreshPerms = function()
    FW.Config.Server.PermissionList = {}
    exports['ghmattimysql']:execute("SELECT * FROM `server_extra`", {}, function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                FW.Config.Server.PermissionList[v.steam] = {
                    steam = v.steam,
                    license = v.license,
                    permission = v.permission,
                    optin = true,
                }
            end
        end
    end)
end

FW.Functions.IsPlayerBanned = function(source)
    local Source, IsBanned, Message = source, nil, nil
    local result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_bans` WHERE `steam` = @Steam OR `license` = @License", {
        ['@Steam'] = FW.Functions.GetIdentifier(source, "steam"),
        ['@License'] = FW.Functions.GetIdentifier(source, "license"),
    })

    if result ~= nil and result[1] ~= nil then
        if os.time() < result[1].expire then
            local timeTable = os.date('*t', result[1].expire)
            if result[1].expire >= 3132036000 then
                Message = "\n🔰 Je bent verbannen van de server. \n🛑 Reden: " ..result[1].reason.. '\n🛑 Verbannen Door: ' ..result[1].bannedby.. '\n🛑Ban vervalt over: permanent\n\n Voor een unban kan je een ticket openen in de discord.'
            else
                Message = "\n🔰 Je bent verbannen van de server. \n🛑 Reden: " ..result[1].reason.. '\n🛑 Verbannen Door: ' ..result[1].bannedby.. '\n🛑Ban vervalt over: ' .. timeTable['day'] .. '/' .. timeTable['month'] .. '/' .. timeTable['year'] .. ' ' .. timeTable['hour'] .. ':' .. timeTable['min'] .. '\n\n Voor een unban kan je een ticket openen in de discord.'
            end
            IsBanned = true
        else
            exports['ghmattimysql']:execute("DELETE FROM `server_bans` WHERE `id` = @Id", { ['@Id'] = result[1].id })
            IsBanned = false
        end
    else
        IsBanned = false
    end

    return IsBanned, Message
end

FW.Functions.SpawnVehicle = function(Source, SendModel, SpawnCoords, IsAdmin, Plate)
    local CreateAutoMobile = GetHashKey("CREATE_AUTOMOBILE")
    local Model = (type(SendModel) == "number" and SendModel or GetHashKey(SendModel))
    local Coords = SpawnCoords ~= nil and SpawnCoords or GetEntityCoords(GetPlayerPed(Source))
    local Heading = SpawnCoords ~= nil and SpawnCoords.a ~= nil and SpawnCoords.a or GetEntityHeading(GetPlayerPed(Source))
    local Vehicle = Citizen.InvokeNative(CreateAutoMobile, Model, Coords.x, Coords.y, Coords.z, Heading);
    while not DoesEntityExist(Vehicle) do
        Citizen.Wait(1)
    end

    SetEntityRoutingBucket(Vehicle, GetPlayerRoutingBucket(Source))

    if Plate ~= nil and Plate ~= false then
        SetVehicleNumberPlateText(Vehicle, Plate)
        TriggerClientEvent('FW:client:set:vehicle:plate', Source, NetworkGetNetworkIdFromEntity(Vehicle), Plate)
    end
    if IsAdmin then
        TriggerClientEvent('FW:client:spawn:vehicle', Source, NetworkGetNetworkIdFromEntity(Vehicle), SendModel)
        return
    else
        TriggerClientEvent('FW:client:add:vehicle:properties', Source, NetworkGetNetworkIdFromEntity(Vehicle))
        return NetworkGetNetworkIdFromEntity(Vehicle)
    end
end

function FW.Functions.MergeTables(OriginalTable, NewTable)
    local Retval = OriginalTable

    for k, v in pairs(NewTable) do
        OriginalTable[k] = v
    end

    return Retval
end

FW.Functions.GeneratePlate = function()
    local Plate = tostring(FW.Shared.RandomInt(1)) .. FW.Shared.RandomStr(2) .. tostring(FW.Shared.RandomInt(3)) .. FW.Shared.RandomStr(2)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `plate` = @Plate", { ['@Plate'] = Plate })

    if Result[1] ~= nil then
        Plate = FW.Functions.GeneratePlate()
    end

    return Plate:upper()
end

FW.Functions.GenerateVin = function()
    local Vin = tostring(FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(2) .. FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(1) .. FW.Shared.RandomStr(1) .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(5))
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `vinnumber` = @Vin", { ['@Vin'] = Vin })

    if Result[1] ~= nil then
        Vin = FW.Functions.GenerateVin()
    end

    return Vin:upper()
end

FW.Functions.CreateCallback("FW:GetTax", function(Source, Cb)
    Cb(FW.Shared.Tax)
end)

function FW.AreLicensesUsed(SteamId, License)
    local Players = GetPlayers()
    for k, v in pairs(Players) do
        local Identifiers = GetPlayerIdentifiers(v)
        for _, Id in pairs(Identifiers) do
            if Id == SteamId or Id == License then
                return true
            end
        end
    end
    return false
end