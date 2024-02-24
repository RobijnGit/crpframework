-- Citizen.CreateThread(function()
--     FW.Blips.CreateGroup('gov', {
--         Sprite = 480, Scale = 1.3,
--         Color = 38, ShortRange = true,
--     }, function()
--         if not LoggedIn then return false end
--         local PlayerJob = FW.Functions.GetPlayerData().job
--         return (PlayerJob.name == 'police' or PlayerJob.name == 'doc' or PlayerJob.name == 'ems') and PlayerData.job.onduty and exports['fw-inventory']:HasEnoughOfItem('pdradio', 1)
--     end)
-- end)

function GetPDBlipColor(Job, Department)
    if Job == 'ems' then
        return 23
    elseif Job == "doc" then
        return 2
    end

    local DepartmentColors = {
        ["LSPD"] = 3,
        ["BCSO"] = 5,
        ["SDSO"] = 31,
        ["RANGER"] = 25,
        ["SASP"] = 63,
        ["DISPATCH"] = 8,
        ["MCU"] = 40,
        ["HSPU"] = 0,
    }

    return DepartmentColors[Department] or 3
end

function GetDepartmentName(Job, Department)
    if Job == 'ems' then
        return 'Medic'
    elseif Job == 'doc' then
        return 'DOC'
    end

    return "Officer"
end

RegisterNetEvent("fw-inventory:Client:Cock")
AddEventHandler("fw-inventory:Client:Cock", function()
    Citizen.SetTimeout(500, function()
        local PlayerData = FW.Functions.GetPlayerData()

        local HasRadio = exports['fw-inventory']:HasEnoughOfItem('pdradio', 1)

        if not HasRadio then
            return exports['fw-sync']:RemoveSubscriberFromGroup("gov")
        end

        if HasRadio and (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity' or PlayerData.job.name == 'doc' or PlayerData.job.name == 'ems') and PlayerData.job.onduty then
            exports['fw-sync']:AddSubscriberToGroup('gov', PlayerData.job.name == 'police' and PlayerData.metadata.division or PlayerData.job.name:upper())
            TriggerServerEvent("fw-sync:Server:Blips:RegisterSourceName", ("%s | %s %s"):format(PlayerData.metadata.callsign, PlayerData.charinfo.firstname, PlayerData.charinfo.lastname))
        end
    end)
end)

RegisterNetEvent("fw-police:Client:UpdateBlipName")
AddEventHandler("fw-police:Client:UpdateBlipName", function()
    Citizen.SetTimeout(100, function()
        local PlayerData = FW.Functions.GetPlayerData()
        TriggerServerEvent("fw-sync:Server:Blips:RegisterSourceName", ("%s | %s %s"):format(PlayerData.metadata.callsign, PlayerData.charinfo.firstname, PlayerData.charinfo.lastname))
    end)
end)

RegisterNetEvent("fw-police:Client:UpdateBlipColor")
AddEventHandler("fw-police:Client:UpdateBlipColor", function()
    exports['fw-sync']:RemoveSubscriberFromGroup("gov")

    Citizen.SetTimeout(100, function()
        local HasRadio = exports['fw-inventory']:HasEnoughOfItem('pdradio', 1)
        local PlayerData = FW.Functions.GetPlayerData()

        if HasRadio and (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity' or PlayerData.job.name == 'doc' or PlayerData.job.name == 'ems') and PlayerData.job.onduty then
            exports['fw-sync']:AddSubscriberToGroup('gov', PlayerData.job.name == 'police' and PlayerData.metadata.division or PlayerData.job.name:upper())
            TriggerServerEvent("fw-sync:Server:Blips:RegisterSourceName", ("%s | %s %s"):format(PlayerData.metadata.callsign, PlayerData.charinfo.firstname, PlayerData.charinfo.lastname))
        end
    end)
end)