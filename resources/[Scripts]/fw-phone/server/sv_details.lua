FW.Functions.CreateCallback("fw-phone:Server:Details:GetLicenses", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(Player.PlayerData.metadata.licenses)
end)