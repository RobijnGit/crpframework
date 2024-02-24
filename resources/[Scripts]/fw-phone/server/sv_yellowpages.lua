YellowPages = {
    Posts = {}
}

FW.Functions.CreateCallback("fw-phone:Server:YellowPages:GetPosts", function(Source, Cb)
    Cb(YellowPages.Posts)
end)

FW.Functions.CreateCallback("fw-phone:Server:YellowPages:PostAd", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Data.Msg == nil then return Cb(false) end

    local PostId = #YellowPages.Posts + 1
    YellowPages.Posts[PostId] = {
        Id = PostId,
        Cid = Player.PlayerData.citizenid,
        Msg = Data.Msg,
        Sender = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname),
        Phone = Player.PlayerData.charinfo.phone,
    }

    TriggerClientEvent("fw-phone:Client:YellowPages:PostAd", -1, PostId, YellowPages.Posts[PostId])
    TriggerEvent("fw-logs:Server:Log", 'yellowpages', "Post Added", ("User: [%s] - %s - %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Msg), "green")

    Cb(true)
end)

FW.Functions.CreateCallback("fw-phone:Server:YellowPages:RemoveAd", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Index = 0

    for k, v in pairs(YellowPages.Posts) do
        if v.Cid == Player.PlayerData.citizenid then
            Index = k
            break
        end
    end

    if YellowPages.Posts[Index] == nil then return Cb(false) end

    TriggerEvent("fw-logs:Server:Log", 'yellowpages', "Post Removed", ("User: [%s] - %s - %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, YellowPages.Posts[Index].Msg), "red")
    table.remove(YellowPages.Posts, Index)
    TriggerClientEvent("fw-phone:Client:YellowPages:RemoveAd", -1, Index)

    Cb(true)
end)

FW.Commands.Add("clearyp", "Clear all Yellow Pages", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    YellowPages.Posts = {}
    TriggerClientEvent("fw-phone:Client:YellowPages:ResetAds", -1)
end, "admin")

AddEventHandler("playerDropped", function(Reason)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if not Player then return end

    local Cid = Player.PlayerData.citizenid

    Citizen.SetTimeout((1000 * 60) * 15, function()
        local CurrentPlayer = FW.Functions.GetPlayerByCitizenId(Cid)
        if not CurrentPlayer then
            local Indexes = {}
            for k, v in pairs(YellowPages.Posts) do
                if v.Cid == Player.PlayerData.citizenid then
                    table.insert(Indexes, k)
                end
            end

            for k, v in pairs(Indexes) do
                table.remove(YellowPages.Posts, v)
                TriggerClientEvent("fw-phone:Client:YellowPages:RemoveAd", -1, v)
            end
        end
    end)
end)