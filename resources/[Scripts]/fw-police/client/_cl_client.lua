FW = exports['fw-core']:GetCoreObject()
LoggedIn, PlayerData, InsideLogout = false, {}, false
local CurrentCops = 0

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(550, function()
        LoggedIn = true

        Config.Barricades = FW.SendCallback("fw-police:Server:GetProps")
        PlayerData = FW.Functions.GetPlayerData()
        Config.Handcuffed = PlayerData.metadata.ishandcuffed
    end)
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for k,v in pairs(Config.LogoutSpots) do
        exports['PolyZone']:CreateBox({
            center = v.center,
            length = v.length,
            width = v.width,
        }, {
            name = v.name,
            heading = v.heading,
            minZ = v.minZ,
            maxZ = v.maxZ,
        }, function(IsInside, Zone, Point)
            local PlayerJob = FW.Functions.GetPlayerData().job
            if PlayerJob.name ~= 'police' then return end
            InsideLogout = IsInside
            if InsideLogout then
                exports['fw-ui']:ShowInteraction("[E] Slapen")
            else
                exports['fw-ui']:HideInteraction()
            end
    
            Citizen.CreateThread(function()
                while InsideLogout do    
                    if IsControlJustReleased(0, 38) then    
                        exports['fw-ui']:HideInteraction()
                        TriggerServerEvent('fw-apartments:Server:Logout')
                    end    
                    Citizen.Wait(1)
                end
            end)
        end)
    end
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    exports['fw-sync']:RemoveSubscriberFromGroup("gov")
    LoggedIn, PlayerData = false, false
end)

RegisterNetEvent('FW:Client:OnJobUpdate')
AddEventHandler('FW:Client:OnJobUpdate', function(PlayerJob)
    PlayerData = FW.Functions.GetPlayerData()

    local HasRadio = exports['fw-inventory']:HasEnoughOfItem('pdradio', 1)
    if HasRadio and (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity' or PlayerData.job.name == 'doc' or PlayerData.job.name == 'ems') and PlayerData.job.onduty then
        exports['fw-sync']:AddSubscriberToGroup('gov', PlayerData.job.name == 'police' and PlayerData.metadata.division or PlayerData.job.name:upper())
        TriggerServerEvent("fw-sync:Server:Blips:RegisterSourceName", ("%s | %s %s"):format(PlayerData.metadata.callsign, PlayerData.charinfo.firstname, PlayerData.charinfo.lastname))
    else
        exports['fw-sync']:RemoveSubscriberFromGroup("gov")
    end
end)

RegisterNetEvent('FW:Client:SetDuty')
AddEventHandler('FW:Client:SetDuty', function()
    Citizen.SetTimeout(200, function()
        PlayerData = FW.Functions.GetPlayerData()

        local HasRadio = exports['fw-inventory']:HasEnoughOfItem('pdradio', 1)
        if HasRadio and (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity' or PlayerData.job.name == 'doc' or PlayerData.job.name == 'ems') and PlayerData.job.onduty then
            exports['fw-sync']:AddSubscriberToGroup('gov', PlayerData.job.name == 'police' and PlayerData.metadata.division or PlayerData.job.name:upper())
            TriggerServerEvent("fw-sync:Server:Blips:RegisterSourceName", ("%s | %s %s"):format(PlayerData.metadata.callsign, PlayerData.charinfo.firstname, PlayerData.charinfo.lastname))
        else
            exports['fw-sync']:RemoveSubscriberFromGroup("gov")
        end
    end)
end)

RegisterNetEvent("fw-police:SetCopCount")
AddEventHandler("fw-police:SetCopCount", function(Amount)
    CurrentCops = Amount
end)

exports("GetCurrentCops", function()
    return CurrentCops
end)

-- Code

function IgnoreWeapon(Weapon)
    for k, v in pairs(Config.IgnoredWeapons) do
        if GetHashKey(v) == Weapon then
            return true
        end
    end

    return false
end
exports("IgnoreWeapon", IgnoreWeapon)

function IsPlayerHandcuffed(PlayerId)
    local Result = FW.SendCallback("fw-police:Server:IsPlayerHandcuffed", PlayerId)
    return Result.Cuffed, Result.Dead
end
exports("IsPlayerHandcuffed", IsPlayerHandcuffed)

function GetFreeSeat(Vehicle)
    local Seats = GetVehicleMaxNumberOfPassengers(Vehicle)
    local Retval = false

    for i = -1, Seats - 1, 1 do
        if IsVehicleSeatFree(Vehicle, i, true) then
            Retval = i
        end
    end

    if Retval == -1 then
        return false
    end

    return Retval
end

function GetFirstPlayerInVehicle(Vehicle)
    local MaxSeats = GetVehicleMaxNumberOfPassengers(Vehicle)
    for i = MaxSeats, -1, -1 do
        local Ped = GetPedInVehicleSeat(Vehicle, i)
        if Ped and IsPedAPlayer(Ped) then
            return GetPlayerServerId(NetworkGetPlayerIndexFromPed(Ped))
        end
    end
    return false
end

function GetVehicleFromNetId(NetId)
    local Tries = 0
    while not NetworkDoesEntityExistWithNetworkId(NetId) do
        Citizen.Wait(100)
        Tries = Tries + 1

        if Tries > 50 then
            return false
        end
    end

    return NetToVeh(NetId)
end

RegisterNetEvent("fw-police:Client:OpenClosedCompartment")
AddEventHandler("fw-police:Client:OpenClosedCompartment", function()
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    FW.Functions.Progressbar("rifle-rack", "Slotje open draaien...", 1000, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', "riflerack_" .. GetVehicleNumberPlateText(Vehicle), 10, 75)
    end, function()
        FW.Functions.Notify("Geannuleerd..", "error")
    end)
end)

RegisterNetEvent("fw-police:Client:SendAlert")
AddEventHandler("fw-police:Client:SendAlert", function(Message)
    TriggerServerEvent('fw-mdw:Server:SendAlert:Call', GetEntityCoords(PlayerPedId()), Message)
end)

RegisterNetEvent("fw-police:Client:CallAnim")
AddEventHandler("fw-police:Client:CallAnim", function()
    local AnimDict, AnimName = "cellphone@", "cellphone_call_listen_base"

    if IsPedArmed(PlayerPedId(), 7) then
        SetCurrentPedWeapon(PlayerPedId(), 0xA2719263, true)
    end

    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do Citizen.Wait(0) end

    local AnimLength = GetAnimDuration(AnimDict, AnimName)
    exports['fw-assets']:AddProp("Phone")

    TaskPlayAnim(PlayerPedId(), AnimDict, AnimName, 2.0, 2.0, AnimLength, 49, 0, 0, 0, 0)
    Citizen.Wait(AnimLength * 1000)
    exports['fw-assets']:RemoveProp()
    StopAnimTask(PlayerPedId(), AnimDict, AnimName, 1.0)
end)

RegisterNetEvent('fw-police:Client:OpenTowMenu')
AddEventHandler('fw-police:Client:OpenTowMenu', function(Groups)
    local ContextItems = {}

    for k, v in pairs(Groups) do
        ContextItems[#ContextItems + 1] = {
            Icon = "fas fa-phone",
            Title = v.Name,
            Desc = "Impound worker bellen (" .. v.State .. ")",
            Data = {
                Event = 'fw-misc:Client:DialPhone', 
                CallerName = 'San Andreas Law Enforcement', CalleeName = 'Impound Worker',
                Phone = v.Phone
            }
        }
    end

    FW.Functions.OpenMenu({ MainMenuItems = ContextItems })
end)