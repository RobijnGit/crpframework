local IsCuffing = false

-- Cuffs
FW.AddKeybind("hardCuff", "Politie", "Hardcuff / Ontboeien", "", function(IsPressed)
    if not IsPressed then return end
    if Config.Handcuffed or Config.Escorted then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.metadata.isdead then return end
    if PlayerData.job.name ~= 'police' then return end

    TriggerEvent("fw-police:Client:Cuff", true)
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(4)
        if LoggedIn then
            if Config.Handcuffed or Config.Escorted then
                DisableAllControlActions(0)

                if Config.Escorted then
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)
                    EnableControlAction(0, 38, true)
                    EnableControlAction(0, 245, true)
                    EnableControlAction(0, 46, true)
                    EnableControlAction(0, 249, true)
                    EnableControlAction(0, 322, true)
                elseif Config.Handcuffed then
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)

                    -- Soft Cuffed
                    if not Config.Hardcuffed then
                        EnableControlAction(0, 21, true)
                        EnableControlAction(0, 30, true)
                        EnableControlAction(0, 31, true)
                        EnableControlAction(0, 32, true)
                        EnableControlAction(0, 33, true)
                        EnableControlAction(0, 34, true)
                        EnableControlAction(0, 35, true)
                    end

                    EnableControlAction(0, 38, true)
                    EnableControlAction(0, 245, true)
                    EnableControlAction(0, 249, true)
                    EnableControlAction(0, 322, true)
                end
            else
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(4)
        if LoggedIn then
            if Config.Handcuffed then
                if not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3 and not IsEntityPlayingAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3)) and not exports['fw-medical']:GetDeathStatus() then
                    if not HasAnimDictLoaded("mp_arresting") then
                        exports['fw-assets']:RequestAnimationDict('mp_arresting')
                    end
                    TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, -8, -1, 49, 0, 0, 0, 0)
                else
                    Citizen.Wait(250)
                end
            end
        else
            Citizen.Wait(450)
        end
    end
end)

function DoCuffingAnimation(Cuffer)
    Citizen.CreateThread(function()
        TriggerEvent("fw-misc:Client:PlaySoundEntity", 'items.cuff', NetworkGetNetworkIdFromEntity(PlayerPedId()), true, GetPlayerServerId(PlayerId()))
        local TPed = GetPlayerPed(GetPlayerFromServerId(Cuffer))
        SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(TPed, 0.0, 0.45, 0.0))
        Citizen.Wait(100)
        SetEntityHeading(PlayerPedId(), GetEntityHeading(TPed))
        TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 3.0, 3.0, -1, 32, 0, 0, 0, 0)
        Citizen.Wait(2500)
        ClearPedTasks(PlayerPedId())
    end)
end

RegisterNetEvent("fw-police:Client:Cuff")
AddEventHandler("fw-police:Client:Cuff", function(IsHardcuff)
    if IsCuffing then return end

    if Config.Handcuffed or not exports['fw-inventory']:HasEnoughOfItem('handcuffs', 1) then
        return
    end

    if IsPedInAnyVehicle(PlayerPedId()) then
        return
    end

    if IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId()) then
        return
    end

    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    -- Don't allow running players to be softcuffed.
    if not IsHardcuff and IsPedRunning(Target) then
        return
    end

    local Target = GetPlayerPed(GetPlayerFromServerId(Player))
    local Angle = math.abs(GetEntityHeading(PlayerPedId()) - GetEntityHeading(Target))
    if Angle > 120 and Angle < 240 then
        return
    end

    if IsPedInAnyVehicle(Target) then
        return
    end

    local IsCuffed, IsDead = IsPlayerHandcuffed(Player)
    local Bool = not IsCuffed
    IsCuffing = true

    Citizen.SetTimeout(Bool and 0 or 3000, function()
        FW.TriggerServer("fw-police:Server:CuffPlayer", Player, Bool, IsHardcuff)
        if Bool then
            FW.Functions.Notify(IsHardcuff and "Je hebt iemand gehardcuffed." or "Je hebt iemand geboeid.", IsHardcuff and "error" or "primary")
        end
    end)
    
    exports['fw-assets']:RequestAnimationDict('mp_arresting')
    exports['fw-assets']:RequestAnimationDict('mp_arrest_paired')

    if Bool then
        TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
        Citizen.Wait(3500)
        TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "exit", 3.0, 3.0, -1, 48, 0, 0, 0, 0)
        IsCuffing = false
    else
        TaskPlayAnim(PlayerPedId(), "mp_arresting", "a_uncuff", 1.0, 1.0, 3000, 16, -1, 0,0, 0)
        Citizen.Wait(3000)
        StopAnimTask(PlayerPedId(), "mp_arresting", "a_uncuff", 1.0)
        IsCuffing = false
    end
