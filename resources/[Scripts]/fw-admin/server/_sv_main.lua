local BanTimes = {
    ['1 Hour'] = 3600, ['6 Hours'] = 21600, ['12 Hours'] = 43200,
    ['1 Day'] = 86400, ['3 Days'] = 259200,
    ['1 Week'] = 604800,
    ['1 Month'] = 2678400, ['3 Months'] = 8035200,
    ['Permanent'] = 3132036000
}

local FW = exports['fw-core']:GetCoreObject()

function IsPlayerAdmin(Source)
    if FW.Functions.HasPermission(Source, "admin") or FW.Functions.HasPermission(Source, "god") then
        return true
    end
    return false
end

FW.Functions.CreateCallback('fw-admin:Server:IsPlayerAdmin', function(Source, Cb)
    local IsAdmin = IsPlayerAdmin(Source)
    Cb(IsAdmin)
end)

FW.Functions.CreateCallback('fw-admin:Server:GetPlayers', function(Source, Cb)
    local Players = {}

    for k, v in pairs(FW.Functions.GetPlayers()) do
        local Player = FW.Functions.GetPlayer(v)
        if Player then
            table.insert(Players, {
                Name = GetPlayerName(v),
                Cid = Player.PlayerData.citizenid,
                CharName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
                ServerId = v,
                Steam = Player.PlayerData.steam,
                Cash = Player.PlayerData.money.cash,
                Bank = exports['fw-financials']:GetAccountBalance(Player.PlayerData.charinfo.account),
                Job = Player.PlayerData.job.name,
                Grade = Player.PlayerData.job.grade.level,
                GradeName = FW.Shared.Jobs[Player.PlayerData.job.name].grades[Player.PlayerData.job.grade.level] and FW.Shared.Jobs[Player.PlayerData.job.name].grades[Player.PlayerData.job.grade.level].name or "Ongeldige grade",
                Highcommand = Player.PlayerData.metadata.ishighcommand,
                ApartmentId = Player.PlayerData.metadata.apartmentid,
                Phone = Player.PlayerData.charinfo.phone,
                Account = Player.PlayerData.charinfo.account,
            })
        end
    end

    Cb(Players)
end)

FW.Functions.CreateCallback('fw-admin:Server:GetNearbyPlayers', function(Source, Cb)
    local Players = {}

    local MyCoords = GetEntityCoords(GetPlayerPed(Source))

    for k, v in pairs(FW.Functions.GetPlayers()) do
        local Coords = GetEntityCoords(GetPlayerPed(v))
        if #(MyCoords - Coords) < 50.0 then
            local Player = FW.Functions.GetPlayer(v)
            table.insert(Players, {
                ServerId = v,
                Name = GetPlayerName(v),
                CharName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            })
        end
    end

    Cb(Players)
end)

