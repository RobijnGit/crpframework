FW = exports['fw-core']:GetCoreObject()

-- Code
RegisterNetEvent("fw-island:Server:ToggleFlight")
AddEventHandler("fw-island:Server:ToggleFlight", function(Data, Entity)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- if Player.PlayerData.citizenid ~= '2920' then
    --     return
    -- end

    Config.AvailableFlights[Data.Flight] = not Config.AvailableFlights[Data.Flight]
    Player.Functions.Notify("Flights " .. (Config.AvailableFlights[Data.Flight] and "opened" or "closed") .. ".", Config.AvailableFlights[Data.Flight] and "success" or "error")
end)

RegisterNetEvent("fw-island:Server:BookFlight")
AddEventHandler("fw-island:Server:BookFlight", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Player.Functions.RemoveMoney("cash", 5000) then
        return Player.Functions.Notify("You don't have enough cash to pay this flight..", "error")
    end

    TriggerClientEvent("fw-island:Client:SpawnFlight", Source, Data.Flight)
end)

FW.Functions.CreateCallback("fw-island:Server:IsFlightAvailable", function(Source, Cb, Flight)
    Cb(Config.AvailableFlights[Flight])
end)