Twitter = {
    Tweets = {}
}

function InitTwitter()
    local Posts = FW.SendCallback("fw-phone:Server:Twitter:GetTweets")
    Twitter.Tweets = Posts
end

function Twitter.SetTweets()
    SendNUIMessage({
        Action = "Twitter/SetTweets",
        Tweets = Twitter.Tweets,
    })
end

RegisterNUICallback("Twitter/GetTweets", function(Data, Cb)
    Cb(Twitter.Tweets)
end)

RegisterNUICallback("Twitter/PostTweet", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Twitter:PostTweet", Data)
    Cb("Ok")
end)

RegisterNUICallback("Twitter/ReportTweet", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Twitter:ReportTweet", Data)
    Cb("Ok")
end)

RegisterNetEvent("fw-phone:Client:Twitter:PostTweet")
AddEventHandler("fw-phone:Client:Twitter:PostTweet", function(TweetId, Data)
    Twitter.Tweets[TweetId] = Data

    if CurrentApp == 'twatter' then
        Citizen.SetTimeout(5, function()
            Twitter.SetTweets()
        end)
    else
        SetAppUnread("twatter")
        if exports['fw-hud']:GetPreferenceById('Notifications.Tweet') then
            Notification("new-twitter-" .. TweetId, "fab fa-twitter", { "white", "#01AFFB" }, "@" .. Data.Sender, Data.Msg)
        end
    end
end)

RegisterNetEvent("fw-phone:Client:Twitter:RemoveTweet")
AddEventHandler("fw-phone:Client:Twitter:RemoveTweet", function(TweetId)
    table.remove(Twitter.Tweets, TweetId)

    if CurrentApp == 'twatter' then
        Citizen.SetTimeout(5, function()
            Twitter.SetTweets()
        end)
    end
end)

RegisterNetEvent("fw-phone:Client:Twitter:ResetTweets")
AddEventHandler("fw-phone:Client:Twitter:ResetTweets", function(TweetId, Data)
    Twitter.Tweets = {}

    if CurrentApp == 'twatter' then
        Citizen.SetTimeout(5, function()
            Twitter.SetTweets()
        end)
    end
end)