end)

RegisterNetEvent("fw-police:Client:DoCuff")
AddEventHandler("fw-police:Client:DoCuff", function(Cuffer, State, IsHardcuff)
    if not State then -- uncuff
        Config.Handcuffed = false
        TriggerEvent('fw-police:Server:ForceUnescort')
        TriggerServerEvent("FW:Server:SetMetaData", 'ishandcuffed', false)
        ClearPedTasksImmediately(PlayerPedId())
        return
    end

    TriggerEvent("fw-inventory:Client:ResetWeapon")

    exports['fw-assets']:RequestAnimationDict('mp_arrest_paired')

    DoCuffingAnimation(Cuffer)

    if not IsHardcuff and math.random() > 0.2 then
        SetTimeout(2600, function()
            Config.Handcuffed, Config.Hardcuffed = true, IsHardcuff
            TriggerServerEvent("FW:Server:SetMetaData", 'ishandcuffed', true)
            FW.Functions.Notify("Je bent geboeid.")
        end)
        return
    end

    local TimeTable = IsHardcuff and { 1000, 1100 } or { 1500, 1600 }
    local Outcome = exports['fw-ui']:StartSkillTest(1, { 5, 10 }, TimeTable, true)
    if not Outcome then
        FW.Functions.Notify("Je bent gefaald, je zit in de boeien.", "error")
        SetTimeout(2600 - TimeTable[2], function()
            Config.Handcuffed, Config.Hardcuffed = true, IsHardcuff
            TriggerServerEvent("FW:Server:SetMetaData", 'ishandcuffed', true)
        end)
        return
    end
end)

-- Escort
RegisterNetEvent("fw-police:Client:Escort")
AddEventHandler("fw-police:Client:Escort", function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return false
    end

    local IsCuffed, IsDead = IsPlayerHandcuffed(Player)
    if not IsCuffed and not IsDead then
        return FW.Functions.Notify("Persoon is niet geboeid of bewusteloos.", "error")
    end

    if IsPedInAnyVehicle(GetPlayerPed(GetPlayerFromServerId(Player))) then
        return TriggerEvent('fw-police:Client:UnseatVehicle', {}, GetVehiclePedIsIn(GetPlayerPed(GetPlayerFromServerId(Player))))
    end

    FW.TriggerServer("fw-police:Server:EscortPlayer", Player)
end)

RegisterNetEvent("fw-police:Server:DoEscort")
AddEventHandler("fw-police:Server:DoEscort", function(Escorter)
    if Config.Escorted then
        DetachEntity(PlayerPedId(), true, false)
        Config.Escorted = false
        return
    end

    Config.Escorted = true
    local TPed = GetPlayerPed(GetPlayerFromServerId(Escorter))
    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(TPed, 0.0, 0.45, 0.0))
    AttachEntityToEntity(PlayerPedId(), TPed, 11816, 0.45, 0.45, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
end)

RegisterNetEvent("fw-police:Server:ForceUnescort")
AddEventHandler("fw-police:Server:ForceUnescort", function()
    if not Config.Escorted then return end
    DetachEntity(PlayerPedId(), true, false)
    Config.Escorted = false
end)

