Units = { Police = {}, EMS = {}, DOC = {} }
CurrentDispatchers = {}
local DispatchJobs = {
    police = 'Police',
    ems = 'EMS',
    doc = 'DOC',
    storesecurity = 'Police',
}

FW.Functions.CreateCallback("fw-mdw:Client:GetUnits", function(Source, Cb)
    Cb(Units)
end)

-- Alerts
RegisterNetEvent("fw-mdw:Server:DismissPing")
AddEventHandler("fw-mdw:Server:DismissPing", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Id = nil

    if Data.IsCall then
        Id = GetCallById(Data.Id)
        if not Id then return end

        table.remove(Calls, Id)
        RemoveCalloutFromMap(Data.Id)
    else
        Id = GetAlertById(Data.Id)
        if not Id then return end

        table.remove(Alerts, Id)
    end

    if Id == nil then return end
    TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Remove", { Id = Data.Id, IsCall = Data.IsCall })
end)

RegisterNetEvent("fw-mdw:Server:CreateCall")
AddEventHandler("fw-mdw:Server:CreateCall", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    
    local Id = GetAlertById(Data.Id)
    if not Id then return end

    local AlertData = Alerts[Id]
    AlertData.Units = { Police = {}, EMS = {} }

    local CallId = #Calls + 1
    Calls[CallId] = AlertData

    table.remove(Alerts, Id)
    if AlertData.Coords then
        AddCalloutToMap(AlertData.Coords, Data.Id)
    end

    TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Remove", { Id = Data.Id, IsCall = false })
    TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Set", { Id = Data.Id, IsCall = true, Alert = AlertData })
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:SetCallRadio")
AddEventHandler("fw-mdw:Server:Dispatch:SetCallRadio", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Id then return end

    local CallId = GetCallById(Data.Id)
    if not CallId then return end

    Calls[CallId].Radio = Data.Radio;

    TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Set", { Id = Data.Id, IsCall = true, Alert = Calls[CallId] })
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:ToggleCallUnit")
AddEventHandler("fw-mdw:Server:Dispatch:ToggleCallUnit", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Cid then return end
    if not Data.Id then return end

    local Target = FW.Functions.GetPlayerByCitizenId(Data.Cid)
    if Target == nil then return end

    local Job = DispatchJobs[Player.PlayerData.job.name]
    if not Job then
        return
    end
    if not Units[Job] then return end

    local CallId = GetCallById(Data.Id)
    if not CallId then return end

    for k, v in pairs(Calls[CallId].Units[Job]) do
        if v.Cid == Data.Cid then
            table.remove(Calls[CallId].Units[Job], k)
            TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Set", { Id = Data.Id, IsCall = true, Alert = Calls[CallId] })
            return
        end
    end

    local UnitId, MemberId = GetUnitByCid(Job, Data.Cid)
    if not UnitId or not Units[Job][UnitId] then return end

    table.insert(Calls[CallId].Units[Job], {
        Cid = Data.Cid,
        Callsign = Units[Job][UnitId].Units[1].Callsign,
        Radio = exports['fw-voice']:GetSubscriberChannel(Target.PlayerData.source)
    })
    TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Set", { Id = Data.Id, IsCall = true, Alert = Calls[CallId] })
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:RemoveUnits")
AddEventHandler("fw-mdw:Server:Dispatch:RemoveUnits", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Id then return end
    
    local CallId = GetCallById(Data.Id)
    if not CallId then return end

    Calls[CallId].Units.Police = {}
    Calls[CallId].Units.EMS = {}
    TriggerClientEvent("fw-mdw:Client:SetAlertData", -1, "Set", { Id = Data.Id, IsCall = true, Alert = Calls[CallId] })
end)

-- Units
RegisterNetEvent("fw-mdw:Server:SetCallsign")
AddEventHandler("fw-mdw:Server:SetCallsign", function(Cid, Callsign)
    local Player = FW.Functions.GetPlayerByCitizenId(Cid)
    if Player == nil then return end

    local Job = DispatchJobs[Player.PlayerData.job.name]
    if not Job then
        return
    end

    local UnitId, MemberId = GetUnitByCid(Job, Cid)
    if not UnitId then return end

    Units[Job][UnitId].Units[MemberId].Callsign = Callsign
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Job, UnitId, Units[Job][UnitId])

    if MemberId == 1 then
        SetDispatchMarkerText(Cid, Callsign)
    end
end)

RegisterNetEvent("fw-mdw:Server:SetRadio")
AddEventHandler("fw-mdw:Server:SetRadio", function(Target, Radio)
    local Player = FW.Functions.GetPlayer(Target)
    if Player == nil then return end

    local Job = DispatchJobs[Player.PlayerData.job.name]
    if not Job then
        return
    end

    local UnitId, MemberId = GetUnitByCid(Job, Player.PlayerData.citizenid)
    if not UnitId then return end

    Units[Job][UnitId].Units[MemberId].Radio = Radio
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Job, UnitId, Units[Job][UnitId])
end)

RegisterNetEvent("fw-mdw:Server:SetDuty")
AddEventHandler("fw-mdw:Server:SetDuty", function(Data)
    local Source = Data.Source or source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Data.Job == 'Dispatch' then
        if not Data.Duty then
            for k, v in pairs(CurrentDispatchers) do
                if v == Player.PlayerData.charinfo.phone then
                    table.remove(CurrentDispatchers, k)
                    return
                end
            end

            Player.Functions.Notify("Uitgeklokt als dispatcher.")
            return
        end

        table.insert(CurrentDispatchers, Player.PlayerData.charinfo.phone)
        Player.Functions.Notify("Je bent nu ingeklokt als dispatcher.")

        return
    end

    if Player.PlayerData.job.name ~= Data.Job:lower() then
        return Player.Functions.Notify("Ze herkennen je niet..", "error")
    end

    local UnitId, MemberId = GetUnitByCid(Data.Job, Player.PlayerData.citizenid)
    if UnitId and Units[Data.Job][UnitId] and Units[Data.Job][UnitId].Cid == Player.PlayerData.citizenid then
        RemoveUnitFromDispatchMap(Data.Job, Units[Data.Job][UnitId].Cid)
        TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Remove", Data.Job, UnitId)
        table.remove(Units[Data.Job], UnitId)
    end

    Player.Functions.SetJobDuty(Data.Duty)
    TriggerClientEvent("FW:Client:SetDuty", Source, Data.Duty)

    if not Data.Duty then
        return
    end

    if Data.Job ~= 'Police' and Data.Job ~= 'EMS'and Data.Job ~= 'DOC' then
        return
    end

    local Icons = {
        ['EMS'] = 'fa-ambulance',
        ['Police'] = 'fa-car',
        ['DOC'] = 'fa-user-cowboy',
    }

    local NewUnitId = #Units[Data.Job] + 1
    Units[Data.Job][NewUnitId] = {
        Busy = false,
        Unavailable = false,
        Cid = Player.PlayerData.citizenid,
        Icon = Icons[Data.Job],
        Units = {
            {
                Cid = Player.PlayerData.citizenid,
                Callsign = Player.PlayerData.metadata.callsign,
                Radio = exports['fw-voice']:GetSubscriberChannel(Player.PlayerData.source),
                Name = ("%s %s"):format(Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname)
            },
        }
    }

    AddUnitToDispatchMap(Source, Data.Job, Player.PlayerData.citizenid, Player.PlayerData.metadata.callsign)

    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Data.Job, NewUnitId, Units[Data.Job][NewUnitId])
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:AddUnit")
AddEventHandler("fw-mdw:Server:Dispatch:AddUnit", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Job then return end
    if not Data.Cid then return end
    if not Data.UnitCid then return end

    local UnitId, MemberId = GetUnitByCid(Data.Job, Data.Cid)
    if not UnitId or not Units[Data.Job][UnitId] then return end

    local TargetUnitId, TargetMemberId = GetUnitByCid(Data.Job, Data.UnitCid)
    if not TargetUnitId or not Units[Data.Job][TargetUnitId] then return end

    local NewUnits = TableConcat(Units[Data.Job][UnitId].Units, Units[Data.Job][TargetUnitId].Units)
    
    Units[Data.Job][UnitId].Units = NewUnits
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Data.Job, UnitId, Units[Data.Job][UnitId])

    table.remove(Units[Data.Job], TargetUnitId)
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Remove", Data.Job, TargetUnitId)

    RemoveUnitFromDispatchMap(Data.Job, Data.UnitCid)
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:SetVehicle")
AddEventHandler("fw-mdw:Server:Dispatch:SetVehicle", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Job then return end
    if not Data.Cid then return end
    if not Data.Icon then return end

    local UnitId, MemberId = GetUnitByCid(Data.Job, Data.Cid)
    if not UnitId or not Units[Data.Job][UnitId] then return end

    Units[Data.Job][UnitId].Icon = Data.Icon
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Data.Job, UnitId, Units[Data.Job][UnitId])

    if Data.Icon ~= "Ignore" then
        SetMarkerUnitVehicle(Data.Cid, Data.Type)
    end
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:RemoveUnit")
AddEventHandler("fw-mdw:Server:Dispatch:RemoveUnit", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Job then return end
    if not Data.Cid then return end
    if not Data.UnitCid then return end

    local UnitId, MemberId = GetUnitByCid(Data.Job, Data.Cid)
    if not UnitId or not Units[Data.Job][UnitId] then return end

    local NewUnits = Units[Data.Job][UnitId].Units
    for i = 1, #NewUnits, 1 do
        if NewUnits[i].Cid == Data.UnitCid then
            table.remove(NewUnits, i)
            break
        end
    end

    Units[Data.Job][UnitId].Units = NewUnits
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Data.Job, UnitId, Units[Data.Job][UnitId])

    local Target = FW.Functions.GetPlayerByCitizenId(Data.UnitCid)
    if Target == nil then return end

    local NewUnitId = #Units[Data.Job] + 1
    Units[Data.Job][NewUnitId] = {
        Busy = false,
        Unavailable = false,
        Cid = Target.PlayerData.citizenid,
        Icon = Job == 'EMS' and 'fa-ambulance' or 'fa-car',
        Units = {
            {
                Cid = Target.PlayerData.citizenid,
                Callsign = Target.PlayerData.metadata.callsign,
                Radio = exports['fw-voice']:GetSubscriberChannel(Target.PlayerData.source),
                Name = ("%s %s"):format(Target.PlayerData.charinfo.firstname, Target.PlayerData.charinfo.lastname)
            },
        }
    }

    AddUnitToDispatchMap(Target.PlayerData.source, Data.Job, Target.PlayerData.citizenid, Target.PlayerData.metadata.callsign)

    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Data.Job, NewUnitId, Units[Data.Job][NewUnitId])
