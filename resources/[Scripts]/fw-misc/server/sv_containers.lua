Citizen.CreateThread(function()
    -- local New = {
    -- 
    -- }
    
    -- for k, v in pairs(New) do
    --     exports['ghmattimysql']:executeSync("INSERT INTO `server_containers` (`containerid`, `boxzone`) VALUES (@ContainerId, @BoxZone)", {
    --         ['@ContainerId'] = v.name,
    --         ['@BoxZone'] = json.encode({
    --             center = v.center,
    --             length = v.length,
    --             width = v.width,
    --             heading = v.heading,
    --             minZ = v.minZ,
    --             maxZ = v.maxZ,
    --         })
    --     })
    -- end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `server_containers`")

    local Containers = {}
    for k, v in pairs(Result) do
        Containers[v.id] = {
            ContainerId = v.containerid,
            Owner = v.owner,
            Pin = v.pincode,
            HackDate = v.hack_date,
            Coords = json.decode(v.coords),
        }
    end

    Config.Containers = Containers
end)

FW.Functions.CreateCallback("fw-misc:Server:GetContainers", function(Source, Cb)
    Cb(Config.Containers)
end)

FW.Functions.CreateCallback("fw-misc:Server:GetContainerMeta", function(Source, Cb, ContainerId)
    local Result = exports['ghmattimysql']:executeSync("SELECT `meta` FROM `server_containers` WHERE id = ?", {
        ContainerId
    })

    Cb(json.decode(Result[1].meta))
end)

FW.Functions.CreateCallback("fw-misc:Server:IsContainerRobbable", function(Source, Cb, ContainerId)
    local Container = Config.Containers[ContainerId]
    if Container == nil then return end

    Cb(os.time() > Container.HackDate + (86400 * 14)) -- 14 days
end)

FW.RegisterServer("fw-misc:Server:SaveContainerMeta", function(Source, ContainerId, Meta, AddItems)
    exports['ghmattimysql']:executeSync("UPDATE `server_containers` SET `meta` = ? WHERE id = ?", {
        json.encode(Meta),
        ContainerId
    })

    if AddItems then
        local Player = FW.Functions.GetPlayer(Source)
        if Player == nil then return end

        for k, v in pairs(AddItems) do
            Player.Functions.AddItem(k, v, false, false, true)
        end
    end
end)

RegisterNetEvent("fw-misc:Server:Container:SetContainerHack")
AddEventHandler("fw-misc:Server:Container:SetContainerHack", function(ContainerId)
    if Config.Containers[ContainerId] == nil then return end

    local Time = os.time()
    Config.Containers[ContainerId].HackDate = Time
    TriggerClientEvent("fw-misc:Client:SyncContainer", -1, ContainerId, 'HackDate', Time)
    exports['ghmattimysql']:executeSync("UPDATE `server_containers` SET `hack_date` = @HackDate WHERE `id` = @Id", {
        ['@HackDate'] = Time,
        ['@Id'] = ContainerId
    })
end)

RegisterNetEvent('fw-misc:Server:ChangeContainerCode')
AddEventHandler('fw-misc:Server:ChangeContainerCode', function(ContainerId, Pin)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Container = Config.Containers[ContainerId]
    if Container == nil then return Player.Functions.Notify("Deze container bestaat niet..", "error") end

    if not exports['fw-businesses']:HasPlayerBusinessPermission("Cortainer", Source, "StashAccess") then
        return Player.Functions.Notify("Geen toegang..", "error")
    end

    Config.Containers[ContainerId].Pin = Pin
    TriggerClientEvent("fw-misc:Client:SyncContainer", -1, ContainerId, 'Pin', Pin)
    exports['ghmattimysql']:executeSync("UPDATE `server_containers` SET `pincode` = @Pin WHERE `id` = @Id", {
        ['@Pin'] = Pin,
        ['@Id'] = ContainerId
    })
    Player.Functions.Notify("Container pincode aangepast!", "success")
end)

RegisterNetEvent("fw-misc:Server:SetContainerOwnership")
AddEventHandler("fw-misc:Server:SetContainerOwnership", function(ContainerId, Cid)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Cid)
    if Target == nil then return end

    local Container = Config.Containers[ContainerId]
    if Container == nil then return Player.Functions.Notify("Deze container bestaat niet..", "error") end

    if not exports['fw-businesses']:HasPlayerBusinessPermission("Cortainer", Source, "StashAccess") then
        return Player.Functions.Notify("Geen toegang..", "error")
    end

    Config.Containers[ContainerId].Owner = Cid
    TriggerClientEvent("fw-misc:Client:SyncContainer", -1, ContainerId, 'Owner', Cid)

    exports['ghmattimysql']:executeSync("UPDATE `server_containers` SET `owner` = @Cid WHERE `id` = @Id", {
        ['@Cid'] = Cid,
        ['@Id'] = ContainerId
    })

    Player.Functions.Notify("Container eigenaarschap overgedragen!", "success")
    Target.Functions.Notify("Container eigenaarschap ontvangen!", "success")
end)