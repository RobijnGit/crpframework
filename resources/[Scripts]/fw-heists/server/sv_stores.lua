local CrackedSafes = {}

FW.Functions.CreateCallback("fw-heists:Server:Stores:GetRegisterState", function(Source, Cb, RegId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Register = Config.Registers[RegId]
    Cb(Register.Busy or Register.Robbed)
end)

RegisterNetEvent("fw-heists:Server:SetRegisterState")
AddEventHandler("fw-heists:Server:SetRegisterState", function(Type, RegId, State)
    Config.Registers[RegId][Type] = State

    if Type == 'Robbed' and State then
        Citizen.SetTimeout((1000 * 60) * 30, function()
            Config.Registers[RegId]['Robbed'] = false
            Config.Registers[RegId]['Busy'] = false
        end)
    end
end)

RegisterNetEvent("fw-heists:Server:Stores:ReceiveReward")
AddEventHandler("fw-heists:Server:Stores:ReceiveReward", function(RegId)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Config.Registers[RegId] == nil then return end
    if not Config.Registers[RegId].Robbed then return end
    if #(GetEntityCoords(GetPlayerPed(Source)) - Config.Registers[RegId].Coords) > 5.0 then return end

    local HasBuff = exports['fw-hud']:DoesPlayerHaveBuff(Source, 'Stores')
    Player.Functions.AddMoney('cash', HasBuff and math.random(100, 210) or math.random(80, 170), 'Store Robbery')
    if math.random(1, 100) > 45 and math.random(1, 100) < 80 then
        Player.Functions.AddItem('money-roll', HasBuff and math.random(2, 6) or math.random(1, 4), nil, nil, true)
    end

    if math.random() < 0.15 then -- 15% to get 2 EVD.
        Player.Functions.AddItem('heist-loot-usb', 1, false, nil, true)
    end
end)

FW.Functions.CreateCallback("fw-heists:Server:GetSafeState", function(Source, Cb, SafeId)
    Cb(Config.Safes[SafeId].State)
end)

FW.RegisterServer("fw-heists:Store:SetSafeState", function(Source, SafeId, State)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Config.Safes[SafeId].State = State

    if State == 2 then
        Player.Functions.Notify("Je hebt de kluis gekraakt, je kan hem zometeen openen.")

        Citizen.SetTimeout((1000 * 60) * math.random(3, 8), function()
            CrackedSafes[SafeId] = true

            Citizen.SetTimeout((1000 * 60) * 30, function()
                CrackedSafes[SafeId] = false
                Config.Safes[SafeId].State = 0
            end)
        end)
    end
end)

RegisterNetEvent("fw-heists:Server:RewardSafe")
AddEventHandler("fw-heists:Server:RewardSafe", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    if not Config.Safes[Data.SafeId] then
        return
    end

    if Config.Safes[Data.SafeId].State ~= 2 then
        return Player.Functions.Notify("De kluis zit op slot.")
    end

    if not CrackedSafes[Data.SafeId] then
        return Player.Functions.Notify("Wacht nog even..")
    end

    CrackedSafes[Data.SafeId] = false

    -- if math.random() > 0.75 then
    --     Player.Functions.AddItem('heist-usb', 1, false, false, true, 'green')
    -- end

    if math.random(1, 100) > 97 then
        Player.Functions.AddItem('gruppe6', 1, nil, nil, true)
    end

    Player.Functions.AddItem('money-roll', math.random(8, 17), false, false, true)
end)