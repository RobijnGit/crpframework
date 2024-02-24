local PayPhones = {
    "p_phonebox_01b_s",
    "prop_phonebox_01a",
    "prop_phonebox_01b",
    "prop_phonebox_01c",
    "prop_phonebox_02",
    "prop_phonebox_03",
    "prop_phonebox_04",
    "ch_chint02_phonebox001",
    "sf_prop_sf_phonebox_01b_s",
    "sf_prop_sf_phonebox_01b_straight",
}

local CallingFromPayphone, PayphoneCoords = false, false

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    for k, v in pairs(PayPhones) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
            Type = 'Model',
            Model = v,
            SpriteDistance = 5.0,
            Distance = 1.5,
            Options = {
                {
                    Name = 'call_payphone',
                    Icon = 'fas fa-phone-volume',
                    Label = 'Iemand bellen (€ 150.00)',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:Payphones:Call',
                    EventParams = { Costs = 150, Caller = 'Telefooncel', Phone = "69" .. tostring(FW.Shared.RandomInt(9)) },
                    Enabled = function(Entity)
                        return true
                    end,
                },
            }
        })
    end
end)

RegisterNetEvent("fw-misc:Client:Payphones:Call")
AddEventHandler("fw-misc:Client:Payphones:Call", function(Data, Entity)
    PayphoneCoords = GetEntityCoords(Entity)

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Telefoonnummer', Icon = 'fas fa-phone', Name = 'Phone' },
    })

    if Result and Result.Phone and #Result.Phone == 10 then
        local CashRemoved = FW.SendCallback("FW:RemoveCash", Data.Costs)
        if not CashRemoved then
            return FW.Functions.Notify("Niet genoeg cash..", "error")
        end
        
        CallingFromPayphone = true
        TriggerServerEvent("fw-phone:Server:DialPayphone", {
            Phone = Result.Phone,
            CallerName = Data.Caller,
            CallingFrom = Data.Phone,
        })
    end
end)

RegisterNetEvent("fw-misc:Client:DialPhone")
AddEventHandler("fw-misc:Client:DialPhone", function(...)
    TriggerServerEvent("fw-phone:Server:DialPayphone", ...)
end)

RegisterNetEvent("fw-phone:Client:SetCallData")
AddEventHandler("fw-phone:Client:SetCallData", function(Data)
    if not PayphoneCoords then return end

    if not Data then
        CallingFromPayphone = false
        return
    end

    CallingFromPayphone = Data.Payphone

    Citizen.CreateThread(function()
        if not PayphoneCoords then end
        while CallingFromPayphone and #(GetEntityCoords(PlayerPedId()) - PayphoneCoords) <= 3.0 do Citizen.Wait(500) end
        if #(GetEntityCoords(PlayerPedId()) - PayphoneCoords) > 3.0 then
            FW.Functions.Notify("Je gaat te ver weg van de telefooncel..", "error")
            TriggerServerEvent('fw-phone:Server:Contacts:DeclineCall', { CallId = Data.CallId })
        end
        PayphoneCoords = false
    end)
end)