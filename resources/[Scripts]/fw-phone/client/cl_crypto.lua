RegisterNUICallback("Crypto/GetCrypto", function(Data, Cb)
    Cb(Config.Crypto)
end)

RegisterNUICallback("Crypto/BuyCrypto", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Crypto:BuyCrypto", Data)
    if Result.Success then
        UpdatePlayerData()
    end
    Cb(Result)
end)

RegisterNUICallback("Crypto/TransferCrypto", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Crypto:TransferCrypto", Data)
    if Result.Success then
        UpdatePlayerData()
    end
    Cb(Result)
end)