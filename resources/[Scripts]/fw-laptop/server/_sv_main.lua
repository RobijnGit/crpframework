FW = exports['fw-core']:GetCoreObject()

FW.Functions.CreateUsableItem("laptop", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-laptop:Client:Open', Source, "Crime")
    end
end)