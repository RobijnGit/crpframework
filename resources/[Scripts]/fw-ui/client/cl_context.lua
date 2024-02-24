local HasContext = false
function OpenMenu(MenuData)
    HasContext = true
    SendUIMessage("Context", "ShowContext", MenuData)
    Citizen.SetTimeout(5, function()
        SetNuiFocus(true, true)
    end)
end

function CloseMenu(Data)
    HasContext = false
    SetNuiFocus(false, false)
    SendUIMessage("Context", "CloseContext", Data)
end
exports("CloseContextMenu", CloseMenu)

RegisterNUICallback('Context/Close', function(Data, Cb)
    CloseMenu(Data)
    Cb("Ok")
end)

RegisterNUICallback('Context/ProcessClick', function(Data, Cb)
    local Params = Data.ContextItem.Args
    if Params == nil then
        Params = { Data.ContextItem }
    end

    if string.find(Data.ContextItem.Event:lower(), ":server:") then
        TriggerServerEvent(Data.ContextItem.Event, table.unpack(Params))
    else
        TriggerEvent(Data.ContextItem.Event, table.unpack(Params))
    end

    Cb("Ok")
end)