-- // Events \\ --
RegisterNetEvent("fw-admin:Server:RegisterCommand")
AddEventHandler("fw-admin:Server:RegisterCommand", function(Data)
    local Src = source
    local Player = FW.Functions.GetPlayer(Src)

    if Data.Event ~= 'Admin:Toggle:Noclip' and Data.Event ~= 'Admin:Open:Inventory' and Data.Event ~= 'Admin:Delete:Vehicle' and Data.Event ~= 'Admin:Fix:Vehicle' and Data.Event ~= 'Admin:Open:Bennys' and Data.Event ~= 'Admin:Teleport' and Data.Event ~= 'Admin:Teleport:Coords' and Data.Event ~= 'Admin:Teleport:Marker' and Data.Event ~= 'Admin:Copy:Coords' and Data.Event ~= 'Admin:Toggle:Coords' and Data.Event ~= 'Admin:Toggle:DeteLazer' and Data.Event ~= 'Admin:Toggle:Blips' and Data.Event ~= 'Admin:Toggle:Names' and Data.Event ~= 'Admin:Set:Ammo' and Data.Event ~= 'Admin:Kick:Player' and Data.Event ~= 'Admin:Ban:Player' and Data.Event ~= 'Admin:Fling:Player' and Data.Event ~= 'Admin:Toggle:Cuffs' and Data.Event ~= 'Admin:Set:Time:Weather' then
        TriggerEvent('fw-logs:Server:Log', 'admin', 'Command Ran', ("User: [%s] - %s - %s \nData: ```json\n %s ```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, json.encode(Data, {indent = 2})), 'red')
    end
end)

RegisterServerEvent('Admin:Revive:In:Distance')
AddEventHandler('Admin:Revive:In:Distance', function()
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local AllPlayers = FW.Functions.GetPlayers()
    local PlayerCoords = GetEntityCoords(GetPlayerPed(source))
    for _, Id in pairs(AllPlayers) do
        local TargetCoords = GetEntityCoords(GetPlayerPed(Id))
        local Distance = #(PlayerCoords - TargetCoords)
        if Distance < 7.0 then
            TriggerClientEvent('fw-medical:Client:Revive', Id)
        end
    end
end)

RegisterServerEvent('fw-admin:Server:Teleport:Player')
AddEventHandler('fw-admin:Server:Teleport:Player', function(Target, Type)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        if Type == 'Goto' then
            local TargetCoords = GetEntityCoords(GetPlayerPed(Target))
            TriggerClientEvent('fw-admin:Client:Teleport:Player', source, TargetCoords)
        else
            local TargetCoords = GetEntityCoords(GetPlayerPed(source))
            TriggerClientEvent('fw-admin:Client:Teleport:Player', Target, TargetCoords)
        end
    end
end)

RegisterServerEvent('fw-admin:Server:Open:Clothing')
AddEventHandler('fw-admin:Server:Open:Clothing', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        if Target == source then
            TriggerClientEvent('fw-admin:Client:Force:Close', source)
        end
        TriggerClientEvent('fw-clothes:Client:OpenClothesMenu', Target, "Creation")
    end
end)

RegisterServerEvent('fw-admin:Server:Revive:Target')
AddEventHandler('fw-admin:Server:Revive:Target', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TriggerClientEvent('fw-medical:Client:Revive', TPlayer.PlayerData.source)
    end
end)

RegisterServerEvent('fw-admin:Server:Remove:Stress')
AddEventHandler('fw-admin:Server:Remove:Stress', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TriggerClientEvent('fw-admin:Client:Remove:Stress', TPlayer.PlayerData.source)
    end
end)

RegisterServerEvent('fw-admin:Server:Set:Model')
AddEventHandler('fw-admin:Server:Set:Model', function(Target, Model)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TriggerClientEvent('fw-admin:Client:SetModel', Target, Model)
    end
end)

RegisterServerEvent('fw-admin:Server:Reset:Skin')
AddEventHandler('fw-admin:Server:Reset:Skin', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TriggerClientEvent('fw-admin:Client:Reset:Skin', TPlayer.PlayerData.source)
    end
end)

RegisterServerEvent('fw-admin:Server:Set:Armor')
AddEventHandler('fw-admin:Server:Set:Armor', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TriggerClientEvent('fw-admin:Client:Armor:Up', Target)
    end
end)

RegisterServerEvent('fw-admin:Server:Set:Food:Drink')
AddEventHandler('fw-admin:Server:Set:Food:Drink', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TPlayer.Functions.SetMetaData('hunger', 100)
        TPlayer.Functions.SetMetaData('thirst', 100)
    end
end)

RegisterServerEvent('fw-admin:Server:Request:Job')
AddEventHandler('fw-admin:Server:Request:Job', function(Target, Job, Grade)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TPlayer.Functions.SetJob(Job, Grade)
        TriggerClientEvent('FW:Notify', source, GetPlayerName(Target) .. " zijn job veranderd naar: " .. Job .. " (Grade: " .. Grade .. ")", "success")
    end
end)

RegisterServerEvent('fw-admin:Server:Fling:Player')
AddEventHandler('fw-admin:Server:Fling:Player', function(Target)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Target))
    if TPlayer ~= nil then
        TriggerClientEvent('fw-admin:Client:Fling:Player', Target)
    end
end)

