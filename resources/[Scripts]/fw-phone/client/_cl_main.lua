FW = exports['fw-core']:GetCoreObject()
LoggedIn, PlayerJob = false, {}

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    PlayerJob = FW.Functions.GetPlayerData().job
    LoggedIn = true
    InitPhone(false)
    ClearCallHistory()
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
    Mails.Mails = {}
end)

RegisterNetEvent('FW:Player:SetPlayerData')
AddEventHandler('FW:Player:SetPlayerData', function()
	if not IsPhoneOpen then return end
    Citizen.SetTimeout(100, function()
        UpdatePlayerData()
    end)
end)

RegisterNetEvent("fw-hud:Client:OnPreferenceUpdate")
AddEventHandler("fw-hud:Client:OnPreferenceUpdate", function(Preferences)
    SendNUIMessage({
        Action = "SetPhoneBrand",
        Brand = Preferences['Phone.Brand']
    })

    SendNUIMessage({
        Action = "SetPhoneBackground",
        Background = Preferences['Phone.Background']
    })

    SendNUIMessage({
        Action = "SetEmbedsEnabled",
        Enabled = Preferences['Images.Embedded']
    })
end)

-- Code
CurrentApp, CurrentNetwork, IsNetworkEnabled = 'home', '', true
NotificationsIds, IsPhoneOpen, UsingBurner, InCamera = {}, false, false, false

-- Loops
Citizen.CreateThread(function()
    FW.AddKeybind("openMobile", "Telefoon", "Openen", "M", OpenPhone)
    FW.AddKeybind("phoneAnwser", "Telefoon", "Opnemen", "", function(IsPressed)
        if not IsPressed then return end

        local PlayerData = FW.Functions.GetPlayerData()
        if PlayerData.metadata.ishandcuffed or PlayerData.metadata.isdead then return end

        if CallData == nil or not CallData.Dialing then return end
        TriggerServerEvent('fw-phone:Server:Contacts:AnswerContact', {CallId = CallData.CallId})
    end)

    FW.AddKeybind("phoneDecline", "Telefoon", "Ophangen", "", function(IsPressed)
        if not IsPressed then return end

        local PlayerData = FW.Functions.GetPlayerData()
        if PlayerData.metadata.ishandcuffed or PlayerData.metadata.isdead then return end

        if CallData == nil then return end
        TriggerServerEvent('fw-phone:Server:Contacts:DeclineCall', {CallId = CallData.CallId})
    end)

    while true do
        DisableControlAction(0, 199, true)
        Citizen.Wait(4)
    end
end)

Citizen.CreateThread(function()
    RequestModel("csb_sol")
    while not HasModelLoaded("csb_sol") do Citizen.Wait(4) end

    local PedCoords = FW.SendCallback("fw-heists:Server:GetPedCoords", "PublicHotspot")
    local TempPed = CreatePed(-1, "csb_sol", PedCoords.x, PedCoords.y, PedCoords.z, PedCoords.w, false, true)
    SetEntityHeading(TempPed, PedCoords.w)
    FreezeEntityPosition(TempPed, true)
    FreezeEntityPosition(TempPed, true)
    SetEntityInvincible(TempPed, true)
    SetPedDefaultComponentVariation(TempPed)
    SetBlockingOfNonTemporaryEvents(TempPed, true)
    TaskStartScenarioInPlace(TempPed, "WORLD_HUMAN_STAND_MOBILE", 0, true)

    -- while true do
    --     if LoggedIn then
    --         if IsPhoneOpen or #NotificationsIds > 0 then
    --             local Time = exports['fw-sync']:GetCurrentTime()
    --             SendNUIMessage({
    --                 Action = "UpdateGameTime",
    --                 Time = { Time.Hour, Time.Minute } ,
    --             })
    --         end
    --     else
    --         Citizen.Wait(5000)
    --     end
    --     Citizen.Wait(2350)
    -- end
end)

-- NUI Callbacks
RegisterNUICallback("SetCurrentApp", function(Data, Cb)
    CurrentApp = Data.App
    Cb("Ok")
end)

