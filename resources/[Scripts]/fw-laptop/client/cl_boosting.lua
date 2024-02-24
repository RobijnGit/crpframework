RegisterNUICallback("Boosting/GetData", function(Data, Cb)
    local Result = exports['fw-boosting']:GetData(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/GetContracts", function(Data, Cb)
    local Result = exports['fw-boosting']:GetContracts(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/GetAuctions", function(Data, Cb)
    local Result = exports['fw-boosting']:GetAuctions(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/SetQueue", function(Data, Cb)
    local Result = exports['fw-boosting']:SetQueue(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/StartContract", function(Data, Cb)
    local Result = exports['fw-boosting']:StartContract(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/DeclineContract", function(Data, Cb)
    local Result = exports['fw-boosting']:DeclineContract(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/CancelContract", function(Data, Cb)
    local Result = exports['fw-boosting']:CancelContract(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/AuctionContract", function(Data, Cb)
    local Result = exports['fw-boosting']:AuctionContract(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/TransferContract", function(Data, Cb)
    local Result = exports['fw-boosting']:TransferContract(Data)
    Cb(Result)
end)

RegisterNUICallback("Boosting/PlaceBid", function(Data, Cb)
    local Result = exports['fw-boosting']:PlaceBid(Data)
    Cb(Result)
end)