-- Seat & Unseat
RegisterNetEvent("fw-police:Client:SeatVehicle")
AddEventHandler("fw-police:Client:SeatVehicle", function(Data, Entity)
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    local IsCuffed, IsDead = IsPlayerHandcuffed(Player)
    if not IsCuffed and not IsDead then
        return FW.Functions.Notify("Persoon is niet geboeid of bewusteloos.", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(7000, "Persoon in voertuig zetten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, true)
    if not Finished then return end

    local SeatId = GetFreeSeat(Entity)
    if not SeatId then
        return FW.Functions.Notify("Geen plek meer..", "error")
    end

    FW.TriggerServer("fw-police:Server:SeatVehicle", Player, NetworkGetNetworkIdFromEntity(Entity), true, SeatId)
end)

RegisterNetEvent("fw-police:Client:UnseatVehicle")
AddEventHandler("fw-police:Client:UnseatVehicle", function(Data, Entity)
    local Finished = FW.Functions.CompactProgressbar(7000, "Persoon uit voertuig halen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, true)
    if not Finished then return end

    local Player = GetFirstPlayerInVehicle(Entity)
    if not Player then
        return FW.Functions.Notify("Niemand in de auto..", "error")
    end

    local IsCuffed, IsDead = IsPlayerHandcuffed(Player)
    if not IsCuffed and not IsDead then
        return FW.Functions.Notify("Persoon is niet geboeid of bewusteloos.", "error")
    end

    FW.TriggerServer("fw-police:Server:SeatVehicle", Player, NetworkGetNetworkIdFromEntity(Entity), false, SeatId)
    FW.TriggerServer("fw-police:Server:EscortPlayer", Player)
end)

RegisterNetEvent("fw-police:Client:SetInVehicle")
AddEventHandler("fw-police:Client:SetInVehicle", function(NetId, WarpInto, SeatId)
    TriggerEvent('fw-police:Server:ForceUnescort')

    local Vehicle = GetVehicleFromNetId(NetId)
    if not Vehicle then return end

    if not WarpInto then
        TaskLeaveVehicle(PlayerPedId(), Vehicle, 16)
        return
    end

    TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, SeatId)
end)

-- Robbing & Searching
RegisterNetEvent('fw-police:Client:RobPlayer')
AddEventHandler('fw-police:Client:RobPlayer', function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    local IsCuffed, IsDead = IsPlayerHandcuffed(Player)
    if not IsEntityPlayingAnim(PlayerPed, "missminuteman_1ig_2", "handsup_base", 3) and not IsEntityPlayingAnim(PlayerPed, "mp_arresting", "idle", 3) and not IsCuffed and not IsDead then
        return
    end

    local Finished = FW.Functions.CompactProgressbar(15000, "Spullen stelen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {animDict = "random@shop_robbery", anim = "robbery_action_b", flags = 16}, {}, {}, false)
    StopAnimTask(PlayerPedId(), "random@shop_robbery", "robbery_action_b", 1.0)
    if not Finished then return end
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Other Player', 'ply-' .. FW.GetCitizenIdFromPlayer(Player))
end)

RegisterNetEvent('fw-police:Client:SearchPlayer')
AddEventHandler('fw-police:Client:SearchPlayer', function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end
    
    TriggerServerEvent("fw-police:Server:SearchPlayer", Player)
    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Other Player', 'ply-' .. FW.GetCitizenIdFromPlayer(Player))
end)

RegisterNetEvent("fw-police:OpenServicedeskStash")
AddEventHandler("fw-police:OpenServicedeskStash", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'mrpd-servicedesk-' ..PlayerData.citizenid, 10, 70)
    end
end)

-- PD Actions
RegisterNetEvent("fw-police:Client:OpenPersonalStash")
AddEventHandler("fw-police:Client:OpenPersonalStash", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        return
    end

    local Department = 'MRPD'
    local PlyCoords = GetEntityCoords(PlayerPedId())

    if #(PlyCoords - vector3(836.68, -1287.12, 28.25)) < 3.0 then
        Department = 'LAMESA'
    elseif #(PlyCoords - vector3(381.28, -1609.28, 30.2)) < 2.0 then
        Department = 'DAVISPD'
    elseif #(PlyCoords - vector3(-1080.25, -822.69, 19.3)) < 3.0 then
        Department = 'VBPD'
    elseif #(PlyCoords - vector3(1831.04, 3680.14, 38.86)) < 3.0 then
        Department = 'SANDYPD'
    elseif #(PlyCoords - vector3(1831.04, 3680.14, 38.86)) < 2.5 then
        Department = 'PALETOPD'
    end

    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', Department .. '-Personal-Stash-' ..PlayerData.citizenid, 50, 300)
    end
end)

RegisterNetEvent("fw-police:Client:OpenEvidence")
AddEventHandler("fw-police:Client:OpenEvidence", function()
    Citizen.Wait(250)

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        return
    end

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Kluis Id', Icon = 'fas fa-hashtag', Name = 'EvidenceId', Type = 'number' },
    })

    if Result and Result.EvidenceId then
        if exports['fw-inventory']:CanOpenInventory() then
            FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'PD-Evidence-' .. Result.EvidenceId, 400, 12000)
        end
    end
