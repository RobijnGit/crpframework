FW.Functions.CreateCallback("fw-phone:Server:CanRealtor", function(Source, Cb)
    Cb(FW.Functions.HasPermission(Source, "dev") or FW.Functions.HasPermission(Source, "admin") or FW.Functions.HasPermission(Source, "god"))
end)

FW.Functions.CreateCallback("fw-phone:Server:Housing:GetHouses", function(Source, Cb)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Houses = exports['fw-housing']:GetHouses()
    local Retval = {}

    for k, v in pairs(Houses) do
        local HasKeys = v.Owner == Player.PlayerData.citizenid
        if HasKeys then goto SkipKeyholders end
        for _, Cid in pairs(v.Keyholders) do
            if Cid == Player.PlayerData.citizenid then
                HasKeys = true
                break
            end
        end
        ::SkipKeyholders::

        if HasKeys then
            v.IsOwner = v.Owner == Player.PlayerData.citizenid
            Retval[#Retval + 1] = v
        end
    end

    Cb(Retval)
end)