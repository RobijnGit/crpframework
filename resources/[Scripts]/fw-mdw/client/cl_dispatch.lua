RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    if not LoggedIn then return end
    LoadMarkers()
end)

RegisterNetEvent("fw-ui:appRestart")
AddEventHandler("fw-ui:appRestart", function(App)
    if (App ~= "root" and App ~= "Dispatch") then return end
    LoadMarkers()
end)

function LoadMarkers()
    local Markers = FW.SendCallback("fw-mdw:Server:GetMarkers")

    for k, v in pairs(Markers) do
        if v then
            exports['fw-ui']:SendUIMessage("Dispatch", "CreateMarker", v)
        end
    end

    Alerts = FW.SendCallback("fw-mdw:Client:GetAlerts")
    Calls = FW.SendCallback("fw-mdw:Client:GetCalls")
    Units = FW.SendCallback("fw-mdw:Client:GetUnits")

    exports['fw-ui']:SendUIMessage("Dispatch", "SetAlerts", {Calls = Calls, Alerts = Alerts})
    exports['fw-ui']:SendUIMessage("Dispatch", "SetUnits", Units)
end

RegisterNetEvent("fw-mdw:Client:DutyAction")
AddEventHandler("fw-mdw:Client:DutyAction", function(Data)
    FW.Functions.OpenMenu({
        MainMenuItems = {
            {
                Icon = 'info-circle',
                Title = Config.DutyActions[Data.Job],
                Desc = "Ga in- of uit dienst.",
                Data = { Event = '', Type = 'Client' },
                SecondMenu = {
                    {
                        Icon = 'sign-in',
                        Title = 'In dienst gaan',
                        Desc = "Ga in dienst als " .. Config.DutyActions[Data.Job],
                        CloseMenu = true,
                        Data = { Event = 'fw-mdw:Server:SetDuty', Type = 'Server', Duty = true, Job = Data.Job }
                    },
                    {
                        Icon = 'sign-out',
                        Title = 'Uit dienst gaan',
                        Desc = "Ga uit dienst.",
                        CloseMenu = true,
                        Data = { Event = 'fw-mdw:Server:SetDuty', Type = 'Server', Duty = false, Job = Data.Job }
                    },
                }
            }
        }
    })
end)

RegisterNetEvent("fw-mdw:Client:SetUnitData")
AddEventHandler("fw-mdw:Client:SetUnitData", function(Type, Job, Id, Data)
    if not LoggedIn then return end

    if Type == 'Set' then
        if Units[Job] == nil then return end
        Units[Job][Id] = Data
    elseif Type == 'Remove' then
        if Units[Job] == nil or Units[Job][Id] == nil then return end
        table.remove(Units[Job], Id)
    end

    exports['fw-ui']:SendUIMessage("Dispatch", "SetUnits", Units)
end)

RegisterNUICallback("Dispatch/SetGPS", function(Data, Cb)
    SetNewWaypoint(Data.x, Data.y)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/Dismiss", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:DismissPing", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/CreateCall", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:CreateCall", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/RemoveUnits", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:Dispatch:RemoveUnits", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/SetRadioFrequency", function(Data, Cb)
    Cb("Ok")

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Radio', Icon = 'fas fa-signal', Name = 'Radio', Type = 'number' },
    })

    if Result and Result.Radio then
        TriggerServerEvent("fw-mdw:Server:Dispatch:SetCallRadio", {Id = Data.Id, Radio = Result.Radio})
    end
end)

RegisterNUICallback("Dispatch/ToggleCallUnit", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:Dispatch:ToggleCallUnit", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/AddUnit", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:Dispatch:AddUnit", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/SetVehicle", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:Dispatch:SetVehicle", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/RemoveUnit", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:Dispatch:RemoveUnit", Data)
    Cb("Ok")
end)

RegisterNUICallback("Dispatch/SetStatus", function(Data, Cb)
    TriggerServerEvent("fw-mdw:Server:Dispatch:SetStatus", Data)
    Cb("Ok")
end)

-- Map
RegisterNetEvent("fw-mdw:Client:AddDispatchMarker")
AddEventHandler("fw-mdw:Client:AddDispatchMarker", function(Data)
    exports['fw-ui']:SendUIMessage("Dispatch", "CreateMarker", Data)
end)

RegisterNetEvent("fw-mdw:Client:RemoveDispatchMarker")
AddEventHandler("fw-mdw:Client:RemoveDispatchMarker", function(Data)
    exports['fw-ui']:SendUIMessage("Dispatch", "RemoveMarker", Data)
end)

RegisterNetEvent("fw-mdw:Client:SetDispatchMarkerCoords")
AddEventHandler("fw-mdw:Client:SetDispatchMarkerCoords", function(Data)
    exports['fw-ui']:SendUIMessage("Dispatch", "SetMarkerCoords", Data)
end)

RegisterNetEvent("fw-mdw:Client:SetDispatchMarkerText")
AddEventHandler("fw-mdw:Client:SetDispatchMarkerText", function(Data)
    exports['fw-ui']:SendUIMessage("Dispatch", "SetMarkerText", Data)
end)

RegisterNetEvent("fw-mdw:Client:SetDispatchMarkerType")
AddEventHandler("fw-mdw:Client:SetDispatchMarkerType", function(Data)
    exports['fw-ui']:SendUIMessage("Dispatch", "SetMarkerType", Data)
end)