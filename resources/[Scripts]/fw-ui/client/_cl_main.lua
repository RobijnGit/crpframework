local ScannerOpen, isMeosOpened, isEPDOpened = false, false, false
FW, LoggedIn, Restarting = exports['fw-core']:GetCoreObject(), false, false
InVehicle, Seatbelt, ShowCompass = false, false, true

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function()
        ShowCompass = GetResourceKvpInt("fw-hide-compass") == 0
        LoggedIn = true

        RequestStreamedTextureDict('fw_sprites')
        if FW.GetCustomizedKey("eyePeek") ~= "L Alt" then
            FW.Functions.Notify("Je hebt de sneltoets van het oogje veranderd, hierdoor zal het oogje niet correct functioneren. (Standaard: Left Alt)", "error", 10000)
        end

        InitUI()
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn, InVehicle = false, false
end)

RegisterNetEvent('FW:Client:OnJobUpdate')
AddEventHandler('FW:Client:OnJobUpdate', function()
    InitUI()
end)

RegisterNetEvent('FW:Client:CloseNui')
AddEventHandler('FW:Client:CloseNui', function()
    SetNuiFocus(false, false)
end)

-- Code

RegisterNUICallback("uiReady", function(Data, Cb)
    SetNuiFocus(false, false)
    TriggerEvent("fw-ui:Ready")
    Cb("Ok")
end)

RegisterNUICallback("appRestart", function(Data, Cb)
    if Data.App == "root" then
        TriggerEvent("fw-ui:Ready")
        InitUI()
    end

    TriggerEvent("fw-ui:appRestart", Data.App)
end)

-- // Events \\ --

RegisterNetEvent("fw-ui:Client:CreateBadge")
AddEventHandler("fw-ui:Client:CreateBadge", function(Data)
    local Inputs = {
        { Label = 'Naam', Icon = 'fas fa-user', Name = 'Name' },
        { Label = 'Functie', Icon = 'fas fa-mask', Name = 'Rank' },
        { Label = 'Roepnummer (optioneel)', Icon = 'fas fa-tag', Name = 'Callsign' },
        { Label = 'Foto URL (.png/.jpg/.jpeg)', Icon = 'fas fa-heading', Name = 'Image' },
    }

    if Data.Badge == 'pd' then
        table.insert(Inputs, {
            Label = 'Department',
            Icon = 'fas fa-certificate',
            Name = 'Department',
            Choices = {
                { Text = "Unified PD" },
                { Text = "Los Santos PD" },
                { Text = "State Troopers" },
                { Text = "State Parks" },
                { Text = "Blaine County Sheriffs Office" },
            }
        })
    end

    local Result = exports['fw-ui']:CreateInput(Inputs)

    if Result and #Result.Name > 0 and #Result.Rank > 0 and #Result.Image > 0 then
        TriggerServerEvent("fw-ui:Server:CreateBadge", Data, Result)
    else
        FW.Functions.Notify("Je moet een naam, rang en foto aangeven!", "error")
    end
end)

RegisterNetEvent('fw-ui:Client:BadgeAnim')
AddEventHandler('fw-ui:Client:BadgeAnim', function(ItemInfo)
    exports['fw-assets']:RequestAnimationDict('paper_1_rcm_alt1-7')
    TaskPlayAnim(PlayerPedId(), "paper_1_rcm_alt1-7", "player_one_dual-7", 1.0, 1.0, -1, 63, 0, 0, 0, 0)
    exports['fw-assets']:AddProp('PBadge')
    Citizen.SetTimeout(9000, function()
        exports['fw-assets']:RemoveProp()
        ClearPedTasks(PlayerPedId())
    end)
end)

RegisterNetEvent('fw-ui:Client:ShowBadge')
AddEventHandler('fw-ui:Client:ShowBadge', function(Type, Data, Department)
    SendUIMessage("Badge", "ShowBadge", {
        Type = Type,
        Badge = Data,
    })
end)

RegisterNetEvent("fw-ui:Client:DoJumpscare")
AddEventHandler("fw-ui:Client:DoJumpscare", function()
    SendUIMessage("Halloween", "DoJumpscare")
end)

-- // Functions \\ --

function SendUIMessage(App, Action, Payload)
    SendNUIMessage({
        App = App,
        Action = Action,
        Payload = Payload,
    })
end
exports("SendUIMessage", SendUIMessage)
exports("SetUIFocus", SetNuiFocus)
exports("SetNuiFocus", SetNuiFocus)
exports("SetNuiFocusKeepInput", SetNuiFocusKeepInput)

function OpenEPD()
    isEPDOpened = true
    SetNuiFocus(true, true)
    SendUIMessage("Tablet", "SetIframe", {
        Iframe = "epd"
    })
end

function InitUI()
    local PlayerData = FW.Functions.GetPlayerData()
    SendUIMessage("Root", "SetPlayerData", {
        Cid = PlayerData.citizenid,
        Job = PlayerData.job.name,
        Duty = PlayerData.job.onduty,
    })
end

RegisterNUICallback("Tablet/Close", function(Data, Cb)
    isEPDOpened = false
    SendUIMessage("Tablet", "HideIframe", {})
    SetNuiFocus(false, false)

    exports['fw-assets']:RemoveProp()
    ClearPedTasks(PlayerPedId())

    Cb("Ok")
end)

exports('isEPDOpened', function()
    return isEPDOpened
end)

RegisterNetEvent("fw-ui:Client:ToggleCompass")
AddEventHandler("fw-ui:Client:ToggleCompass", function()
    ShowCompass = not ShowCompass
    SetResourceKvpInt("fw-hide-compass", ShowCompass and 1 or 0)

    FW.Functions.Notify("Je hebt het kompas " .. (ShowCompass and "geactiveerd" or "gedeactiveerd") .. "!", ShowCompass and "success" or "error")

    if IsPedInAnyVehicle(PlayerPedId()) and CompassState ~= ShowCompass then
        CompassState = ShowCompass
        SendNUIMessage({
            action = "SetCompassVisiblity",
            Visible = ShowCompass,
        })

        if ShowCompass then
            StartCompass()
        end
    end
end)

RegisterNetEvent('fw-ui:Client:refresh')
AddEventHandler('fw-ui:Client:refresh', function()
    SendUIMessage("Prompt", "Reload", {})
end)

function _RequestModel(Model)
    RequestModel(Model)
    while not HasModelLoaded(Model) do
        Citizen.Wait(1)
    end
end