end)

RegisterNetEvent("fw-police:Client:OpenTrash")
AddEventHandler("fw-police:Client:OpenTrash", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        return
    end

    local Department = 'MRPD'
    local PlyCoords = GetEntityCoords(PlayerPedId())

    if #(PlyCoords - vector3(836.68, -1287.12, 28.25)) < 3.0 then
        Department = 'LAMESA'
    elseif #(PlyCoords - vector3(381.28, -1609.28, 30.2)) < 2.0 then
        Department = 'DAVIS'
    elseif #(PlyCoords - vector3(-1080.25, -822.69, 19.3)) < 3.0 then
        Department = 'VBPD'
    elseif #(PlyCoords - vector3(1831.04, 3680.14, 38.86)) < 3.0 then
        Department = 'SDSO'
    elseif #(PlyCoords - vector3(1831.04, 3680.14, 38.86)) < 2.5 then
        Department = 'PBSO'
    end

    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'temp-' .. Department .. '-trash', 50, 300)
    end
end)

RegisterNetEvent("fw-police:Client:OpenLab")
AddEventHandler("fw-police:Client:OpenLab", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        return
    end

    local Items = FW.SendCallback("fw-police:Server:GetCasingEvidence")
    if #Items == 0 then
        return FW.Functions.Notify("Je hebt geen bewijs op zak..", "error")
    end

    local MenuItems = {}

    for k, v in pairs(Items) do
        MenuItems[#MenuItems + 1] = {
            Disabled = v.IsDehashed,
            Title = "<div style='display: flex; justify-content: space-between; width: 26.3vh;'><span>" .. v.Type .. "</span><span><i class='fas fa-" .. (v.IsDehashed and "times-circle" or "check-circle") .. "'></i></span></div>",
            Desc = "<div style='display: flex; justify-content: space-between;'><span>Slot " .. v.Slot .. "</span></div>",
            Data = {
                Event = "fw-police:Client:TryDehash",
                Type = "Client",
                Slot = v.Slot,
            }
        }
    end

    Citizen.SetTimeout(50, function()
        FW.Functions.OpenMenu({MainMenuItems = MenuItems})
    end)
end)

RegisterNetEvent("fw-police:Client:TryDehash")
AddEventHandler("fw-police:Client:TryDehash", function(Data)
    local Outcome = exports['fw-ui']:StartSkillTest(4, { 8, 12 }, { 1500, 3000 }, true)
    FW.TriggerServer("fw-police:Server:DehashSerial", Data, Outcome)
end)

RegisterNetEvent("fw-police:Client:OpenArmory")
AddEventHandler("fw-police:Client:OpenArmory", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'storesecurity' then
        return
    end

    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'PoliceArmory')
    end
end)

RegisterNetEvent("fw-police:Client:OpenHCStore")
AddEventHandler("fw-police:Client:OpenHCStore", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' or not PlayerData.metadata.ishighcommand then
        return
    end

    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Store', 'PoliceHighcommandArmory')
    end
end)

-- F1 Actions
RegisterNetEvent("fw-police:Client:CheckBank")
AddEventHandler("fw-police:Client:CheckBank", function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    if IsPedInAnyVehicle(PlayerPedId()) or IsPedInAnyVehicle(GetPlayerPed(Player)) then
        FW.Functions.Notify("Dit kan je niet in een voertuig doen..", "error")
    end

    TriggerServerEvent("fw-police:Server:CheckBank", Player)
end)

RegisterNetEvent("fw-police:Client:SeizePossesionsClosest")
AddEventHandler("fw-police:Client:SeizePossesionsClosest", function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    if IsPedInAnyVehicle(PlayerPedId()) or IsPedInAnyVehicle(GetPlayerPed(Player)) then
        FW.Functions.Notify("Dit kan je niet in een voertuig doen..", "error")
    end

    TriggerServerEvent("fw-police:Server:SeizePossesions", Player)
end)

RegisterNetEvent("fw-police:Client:CheckFingerprint")
AddEventHandler("fw-police:Client:CheckFingerprint", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'storesecurity' then
        return
    end

    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    if IsPedInAnyVehicle(PlayerPedId()) or IsPedInAnyVehicle(GetPlayerPed(Player)) then
        FW.Functions.Notify("Dit kan je niet in een voertuig doen..", "error")
    end

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, 1)
    local Finished = FW.Functions.CompactProgressbar(5000, "Vingerafdruk scannen...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())

    if not Finished then return end

    local Fingerprint = FW.SendCallback("fw-police:Server:GetFingerprintResult", Player)
    TriggerEvent('chatMessage', "Vingerafdruk resultaat", "error", Fingerprint)
end)

