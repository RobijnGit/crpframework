RegisterNetEvent("fw-jobmanager:Server:FoodDelivery:CollectOrder")
AddEventHandler("fw-jobmanager:Server:FoodDelivery:CollectOrder", function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddItem('food-box', 1, false, false, true)
end)