RegisterNUICallback("ClosePhone", function(Data, Cb)
    ClosePhone(false)

    if Data.Crash then
        InitPhone(true)
    end

    Cb("Ok")
end)

RegisterNUICallback("Notifications/Click", function(Data, Cb)
    local NotifData = NotificationsIds[Data.Id]
    if NotifData == nil then return Cb("Ok") end
    local NotificationCallback = NotifData.OnAccept
    if not Data.Accepted then NotificationCallback = NotifData.OnReject end

    if type(NotificationCallback) == 'function' then
        NotificationCallback(NotifData)
    elseif type(NotificationCallback) == 'string' then
        if string.find(NotificationCallback:lower(), ':server:') then
            TriggerServerEvent(NotificationCallback, NotifData.Data)
        else
            TriggerEvent(NotificationCallback, NotifData.Data)
        end
    end

    NotificationsIds[Data.Id] = nil

    Cb("Ok")
end)

RegisterNUICallback("Network/GetNetworks", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Networks:GetNetworks")
    Cb(Result)
end)

RegisterNUICallback("Network/Connect", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:Networks:Connect", Data)
    if Result.Success then
        CurrentNetwork = Data.Network
        SendNUIMessage({
            Action = "SetCurrentNetwork",
            Network = Data.Network
        })

        Citizen.CreateThread(function()
            while true do
                if #(GetEntityCoords(PlayerPedId()) - Result.Coords) > Result.Size then
                    CurrentNetwork = ''
                    SendNUIMessage({
                        Action = "SetCurrentNetwork",
                        Network = CurrentNetwork
                    })
                    break
                end
                Citizen.Wait(1000)
            end
        end)
    end
    Cb(Result.Success)
end)

RegisterNUICallback("Phone/ToggleSounds", function(Data, Cb)
    TriggerServerEvent('fw-phone:Server:SetSoundState', Data.State)
end)

RegisterNUICallback("Phone/Selfie", function(Data, Cb)
    ClosePhone(true)
    InCamera = true

    DestroyMobilePhone()
    Citizen.Wait(0) -- dunno why, but if it doesn't wait, it doesn't work?
    CreateMobilePhone(0)
    CellCamActivate(true, true)
    CellCamDisableThisFrame(true)

    Citizen.CreateThread(function()
        while InCamera do
            if IsControlJustPressed(0, 177) then
                InCamera = false
                
                DestroyMobilePhone()
                Citizen.Wait(0) -- dunno why, but if it doesn't wait, it doesn't work?
                CellCamDisableThisFrame(false)
                CellCamActivate(false, false)
            end
            
            Citizen.Wait(0)
        end
    end)

    -- Little workaround, because disabling the 199 and 200 key does not work (199 = P / 200 = ESC (pause menu alternate))
    local DisablePause = true
    Citizen.CreateThread(function()
        while DisablePause do
            SetPauseMenuActive(false)
            
            if IsControlJustPressed(0, 177) then
                Citizen.SetTimeout(500, function()
                    DisablePause = false
                end)
            end
            
            Citizen.Wait(0)
        end
    end)

    Cb('Ok')
end)

RegisterNUICallback("Utils/SetWaypoint", function(Data, Cb)
    SetNewWaypoint(Data.x, Data.y)
    Cb("ok")
end)

-- Functions
function InitPhone(Crashed)
    InitYellowPages()
    InitTwitter()
    InitDocuments()

    SendNUIMessage({
        Action = "SetTax",
        Tax = FW.SendCallback("FW:GetTax")
    })

    local HasUnreadConversations = FW.SendCallback("fw-phone:Server:HasUnreadConversations")
    if HasUnreadConversations then
        SetAppUnread("messages")
        FW.Functions.Notify("Je hebt ongelezen berichten.")
    end

    if Crashed then
        TriggerEvent("fw-hud:Client:ReloadPreferences")
    end

    IsNetworkEnabled = FW.SendCallback("fw-phone:Server:GetNetworkState")
end

function GetNearNetwork()
    local IsNearNetwork = FW.SendCallback("fw-phone:Server:Networks:IsNearNetwork")
    return IsNearNetwork
end

