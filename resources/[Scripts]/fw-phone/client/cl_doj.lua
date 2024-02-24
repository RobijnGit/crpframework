RegisterNUICallback("DOJ/GetUsers", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:DOJ:GetUsers")
    Cb(Result)
end)

RegisterNUICallback("DOJ/SetStatus", function(Data, Cb)
    FW.TriggerServer("fw-phone:Server:DOJ:SetStatus", Data)
    Cb("ok")
end)