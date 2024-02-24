FW = exports['fw-core']:GetCoreObject()

RegisterNetEvent("fw-assets:Server:ErrorLog")
AddEventHandler('fw-assets:Server:ErrorLog', function(Resource, Error, IsServer)
    if IsServer then
        TriggerEvent("fw-logs:Server:Log", 'bugs', "Server Error Found [" .. Resource .. "]", Error, "red")
    else
        local Player = FW.Functions.GetPlayer(source)
        if Player == nil then return end

        TriggerEvent("fw-logs:Server:Log", 'bugs', "Client Error Found [" .. Resource .. "]", ("User: [%s] - %s - %s\nError: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Error), "orange")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(15000)
        TriggerClientEvent("setPlayerCount", -1, #GetPlayers())
    end
end)

AddEventHandler('entityCreating', function(Entity)
    if Config.BlacklistedEntitys[GetEntityModel(Entity)] then
        CancelEvent()
    end
end)

function DrawMeText(Source, Text)
    local MyCoords = GetEntityCoords(GetPlayerPed(Source))
    local Players = FW.GetPlayers()
    for k, v in pairs(Players) do
        if #(MyCoords - GetEntityCoords(GetPlayerPed(v.ServerId))) <= 25.0 then
            TriggerClientEvent('fw-assets:Client:DrawMeText', v.ServerId, Source, Text)
        end
    end
end

RegisterNetEvent("fw-assets:Server:DrawMeText")
AddEventHandler("fw-assets:Server:DrawMeText", function(source, Text)
    DrawMeText(source, Text)
end)

-- 

FW.Functions.CreateCallback("fw-assets:Server:GetDuiData", function(Source, Cb)
    Cb(Config.SavedDuiData)
end)

-- Commands
FW.Commands.Add("me", "Karakter expresie", {}, false, function(source, args)
    local Text = table.concat(args, ' ')
    DrawMeText(source, Text)
end)

FW.Commands.Add("forceintrunk", "Duw speler in een kofferbak.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local ClosestPlayer, ClosestDistance = nil, 3.0
    local AllPlayers = FW.GetPlayers()
    local PlayerCoords = GetEntityCoords(GetPlayerPed(Source))
    for k, v in pairs(AllPlayers) do
        if tonumber(v['ServerId']) ~= Source then
            local TargetCoords = GetEntityCoords(GetPlayerPed(v['ServerId']))
            local Distance = #(PlayerCoords - TargetCoords)
            if Distance <= 3.0 then
                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestPlayer = v['ServerId']
                end
            end
        end
    end

    if ClosestPlayer == nil then
        return Player.Functions.Notify("Geen speler gevonden..", "error")
    end

    local Target = FW.Functions.GetPlayer(ClosestPlayer)
    if Target == nil then return end

    if not Target.PlayerData.metadata['ishandcuffed'] then
        return Player.Functions.Notify("Persoon is niet geboeid..", "error")
    end

    TriggerClientEvent('fw-assets:client:getin:trunk', ClosestPlayer, { Forced = true })
end)

RegisterNetEvent('fw-assets:Server:SetTrunkOccupied')
AddEventHandler('fw-assets:Server:SetTrunkOccupied', function(Plate, State)
    Config.TrunkData[Plate] = State
end)

FW.Functions.CreateCallback('fw-assets:Server:IsTrunkEmpty', function(Source, Cb, Plate)
    Cb(not Config.TrunkData[Plate])
end)