function LoadVehicleMeta(NetId, Meta)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return false end

    local Data = {}
    for k, v in pairs(Config.DefaultMeta) do
        Data[k] = Meta and Meta[k] ~= nil and Meta[k] or v
    end

    Entity(Vehicle).state.meta = Data

    Citizen.CreateThread(function()
        while DoesEntityExist(Vehicle) do
            local Meta = GetVehicleMeta(NetId)

            Meta.Body = GetVehicleBodyHealth(Vehicle)
            Meta.Engine = GetVehicleEngineHealth(Vehicle)

            exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `metadata` = @Meta WHERE `plate` = @Plate", {
                ['@Meta'] = json.encode(Meta),
                ['@Plate'] = GetVehicleNumberPlateText(Vehicle),
            })

            Citizen.Wait((1000 * 60) * 5)
        end
    end)
end

function SetVehicleMeta(NetId, Key, Value)
    if Key == nil then return false end

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return false end

    if Entity(Vehicle).state.meta == nil then
        Entity(Vehicle).state.meta = {}
    end

    local NewState = Entity(Vehicle).state.meta
    NewState[Key] = Value

    Entity(Vehicle).state.meta = NewState
    return true
end

function GetVehicleMeta(NetId, Key)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return false end

    if Entity(Vehicle).state.meta == nil then
        Entity(Vehicle).state.meta = {}
    end

    local Meta = Entity(Vehicle).state.meta
    if Key == nil then
        return Meta
    else
        return Meta[Key]
    end
end

exports("LoadVehicleMeta", LoadVehicleMeta)
exports("SetVehicleMeta", SetVehicleMeta)
exports("GetVehicleMeta", GetVehicleMeta)

RegisterNetEvent("fw-vehicles:Server:LoadVehicleMeta")
AddEventHandler("fw-vehicles:Server:LoadVehicleMeta", function(NetId, Data)
    LoadVehicleMeta(NetId, Data)
end)

RegisterNetEvent("fw-vehicles:Server:SetVehicleMeta")
AddEventHandler("fw-vehicles:Server:SetVehicleMeta", function(NetId, Key, Value)
    SetVehicleMeta(NetId, Key, Value)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetVehicleMeta", function()
    Cb(GetVehicleMeta(NetId, Key))
end)