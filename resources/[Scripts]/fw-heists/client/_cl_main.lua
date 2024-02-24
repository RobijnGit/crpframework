FW = exports['fw-core']:GetCoreObject()
LoggedIn, CurrentCops = false, 0

-- Code

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)


RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    local PickupCoords = FW.SendCallback("fw-heists:Server:GetPedCoords", "HeistPickup")
    exports['fw-ui']:AddEyeEntry("heist_pickup_ped", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        State = false,
        Position = PickupCoords,
        Model = 'mp_m_weapwork_01',
        Options = {
            -- {
            --     Name = 'purchase_pickup',
            --     Icon = 'fas fa-user-secret',
            --     Label = 'Goederen Kopen',
            --     EventType = 'Client',
            --     EventName = "fw-heists:Client:PickupStore",
            --     EventParams = {},
            --     Enabled = function(Entity)
            --         return true
            --     end,
            -- },
            {
                Name = 'table',
                Icon = 'fas fa-pills',
                Label = 'Tafeltje Kopen (150 SHUNG)',
                EventType = 'Server',
                EventName = "fw-illegal:Server:Meth:PurchaseTable",
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
end)

RegisterNetEvent('fw-police:SetCopCount')
AddEventHandler('fw-police:SetCopCount', function(Amount)
    CurrentCops = Amount
end)

RegisterNetEvent("fw-items:Client:HeistLootTracker")
AddEventHandler("fw-items:Client:HeistLootTracker", function(Item)
    if GetEntitySpeed(PlayerPedId()) * 3.6 < 50 then
        return FW.Functions.Notify("Je gaat te traag om de tracker te hacken..", "error")
    end

    if math.random() < 0.65 then
        TriggerServerEvent("fw-mdw:Server:SendAlert:TrackedGoods", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), Item.Info.Serial)
    end

    if Item.Info.Encryption == 'Grid' then
        local Success = exports['fw-ui']:StartGridMinigame(4)
        if not Success then return end
        FW.TriggerServer("fw-heists:Server:RemoveTrackerFromLoot", Item)
    elseif Item.Info.Encryption == 'Keystroke' then
        local Success = exports['fw-minigames']:StartKeystrokeMinigame('Medium', 30, 6)
        if not Success then return end
        FW.TriggerServer("fw-heists:Server:RemoveTrackerFromLoot", Item)
    elseif Item.Info.Encryption == 'Thermite' then
        local Success = exports['fw-ui']:StartThermite(7)
        if not Success then return end
        FW.TriggerServer("fw-heists:Server:RemoveTrackerFromLoot", Item)
    elseif Item.Info.Encryption == 'Datacrack' then
        exports["minigame-datacrack"]:Start(5, function(Success)
            if not Success then return end
            FW.TriggerServer("fw-heists:Server:RemoveTrackerFromLoot", Item)
        end)
    elseif Item.Info.Encryption == 'Shape' then
        exports['minigame-shape']:StartShapeGame(15, 4, 4, function(Success)
            if not Success then return end
            FW.TriggerServer("fw-heists:Server:RemoveTrackerFromLoot", Item)
        end)
    elseif Item.Info.Encryption == 'Phone' then
        exports['minigame-phone']:ShowHack()
        exports['minigame-phone']:StartHack(math.random(1, 3), math.random(9, 13), function(Success)
            exports['minigame-phone']:HideHack()
            if not Success then return end
            FW.TriggerServer("fw-heists:Server:RemoveTrackerFromLoot", Item)
        end)
    end
end)

function IsWearingHandshoes()
    local ArmIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    if model == GetHashKey("mp_m_freemode_01") then
        if Config.MaleNoGloves[ArmIndex] ~= nil and Config.MaleNoGloves[ArmIndex] then
            return false
        end
    else
        if Config.FemaleNoGloves[ArmIndex] ~= nil and Config.FemaleNoGloves[ArmIndex] then
            return false
        end
    end

    return math.random() > 0.2
end