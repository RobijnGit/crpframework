FW = exports['fw-core']:GetCoreObject()
LoggedIn = false

RegisterNetEvent("FW:Client:OnPlayerLoaded")
AddEventHandler("FW:Client:OnPlayerLoaded", function()
    LoggedIn = true
    InitMenu()
end)

RegisterNetEvent("FW:Client:OnPlayerUnload")
AddEventHandler("FW:Client:OnPlayerUnload", function()
    LoggedIn = false
end)

-- Code
CurrentEntityType, FocusingEntity = false, false

Citizen.CreateThread(function()
    LoggedIn = true
    InitMenu()
end)

function SendUIMessage(Action, Data)
    SendNUIMessage({
        Action = Action,
        Data = Data
    })
end

function GetEntityDetails(Entity)
    local EntityType = GetEntityType(Entity)
    local Details = {}

    local Hash = GetEntityModel(Entity)
    local ModelName = Config.Entities[Hash] or Hash

    if EntityType == 1 then
        CurrentEntityType = IsPedAPlayer(Entity) and 'player' or 'ped'
    elseif EntityType == 2 then
        CurrentEntityType = 'vehicle'
        Details = FW.SendCallback("fw-dev:Server:GetVehicleDetails", Hash, GetVehicleNumberPlateText(Entity))
    elseif EntityType == 3 then
        CurrentEntityType = 'object'
    end

    return {
        ModelName = ModelName,
        Details = Details,
    }
end