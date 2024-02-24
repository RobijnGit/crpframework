FW = exports['fw-core']:GetCoreObject()

-- Code

RegisterServerEvent('fw-vehicles:Server:Set:Vehicle:Flames')
AddEventHandler('fw-vehicles:Server:Set:Vehicle:Flames', function(Vehicle, Bool)
    TriggerClientEvent('fw-vehicles:Client:Set:Vehicle:Flames', -1, Vehicle, Bool)
end)

RegisterServerEvent('fw-vehicles:Server:Set:Vehicle:Purge')
AddEventHandler('fw-vehicles:Server:Set:Vehicle:Purge', function(Vehicle, Bool)
    TriggerClientEvent('fw-vehicles:Client:Set:Vehicle:Purge', -1, Vehicle, Bool)
end)

RegisterServerEvent('fw-vehicles:Server:ReceiveRentalPapers')
AddEventHandler('fw-vehicles:Server:ReceiveRentalPapers', function(Plate)
	local Player = FW.Functions.GetPlayer(source)
	Player.Functions.AddItem('rentalpapers', 1, false, { Plate = Plate }, true)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetVIN", function(Source, Cb, Plate)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT `vinnumber`, `vinscratched` FROM `player_vehicles` WHERE `Plate` = @Plate", {
        ['@Plate'] = Plate
    })

    if not Result[1] or Result[1].vinscratched == 1 then
        Cb(false)
        return
    end

    Cb(Result[1] and Result[1].vinnumber or false)
end)

FW.Commands.Add("seat", "Verander van stoel (-1 tot 6)", {{name="id", help="Stoel Nummer (-1 tot 6)"}}, true, function(Source, Args)
    TriggerClientEvent('fw-vehicles:Client:Switch:Seat', Source, tonumber(Args[1]))
end)

FW.Commands.Add("callsignv", "Verander voertuig roepnummer", {
    { name = "Nummer", help = "Roepnummer (3 getallen)" }
}, true, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Args[1]:len() ~= 3 then
        return Player.Functions.Notify("Het roepnummer moet 3 getallen zijn.", "error")
    end

    if (Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'doc' and Player.PlayerData.job.name ~= 'ems') or not Player.PlayerData.job.onduty then
        return
    end

    TriggerClientEvent("fw-vehicles:Client:SetPoliceCallsign", Source, Args[1])
end)

function DeepCopyTable(Obj)
    if type(Obj) ~= 'table' then return Obj end
    local res = {}
    
    for k, v in pairs(Obj) do
        res[DeepCopyTable(k)] = DeepCopyTable(v)
    end

    return res
end