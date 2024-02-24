FW.Functions.CreateCallback("fw-phone:Server:MilkRoad:GetProducts", function(Source, Cb, Network)
    Cb(Config.MilkRoadProducts[Network])
end)

FW.Functions.CreateCallback("fw-phone:Server:MilkRoad:PurchaseProduct", function(Source, Cb, Network, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not IsNetworkEnabled then
        return Cb({Success = false, Msg = "Geen internet toegang.."})
    end

    local Product = Config.MilkRoadProducts[Network][Data.Id]
    if not Product then return Cb({Success = false, Msg = "Ongeldig product"}) end

    local Crypto = Config.Crypto[Product.Costs.CryptoId]

    if not Player.Functions.RemoveCrypto(Crypto.Id, tonumber(Product.Costs.Amount)) then
        Cb({Success = false, Msg = "Niet genoeg crypto"})
        return
    end

    Citizen.CreateThread(function()
        TriggerEvent('fw-phone:Server:Mails:AddMail', 'Dark Market', '#A-1001', "You know where to go.", Source)
        TriggerClientEvent("fw-heists:Client:MarkPickupGPS", Source, vector3(436.31, 2996.2, 41.28))
        while true do
            if #(GetEntityCoords(GetPlayerPed(Source)) - vector3(436.31, 2996.2, 41.28)) < 2.0 then
                Player.Functions.Notify("Je hebt je troep, maak dat je weg komt..", "error")
                Player.Functions.AddItem(Product.Reward.Item, 1, nil, nil, true, Product.Reward.CustomType)

                if Product.Reward.Item == "vpn" then
                    if not IsPlayerInGroup(Player.PlayerData.citizenid) then
                        TriggerEvent("fw-phone:Server:Mails:AddMail", "The Unknown", "Welcome to the dark side.", "Hé, ik merkte dat je een VPN hebt aangeschaft. Je hebt nu de app 'TierUp!' op je telefoon staan. Maak snel een groep aan in deze app om je reputatie op te bouwen... Happy robbing!", Source)
                    end
                end
                
                return
            end

            Citizen.Wait(1500)
        end
    end)

    Cb({Success = true})
end)