RegisterNetEvent('Admin:RequestMoney')
AddEventHandler('Admin:RequestMoney', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    if Result.action == 'give' then
        TPlayer.Functions.AddMoney(Result.type, tonumber(Result.amount))
        TriggerClientEvent('FW:Notify', source, GetPlayerName(Result.player) .. " ontvangt €" .. Result.amount .. " " .. Result.type .. '!', "success")
    else
        TPlayer.Functions.SetMoney(Result.type, tonumber(Result.amount))
        TriggerClientEvent('FW:Notify', source, "Geld van " .. GetPlayerName(Result.player) .. " gezet naar €" .. Result.amount .. " " .. Result.type .. '!', "success")
    end
end)

RegisterNetEvent('Admin:Wipe:Inventory')
AddEventHandler('Admin:Wipe:Inventory', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end
    
    TPlayer.Functions.ClearInventory()
    Player.Functions.Notify("Inventory van " .. GetPlayerName(Result.player) .. " is gewiped.", "success")
end)

RegisterNetEvent('Admin:Spawn:Item')
AddEventHandler('Admin:Spawn:Item', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    local Amount = math.min(tonumber(Result.amount) or 1, 100)
    local ItemName = Result.item
    TriggerClientEvent('FW:Notify', source, "Je gaf " .. Amount .. 'x ' .. ItemName .. ' (' .. Result.customType .. ') aan ' .. GetPlayerName(Result.player) .. "!", "success")
    TPlayer.Functions.AddItem(ItemName, Amount, false, nil, true, Result.customType)
end)

RegisterNetEvent('Admin:Remove:Item')
AddEventHandler('Admin:Remove:Item', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    if TPlayer.Functions.RemoveItemByName(Result.item, tonumber(Result.amount) or 1, true) then
        TriggerClientEvent('FW:Notify', source, "Je verwijderde " .. Result.amount .. 'x ' .. Result.item .. ' van ' .. GetPlayerName(Result.player) .. "!", "success")
    else
        TriggerClientEvent('FW:Notify', source, "Item " .. Result.item .. " was niet verwijderd.. (Amuunt: " .. Result.amount .. ' | Speler: ' .. GetPlayerName(Result.player) .. "!", "error")
    end
end)

RegisterNetEvent('Admin:Set:High:Command')
AddEventHandler('Admin:Set:High:Command', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    if Result.state:lower() == 'true' then
        TPlayer.Functions.SetMetaData("ishighcommand", true)
        TriggerClientEvent('FW:Notify', TPlayer.PlayerData.source, 'Je bent nu een leiding gevende!', 'success')
        TriggerClientEvent('FW:Notify', source, 'Speler is nu een leiding gevende!', 'success')
        TriggerEvent('fw-logs:Server:Log', 'police', 'High Command Set', ("User: [%s] - %s - %s %s\nTarget: [%s] - %s - %s %s\nState: true"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, TPlayer.PlayerData.source, TPlayer.PlayerData.citizenid, TPlayer.PlayerData.charinfo.firstname, TPlayer.PlayerData.charinfo.lastname), 'green')
    else
        TPlayer.Functions.SetMetaData("ishighcommand", false)
        TriggerClientEvent('FW:Notify', TPlayer.PlayerData.source, 'Je bent geen leiding gevende meer!', 'error')
        TriggerClientEvent('FW:Notify', source, 'Speler is GEEN leiding gevende meer!', 'error')
        TriggerEvent('fw-logs:Server:Log', 'police', 'High Command Set', ("User: [%s] - %s - %s %s\nTarget: [%s] - %s - %s %s\nState: false"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, TPlayer.PlayerData.source, TPlayer.PlayerData.citizenid, TPlayer.PlayerData.charinfo.firstname, TPlayer.PlayerData.charinfo.lastname), 'error')
    end
end)

RegisterNetEvent('Admin:Set:Ammo')
AddEventHandler('Admin:Set:Ammo', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    TriggerClientEvent('fw-weapons:Client:SetAmmo', TPlayer.PlayerData.source, tonumber(Result.amount))
end)

RegisterNetEvent('Admin:Request:Gang')
AddEventHandler('Admin:Request:Gang', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    TPlayer.Functions.SetGang(tostring(Result.gang))
    TriggerClientEvent('FW:Notify', source, "Gang gezet van " .. GetPlayerName(Result.player) .. " naar " .. Result.gang .. "!", "success")
end)

