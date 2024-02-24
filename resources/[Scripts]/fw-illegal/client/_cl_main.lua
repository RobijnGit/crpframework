FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(2500, function()
        InitZones() InitPlants()
        InitCocaine() InitMeth()
        InitMethruns()
        LoggedIn = true
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
    RemoveAllPlants()
end)

-- Code

function DoEntityPlacer(Model, MaxDistance, StickToGround, PlayerHeading, ZMin)
    local Promise = promise.new()
    exports['fw-core']:DoEntityPlacer(Model, MaxDistance, StickToGround, PlayerHeading, ZMin, function(...)
        Citizen.Wait(100)
        Promise:resolve({...})
    end)
    return Citizen.Await(Promise)
end