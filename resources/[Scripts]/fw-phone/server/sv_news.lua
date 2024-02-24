local NetworkLabels = {
    weazelnews = "WeazelNews",
    bin = "Binsbergen International Network"
}

FW.Functions.CreateCallback("fw-phone:Server:News:GetArticles", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_newsarticles` WHERE `network` = ? ORDER BY `timestamp` DESC", {Data.Network})
    for i = 1, #Result, 1 do
        Result[i].images = json.decode(Result[i].images)
    end

    Cb(Result)
end)

FW.Functions.CreateCallback("fw-phone:Server:News:SaveArticle", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Query = "INSERT INTO `phone_newsarticles` (`network`, `title`, `content`, `images`, `author`) VALUES (@Network, @Title, @Content, @Images, @Author)"
    if Data.Id then
        Query = "UPDATE `phone_newsarticles` SET `title` = @Title, `content` = @Content, `images` = @Images WHERE `id` = @Id"
    end

    exports['ghmattimysql']:executeSync(Query, {
        ['@Network'] = Data.Network,
        ['@Id'] = Data.Id or false,
        ['@Title'] = Data.Title,
        ['@Content'] = Data.Content,
        ['@Images'] = json.encode(Data.Images),
        ['@Author'] = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
    })

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `phone_newsarticles` WHERE `network` = ? ORDER BY `timestamp` DESC", {Data.Network})
    for i = 1, #Result, 1 do
        Result[i].images = json.decode(Result[i].images)
    end

    if not Data.Id then
        TriggerClientEvent("fw-phone:Client:News:NewArticle", -1, Data.Network, NetworkLabels[Data.Network], Data.Title, Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname, Data.Content)
    end

    Cb(Result)
end)

FW.Functions.CreateCallback("fw-phone:Server:News:DeleteArticle", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    exports['ghmattimysql']:executeSync("DELETE FROM `phone_newsarticles` WHERE `id` = ?", {Data.id})

    Cb(Result)
end)