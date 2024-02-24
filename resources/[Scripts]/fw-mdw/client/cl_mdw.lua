FW.AddKeybind("openMDW", "Hulpdiensten", "MDW Openen", "", function(IsPressed)
    if not IsPressed then return end
    if not LoggedIn then return end

    if not FW.Functions.GetPlayerData().job.onduty then return end
    if FW.Functions.GetPlayerData().job.name ~= "police" and FW.Functions.GetPlayerData().job.name ~= "ems" then return end

    TriggerEvent('fw-mdw:Client:OpenMDW', false)
end)

RegisterNetEvent("fw-mdw:Client:OpenMDW")
AddEventHandler("fw-mdw:Client:OpenMDW", function(IsPublic, Job)
    local Job = Job or FW.Functions.GetPlayerData().job.name == 'ems' and 'ems' or 'pd'

    MdwOpen = true
    SetGlobalData(Job)

    exports['fw-assets']:AddProp('Tablet')
    exports['fw-assets']:RequestAnimationDict('amb@code_human_in_bus_passenger_idles@female@tablet@base')
    TaskPlayAnim(PlayerPedId(), "amb@code_human_in_bus_passenger_idles@female@tablet@base", "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
    SendUIMessage("Mdw/SetVisiblity", {
        Visible = true,
        IsPublic = IsPublic,
        Job = Job,
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("Mdw/FetchTags", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:FetchAllTags")
    Cb(Result)
end)

RegisterNUICallback("Mdw/FetchStaffRoles", function(Data, Cb)
    local Result = FW.SendCallback("fw-mdw:Server:FetchStaffRoles", Data)
    Cb(Result)
end)