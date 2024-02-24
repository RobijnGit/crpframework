local SearchedATMs, RobbedATMs = {}, {}

FW.Functions.CreateUsableItem("atm-blackbox", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-heists:Client:CrackATM', Source)
    end
end)

FW.Functions.CreateCallback("fw-heists:Server:IsATMSearched", function(Source, Cb, NetId)
    Cb(SearchedATMs[NetId])
end)

FW.Functions.CreateCallback("fw-heists:Server:IsATMRobbed", function(Source, Cb, Coords)
    for k, ATMCoords in pairs(RobbedATMs) do
        if #(ATMCoords - Coords) < 1.0 then
            return Cb(true)
        end
    end
    Cb(false)
end)

FW.RegisterServer("fw-heists:Server:CreateRope", function(Source, NetId)
    TriggerClientEvent("fw-heists:Client:CreateRope", -1, Source, NetId)
end)

FW.RegisterServer("fw-heists:Server:AttachRopeToATM", function(Source, NetIdATM, NetIdVeh, NetIdConsole, Coords)
    TriggerClientEvent("fw-heists:Client:AttachRopeToATM", -1, NetIdATM, NetIdVeh, NetIdConsole, Coords)
end)

FW.RegisterServer("fw-heists:Server:DetachATM", function(Source, NetIdVeh, NetIdConsole)
    TriggerClientEvent("fw-heists:Client:DetachATM", -1, NetIdVeh, NetIdConsole)

    if NetIdConsole then
        local Entity = NetworkGetEntityFromNetworkId(NetIdConsole)
        local Coords = GetEntityCoords(Entity)
        table.insert(RobbedATMs, Coords)
    
        Citizen.SetTimeout(90 * (60 * 1000), function()
            for k, ATMCoords in pairs(RobbedATMs) do
                if #(ATMCoords - Coords) < 1.5 then
                    table.remove(RobbedATMs, k)
                    return
                end
            end
        end)
    end
end)

FW.RegisterServer("fw-heists:Server:PickupATM", function(Source, NetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Entity = NetworkGetEntityFromNetworkId(NetId)
    Citizen.SetTimeout(500, function()
        if DoesEntityExist(Entity) then
            Player.Functions.AddItem('atm-blackbox', 1, false, false, true, nil)
            DeleteEntity(Entity)
        end
    end)
end)

FW.RegisterServer("fw-heists:Server:SetATMSearched", function(Source, NetId, Bool)
    SearchedATMs[NetId] = Bool
end)

FW.RegisterServer("fw-heists:Server:SearchATM", function(Source, NetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddMoney('cash', math.random(300, 1000))
end)

FW.RegisterServer("fw-heists:Server:ATMReward", function(Source, NetId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddMoney('cash', math.random(500, 1600))
    if math.random() < 0.32 then
        Player.Functions.AddItem('money-roll', math.random(1, 5), false, false, true, nil)
    end

    if math.random() < 0.12 then
        Player.Functions.AddItem('markedbills', math.random(1, 2), false, false, true, nil)
    end

    -- if math.random() < 0.02 then
    --     Player.Functions.AddItem('heist-usb', 1, false, false, true, 'blue')
    -- end
end)