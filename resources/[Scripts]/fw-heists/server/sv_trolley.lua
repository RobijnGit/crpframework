FW.RegisterServer("fw-heists:Server:Trolley:PayoutGrab", function(Source, TrolleyId, Trolley)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if DataManager.Get("trolley-" .. TrolleyId, 0) ~= 2 then
        return
    end

    if TrolleyId == "baycity_1" then
        Player.Functions.AddItem('markedbills', math.random(130, 160), false, nil, true)
        Player.Functions.AddMoney('cash', math.random(3000, 6000), 'Bay City Bank Vault')
    elseif TrolleyId == "vault-1" or TrolleyId == "vault-2" or TrolleyId == "vault-3" or TrolleyId == "vault-4" then -- Cash
        Player.Functions.AddItem('markedbills', math.random(135, 200), false, nil, true)
        Player.Functions.AddMoney('cash', math.random(8000, 11000), 'The City Vault')
    else
        print("Invalid Trolley Payout.")
    end
end)