FW = exports['fw-core']:GetCoreObject()
local FreezeCoords = vector3(0.0, 0.0, 0.0)
local InfectedPlayers = {}

FW.Functions.CreateCallback("fw-events:Server:GetInfectedPlayers", function(Source, Cb)
    Cb(InfectedPlayers)
end)

FW.Functions.CreateCallback("fw-events:Server:GetFreezeCoords", function(Source, Cb)
    Cb(FreezeCoords)
end)

FW.Functions.CreateCallback("fw-events:Server:GetPortals", function(Source, Cb)
    Cb(Config.Portals)
end)

-- // Commands \\ --

FW.Commands.Add("eventstart", "Start Halloween Event", {}, false, function(source, args)
    Config.IsEventActive = true
    TriggerClientEvent('fw-events:Client:Start:Event', -1)
    TriggerEvent('fw-heists:Server:DisableHeists', -1)
    SendStateEmergency('DUE TO AN UNNATURAL GATHERING AT THE CEMETERY, WE ADVISE EVERYONE TO STAY AWAY FROM THE CEMETERY AND TO STAY CLOSE TO YOUR LOVED ONES. CLOSE WINDOWS AND DOORS AND TRUST ONLY YOUR LOVED ONES. MAY GOD BE WITH US.')
    TriggerEvent('fw-sync:Server:SetCurrentWeather', 'Halloween')
end, "admin")

FW.Commands.Add("eventstop", "Stop Halloween Event", {}, false, function(source, args)
    Config.IsEventActive = false
    TriggerClientEvent('fw-events:Client:End:Event', -1)

    Citizen.SetTimeout(30000, function()
        local AllPlayers = FW.GetPlayers()
        for k, v in pairs(AllPlayers) do
            DropPlayer(v.ServerId, 'The ghost hunting is over, hopefully you had just as much fun at this event as we did! The city will be back to normal after a short restart..')
        end
    end)
end, "admin")

FW.Commands.Add("sendEventMail", "Send Event Mail", {}, false, function(source, args)
    local Message = table.concat(args, " ")
    SendStateEmergency(Message)
end, "admin")

FW.Commands.Add("setEventFreeze", "Set Event Freeze Location", {}, false, function(source, args)
    if args[1]:lower() == 'true' then
        FreezeCoords = GetEntityCoords(GetPlayerPed(source))
        TriggerClientEvent("fw-events:Client:SetEventFreezeCoords", -1, FreezeCoords)
    else
        FreezeCoords = vector3(0.0, 0.0, 0.0)
        TriggerClientEvent("fw-events:Client:SetEventFreezeCoords", -1, FreezeCoords)
    end
end, "admin")

FW.Commands.Add("setInfected", "Turn a Player Infected", {}, false, function(source, args)
    TriggerClientEvent("fw-events:Client:SetPlayerInfected", tonumber(args[1]))
end, "admin")

FW.Commands.Add("createPortal", "Create a Portal on Current Location", {}, false, function(source, args)
    local Coords = GetEntityCoords(GetPlayerPed(source))

    local PortalId = #Config.Portals + 1
    Config.Portals[PortalId] = Coords

    TriggerClientEvent("fw-events:Client:AddPortal", -1, vector4(Coords.x + math.random(-5, 5), Coords.y + math.random(-5, 5), Coords.z, math.random(1, 360)))
end, "admin")

FW.Functions.CreateUsableItem("zombie-antidote", function(Source, item)
	local Player = FW.Functions.GetPlayer(Source)
    if Player.Functions.GetItemBySlot(item.Slot) ~= nil then
        if InfectedPlayers[source] then
            Player.Functions.Notify("You are dumbfounded by what this is?", "error")
            return
        end

        TriggerClientEvent('fw-events:Client:GiveAntidote', Source, item)
    end
end)

RegisterNetEvent("fw-events:Server:UsedAntidote")
AddEventHandler("fw-events:Server:UsedAntidote", function(Target)
    InfectedPlayers[Target] = false
    TriggerClientEvent('fw-events:Client:RecieveAntidote', Target)
    TriggerClientEvent('fw-events:Client:SetInfected', -1, Target, false)
end)

RegisterNetEvent('fw-events:Server:SetInfected')
AddEventHandler('fw-events:Server:SetInfected', function()
    InfectedPlayers[source] = true
    TriggerClientEvent('fw-events:Client:SetInfected', -1, source, true)
end)

function SendStateEmergency(Message)
    TriggerClientEvent('fw-phone:Client:Mails:AddMail', -1, {
        From = 'De Staat van San Andreas',
        Subject = 'STAAT NOODGEVAL',
        Msg = Message,
        Timestamp = os.time() * 1000
    })

    Citizen.Wait(100)
    TriggerClientEvent("fw-phone:Client:Notification", -1, 'state-emergency', 'fas fa-exclamation-triangle', { 'white', 'rgb(38, 50, 56)' }, "STATE EMERGENCY", "READ YOUR EMAIL APP!", false, true, "", "", { HideOnAction = true })
end
