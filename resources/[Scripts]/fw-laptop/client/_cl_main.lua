FW = exports['fw-core']:GetCoreObject()
LoggedIn, LaptopVisible = false, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
    SetGlobalData()

    if GetResourceKvpString("fw-laptop_preferences") == nil then
        SetResourceKvp("fw-laptop_preferences", json.encode({ background = '', whiteFont = true }))
    end
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

RegisterNetEvent("fw-ui:Client:refresh")
AddEventHandler("fw-ui:Client:refresh", function()
    Citizen.SetTimeout(100, SetGlobalData)
end)

-- Code

RegisterNetEvent("fw-laptop:Client:Open")
AddEventHandler("fw-laptop:Client:Open", function(Type)
    LaptopVisible = true

    exports['fw-assets']:AddProp('Tablet')
    exports['fw-assets']:RequestAnimationDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)

    local Time = exports['fw-sync']:GetCurrentTime()
    local PlayerData = FW.Functions.GetPlayerData()

    SetNuiFocus(true, true)
    SendUIMessage("Laptop/SetVisiblity", {
        Visible = true,
        HasVPN = exports['fw-inventory']:HasEnoughOfItem('vpn', 1),
        Time = (Time.Hour < 10 and "0" .. Time.Hour or Time.Hour) .. ":" .. (Time.Minute < 10 and "0" .. Time.Minute or Time.Minute),
        Preferences = json.decode(GetResourceKvpString("fw-laptop_preferences")),
        Type = Type,
        PlayerData = {
            Cid = PlayerData.citizenid
        },
    })
end)

RegisterNetEvent("fw-laptop:Client:AddNotification", function(Logo, Colors, Title, Message)
    SendUIMessage("Laptop/AddNotification", {
        Logo = Logo,
        Colors = Colors,
        Title = Title,
        Message = Message,
    })
end)

-- UI Wrapper Functions
function SetGlobalData()
    -- local PlayerData = FW.Functions.GetPlayerData()
    -- SendUIMessage("Mdw/SetGlobalData", Data)
end

function SendUIMessage(Action, Data)
    SendNUIMessage({
        Action = Action,
        Data = Data
    })
end
exports("SendUIMessage", SendUIMessage)

RegisterNUICallback("Laptop/Close", function(Data, Cb)
    LaptopVisible = false
    SetNuiFocus(false, false)

    SendUIMessage("Laptop/SetVisiblity", {
        Visible = false,
    })

    exports['fw-assets']:RemoveProp()
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0)

    Cb("Ok")
end)

RegisterNUICallback("Laptop/SaveSettings", function(Data, Cb)
    SetResourceKvp("fw-laptop_preferences", json.encode(Data))
    Cb("Ok")
end)

RegisterNUICallback("Laptop/GetLocale", function(Data, Cb)
    Cb(Config.Locale)
end)
