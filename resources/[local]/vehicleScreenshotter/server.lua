local ServerRoute = 'E:/CfxServers/FiveM/Clarity/resources/[Scripts]/fw-ui/web/public/images/pdm/'
local DoScreenshot = false
local VehiclesDone = 0

RegisterCommand("carScreenshot", function(source)
    local Player = FW.Functions.GetPlayer(source)
    if Player == nil then return end

    DoScreenshot = true

    local Vehicles = { "newsvan" }
    for k, v in pairs(Vehicles) do
        if not DoScreenshot then break end
        ScreenshotCar(Player.PlayerData.source, v)
        print(#Vehicles - VehiclesDone .. " vehicles left.")
    end

    TriggerClientEvent("fw-businesses:Client:DeleteTempVehicle", source)
end)

RegisterCommand("stopScreenshot", function(source)
    DoScreenshot = false
    TriggerClientEvent("fw-businesses:Client:DeleteTempVehicle", source)
    print("Stopping!")
end)

function ScreenshotCar(Source, Data)
    local VehicleName = Data
    TriggerClientEvent("fw-businesses:Client:SpawnTempVehicle", Source, Data)
    local CurrentDone = VehiclesDone + 1
    while VehiclesDone ~= CurrentDone do
        Citizen.Wait(4)
    end
end

RegisterNetEvent("takeScreenshot")
AddEventHandler("takeScreenshot", function(VehicleName, Invalid)
    if Invalid then
        VehiclesDone = VehiclesDone + 1
        return
    end

    local Source = source
    exports['screenshot-basic']:requestClientScreenshot(Source, {
        fileName = ServerRoute .. VehicleName .. '.jpg',
        encoding = 'jpg',
        quality = 0.25,
    }, function(err, data)
        VehiclesDone = VehiclesDone + 1
    end)
end)