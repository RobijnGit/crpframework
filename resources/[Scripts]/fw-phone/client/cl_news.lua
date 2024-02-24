RegisterNUICallback("News/IsJournalist", function(Data, Cb)
    if Data.Network == 'weazelnews' then
        local Job = FW.Functions.GetPlayerData().job
        return Cb(Job.name == "news")
    elseif Data.Network == 'bin' then
        local IsJournalist = exports['fw-businesses']:IsPlayerInBusiness("Binsbergen International Network")
        return Cb(IsJournalist)
    end

    Cb(false)
end)

RegisterNUICallback("News/GetArticles", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:News:GetArticles", Data)
    Cb(Result)
end)

RegisterNUICallback("News/SaveArticle", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:News:SaveArticle", Data)
    Cb(Result)
end)

RegisterNUICallback("News/DeleteArticle", function(Data, Cb)
    FW.SendCallback("fw-phone:Server:News:DeleteArticle", Data)
    Cb("Ok")
end)

RegisterNetEvent("fw-phone:Client:News:NewArticle")
AddEventHandler("fw-phone:Client:News:NewArticle", function(NewsApp, NewsNetwork, Title, Author, Content)
    if CurrentApp ~= NewsApp then
        SetAppUnread(NewsApp)
        Notification("new-news-" .. math.random(1, 99999), "fas fa-rss", { "white", "#1d1d1d" }, NewsNetwork, ("TRENDING: %s - %s"):format(Author, Title))
    end
end)