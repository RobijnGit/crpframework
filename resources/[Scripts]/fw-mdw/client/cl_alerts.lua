FW.AddKeybind("openDispatch", "Hulpdiensten", "Focus Meldingen", "", function(IsPressed)
    if not IsPressed then return end
    if not LoggedIn then return end

    TriggerEvent('fw-mdw:Client:OpenDispatch', true)
end)

RegisterNetEvent("fw-mdw:Client:OpenDispatch")
AddEventHandler("fw-mdw:Client:OpenDispatch", function(IsCompact)
    local PlayerJob = FW.Functions.GetPlayerData().job
    if not PlayerJob.onduty then return end
    if PlayerJob.name ~= "police" and PlayerJob.name ~= "doc" and PlayerJob.name ~= "ems" and PlayerJob.name ~= "storesecurity" then return end

    exports['fw-ui']:SetUIFocus(true, true)
    if IsCompact then
        SetCursorLocation(0.973, 0.035)
    else
        exports['fw-hud']:SetHudVisibleState(false)
    end

    OpenDispatch(IsCompact)
end)

RegisterNetEvent("fw-mdw:Client:AddAlert")
AddEventHandler("fw-mdw:Client:AddAlert", function(AlertId, Data, IgnoreSound, HighCrime, HighPrio, ForEMS, ForScanner)
    if not LoggedIn then return end

    local HasRadioscanner = exports['fw-inventory']:HasEnoughOfItem("radioscanner", 1)

    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob == nil then return end
    if not HasRadioscanner and not PlayerJob.onduty then return end

    if PlayerJob.name == 'police' or PlayerJob.name == 'storesecurity' or (ForEMS and (PlayerJob.name == 'ems' or PlayerJob.name == 'doc')) then
        if not IgnoreSound then PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1) end

        if FW.Functions.GetPlayerData().metadata.division ~= "MCU" then
            if HighCrime then
                TriggerEvent("fw-misc:Client:PlaySoundEntity", 'state.alertHighCrime', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, Source)
            elseif HighPrio then
                TriggerEvent("fw-misc:Client:PlaySoundEntity", 'state.alertHighPrio', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, Source)
            end
        end

        if Data.Coords then
            Citizen.CreateThread(function()
                local Blip = AddBlipForCoord(Data.Coords.x, Data.Coords.y, Data.Coords.z)
                SetBlipSprite(Blip, Config.AlertBlip[Data.Title] or 66)
                SetBlipColour(Blip, 1)
                SetBlipScale(Blip, (Config.AlertBlip[Data.Title] == 354 or Config.AlertBlip[Data.Title] == 618 or Config.AlertBlip[Data.Title] == 189) and 1.5 or 1.0)
                SetBlipAsShortRange(Blip, false)
                SetBlipDisplay(Blip, 2)
                BeginTextCommandSetBlipName("STRING")
                if Data.Code then
                    AddTextComponentString(Data.Code .. ' - ' .. Data.Title)
                else
                    AddTextComponentString(Data.Title)
                end
                EndTextCommandSetBlipName(Blip)
        
                local Transition = 255
                while Transition ~= 0 do
                    Citizen.Wait(180 * 6)
                    Transition = Transition - 1
                    SetBlipAlpha(Blip, Transition)
                    if Transition == 0 then
                        SetBlipSprite(Blip, 2) 
                        RemoveBlip(Blip)
                        return
                    end
                end
            end)
        end

        Alerts[#Alerts + 1] = Data
        exports['fw-ui']:SendUIMessage("Dispatch", "AddAlert", Data)
    elseif ForScanner and Data.Coords and HasRadioscanner and math.random(1, 100) > 15 and #(GetEntityCoords(PlayerPedId()) - Data.Coords) <= 80.0 then
        Alerts[#Alerts + 1] = Data

        Citizen.CreateThread(function()
            local Blip = AddBlipForCoord(Data.Coords.x, Data.Coords.y, Data.Coords.z)
            SetBlipSprite(Blip, 459)
            SetBlipColour(Blip, 0)
            SetBlipScale(Blip, 1.5)
            SetBlipAsShortRange(Blip, false)
            SetBlipDisplay(Blip, 2)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Radio Scanner signaal")
            EndTextCommandSetBlipName(Blip)
    
            local Transition = 255
            while Transition ~= 0 do
                Citizen.Wait(180 * 6)
                Transition = Transition - 1
                SetBlipAlpha(Blip, Transition)
                if Transition == 0 then
                    SetBlipSprite(Blip, 2) 
                    RemoveBlip(Blip)
                    return
                end
            end
        end)

        exports['fw-ui']:SendUIMessage("Dispatch", "AddAlert", {
            Id = Data.Id,
            Title = Data.Title,
            Color = Data.Color,
        })
    end
end)

RegisterNetEvent("fw-mdw:Client:SetAlertData")
AddEventHandler("fw-mdw:Client:SetAlertData", function(Type, Data)
    if not LoggedIn then return end

    if Type == 'Remove' then
        if Data.IsCall then
            local AlertId = GetCallById(Data.Id)
            if AlertId and Calls[AlertId] then table.remove(Calls, AlertId) end
        else
            local AlertId = GetAlertById(Data.Id)
            if AlertId and Alerts[AlertId] then table.remove(Alerts, AlertId) end
        end
    elseif Type == 'Set' then
        if Data.IsCall then
            local AlertId = GetCallById(Data.Id)
            if AlertId then
                Calls[AlertId] = Data.Alert
            else
                Calls[#Calls + 1] = Data.Alert
            end
        else
            local AlertId = GetAlertById(Data.Id)
            if AlertId then
                Alerts[Data.Id] = Data.Alert
            else
                Alerts[#Alerts + 1] = Data.Alert
            end
        end
    end
    exports['fw-ui']:SendUIMessage("Dispatch", "SetAlerts", {Calls = Calls, Alerts = Alerts})
end)

function OpenDispatch(IsCompact)
    DispatchOpen = true
    exports['fw-ui']:SendUIMessage("Dispatch", "SetVisibility", {
        Show = true,
        Compact = IsCompact
    })

    if IsCompact then
        SetNuiFocusKeepInput(true)

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

        Citizen.CreateThread(function()
            while DispatchOpen do
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 24, true)
                DisableControlAction(0, 25, true)
                DisableControlAction(0, 257, true)
                DisableControlAction(0, 289, true)
                DisableControlAction(0, 288, true)
                DisableControlAction(0, 346, true)
                Citizen.Wait(4)
            end
            SetNuiFocusKeepInput(false)
        end)
    end
end

function GetAlertById(Id)
    for k, v in pairs(Alerts) do
        if v.Id == Id then
            return k
        end
    end

    return false
end

function GetCallById(Id)
    for k, v in pairs(Calls) do
        if v.Id == Id then
            return k
        end
    end

    return false
end