RegisterNetEvent('Admin:Toggle:Cuffs')
AddEventHandler('Admin:Toggle:Cuffs', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    TriggerClientEvent("fw-police:client:get:cuffed", TPlayer.PlayerData.source, source)
end)

RegisterNetEvent("Admin:Open:Inventory")
AddEventHandler("Admin:Open:Inventory", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    TriggerClientEvent('fw-admin:Client:OpenInventory', source, TPlayer.PlayerData.citizenid)
end)

RegisterNetEvent("Admin:Announce")
AddEventHandler("Admin:Announce", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    TriggerClientEvent('chatMessage', -1, "Mededeling", "error", Result.msg)
end)

RegisterNetEvent("Admin:Kick:Player")
AddEventHandler("Admin:Kick:Player", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    DropPlayer(TPlayer.PlayerData.source, 'Je werd gekickt van de server, reden:\n' .. Result.reason .. '\n\n🔸 Indien je vragen hebt maak een ticket aan in onze discord: discord.gg/clarityrp')
    TriggerClientEvent('FW:Notify', source, GetPlayerName(Result.player) .. " is gekickt voor " .. Result.reason .. "!", "success")
end)

RegisterNetEvent("Admin:Ban:Player")
AddEventHandler("Admin:Ban:Player", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    local BanTime = BanTimes[Result.expire]
    local ExpireTime = tonumber(os.time() + BanTime)
    if ExpireTime > 3132036000 then ExpireTime = 3132036000 end

    local TimeTable = os.date('*t', ExpireTime)

    exports['ghmattimysql']:execute('INSERT INTO server_bans (name, steam, license, reason, expire, bannedby) VALUES (@name, @steam, @license, @reason, @expire, @bannedby)', {
        ['@name'] = GetPlayerName(TPlayer.PlayerData.source),
        ['@steam'] = GetPlayerIdentifiers(TPlayer.PlayerData.source)[1],
        ['@license'] = GetPlayerIdentifiers(TPlayer.PlayerData.source)[2],
        ['@reason'] = Result.reason,
        ['@expire'] = ExpireTime,
        ['@bannedby'] = GetPlayerName(source)
    })

    TriggerEvent('fw-logs:Server:Log', 'bans', 'Player Banned', GetPlayerName(TPlayer.PlayerData.source)..' werd gebanned door '..GetPlayerName(source)..' met de reden '..Result.reason, 'red')

    if ExpireTime >= 3132036000 then
        DropPlayer(TPlayer.PlayerData.source, 'Je werd verbannen met de reden:\n' .. Result.reason .. '\n\nJouw ban is permanent.\n🔸 Indien mogelijk kan je nog een ticket aanmaken in onze discord: discord.gg/clarityrp')
    else
        DropPlayer(TPlayer.PlayerData.source, 'Je werd verbannen met de reden:\n' .. Result.reason .. '\n\nBan vervalt over: ' .. TimeTable['day'] .. '/' .. TimeTable['month'] .. '/' .. TimeTable['year'] .. ' ' .. TimeTable['hour'] .. ':' .. TimeTable['min'] .. '\n🔸 Indien mogelijk kan je nog een ticket aanmaken in onze discord: discord.gg/clarityrp')
    end
end)

local Blippers = {}
RegisterNetEvent("fw-admin:Server:SetBlipsState")
AddEventHandler("fw-admin:Server:SetBlipsState", function(State)
    local Source = source
    Blippers[Source] = State
    if not Blippers[Source] then
        return
    end

    Citizen.CreateThread(function()
        while Blippers[Source] do
            RefreshPlayerBlips(Source, false)
            Citizen.Wait(2000)
        end
        Citizen.SetTimeout(1000, function()
            TriggerClientEvent("fw-admin:Client:UpdatePlayerBlips", Source, {}, true)
        end)
    end)
end)