function OpenPhone(IsPressed, IsBurner)
    if not IsPressed then return end
    UsingBurner = IsBurner

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.metadata.isdead or PlayerData.metadata.ishandcuffed then return end
    if not exports['fw-inventory']:HasEnoughOfItem(IsBurner and 'burnerphone' or 'phone', 1) then return end
    
    IsPhoneOpen = true
    local HasVPN = exports['fw-inventory']:HasEnoughOfItem('vpn', 1) and PlayerData.job.name ~= 'police'
    local HasRacingUsb, HasPDRacingUsb, RacingAlias = table.unpack(exports['fw-racing']:HasRacingUsb())

    local DisableMovement = exports['fw-hud']:GetPreferenceById('Phone.DisableMovement')
    SetNuiFocus(true, true)

    if not DisableMovement then
        SetNuiFocusKeepInput(true)

        Citizen.CreateThread(function()
            while IsPhoneOpen do
                Citizen.Wait(0)

                -- disable camera movement
                DisableControlAction(0, 0, true)
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 3, true)
                DisableControlAction(0, 4, true)
                DisableControlAction(0, 5, true)
                DisableControlAction(0, 6, true)
                DisableControlAction(0, 26, true)
                DisableControlAction(0, 79, true)
                DisableControlAction(0, 270, true)
                DisableControlAction(0, 271, true)
                DisableControlAction(0, 272, true)
                DisableControlAction(0, 273, true)
                DisableControlAction(0, 286, true)
                DisableControlAction(0, 287, true)
                DisableControlAction(0, 290, true)
                DisableControlAction(0, 291, true)
                DisableControlAction(0, 292, true)
                DisableControlAction(0, 293, true)
                DisableControlAction(0, 294, true)
                DisableControlAction(0, 295, true)
                DisableControlAction(0, 329, true)
                DisableControlAction(0, 330, true)

                -- disable pause
                DisableControlAction(0, 199, true)
                DisableControlAction(0, 200, true)

                -- disable attack
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 68, true)
                DisableControlAction(0, 69, true)
                DisableControlAction(0, 70, true)
                DisableControlAction(0, 91, true)
                DisableControlAction(0, 92, true)
                DisableControlAction(0, 114, true)
                DisableControlAction(0, 121, true)
                DisableControlAction(0, 140, true)
                DisableControlAction(0, 141, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 263, true)
                DisableControlAction(0, 264, true)
                DisableControlAction(0, 331, true)

                -- disable chat
                DisableControlAction(0, 245, true)
            end

            SetNuiFocusKeepInput(false)
        end)
    end

    local Time = exports['fw-sync']:GetCurrentTime()
    SendNUIMessage({
        Action = "OpenPhone",
        IsBurner = IsBurner,
        HasVPN = HasVPN,
        HasRacingUsb = HasRacingUsb,
        HasPDRacingUsb = HasPDRacingUsb,
        RacingAlias = RacingAlias,
        Weather = exports['fw-sync']:GetCurrentWeather(),
        Time = {Time.Hour, Time.Minute},
        IsNearNetwork = GetNearNetwork(),
        IsNetworkEnabled = IsNetworkEnabled,
        PlayerData = {
            Id = PlayerData.source,
            Cid = PlayerData.citizenid,
            BankId = PlayerData.charinfo.account,
            PhoneNumber = PlayerData.charinfo.phone,
            Cash = PlayerData.money.cash,
            Bank = exports['fw-financials']:GetAccountBalance(PlayerData.charinfo.account),
            Casino = PlayerData.money.casino,
            Crypto = PlayerData.money.crypto,
            RoomId = PlayerData.metadata.apartmentid,
            Job = PlayerData.job.name
        },
    })

    StartPhoneAnim()
end

function ClosePhone(Forced)
    IsPhoneOpen, CurrentApp = false, ""
    StopPhoneAnim()
    SetNuiFocus(false, false)
    if Forced then
        SendNUIMessage({
            Action = "ClosePhone",
        })
    end
end
exports("ClosePhone", ClosePhone)

RegisterNetEvent("fw-phone:Client:ClosePhone", ClosePhone)

