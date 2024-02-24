FW = exports['fw-core']:GetCoreObject()
LoggedIn, PlayerJob = false, {}

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    PlayerJob = FW.Functions.GetPlayerData().job
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code
NearBank = false

-- Events
RegisterNetEvent('fw-financials:Client:Give:Cash:Animation')
AddEventHandler('fw-financials:Client:Give:Cash:Animation', function()
    if not IsPedInAnyVehicle(PlayerPedId()) then
        exports['fw-assets']:RequestAnimationDict("friends@laf@ig_5")
        TaskPlayAnim(PlayerPedId(), 'friends@laf@ig_5', 'nephew', 5.0, 1.0, 5.0, 49, 0, 0, 0, 0)
        Citizen.Wait(1500)
        ClearPedTasks(PlayerPedId())
    end
end)

RegisterNetEvent("fw-financials:Client:OpenFinancial")
AddEventHandler("fw-financials:Client:OpenFinancial", function(IsBank, Entity)
    local AnimDict, Anim, Text = 'amb@prop_human_atm@male@idle_a', 'idle_b', 'Kaart plaatsen..'
    if IsBank then
        AnimDict, Anim, Text = 'mp_common', 'givetake1_a', 'Bankdocumentatie tonen..'
    else
        TaskTurnPedToFaceEntity(PlayerPedId(), Entity, -1)
    end

    FW.Functions.Progressbar("financial", Text, 2000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = AnimDict,
        anim = Anim,
        flags = 49,
    }, {}, {}, function() -- Done
        local Accounts = FW.SendCallback("fw-financials:Server:GetPlayerAccounts")

        ClearPedTasks(PlayerPedId())
        StopAnimTask(PlayerPedId(), AnimDict, Anim, 1.0)
        exports['fw-ui']:SetUIFocus(true, true)
        exports['fw-ui']:SendUIMessage("Financials", "SetVisibility", {
            Visible = true,
            Cash = FW.Functions.GetPlayerData().money.cash,
            Accounts = Accounts,
            IsATM = not IsBank
        })
    end, function() end)
end)

RegisterNetEvent("fw-financials:Client:RefreshFinancials")
AddEventHandler("fw-financials:Client:RefreshFinancials", function()
    local Accounts = FW.SendCallback("fw-financials:Server:GetPlayerAccounts")
    exports['fw-ui']:SendUIMessage("Financials", "SetFinancials", Accounts)
end)

RegisterNetEvent("fw-financials:Client:SendMonitoredAccount")
AddEventHandler("fw-financials:Client:SendMonitoredAccount", function(Name)
    TriggerServerEvent("fw-mdw:Server:SendAlert:MonitedAccountActivity", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), Name)
end)

-- Functions
function GetAccountBalance(AccountId)
    local Balance = FW.SendCallback("fw-financials:Server:GetAccountBalance", AccountId)
    return Balance
end
exports("GetAccountBalance", GetAccountBalance)

-- NUI Callback
RegisterNUICallback("Financials/Close", function(Data, Cb)
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage("Financials", "SetVisibility", { Visible = false })

    local AnimDict, Anim, Text = 'amb@prop_human_atm@male@exit', 'exit', 'Kaart ophalen..'
    if NearBank then
        AnimDict, Anim, Text = 'mp_common', 'givetake1_a', 'Documentatie verzamelen..'
    end

    FW.Functions.Progressbar("financial", Text, 1000, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = AnimDict,
        anim = Anim,
        flags = 49,
    }, {}, {}, function() -- Done
        ClearPedTasks(PlayerPedId())
        StopAnimTask(PlayerPedId(), AnimDict, Anim, 1.0)
    end, function() end)

    Cb("ok")
end)

RegisterNUICallback("Financials/GetAccounts", function(Data, Cb)
    local Result = FW.SendCallback("fw-financials:Server:GetPlayerAccounts")
    Cb(Result)
end)

RegisterNUICallback("Financials/GetTransactions", function(Data, Cb)
    local Result = FW.SendCallback("fw-financials:Server:GetAccountTransactions", Data)
    Cb(Result)
end)

RegisterNUICallback("Financials/Deposit", function(Data, Cb)
    local Result = FW.SendCallback("fw-financials:Server:Deposit", Data)
    Cb(Result)
end)

RegisterNUICallback("Financials/Withdraw", function(Data, Cb)
    local Result = FW.SendCallback("fw-financials:Server:Withdraw", Data)
    Cb(Result)
end)

RegisterNUICallback("Financials/Transfer", function(Data, Cb)
    local Result = FW.SendCallback("fw-financials:Server:Transfer", Data)
    Cb(Result)
end)

RegisterNUICallback("Financials/ExportData", function(Data, Cb)
    local Result = FW.SendCallback("fw-financials:Server:ExportData", Data)
    Cb(Result)
end)