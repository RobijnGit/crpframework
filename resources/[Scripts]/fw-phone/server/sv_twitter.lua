Twitter = {
    Tweets = {},
    Reports = {},
}

FW.Functions.CreateCallback("fw-phone:Server:Twitter:GetTweets", function(Source, Cb)
    Cb(Twitter.Tweets)
end)

FW.Functions.CreateCallback("fw-phone:Server:Twitter:PostTweet", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Data.Msg == nil then return Cb(false) end

    local TweetId = #Twitter.Tweets + 1
    Twitter.Tweets[TweetId] = {
        Cid = Player.PlayerData.citizenid,
        Id = TweetId,
        Msg = Data.Msg,
        Sender = string.gsub(("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname), "%s", "_"),
        Timestamp = os.time() * 1000,
    }

    TriggerClientEvent("fw-phone:Client:Twitter:PostTweet", -1, TweetId, Twitter.Tweets[TweetId])
    TriggerEvent("fw-logs:Server:Log", 'twitter', "Tweet Posted", ("User: [%s] - %s - %s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Msg), "green")

    Cb(true)
end)

FW.Functions.CreateCallback("fw-phone:Server:Twitter:ReportTweet", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Twitter.Reports[Data.Id] ~= nil and Twitter.Reports[Data.Id].Reporters[Player.PlayerData.citizenid] then Cb(false) return end

    if Twitter.Reports[Data.Id] == nil then Twitter.Reports[Data.Id] = { Count = 0, Reporters = {} } end
    Twitter.Reports[Data.Id].Count = Twitter.Reports[Data.Id].Count + 1
    Twitter.Reports[Data.Id].Reporters[Player.PlayerData.citizenid] = true

    TriggerEvent("fw-logs:Server:Log", 'twitter', "Tweet Reported", ("User: [%s] - %s - %s\nSender: [%s] - @%s\nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Twitter.Tweets[Data.Id].Cid, Twitter.Tweets[Data.Id].Sender, Data.Msg), "yellow")

    if Twitter.Reports[Data.Id].Count >= 20 then
        TriggerEvent("fw-logs:Server:Log", 'twitter', "Tweet Removed after 20 reports", ("Sender: [%s] - @%s\nMessage: %s"):format(Twitter.Tweets[Data.Id].Cid, Twitter.Tweets[Data.Id].Sender, Data.Msg), "red")
        table.remove(Twitter.Tweets, Data.Id)
        TriggerClientEvent('fw-phone:Client:Twitter:RemoveTweet', -1, Data.Id)
    end

    Cb(true)
end)

FW.Commands.Add("cleartwt", "Clear all twitter", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Twitter.Tweets = {}
    TriggerClientEvent("fw-phone:Client:Twitter:ResetTweets", -1)
end, "admin")

RegisterNetEvent("Admin:Server:PostTwat")
AddEventHandler("Admin:Server:PostTwat", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not FW.Functions.HasPermission(Source, "admin") and not FW.Functions.HasPermission(Source, "god") then
        return print(source .. " tried to post a tweet through admin menu but lacks permission.")
    end

    local TweetId = #Twitter.Tweets + 1
    Twitter.Tweets[TweetId] = {
        Cid = Player.PlayerData.citizenid,
        Id = TweetId,
        Msg = Data.Message,
        Sender = string.gsub(Data.Poster, "%s", "_"),
        Timestamp = os.time() * 1000,
    }

    TriggerClientEvent("fw-phone:Client:Twitter:PostTweet", -1, TweetId, Twitter.Tweets[TweetId])
    TriggerEvent("fw-logs:Server:Log", 'twitter', "Tweet Posted (Admin)", ("User: [%s] - %s - %s\nName: \nMessage: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Poster, Data.Message), "green")
end)