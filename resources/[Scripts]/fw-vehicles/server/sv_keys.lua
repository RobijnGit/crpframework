FW.Functions.CreateCallback("fw-vehicles:Server:GetVehicleKeys", function(Source, Cb)
    Cb(Config.VehicleKeys)
end)

RegisterNetEvent("fw-vehicles:Server:SetVehicleKeys")
AddEventHandler("fw-vehicles:Server:SetVehicleKeys", function(Plate, State, Cid)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if Plate == nil then return end

    if Config.VehicleKeys[Plate] == nil then Config.VehicleKeys[Plate] = {} end

    if Cid then
        local Target = FW.Functions.GetPlayerByCitizenId(Cid)
        if Target == nil then return end
        if Target.PlayerData.source == Player.PlayerData.source then return end

        Config.VehicleKeys[Plate][Target.PlayerData.citizenid] = State
        Target.Functions.Notify("Je ontving de sleutels van een voertuig..")
    else
        Config.VehicleKeys[Plate][Player.PlayerData.citizenid] = State
    end

    TriggerClientEvent("fw-vehicles:Client:SetVehicleKeys", -1, Plate, Config.VehicleKeys[Plate])
end)