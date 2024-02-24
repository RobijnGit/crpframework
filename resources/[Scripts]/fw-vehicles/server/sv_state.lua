RegisterNetEvent("fw-vehicles:Server:SetState")
AddEventHandler("fw-vehicles:Server:SetState", function(NetId, Data)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return false end

    Entity(Vehicle).state[Data.State] = Data.Value
end)
