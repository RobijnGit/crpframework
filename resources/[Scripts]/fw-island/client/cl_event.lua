
RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    RequestModel("prop_food_tray_01")
    RequestModel("prop_till_01")
    while not HasModelLoaded("prop_food_tray_01") do Citizen.Wait(4) end
    for k, v in pairs(Config.IslandItems) do
        exports['fw-ui']:AddEyeEntry(v.name, {
            Type = 'Zone',
            SpriteDistance = 10.0,
            Distance = 1.75,
            ZoneData = {
                Center = v.center,
                Length = v.length,
                Width = v.width,
                Data = {
                    heading = v.heading,
                    minZ = v.minZ,
                    maxZ = v.maxZ,
                },
            },
            Options = v.options
        })
        if v.Type == 'Tray' then
            local tray = CreateObject(GetHashKey("prop_food_tray_01"), v.center.x, v.center.y, v.center.z-1, false,  false, false)
            SetEntityHeading(tray,v.entityHeading)
        end
        if v.Type == 'Register' then
            local register = CreateObject(GetHashKey("prop_till_01"), v.center.x, v.center.y, v.center.z-1, false,  false, false)
            SetEntityHeading(register,v.entityHeading)
        end
    end
end)

RegisterNetEvent("fw-island:Client:Foodchain:SetupPayment")
AddEventHandler("fw-island:Client:Foodchain:SetupPayment", function(Data)
    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Kosten', Icon = 'fas fa-euro-sign', Name = 'Costs', Type = 'number' },
        { Label = 'Bestelling', Icon = 'fas fa-pencil', Name = 'Comment' },
    })

    if Result then
        TriggerServerEvent('fw-island:Server:Foodchain:SetPaymentData', 'island', Data.RegisterId, Result.Comment, tonumber(Result.Costs))
    end
end)

RegisterNetEvent("fw-island:Client:Foodchain:GetPayments")
AddEventHandler("fw-island:Client:Foodchain:GetPayments", function(Data)
    FW.Functions.TriggerCallback("fw-island:Server:Foodchain:GetPaymentData", function(Payment)
        if not Payment then
            FW.Functions.Notify("Er is geen actieve bestelling..", "error")
            return
        end

        FW.Functions.OpenMenu({
            MainMenuItems = {
                {
                    Icon = 'info-circle',
                    Title = 'Restaurant Bestelling',
                    Desc = exports['fw-businesses']:NumberWithCommas(Payment.Costs) .. ' | ' .. Payment.Order, 
                    Data = { Event = '', Type = '' }
                },
                {
                    Icon = 'credit-card',
                    Title = 'Betalen met Bank',
                    CloseMenu = true,
                    Data = {
                        Event = 'fw-island:Server:Foodchain:PayRegister',
                        Type = 'Server',
                        Foodchain = 'island',
                        Register = Data.RegisterId,
                        PaymentType = 'Bank',
                    },
                },
                {
                    Icon = 'money-bill',
                    Title = 'Betalen met Cash',
                    CloseMenu = true,
                    Data = {
                        Event = 'fw-island:Server:Foodchain:PayRegister',
                        Type = 'Server',
                        Foodchain = 'island',
                        Register = Data.RegisterId,
                        PaymentType = 'Cash',
                    },
                },
            }
        })
    end, Data.Foodchain, Data.RegisterId)
end)

function canPlayerUseRegister()
    local CitizenId = FW.Functions.GetPlayerData().citizenid
    if CitizenId == '2449' or CitizenId == '2546' or  CitizenId == '3084' then
        return true
    end
    return false
end
exports("canPlayerUseRegister", canPlayerUseRegister)