RegisterNetEvent("fw-police:Client:RemoveFacewear")
AddEventHandler("fw-police:Client:RemoveFacewear", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' then
        return
    end

    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player == -1 or Distance > 2.5 then
        return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
    end

    if IsPedInAnyVehicle(PlayerPedId()) or IsPedInAnyVehicle(GetPlayerPed(Player)) then
        FW.Functions.Notify("Dit kan je niet in een voertuig doen..", "error")
    end

    FW.TriggerServer("fw-police:Server:RemoveFaceWear", Player)
end)

-- Employee Management
RegisterNetEvent("fw-police:Client:OpenEmployeelist")
AddEventHandler("fw-police:Client:OpenEmployeelist", function(Data)
    if Data.Job ~= 'police' and Data.Job ~= 'news' and Data.Job ~= 'doc' and Data.Job ~= 'ems' then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= Data.Job or not PlayerData.metadata.ishighcommand then
        return
    end

    local Players = FW.SendCallback("fw-police:Server:GetEmployees", Data)

    local MenuItems = {
        {
            Icon = 'users',
            Title = 'Medewerkers (' .. #Players .. ')',
            Desc = 'Bekijk alle medewerkers.',
            Data = { Event = "fw-police:Client:ShowEmployeesList", Type = "Client", Job = Data.Job },
        },
        {
            Icon = 'user-plus',
            Title = 'Persoon Aannemen',
            Desc = 'Neem iemand aan yeet',
            Data = { Event = "fw-police:Client:HireEmployee", Type = "Client", Job = Data.Job },
        },
        {
            Icon = 'fire',
            Title = 'Persoon Ontslaan met BSN',
            Desc = 'Ontsla iemand d.m.v BSN',
            Data = { Event = "fw-police:Client:FireEmployee", Type = "Client", Job = Data.Job },
        },
    }

    Citizen.SetTimeout(50, function()
        FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
    end)
end)

RegisterNetEvent("fw-police:Client:FireEmployee")
AddEventHandler("fw-police:Client:FireEmployee", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= Data.Job or not PlayerData.metadata.ishighcommand then
        return
    end

    Citizen.Wait(50)

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'BSN', Icon = 'fas fa-id-card', Name = 'Cid' },
    })

    if Result and Result.Cid then
        FW.TriggerServer("fw-police:Server:FireEmployee", { Job = Data.Job, Cid = Result.Cid })
    end
end)

RegisterNetEvent("fw-police:Client:HireEmployee")
AddEventHandler("fw-police:Client:HireEmployee", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= Data.Job or not PlayerData.metadata.ishighcommand then
        return
    end

    Citizen.Wait(50)

    local RangChoices = {}
    for k, v in pairs(FW.Shared.Jobs[Data.Job].grades) do
        RangChoices[#RangChoices + 1] = {
            Icon = false,
            Text = v.name,
            Value = k
        }
    end

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'BSN', Icon = 'fas fa-id-card-alt', Name = 'Cid' },
        { Label = 'Rang', Icon = 'fas fa-tag', Name = 'Grade', Choices = RangChoices },
    })

    if Result and Result.Cid and Result.Grade then
        FW.TriggerServer("fw-police:Server:HireEmployee", Data.Job, Result)
    end
end)

