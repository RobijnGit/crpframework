-- Citizen.CreateThread(function()
--     while true do
--         for k, v in pairs(Config.Bankbusters) do
--             if Config.Bankbusters[k].ExpiresIn == nil then
--                 Config.Bankbusters[k].ExpiresIn = v.Time
--             end

--             if v.Expired == false then
--                 Config.Bankbusters[k].ExpiresIn = Config.Bankbusters[k].ExpiresIn - 60

--                 if Config.Bankbusters[k].ExpiresIn <= 0 then
--                     Config.Bankbusters[k].Expired = true
--                     GiveHeistToClaimee(k)

--                     Citizen.SetTimeout((1000 * 60) * 30, function()
--                         Config.Bankbusters[k].Expired = false
--                         Config.Bankbusters[k].ExpiresIn = Config.Bankbusters[k].Time
--                         Config.Bankbusters[k].Claimers = {}
--                     end)
--                 end
--             end
--         end

--         Citizen.Wait(60 * 1000)
--     end
-- end)

FW.Functions.CreateCallback("fw-phone:Server:GetBusters", function(Source, Cb)
    Cb(Config.Bankbusters)
end)

FW.Functions.CreateCallback("fw-phone:Server:ClaimHeist", function(Source, Cb, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Config.Bankbusters[Data.HeistId].Expired then
        Cb({Success = false, Msg = "Heist is verlopen."})
        return
    end

    for k, v in pairs(Config.Bankbusters[Data.HeistId].Claimers) do
        if Player.PlayerData.citizenid == v then
            Cb({Success = false, Msg = "Je hebt de heist al geclaimed."})
            return
        end
    end

    Config.Bankbusters[Data.HeistId].Claimers[#Config.Bankbusters[Data.HeistId].Claimers + 1] = Player.PlayerData.citizenid
    Cb({ Success = true, Claimers = Config.Bankbusters[Data.HeistId].Claimers })
end)

function GiveHeistToClaimee(HeistId)
    if Config.Bankbusters[HeistId] == nil then return end
    if next(Config.Bankbusters[HeistId].Claimers) == nil then return end

    local Winner = math.random(1, #Config.Bankbusters[HeistId].Claimers)
    local Player = FW.Functions.GetPlayerByCitizenId(Config.Bankbusters[HeistId].Claimers[Winner])
    if Player == nil then
        table.remove(Config.Bankbusters[HeistId].Claimers, Winner)
        if #Config.Bankbusters[HeistId].Claimers > 1 then
            GiveHeistToClaimee(HeistId)
        end
        return
    end

    TriggerEvent('fw-heists:Server:GenerateHeistCodes', Config.Bankbusters[HeistId].Id, Config.Bankbusters[HeistId].Data, Config.Bankbusters[HeistId].Label, Player.PlayerData.source)
    TriggerEvent('fw-phone:Server:Mails:AddMail', 'Dark Market', '#A-2001', 'Je hebt succesvol toegangscodes voor een heist geclaimd. Je weet waar je heen moet.', Player.PlayerData.source)
end