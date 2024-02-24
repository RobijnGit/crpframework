FW.RegisterServer("fw-heists:Server:Baycity:Reset", function(Source)
    StartGlobalCooldown()
    Citizen.SetTimeout((60 * 1000) * 120, function()
        DataManager.Set(GetBaycityPrefix() .. "powerbox", 0)
        DataManager.Set(GetBaycityPrefix() .. "vault", 0)
        DataManager.Set("trolley-baycity_1", 0)

        for k, v in pairs(Config.Baycity.DoorIds) do
            TriggerEvent('fw-doors:Server:SetLockStateById', v, 1)
        end

        print("[HEISTS]: Bay City Reset")
    end)
end)