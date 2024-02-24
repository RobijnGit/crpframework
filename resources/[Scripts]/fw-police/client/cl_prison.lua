-- InJail, PrisonJob, TaskBlip = false, { Task = false, Info = '', Data = {} }, nil

-- Citizen.CreateThread(function()
--     while true do
--         if LoggedIn and InJail then
--             if #(GetEntityCoords(PlayerPedId()) - Config.Prison) > 195.0 then
--                 DoScreenFadeOut(1)
--                 Citizen.SetTimeout(250, function()
--                     local RandomSpawn = Config.PrisonSpawns[math.random(1, #Config.PrisonSpawns)]
--                     SetEntityCoords(PlayerPedId(), RandomSpawn.x, RandomSpawn.y, RandomSpawn.z)
--                     SetEntityHeading(PlayerPedId(), RandomSpawn.w)
--                     Citizen.Wait(400)
--                     DoScreenFadeIn(500)
--                     FW.Functions.Notify("Ik denk niet dat je al mag vertrekken..", "error")
--                 end)
--             end
--         else
--             Citizen.Wait(500)
--         end

--         Citizen.Wait(1000)
--     end
-- end)

-- RegisterNetEvent("fw-police:Client:ChangeTask")
-- AddEventHandler("fw-police:Client:ChangeTask", function()
--     local MenuItems = {}

--     for k, v in pairs(Config.PrisonTasks) do
--         MenuItems[#MenuItems + 1] = {
--             Icon = 'list-alt',
--             Title = v.Task,
--             Desc = v.Info,
--             Data = {
--                 Event = 'fw-police:Client:SetCurrentTask',
--                 Type = 'Client',
--                 Task = k,
--             }
--         }
--     end

--     FW.Functions.OpenMenu({ MainMenuItems = MenuItems, Width = '35vh' })
-- end)

-- RegisterNetEvent("fw-police:Client:SetCurrentTask")
-- AddEventHandler("fw-police:Client:SetCurrentTask", function(Data)
--     PrisonJob = { Task = Config.PrisonTasks[Data.Task].Task, Info = Config.PrisonTasks[Data.Task].Info, Data = {} }
    
--     if DoesBlipExist(TaskBlip) then RemoveBlip(TaskBlip) end
--     if PrisonJob.Task == 'Niksen' then
--         CreateTaskBlip(205, 16, 'Chillplek', vector3(1756.03, 2546.06, 45.55))
--         Citizen.CreateThread(function()
--             while PrisonJob.Task == 'Niksen' do
--                 if #(GetEntityCoords(PlayerPedId()) - vector3(1756.03, 2546.06, 45.55)) < 10.0 then
--                     ReduceJailTime(1)
--                 end
--                 Citizen.Wait((1000 * 60) * 5)
--             end
--         end)
--     end
-- end)

-- RegisterNetEvent("fw-police:Client:DoPrisonTask")
-- AddEventHandler("fw-police:Client:DoPrisonTask", function(Data)
--     local MyPos = GetEntityCoords(PlayerPedId())

--     if Data.Task == 'Scrapyard' then
--         if Data.Job == 'StackBricks' then
--             TaskStartScenarioInPlace(PlayerPedId(), "CODE_HUMAN_MEDIC_TIME_OF_DEATH", 0, true)
--             FW.Functions.Progressbar("prison_task", "Stenen inspecteren..", 10000, false, true, {
--                 disableMovement = false,
--                 disableCarMovement = false,
--                 disableMouse = false,
--                 disableCombat = true,
--             }, {}, {}, {}, function() -- Done
--                 ClearPedTasks(PlayerPedId())
--                 ReduceJailTime(1)
--             end, function()
--                 ClearPedTasks(PlayerPedId())
--                 FW.Functions.Notify("Geannuleerd..", "error")
--             end)
--         elseif Data.Job == 'SortScrap' then
--             if PrisonJob.Data.HasScraps then
--                 return FW.Functions.Notify("Je hebt al een doos met troep..", "error")
--             end

--             TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_CONST_DRILL", 0, true)
--             FW.Functions.Progressbar("prison_task", "Troep soorteren..", 20000, false, true, {
--                 disableMovement = false,
--                 disableCarMovement = false,
--                 disableMouse = false,
--                 disableCombat = true,
--             }, {}, {}, {}, function() -- Done
--                 ClearPedTasks(PlayerPedId())
--                 FW.Functions.Notify("Je hebt een doos gevuld met troep, breng deze naar het afleverpunt.")
--                 CreateTaskBlip(50, 16, 'Afleverpunt', vector3(1720.44, 2566.67, 45.55))
--                 TriggerEvent('fw-emotes:Client:PlayEmote', "box", nil, true)
--                 PrisonJob.Data.HasScraps = true

--                 if math.random() < 0.008 then
--                     TriggerServerEvent("fw-police:Server:ReceiveJailItem", "burnerphone")
--                     FW.Functions.Notify("Je vondt een gek telefoontje..", "error")
--                 end
--             end, function()
--                 ClearPedTasks(PlayerPedId())
--                 FW.Functions.Notify("Geannuleerd..", "error")
--             end)
--         elseif Data.Job == 'DeliverScrap' then
--             if not PrisonJob.Data.HasScraps then
--                 return FW.Functions.Notify("Je hebt wel echt veel troep man..", "error")
--             end

--             TriggerEvent("fw-emotes:Client:CancelEmote", true)
--             TriggerEvent('fw-emotes:Client:PlayEmote', "clipboard", nil, true)
--             FW.Functions.Progressbar("prison_task", "Doos inleveren..", 5000, false, true, {
--                 disableMovement = true,
--                 disableCarMovement = true,
--                 disableMouse = false,
--                 disableCombat = true,
--             }, {}, {}, {}, function() -- Done
--                 TriggerEvent("fw-emotes:Client:CancelEmote", true)
--                 PrisonJob.Data.HasScraps = false
--                 ReduceJailTime(2)
--                 if DoesBlipExist(TaskBlip) then RemoveBlip(TaskBlip) end
--             end, function()
--                 ClearPedTasks(PlayerPedId())
--                 FW.Functions.Notify("Geannuleerd..", "error")
--             end)
--         end
--     elseif Data.Task == 'Keuken' then
--         if Data.Job == 'SortKitchen' then
--             FW.Functions.Progressbar("prison_task", "Sorteren..", 20000, false, true, {
--                 disableMovement = true,
--                 disableCarMovement = true,
--                 disableMouse = false,
--                 disableCombat = true,
--             }, {
--                 animDict = "missexile3",
--                 anim = "ex03_dingy_search_case_a_michael",
--                 flags = 8,
--             }, {}, {}, function() -- Done
--                 StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0)
--                 ReduceJailTime(2)
--             end, function()
--                 StopAnimTask(PlayerPedId(), "missexile3", "ex03_dingy_search_case_a_michael", 1.0)
--                 FW.Functions.Notify("Geannuleerd..", "error")
--             end)
--         elseif Data.Job == 'CleanTable' then
--             FW.Functions.Progressbar("prison_task", "Tafel schoonmaken", 10000, false, true, {
--                 disableMovement = true,
--                 disableCarMovement = true,
--                 disableMouse = false,
--                 disableCombat = true,
--             }, {
--                 animDict = "timetable@maid@cleaning_surface@base",
--                 anim = "base",
--                 flag = 8
--             }, {}, {}, function() -- Done
--                 StopAnimTask(PlayerPedId(), "timetable@maid@cleaning_surface@base", "base", 1.0)
--                 ReduceJailTime(1)
--             end, function()
--                 StopAnimTask(PlayerPedId(), "timetable@maid@cleaning_surface@base", "base", 1.0)
--                 FW.Functions.Notify("Geannuleerd..", "error")
--             end)
--         end
--     end
-- end)

-- RegisterNetEvent("fw-police:Client:ShowCurrentTask")
-- AddEventHandler("fw-police:Client:ShowCurrentTask", function()
--     if not PrisonJob or PrisonJob.Task == false then
--         return FW.Functions.Notify("Je bent niet bezig met een taak.", "error")
--     end

--     exports['fw-ui']:HideInteraction()
--     Citizen.SetTimeout(500, function()
--         exports['fw-ui']:ShowInteraction('Taak: ' .. PrisonJob.Task .. ' - ' .. PrisonJob.Info)
--         Citizen.Wait(5000)
--         exports['fw-ui']:HideInteraction()
--     end)
-- end)

-- RegisterNetEvent("fw-police:Client:TapJailSlushy")
-- AddEventHandler("fw-police:Client:TapJailSlushy", function()
--     exports['fw-inventory']:SetBusyState(true)
--     FW.Functions.Progressbar("slushy", "Lekker slushy tappen", 5000, false, true, {
--         disableMovement = false,
--         disableCarMovement = false,
--         disableMouse = false,
--         disableCombat = true,
--     }, {
--         animDict = "amb@world_human_hang_out_street@female_hold_arm@idle_a",
--         anim = "idle_a",
--         flags = 8
--     }, {}, {}, function() -- Done
--         exports['fw-inventory']:SetBusyState(false)
--         TriggerServerEvent("fw-police:Server:ReceiveJailItem", 'slushy')
--         StopAnimTask(PlayerPedId(), "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
--     end, function()
--         StopAnimTask(PlayerPedId(), "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
--         exports['fw-inventory']:SetBusyState(false)
--         FW.Functions.Notify("Geannuleerd..", "error")
--     end)
-- end)

-- RegisterNetEvent("fw-police:Client:GetJailFood")
-- AddEventHandler("fw-police:Client:GetJailFood", function()
--     exports['fw-inventory']:SetBusyState(true)
--     FW.Functions.Progressbar("slushy", "Wat verrote eten op elkaar stampen..", 5000, false, true, {
--         disableMovement = false,
--         disableCarMovement = false,
--         disableMouse = false,
--         disableCombat = true,
--     }, {
--         animDict = "amb@world_human_hang_out_street@female_hold_arm@idle_a",
--         anim = "idle_a",
--         flags = 8
--     }, {}, {}, function() -- Done
--         exports['fw-inventory']:SetBusyState(false)
--         TriggerServerEvent("fw-police:Server:ReceiveJailItem", 'jail-food')
--         StopAnimTask(PlayerPedId(), "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
--     end, function()
--         StopAnimTask(PlayerPedId(), "amb@world_human_hang_out_street@female_hold_arm@idle_a", "idle_a", 1.0)
--         exports['fw-inventory']:SetBusyState(false)
--         FW.Functions.Notify("Geannuleerd..", "error")
--     end)
-- end)

-- RegisterNetEvent("fw-prison:Client:SetJail")
-- AddEventHandler("fw-prison:Client:SetJail", function(Forced)
--     if Forced then
--         TriggerEvent('fw-misc:Client:PlaySound', 'state.jailCell')
--     end

--     InJail = true
--     local RandomSpawn = Config.PrisonSpawns[math.random(1, #Config.PrisonSpawns)]
--     SetEntityCoords(PlayerPedId(), RandomSpawn.x, RandomSpawn.y, RandomSpawn.z)
--     SetEntityHeading(PlayerPedId(), RandomSpawn.w)
--     Citizen.Wait(2000)
--     DoScreenFadeIn(1000)
-- end)

-- RegisterNetEvent("fw-police:Client:CheckPrisonTime")
-- AddEventHandler("fw-police:Client:CheckPrisonTime", function()
--     TriggerEvent('chatMessage', "OMT", "warning", "Je moet nog " .. FW.Functions.GetPlayerData().metadata.jailtime .. ' maand(en) zitten.')
-- end)

-- RegisterNetEvent("fw-police:Client:ReleaseJail")
-- AddEventHandler("fw-police:Client:ReleaseJail", function()
--     if FW.Functions.GetPlayerData().metadata.jailtime > 1 then return FW.Functions.Notify("Je moet nog een paar maandjes zitten hoor. Loser.") end
--     ResetJail()
--     TriggerEvent('fw-misc:Client:PlaySound', 'state.jailCell')

--     DoScreenFadeOut(1000)
--     while not IsScreenFadedOut() do Citizen.Wait(100) end

--     SetEntityCoords(PlayerPedId(), 1841.69, 2590.94, 46.01, 0, 0, 0, false)
--     SetEntityHeading(PlayerPedId(), 189.05)

--     Citizen.Wait(2000)
--     DoScreenFadeIn(1000)

--     TriggerServerEvent("fw-police:Server:ResetJailTime")
-- end)

-- RegisterNetEvent("fw-police:Client:OpenSeizedPossesions")
-- AddEventHandler("fw-police:Client:OpenSeizedPossesions", function()
--     if exports['fw-inventory']:CanOpenInventory() then
--         FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'jail-seize-' .. FW.Functions.GetPlayerData().citizenid, 40, 250)
--     end
-- end)

-- RegisterNetEvent("fw-police:Client:OpenJailCraft")
-- AddEventHandler("fw-police:Client:OpenJailCraft", function()
--     if exports['fw-inventory']:CanOpenInventory() then
--         FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'Prison')
--     end
-- end)

-- RegisterNetEvent("fw-police:Client:Logout")
-- AddEventHandler("fw-police:Client:Logout", function()
--     TriggerServerEvent('fw-apartments:Server:Logout')
-- end)

-- function ReduceJailTime(Reduction)
--     if math.random(1, 100) >= 75 then return end

--     local JailTime = FW.Functions.GetPlayerData().metadata.jailtime
--     if JailTime - Reduction > 1 then
--         FW.Functions.Notify("Strafvermindering ontvangen. " .. JailTime - Reduction .. " maand(en) resterend.", nil, 7000)
--         TriggerServerEvent('fw-police:Server:ReduceJailTime', Reduction)
--     end
-- end

-- function CreateTaskBlip(Sprite, Color, Text, Coords)
--     if DoesBlipExist(TaskBlip) then
--         RemoveBlip(TaskBlip)
--     end

--     TaskBlip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
--     SetBlipSprite(TaskBlip, Sprite)
--     SetBlipColour(TaskBlip, Color)
--     SetBlipScale(TaskBlip, 0.7)
--     SetBlipAsShortRange(TaskBlip, false)
--     BeginTextCommandSetBlipName('STRING')
--     AddTextComponentString(Text)
--     EndTextCommandSetBlipName(TaskBlip)
-- end

-- function ResetJail()
--     InJail = false
--     exports['fw-ui']:HideInteraction()
--     PrisonJob = { Task = false, Info = '', Data = {} }
--     if DoesBlipExist(TaskBlip) then
--         RemoveBlip(TaskBlip)
--     end
-- end

-- function IsInJail()
--     return InJail
-- end
-- exports("IsInJail", IsInJail)

-- function GetPrisonJob()
--     return PrisonJob
-- end
-- exports("GetPrisonJob", GetPrisonJob)