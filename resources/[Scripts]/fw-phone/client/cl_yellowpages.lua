YellowPages = {
    Posts = {}
}

function InitYellowPages()
    local Posts = FW.SendCallback("fw-phone:Server:YellowPages:GetPosts")
    YellowPages.Posts = Posts
end

function YellowPages.SetPosts()
    SendNUIMessage({
        Action = "YellowPages/SetPosts",
        Posts = YellowPages.Posts,
    })
end

RegisterNUICallback("YellowPages/GetPosts", function(Data, Cb)
    Cb(YellowPages.Posts)
end)

RegisterNUICallback("YellowPages/PostAd", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:YellowPages:PostAd", Data)
    Cb("Ok")
end)

RegisterNUICallback("YellowPages/RemoveAd", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:YellowPages:RemoveAd", Data)
    Cb("Ok")
end)

RegisterNetEvent("fw-phone:Client:YellowPages:PostAd")
AddEventHandler("fw-phone:Client:YellowPages:PostAd", function(PostId, Data)
    YellowPages.Posts[PostId] = Data
    if CurrentApp == 'yellowpages' then
        Citizen.SetTimeout(5, function()
            YellowPages.SetPosts()
        end)
    else
        SetAppUnread("yellowpages")
    end
end)

RegisterNetEvent("fw-phone:Client:YellowPages:RemoveAd")
AddEventHandler("fw-phone:Client:YellowPages:RemoveAd", function(PostId)
    table.remove(YellowPages.Posts, PostId)
    if CurrentApp == 'yellowpages' then
        Citizen.SetTimeout(5, function()
            YellowPages.SetPosts()
        end)
    end
end)

RegisterNetEvent("fw-phone:Client:YellowPages:ResetAds")
AddEventHandler("fw-phone:Client:YellowPages:ResetAds", function(PostId)
    YellowPages.Posts = {}
    if CurrentApp == 'yellowpages' then
        Citizen.SetTimeout(5, function()
            YellowPages.SetPosts()
        end)
    end
end)