function SetVehicleTampering(Vehicle, Key, Value)
    FW.TriggerServer("fw-vehicles:Server:SetVehicleTampering", VehToNet(Vehicle), Key, Value)
end

function GetVehicleTampering(Vehicle, Key, Fallback)
    local Tampering = Entity(Vehicle).state.tampering
    if Tampering == nil then
        return Fallback or {}
    end

    if Key == nil then return Tampering end
    return Tampering[Key]
end

exports("SetVehicleTampering", SetVehicleTampering)
exports("GetVehicleTampering", GetVehicleTampering)