function RefreshPlayerBlips(Source, Clear)
    local Players = FW.Functions.GetPlayers()
    local BlipData = {}
    for k, v in pairs(Players) do
        local Player = FW.Functions.GetPlayer(v)
        table.insert(BlipData, {
            Id = Player.PlayerData.source,
            Name = Player.PlayerData.name,
            CharName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
            Coords = GetEntityCoords(GetPlayerPed(Player.PlayerData.source)),
            Heading = math.ceil(GetEntityHeading(GetPlayerPed(Player.PlayerData.source))),
        })
    end
    
    TriggerClientEvent("fw-admin:Client:UpdatePlayerBlips", Source, BlipData, Clear)
end

RegisterNetEvent("Admin:Set:Time:Weather")
AddEventHandler("Admin:Set:Time:Weather", function(Data)
    if Data['weather'] ~= nil and Data['weather'] ~= '' then
        TriggerEvent('fw-sync:Server:SetCurrentWeather', Data['weather'])
    end

    if Data['time-hours'] ~= nil and Data['time-hours'] ~= '' then
        TriggerEvent('fw-sync:Server:SetWeatherTime', tonumber(Data['time-hours']))
    end
end)

RegisterNetEvent("Admin:Blacklist:Scenes")
AddEventHandler("Admin:Blacklist:Scenes", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Result.state == 'true' then
        Player.Functions.Notify("Speler (" .. TPlayer.PlayerData.name .. ") scenes geblacklisted voor " .. Result.reason .. "!", "error")
    else
        Player.Functions.Notify("Speler (" .. TPlayer.PlayerData.name .. ") scene blacklist verwijderd!", "success")
    end

    TriggerEvent('fw-scenes:Server:UpdateBlacklist', {
        Steam = TPlayer.PlayerData.steam,
        State = Result.state == 'true' and true or false,
        Reason = #Result.reason > 0 and Result.reason or 'Geen reden opgegeven.'
    })
end)

RegisterNetEvent('Admin:Server:SpawnBadge')
AddEventHandler('Admin:Server:SpawnBadge', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    if #Result.Badge == 0 then return end

    local ItemInfo = {
        Name = Result.Name,
        Rank = Result.Rang,
        Callsign = #Result.Callsign > 0 and Result.Callsign or '',
        Image = Result.Image,
        Department = Result.Department,
    }

    Player.Functions.AddItem("identification-badge", 1, false, ItemInfo, true, Result.Badge)
end)

RegisterNetEvent('Admin:Server:SpawnSpray')
AddEventHandler('Admin:Server:SpawnSpray', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    if #Result.Spray == 0 then return end
    TPlayer.Functions.AddItem("gang-spray", 1, false, false, true, Result.Spray)
end)

RegisterNetEvent('Admin:Server:CreateBook')
AddEventHandler('Admin:Server:CreateBook', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    TriggerClientEvent('fw-admin:Client:Force:Close', source)
    TriggerClientEvent("fw-books:Client:WriteBook", source, true)
end)

RegisterNetEvent('Admin:Server:SetGangOwner')
AddEventHandler('Admin:Server:SetGangOwner', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    if exports['fw-laptop']:SetGangLeader(Result.Gang, TPlayer.PlayerData.citizenid) then
        Player.Functions.Notify("Leiding van " .. Result.Gang .. " gezet naar " .. TPlayer.PlayerData.citizenid, "success")
    end
end)

