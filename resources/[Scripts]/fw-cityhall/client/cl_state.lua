RegisterNetEvent("fw-cityhall:Client:OpenStateMenu")
AddEventHandler("fw-cityhall:Client:OpenStateMenu", function()
    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob.name ~= "mayor" and PlayerJob.name ~= "judge" then return end

    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-ui']:SendUIMessage("State", "SetVisibility", {
        Visible = true
    })
end)

RegisterNUICallback("State/Close", function(Data, Cb)
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage("State", "SetVisibility", {
        Visible = false
    })

    Cb("Ok")
end)

RegisterNUICallback("State/GetTaxes", function(Data, Cb)
    local CurrentTaxes = FW.SendCallback("FW:GetTax")
    local NewTax = FW.SendCallback("fw-cityhall:Server:GetTax")

    Cb({Current = CurrentTaxes, New = NewTax})
end)

RegisterNUICallback("State/SetTax", function(Data, Cb)
    FW.TriggerServer('fw-cityhall:Server:SetTax', Data)
    Cb("Ok")
end)