RegisterNetEvent("fw-police:Client:ShowEmployeesList")
AddEventHandler("fw-police:Client:ShowEmployeesList", function(Data)
    local Players = FW.SendCallback("fw-police:Server:GetEmployees", Data)

    local MenuItems = {
        {
            Title = "Terug",
            Data = { Event = "fw-police:Client:OpenEmployeelist", Type = "Client", Job = Data.Job },
        },
    }

    for k, v in pairs(Players) do
        MenuItems[#MenuItems + 1] = {
            Icon = 'user',
            Title = v.Name .. ' (' .. v.Callsign .. ')',
            Desc = 'Medewerker Informatie',
            SecondMenu = {
                {
                    Icon = 'user',
                    Title = 'Medewerker',
                    Desc = v.Name,
                },
                {
                    Icon = 'info-circle',
                    Title = 'Informatie',
                    Desc = 'Callsign: ' .. v.Callsign .. '; Highcommand: ' .. (v.Highcommand and 'Ja' or 'Nee') .. '<br/>Baan: ' .. v.Job .. '; Rang: ' .. v.Rank,
                },
                {
                    Icon = 'dollar-sign',
                    Title = 'Salaris',
                    Desc = 'Huidige Salaris: ' .. exports['fw-businesses']:NumberWithCommas(v.Salary),
                },
                {
                    Icon = 'clock',
                    Title = 'Laatste keer gezien',
                    Desc = v.LastSeen,
                },
                {
                    Icon = 'university',
                    Title = 'Bankrekening Toegang',
                    Desc = Data.Job ~= "ems" and Data.Job ~= "police" and Data.Job ~= "news" and 'Je hebt geen rekening om te beheren.' or 'Beheer rekening permissies van.',
                    Data = { Event = "fw-police:Client:ManageBankaccount", Type = "Client", Job = Data.Job, Cid = v.Cid },
                    Disabled = Data.Job ~= "ems" and Data.Job ~= "police" and Data.Job ~= "news",
                    CloseMenu = true,
                },
                {
                    Icon = 'fire',
                    Title = 'Medewerker Ontslaan',
                    Data = { Event = "fw-police:Server:FireEmployee", Type = "Server", Job = Data.Job, Cid = v.Cid },
                },
            }
        }
    end

    Citizen.SetTimeout(50, function()
        FW.Functions.OpenMenu({MainMenuItems = MenuItems, Width = '20vw'})
    end)
end)

RegisterNetEvent("fw-police:Client:ManageBankaccount")
AddEventHandler("fw-police:Client:ManageBankaccount", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= Data.Job or not PlayerData.metadata.ishighcommand then
        return
    end

    Citizen.Wait(50)

    local TrueOrFalse = {
        { Text = 'Nee', Value = false },
        { Text = 'Ja', Value = true },
    }

    local AccountId = FW.SendCallback("fw-police:Server:GetAccountId", Data)
    local FinancialPermissions = FW.SendCallback('fw-financials:Server:GetFinancialAccess', AccountId, Data.Cid)

    local function GetPermissionValue(Permission)
        return FinancialPermissions[Permission] and 'Ja' or 'Nee'
    end

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Balans', Icon = 'fas fa-dollar-sign', Name = 'Balance', Value = GetPermissionValue('Balance'), Choices = TrueOrFalse },
        { Label = 'Storten', Icon = 'fas fa-inbox-in', Name = 'Deposit', Value = GetPermissionValue('Deposit'), Choices = TrueOrFalse },
        { Label = 'Opnemen', Icon = 'fas fa-inbox-out', Name = 'Withdraw', Value = GetPermissionValue('Withdraw'), Choices = TrueOrFalse },
        { Label = 'Overmaken', Icon = 'fas fa-exchange', Name = 'Transfer', Value = GetPermissionValue('Transfer'), Choices = TrueOrFalse },
        { Label = 'Transacties', Icon = 'fas fa-list', Name = 'Transactions', Value = GetPermissionValue('Transactions'), Choices = TrueOrFalse },
    })

    if Result then
        for k, v in pairs(Result) do
            if type(v) ~= "boolean" then
                Result[k] = v == "Ja"
            end
        end

        local SetFinancials = FW.SendCallback('fw-financials:Server:SetFinancialAccess', {AccountId = AccountId, Employee = Data.Cid, Permissions = Result})
        if SetFinancials.Success then
            FW.Functions.Notify("Opgeslagen!")
        end
    end
end)

RegisterNetEvent("fw-police:Client:GrabTimeTrialUSB")
AddEventHandler("fw-police:Client:GrabTimeTrialUSB", function()
    FW.TriggerServer("fw-police:Server:GrabTimeTrialsUsb")
end)

RegisterNetEvent("fw-police:Client:OpenHCStash")
AddEventHandler("fw-police:Client:OpenHCStash", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if (PlayerData.job.name ~= "police" and PlayerData.job.name ~= "doc" and PlayerData.job.name ~= "ems") or not PlayerData.metadata.ishighcommand then
        return
    end

    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', Data.Department .. '-hc-cabin', 50, 2500)
    end
end)