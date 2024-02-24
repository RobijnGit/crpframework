Calls = {
    Calls = {}
}

function ClearCallHistory()
    Calls.Calls = {}
end

RegisterNUICallback("Calls/GetCalls", function(Data, Cb)
    Cb(Calls.Calls)
end)

RegisterNetEvent("fw-phone:Client:AddCall")
AddEventHandler("fw-phone:Client:AddCall", function(Data)
    Calls.Calls[#Calls.Calls + 1] = Data
    SetAppUnread("calls")
end)