RegisterNetEvent('Admin:Server:GiveStarterCar')
AddEventHandler('Admin:Server:GiveStarterCar', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    local Vehicles = exports['ghmattimysql']:executeSync("SELECT COUNT(*) as Count FROM `player_vehicles` WHERE `citizenid` = ? AND `metadata` LIKE ?", {
        TPlayer.PlayerData.citizenid,
        '%"Gifted":true%'
    })

    if Vehicles[1].Count > 0 then
        return Player.Functions.Notify("Speler heeft al een Gifted voertuig...", "error")
    end

    local SharedData = FW.Shared.HashVehicles[GetHashKey("rhapsody")]

    local Plate = FW.Functions.GeneratePlate()
    local VIN = FW.Functions.GenerateVin()

    exports['ghmattimysql']:executeSync("INSERT INTO `player_vehicles` (`citizenid`, `vehicle`, `plate`, `vinnumber`, `garage`, `state`, `metadata`) VALUES (?, ?, ?, ?, ?, ?, ?)", {
        TPlayer.PlayerData.citizenid,
        "rhapsody",
        Plate,
        VIN,
        'apartment_1',
        'in',
        json.encode({ Body = 1000.0, Engine = 1000.0, Fuel = 100.0, Gifted = true }),
    })

    exports['ghmattimysql']:executeSync("INSERT INTO `vehicles_ownership` (seller, buyer, plate, price, timestamp) VALUES (?, ?, ?, ?, ?)", {
        "1001",
        TPlayer.PlayerData.citizenid,
        Plate,
        0,
        os.time() * 1000
    })

    local Date = os.date("*t", os.time())
    TriggerEvent('fw-phone:Server:Documents:AddDocument', '1001', {
        Type = 3,
        Title = SharedData.Name .. ' - ' .. Plate,
        Content = (exports['fw-businesses']:GetVehicleRegistration()):format(SharedData.Name, "rhapsody", Plate, VIN, TPlayer.PlayerData.charinfo.firstname .. ' ' .. TPlayer.PlayerData.charinfo.lastname, "De Staat", Date.day .. '/' .. Date.month .. '/' .. Date.year .. ' ' .. Date.hour .. ':' .. Date.min, "Gratis"),
        Signatures = {
            { Signed = true, Name = 'De Staat', Timestamp = os.time() * 1000, Cid = '1001' },
            { Signed = true, Name = TPlayer.PlayerData.charinfo.firstname .. ' ' .. TPlayer.PlayerData.charinfo.lastname, Timestamp = os.time() * 1000, Cid = TPlayer.PlayerData.citizenid },
        },
        Sharees = { TPlayer.PlayerData.citizenid },
        Finalized = 1,
    })

    TPlayer.Functions.Notify("Je hebt een starters auto ontvangen!", "success")
    Player.Functions.Notify("Je hebt een starters auto weggegeven!", "success")
end)

RegisterNetEvent('Admin:Server:DeleteClosestSpray')
AddEventHandler('Admin:Server:DeleteClosestSpray', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    TriggerClientEvent("fw-graffiti:Client:RemoveSpray", source)
end)

RegisterNetEvent('Admin:Server:Jumpscare')
AddEventHandler('Admin:Server:Jumpscare', function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end
    
    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end

    TriggerClientEvent("fw-ui:Client:DoJumpscare", TPlayer.PlayerData.source)
end)

RegisterNetEvent("Admin:Server:EditCharachterName")
AddEventHandler("Admin:Server:EditCharachterName", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    local TPlayer = FW.Functions.GetPlayer(tonumber(Result.player))
    if TPlayer == nil then return end
    
    TPlayer.Functions.SetCharData('firstname', Result.firstname)
    TPlayer.Functions.SetCharData('lastname', Result.lastname)

    Player.Functions.Notify("Naam van " .. TPlayer.PlayerData.citizenid .. " veranderd naar " .. Result.firstname .. " " .. Result.lastname, "success")
    TPlayer.Functions.Notify("Je karakter naam is veranderd naar " .. Result.firstname .. " " .. Result.lastname .. '!')
end)

RegisterNetEvent("Admin:Server:CreateSpray")
AddEventHandler("Admin:Server:CreateSpray", function(Result)
    if not IsPlayerAdmin(source) then print(source .. " probeerde een admin optie te executen, maar hij is geen admin... Cheaterrrrrrr") return end

    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    if not Result.Gang then return end

    TriggerClientEvent("fw-graffiti:Client:PlaceSpray", Source, Result.Gang, true)
end)

FW.Commands.Add("admin", "Open het admin menu.", {}, false, function(Source, Args)
    if not IsPlayerAdmin(Source) then return end
    TriggerClientEvent('fw-admin:Client:Try:Open:Menu', Source)
end)

-- Report
RegisterNetEvent('qb-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    if FW.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if FW.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "Admin Report - " .. name .. " (" .. targetSrc .. ")", "warning", msg)
        end
    end
end)