function SetAppUnread(App)
    SendNUIMessage({
        Action = "SetAppUnread",
        App = App
    })
end
exports("SetAppUnread", SetAppUnread)

RegisterNetEvent("fw-phone:Client:SetAppUnread", SetAppUnread)

function UpdatePlayerData()
    local PlayerData = FW.Functions.GetPlayerData()
    SendNUIMessage({
        Action = "UpdatePlayerData",
        PlayerData = {
            Id = PlayerData.source,
            Cid = PlayerData.citizenid,
            BankId = PlayerData.charinfo.account,
            PhoneNumber = PlayerData.charinfo.phone,
            Cash = PlayerData.money.cash,
            Bank = exports['fw-financials']:GetAccountBalance(PlayerData.charinfo.account),
            Casino = PlayerData.money.casino,
            Crypto = PlayerData.money.crypto,
            RoomId = PlayerData.metadata.apartmentid,
            Job = PlayerData.job.name
        },
    })
end

--[[
    You can pass custom data into `Data` table, but there's also a few Data entries that you can use to control the notification, these are:
    - HideOnAction = true/false
        Auto hide notification when Accept/Reject button is clicked.
]]

function Notification(Id, Icon, IconColor, Title, Text, ShowTimer, ShowCountdown, OnAccept, OnReject, Data)
    if not LoggedIn then return end

    if not exports['fw-inventory']:HasEnoughOfItem("phone", 1) then
        return
    end

    NotificationsIds[Id] = {
        OnAccept = OnAccept,
        OnReject = OnReject,
        Data = Data,
    }

    SendNUIMessage({
        Action = "Notification",
        Id = Id,
        IconColor = IconColor[1],
        BgColor = IconColor[2],
        Icon = Icon,
        Title = Title,
        Text = Text,
        ShowTimer = ShowTimer,
        ShowCountdown = ShowCountdown,
        Data = Data,
        HasAccept = OnAccept ~= nil,
        HasReject = OnReject ~= nil,
    })
end

RegisterNetEvent("fw-phone:Client:Notification")
AddEventHandler("fw-phone:Client:Notification", function(...)
    Notification(...)
end)

function UpdateNotification(Id, RemoveTimer, RemoveCountdown, Title, Text, RemoveActions, HideImmediately)
    if RemoveActions then
        NotificationsIds[Id] = nil
    end

    SendNUIMessage({
        Action = "UpdateNotification",
        Id = Id,
        RemoveTimer = RemoveTimer,
        RemoveCountdown = RemoveCountdown,
        Title = Title,
        Text = Text,
        RemoveActions = RemoveActions,
        HideImmediately = HideImmediately,
    })
end

RegisterNetEvent("fw-phone:Client:UpdateNotification")
AddEventHandler("fw-phone:Client:UpdateNotification", function(...)
    if not exports['fw-inventory']:HasEnoughOfItem("phone", 1) then
        return
    end

    UpdateNotification(...)
end)

function RemoveNotification(Id)
    if not exports['fw-inventory']:HasEnoughOfItem("phone", 1) then
        return
    end

    NotificationsIds[Id] = nil
    SendNUIMessage({
        Action = "RemoveNotification",
        Id = Id,
    })
end

RegisterNetEvent("fw-phone:Client:RemoveNotification")
AddEventHandler("fw-phone:Client:RemoveNotification", function(...)
    RemoveNotification(...)
end)

RegisterNetEvent("fw-phone:Client:RemoveNotificationById")
AddEventHandler("fw-phone:Client:RemoveNotificationById", function(Data)
    UpdateNotification(Data.Id, true, true, nil, nil, true, true)
end)

exports("Notification", Notification)
exports("UpdateNotification", UpdateNotification)
exports("RemoveNotification", RemoveNotification)

RegisterNetEvent("fw-items:Client:Used:BurnerPhone")
AddEventHandler("fw-items:Client:Used:BurnerPhone", function(Item)
    OpenPhone(true, Item.Info.PhoneNumber)
end)

RegisterNetEvent("fw-phone:Client:SetNetworkState")
AddEventHandler("fw-phone:Client:SetNetworkState", function(State)
    IsNetworkEnabled = State
    
end)