local Rewards = {
    "plastic",
    "rubber",
    "electronics",
}

FW.RegisterServer("fw-misc:Server:RecycleReward", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    for i = 1, math.random(1, 5), 1 do
        Player.Functions.AddItem(Rewards[math.random(#Rewards)], math.random(1, 2), false, false, true)
    end
end)