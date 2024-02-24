FW = exports['fw-core']:GetCoreObject()

FW.Functions.CreateUsableItem("heist-laptop", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-heists:Client:HeistLaptopUsed', Source, Item.CustomType)
    end
end)

FW.Functions.CreateUsableItem("heist-box", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-heists:Client:HeistBoxUsed', Source)
    end
end)

FW.RegisterServer("fw-heists:Server:RemoveTrackerFromLoot", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.RemoveItemByKV('heist-loot', 1, Item.Info.Serial, true, 'tracked') then
        Player.Functions.AddItem('heist-loot', 1, Item.Slot, {Serial = Item.Info.Serial}, true, '')
    end
end)

FW.Functions.CreateCallback("fw-heists:Server:GetPedCoords", function(Source, Cb, Type)
    local LocationsConfig = exports['fw-config']:GetModuleConfig("locations", {})
    Cb(LocationsConfig[Type])
end)

function StartGlobalCooldown()
    if DataManager.Get("GlobalCooldown", false) then return end
    DataManager.Set("GlobalCooldown", true)

    Citizen.SetTimeout((1000 * 60) * 30, function()
        DataManager.Set("GlobalCooldown", false)
    end)
end

RegisterNetEvent("fw-heists:Server:DisableHeists")
AddEventHandler("fw-heists:Server:DisableHeists", function()
    DataManager.Set("HeistsDisabled", 1)
end)