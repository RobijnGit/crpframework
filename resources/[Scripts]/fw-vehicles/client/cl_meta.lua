function LoadVehicleMeta(Vehicle, Data)
    TriggerServerEvent("fw-vehicles:Server:LoadVehicleMeta", VehToNet(Vehicle), Data)
end

function SetVehicleMeta(Vehicle, Key, Value)
    TriggerServerEvent("fw-vehicles:Server:SetVehicleMeta", VehToNet(Vehicle), Key, Value)

    if HasHarness and GetVehiclePedIsIn(PlayerPedId()) == Vehicle and Key == "Harness" and Value <= 0.0 then
        HasHarness, HasBelt = false, false
        TriggerEvent("fw-misc:Client:PlaySound", 'vehicle.unbuckle')
        FW.Functions.Notify("Je harness is kapot gegaan..", "error")
    end
end

function GetVehicleMeta(Vehicle, Key)
    local Meta = Entity(Vehicle).state.meta
    if Meta == nil then
        LoadVehicleMeta(Vehicle)
        return Config.DefaultMeta[Key]
    end

    if Key == nil then return Meta end
    return Meta[Key]
end

exports("LoadVehicleMeta", LoadVehicleMeta)
exports("SetVehicleMeta", SetVehicleMeta)
exports("GetVehicleMeta", GetVehicleMeta)