FW = exports['fw-core']:GetCoreObject()
LoggedIn = false

DispatchOpen, IsHighCommand = false, false
PlayerJob, Alerts, Calls = {}, {}, {}
Units = { Police = {}, EMS = {}, DOC = {} }
MdwOpen, MdwType = false, "pd"

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    PlayerJob = FW.Functions.GetPlayerData().job
    LoggedIn = true

    Alerts = FW.SendCallback("fw-mdw:Client:GetAlerts")
    Calls = FW.SendCallback("fw-mdw:Client:GetCalls")
    Units = FW.SendCallback("fw-mdw:Client:GetUnits")

    exports['fw-ui']:SendUIMessage("Dispatch", "SetAlerts", {Calls = Calls, Alerts = Alerts})
    exports['fw-ui']:SendUIMessage("Dispatch", "SetUnits", Units)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
    TriggerServerEvent("fw-mdw:Server:PlayerDisconnect")
end)

RegisterNetEvent('FW:Client:OnJobUpdate')
AddEventHandler('FW:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = FW.Functions.GetPlayerData().job
end)
RegisterNetEvent("FW:Client:SetDuty")
AddEventHandler("FW:Client:SetDuty", function()
    Citizen.SetTimeout(100, function()
        local PlayerData = FW.Functions.GetPlayerData()
        PlayerJob = PlayerData.job
    end)
end)

-- Code
local InsidePublicRecords = false

Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({
        center = vector3(-552.69, -194.2, 38.22),
        length = 1.4,
        width = 1.0,
    }, {
        name = "mdw_public_records",
        heading = 30,
        minZ = 37.22,
        maxZ = 39.42,
        IsMultiple = false,
        debugPoly = false,
    }, function(IsInside)
        InsidePublicRecords = IsInside
        if not IsInside then
            exports['fw-ui']:HideInteraction()
            return
        end

        exports['fw-ui']:ShowInteraction("[E] Openbare Databank")
        Citizen.CreateThread(function()
            while InsidePublicRecords do
                if IsControlJustReleased(0, 38) then
                    exports['fw-ui']:HideInteraction()
                    TriggerEvent('fw-mdw:Client:OpenMDW', true, 'pd')
                end

                Citizen.Wait(4)
            end
        end)
    end)
end)

-- UI Wrapper Functions
function SetGlobalData(Type)
    local PlayerData = FW.Functions.GetPlayerData()
    PlayerJob = PlayerData.job

    local Data = {}
    local StaffProfile = FW.SendCallback("fw-mdw:Server:Staff:GetMyProfile")

    Data.IsGov = (PlayerJob.name == 'police' or PlayerJob.name == 'ems') and PlayerJob.onduty
    Data.IsEms = PlayerJob.name == 'ems' and PlayerJob.onduty
    Data.IsJudge = PlayerJob.name == 'judge' or PlayerJob.name == 'mayor'
    Data.IsHighcommand = (PlayerJob.grade.name == 'Leidinggevende' or PlayerJob.grade.name == 'Chief of Justice')
    Data.Profile = StaffProfile
    IsHighCommand = Data.IsHighcommand

    MdwType = Type or "PD"

    SendUIMessage("Mdw/SetCharges", FW.SendCallback("fw-mdw:Server:FetchAllCharges", MdwType))
    SendUIMessage("Mdw/SetTags", FW.SendCallback("fw-mdw:Server:FetchAllTags"))
    SendUIMessage("Mdw/SetCerts", FW.SendCallback("fw-mdw:Server:FetchAllCerts"))
    SendUIMessage("Mdw/SetRanks", FW.SendCallback("fw-mdw:Server:FetchAllRanks"))
    SendUIMessage("Mdw/SetEvidence", FW.SendCallback("fw-mdw:Server:FetchAllEvidenceTypes"))
    SendUIMessage("Mdw/SetRoles", FW.SendCallback("fw-mdw:Server:FetchAllRoles"))
    SendUIMessage("Mdw/SetGlobalData", Data)
end

function SendUIMessage(Action, Data)
    SendNUIMessage({
        Action = Action,
        Data = Data
    })
end

RegisterNUICallback("Mdw/Close", function(Data, Cb)
    DispatchOpen, MdwOpen = false, false
    SetNuiFocus(false, false)

    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage("Dispatch", "SetVisibility", {
        Show = false,
    })

    SendUIMessage("Mdw/SetVisiblity", {
        Visible = false,
    })

    exports['fw-assets']:RemoveProp()
    StopAnimTask(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 1.0)
    exports['fw-hud']:SetHudVisibleState(true)

    Cb("Ok")
end)

exports("IsMdwOpen", function()
    return MdwOpen
end)