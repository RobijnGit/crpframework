RegisterNetEvent('fw-ui:Client:Target:Changed')
AddEventHandler('fw-ui:Client:Target:Changed', function(Entity, EntityType, EntityCoords)
    local Timeout = false
    if Entity ~= 0 and Entity ~= -1 and EntityType == 3 then
        local TargetModel = GetEntityModel(Entity)
        Citizen.SetTimeout(10000, function() Timeout = true end)
        if TargetModel == GetHashKey("prop_elecbox_24b") and not exports['fw-sync']:BlackoutActive() and not Timeout then
            while #(vector3(712.33, 166.22, 79.75) - GetEntityCoords(PlayerPedId())) > 6.0 do
                Citizen.Wait(10)
            end
            FW.Functions.Notify("Zou schandalig zijn als dit explodeerd..", "error")
        end
    end
end)

RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if #(GetEntityCoords(PlayerPedId()) - vector3(711.69, 164.83, 80.75)) < 5.0 then
        local DidRemove = FW.SendCallback("FW:RemoveItem", "heavy-thermite", 1)
        if DidRemove then
            local Success = DoThermite(7, vector3(711.69, 164.83, 80.75))
            if Success then
                TriggerServerEvent("fw-sync:Server:SetBlackout", true)
            end
        end
    end
end)