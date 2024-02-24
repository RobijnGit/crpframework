-- // Events \\ --

FW.Commands.Add("alterprio", "Zet iemand zijn prio level.", {
    { name = "id", help = "" },
    { name = "level", help = "0-80" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end

    local Priority = tonumber(Args[2])
    if Priority < 0 then
        return Player.Functions.Notify("Prio level moet minstens 0 zijn..", "error")
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_extra` WHERE `steam` = ?", { Target.PlayerData.steam })
    if Result[1] then
        exports['ghmattimysql']:executeSync("UPDATE `server_extra` SET `priority` = ? WHERE `steam` = ?", { Priority, Target.PlayerData.steam })
    else
        exports['ghmattimysql']:executeSync("INSERT INTO `server_extra` (`steam`, `license`, `name`, `permission`, `priority`) VALUES (?, ?, ?, ?, ?)", { Target.PlayerData.steam, Target.PlayerData.license, Target.PlayerData.name, 'user', Priority })
    end

    Player.Functions.Notify("Queue priority updated: " .. Priority)
    -- Target.Functions.Notify("Queue priority set: " .. Priority .. '!', "success")
    Config.PriorityList[Target.PlayerData.steam] = Priority
end, 'admin')

FW.Commands.Add("checkprio", "Vraag de prio level aan van een speler.", {
    { name = "id", help = "" },
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_extra` WHERE `steam` = ?", { Target.PlayerData.steam })
    if Result[1] then
        Player.Functions.Notify("Priority is: " .. Result[1].priority)
    else
        Player.Functions.Notify("Priority is: 0")
    end
end, 'admin')

RegisterNetEvent('fw-queue:Server:Set:Queue:Priority')
AddEventHandler('fw-queue:Server:Set:Queue:Priority', function(Target, Priority)
    local SteamId, PlayerName = GetPlayerIdentifiers(Target)[1], GetPlayerName(Target)
    local HasPriority = Config.PriorityList[SteamId] ~= nil
    if HasPriority then
        -- DatabaseModule.ExecuteCb("UPDATE `server_priority` SET `priority` = @Priority WHERE `steam` = @Steam", {
        --     ['@Steam'] = SteamId,
        --     ['@Priority'] = Priority,
        -- }, function()
        --     TriggerClientEvent('fw-ui:Client:Notify', Target, "queue", "Your queue priority changed to: "..Priority, 'success', 7500)
        -- end)
    else
        -- DatabaseModule.ExecuteCb("INSERT INTO `server_priority` (name, steam, priority) VALUES (@Name, @Steam, @Priority)", {
        --     ['@Name'] = PlayerName,
        --     ['@Steam'] = SteamId,
        --     ['@Priority'] = Priority,
        -- }, function()
        --     TriggerClientEvent('fw-ui:Client:Notify', Target, "queue", "Your queue priority changed to: "..Priority, 'success', 7500)
        -- end)
    end
end)

-- // Functions \\ --

function GetPlayerPriority(SteamId)
    if Config.PriorityList[SteamId] == nil then return 0 end
    return Config.PriorityList[SteamId]
end

function LoadPriorityList()
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM server_extra")

    for k, v in pairs(Result) do
        Config.PriorityList[v.steam] = v.priority
    end
end