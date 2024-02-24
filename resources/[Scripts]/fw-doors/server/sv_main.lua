FW = exports['fw-core']:GetCoreObject()
-- Code

Citizen.CreateThread(function()
    -- Set connected to keys instead of info.
    local function GetDoorIndexByInfo(Info)
        for k, v in pairs(Config.Doors) do
            if v.Info == Info then
                return k
            end
        end
    end

    for k, v in pairs(Config.Doors) do
        if v.Connected ~= nil and next(v.Connected) then
            local NewConnected = {}

            for i, j in pairs(v.Connected) do
                NewConnected[#NewConnected + 1] = GetDoorIndexByInfo(j)
            end

            Config.Doors[k].Connected = NewConnected
        end
    end
end)

-- // Events \\ --

RegisterServerEvent('fw-doors:Server:ToggleLockState')
AddEventHandler('fw-doors:Server:ToggleLockState', function(DoorId)
    if Config.Doors[DoorId] ~= nil then
        local CurrentLockState = Config.Doors[DoorId].Locked
        if CurrentLockState == 1 then
            Config.Doors[DoorId].Locked = 0
        else
            Config.Doors[DoorId].Locked = 1
        end
        TriggerClientEvent('fw-doors:Client:Sync:Doors', -1, DoorId, Config.Doors[DoorId])
    end
end)

RegisterServerEvent('fw-doors:Server:SetLockState')
AddEventHandler('fw-doors:Server:SetLockState', function(DoorId, NewState)
    if Config.Doors[DoorId] ~= nil then
        Config.Doors[DoorId].Locked = NewState
        TriggerClientEvent('fw-doors:Client:Sync:Doors', -1, DoorId, Config.Doors[DoorId])
    end
end)


RegisterServerEvent('fw-doors:Server:SetLockStateById')
AddEventHandler('fw-doors:Server:SetLockStateById', function(Id, NewState)
    for k, v in pairs(Config.Doors) do
        if v.Info == Id then
            Config.Doors[k].Locked = NewState
            TriggerClientEvent('fw-doors:Client:Sync:Doors', -1, k, Config.Doors[k])
            break
        end
    end
end)

-- // Callbacks \\ --
FW.Functions.CreateCallback('fw-doors:Server:GetDoorConfig', function(Source, Cb)
    Cb(Config.Doors)
end)