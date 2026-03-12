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

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_extra` WHERE `license` = ?", { Target.PlayerData.license })
    if Result[1] then
        exports['ghmattimysql']:executeSync("UPDATE `server_extra` SET `priority` = ? WHERE `license` = ?", { Priority, Target.PlayerData.license })
    else
        exports['ghmattimysql']:executeSync("INSERT INTO `server_extra` (`license`, `name`, `permission`, `priority`) VALUES (?, ?, ?, ?)", { Target.PlayerData.license, Target.PlayerData.name, 'user', Priority })
    end

    Player.Functions.Notify("Queue priority updated: " .. Priority)
    -- Target.Functions.Notify("Queue priority set: " .. Priority .. '!', "success")
    Config.PriorityList[Target.PlayerData.license] = Priority
end, 'admin')

FW.Commands.Add("checkprio", "Vraag de prio level aan van een speler.", {
    { name = "id", help = "" },
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayer(tonumber(Args[1]))
    if Target == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_extra` WHERE `license` = ?", { Target.PlayerData.license })
    if Result[1] then
        Player.Functions.Notify("Priority is: " .. Result[1].priority)
    else
        Player.Functions.Notify("Priority is: 0")
    end
end, 'admin')

RegisterNetEvent('fw-queue:Server:Set:Queue:Priority')
AddEventHandler('fw-queue:Server:Set:Queue:Priority', function(Target, Priority)
    local licenseId, PlayerName = GetPlayerIdentifiers(Target)[1], GetPlayerName(Target)
    local HasPriority = Config.PriorityList[licenseId] ~= nil
    if HasPriority then
        -- DatabaseModule.ExecuteCb("UPDATE `server_priority` SET `priority` = @Priority WHERE `license` = @license", {
        --     ['@license'] = licenseId,
        --     ['@Priority'] = Priority,
        -- }, function()
        --     TriggerClientEvent('fw-ui:Client:Notify', Target, "queue", "Your queue priority changed to: "..Priority, 'success', 7500)
        -- end)
    else
        -- DatabaseModule.ExecuteCb("INSERT INTO `server_priority` (name, license, priority) VALUES (@Name, @license, @Priority)", {
        --     ['@Name'] = PlayerName,
        --     ['@license'] = licenseId,
        --     ['@Priority'] = Priority,
        -- }, function()
        --     TriggerClientEvent('fw-ui:Client:Notify', Target, "queue", "Your queue priority changed to: "..Priority, 'success', 7500)
        -- end)
    end
end)

-- // Functions \\ --

function GetPlayerPriority(licenseId)
    if Config.PriorityList[licenseId] == nil then return 0 end
    return Config.PriorityList[licenseId]
end

function LoadPriorityList()
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM server_extra")

    for k, v in pairs(Result) do
        Config.PriorityList[v.license] = v.priority
    end
end