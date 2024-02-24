function SetVehicleTampering(NetId, Key, Value)
    if Key == nil then return false end

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return false end

    if Entity(Vehicle).state.tampering == nil then
        Entity(Vehicle).state.tampering = {}
    end

    local NewState = Entity(Vehicle).state.tampering
    NewState[Key] = Value

    Entity(Vehicle).state.tampering = NewState
    return true
end

function GetVehicleTampering(NetId, Key)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return false end

    if Entity(Vehicle).state.tampering == nil then
        Entity(Vehicle).state.tampering = {}
    end

    local Tampering = Entity(Vehicle).state.tampering
    if Key == nil then
        return Tampering
    else
        return Tampering[Key]
    end
end

exports("SetVehicleTampering", SetVehicleTampering)
exports("GetVehicleTampering", GetVehicleTampering)

FW.RegisterServer("fw-vehicles:Server:SetVehicleTampering", function(Source, NetId, Key, Value)
    SetVehicleTampering(NetId, Key, Value)
end)