end)

RegisterNetEvent("fw-mdw:Server:Dispatch:SetStatus")
AddEventHandler("fw-mdw:Server:Dispatch:SetStatus", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    if not IsDispatcher(Source) then return end

    if not Data.Job then return end
    if not Data.Cid then return end

    local UnitId, MemberId = GetUnitByCid(Data.Job, Data.Cid)
    if not UnitId or not Units[Data.Job][UnitId] then return end

    Units[Data.Job][UnitId].Busy = Data.Busy
    Units[Data.Job][UnitId].Unavailable = Data.Unavailable
    TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Data.Job, UnitId, Units[Data.Job][UnitId])
end)

RegisterNetEvent("fw-mdw:Server:PlayerDisconnect")
AddEventHandler("fw-mdw:Server:PlayerDisconnect", function(Target)
    local Source = Target or source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    for k, v in pairs(CurrentDispatchers) do
        if v == Player.PlayerData.charinfo.phone then
            table.remove(CurrentDispatchers, k)
            return
        end
    end

    local Job = DispatchJobs[Player.PlayerData.job.name]
    if not Job then
        return
    end

    local UnitId, MemberId = GetUnitByCid(Job, Player.PlayerData.citizenid)
    if not UnitId or not Units[Job][UnitId] then return end

    table.remove(Units[Job][UnitId].Units, MemberId)

    if #Units[Job][UnitId].Units == 0 then
        RemoveUnitFromDispatchMap(Job, Player.PlayerData.citizenid)
        table.remove(Units[Job], UnitId)
        TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Remove", Job, UnitId)
    else
        Units[Job][UnitId].Cid = Units[Job][UnitId].Units[1].Cid
        RemoveUnitFromDispatchMap(Job, Player.PlayerData.citizenid)
        AddUnitToDispatchMap(Player.PlayerData.source, Job, Units[Job][UnitId].Units[1].Cid, Units[Job][UnitId].Units[1].Callsign)
        TriggerClientEvent("fw-mdw:Client:SetUnitData", -1, "Set", Job, UnitId, Units[Job][UnitId])
    end
end)

AddEventHandler("playerDropped", function()
    local Source = source
    TriggerEvent("fw-mdw:Server:PlayerDisconnect", Source)
end)

function GetUnitByCid(Job, Cid)
    if Units[Job] == nil then
        return false, 0
    end

    for k, v in pairs(Units[Job]) do
        if v.Cid == Cid then
            return k, 1
        end

        for i, j in pairs(v.Units) do
            if j.Cid == Cid then
                return k, i
            end
        end
    end
    return false, 0
end

exports("GetCurrentDispatchers", function()
    return CurrentDispatchers
end)

exports("GetAvailableDispatcher", function()
    for k, v in pairs(CurrentDispatchers) do
        if not exports['fw-phone']:IsCallOngoingByPhone(v) then
            return v
        end
    end

    return false
end)