FW.Commands.Add("report", "Verstuur een report. Player Reports en Refunds gaan via een ticket. Gebruik dus alleen wanneer écht nodig.", {{name="bericht", help="Bericht die je wilt sturen"}}, true, function(source, args)
    local src = source
    local msg = table.concat(args, ' ')
    local Player = FW.Functions.GetPlayer(source)
    TriggerClientEvent('FW:Notify', source, "Je report is ontvangen. Indien je geen antwoord krijgt maak dan een ticket aan!", "success")
    TriggerClientEvent('qb-admin:client:SendReport', -1, GetPlayerName(src), src, msg)
    TriggerEvent('fw-logs:Server:Log', 'reports', 'Report Sent', ("User: [%s] - %s - %s %s\nReply: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, msg), 'green')
end)

FW.Commands.Add("reportr", "Reply op een report", {}, false, function(source, args)
    local PlayerId = tonumber(args[1])
    table.remove(args, 1)
    local Message = table.concat(args, " ")
    local OtherPlayer = FW.Functions.GetPlayer(PlayerId)
    local Player = FW.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chatMessage', PlayerId, "ADMIN - "..GetPlayerName(source), "reportr", Message)
        TriggerEvent('fw-logs:Server:Log', 'reports', 'Report Reply', ("User: [%s] - %s - %s %s\nTarget: [%s] - %s - %s %s\nReply: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, OtherPlayer.PlayerData.source, OtherPlayer.PlayerData.citizenid, OtherPlayer.PlayerData.charinfo.firstname, OtherPlayer.PlayerData.charinfo.lastname, Message), 'purple')
        for k, v in pairs(FW.Functions.GetPlayers()) do
            if FW.Functions.HasPermission(v, "admin") then
                if FW.Functions.IsOptin(v) then
                    TriggerClientEvent('chatMessage', v, "ReportReply("..source..") - "..GetPlayerName(source), "reportr", Message)
                end
            end
        end
    else
        TriggerClientEvent('FW:Notify', source, "Persoon is niet online", "error")
    end
end, "admin")

FW.Commands.Add('reporttoggle', 'Toggle Incoming Reports (Admin Only)', {}, false, function(source, args)
    local src = source
    FW.Functions.ToggleOptin(src)
    if FW.Functions.IsOptin(src) then
        TriggerClientEvent('FW:Notify', source, "Je krijgt WEL reports", "success")
    else
        TriggerClientEvent('FW:Notify', source, "Je krijgt GEEN reports", "error")
    end
end, 'admin')

FW.Commands.Add('s', 'Send A Message To All Staff (Admin Only)', {{name='message', help='Message'}}, true, function(source, args)
    local msg = table.concat(args, ' ')
    TriggerClientEvent('qb-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, 'admin')

RegisterNetEvent('qb-admin:server:Staffchat:addMessage', function(name, msg)
    local src = source
    if FW.Functions.HasPermission(src, 'admin') or IsPlayerAceAllowed(src, 'command') then
        if FW.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "Staff Chat - " .. name, "error", msg)
        end
    end
end)

AddEventHandler('playerDropped', function(Reason)
    for k, v in pairs(Blippers) do
        RefreshPlayerBlips(k, true)
    end
end)

-- TX Stuff
RegisterNetEvent("txAdmin:events:announcement")
AddEventHandler("txAdmin:events:announcement", function(eventData)
    for i = 1, 3, 1 do
        TriggerClientEvent('chatMessage', -1, "Mededeling", "error", eventData.message)
    end
end)

RegisterNetEvent("txAdmin:events:playerDirectMessage")
AddEventHandler("txAdmin:events:playerDirectMessage", function(eventData)
    TriggerClientEvent('chatMessage', eventData.target, "DM - " .. eventData.author, "reportr", eventData.message)
end)

RegisterNetEvent("txAdmin:events:scheduledRestart")
AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    TriggerClientEvent('chatMessage', -1, "Restart", "error", eventData.translatedMessage)

    if eventData.secondsRemaining <= 60 then
        PullRepositories()
    end
end)

RegisterNetEvent("txAdmin:events:playerWarned")
AddEventHandler("txAdmin:events:playerWarned", function(eventData)
    TriggerClientEvent('chatMessage', eventData.target, "WAARSCHUWING (#" .. eventData.actionId .. ")", "error", eventData.reason)
end)