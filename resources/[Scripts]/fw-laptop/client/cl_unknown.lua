-- Application: Unknown (Gangs)
RegisterNUICallback("Unknown/FetchGang", function(Data, Cb)
    local Result = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    Cb(Result or {})
end)

RegisterNUICallback("Unknown/AddMember", function(Data, Cb)
    local Result = FW.SendCallback("fw-laptop:Server:Unknown:AddMember", Data)
    Cb(Result)
end)

RegisterNUICallback("Unknown/KickMember", function(Data, Cb)
    local Result = FW.SendCallback("fw-laptop:Server:Unknown:KickMember", Data)
    Cb(Result)
end)

RegisterNUICallback("Unknown/ToggleDiscoveredGraffitis", function(Data, Cb)
    TriggerEvent("fw-graffiti:Client:ToggleDiscovered")
    Cb("Ok")
end)

RegisterNUICallback("Unknown/ToggleContestedGraffitis", function(Data, Cb)
    TriggerEvent("fw-graffiti:Client:ToggleContested")
    Cb("Ok")
end)

RegisterNUICallback("Unknown/GetMessages", function(Data, Cb)
    local Result = FW.SendCallback('fw-laptop:Server:Unknown:GetMessages')
    Cb(Result)
end)

RegisterNUICallback("Unknown/SendMessage", function(Data, Cb)
    local Result = FW.SendCallback('fw-laptop:Server:Unknown:SendMessage', Data)
    Cb(Result)
end)

RegisterNetEvent("fw-laptop:Client:Unknown:RefreshGangChat")
AddEventHandler("fw-laptop:Client:Unknown:RefreshGangChat", function()
    if LaptopVisible then
        local Result = FW.SendCallback('fw-laptop:Server:Unknown:GetMessages')
        SendUIMessage("Unknown/SetMessages", Result)
    end
end)