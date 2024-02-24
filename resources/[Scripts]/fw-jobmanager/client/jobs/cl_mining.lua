local DoingAnimation, CurrentMining, NowMining = false, nil, false

-- // Loops \\ --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(4)
        if LoggedIn then
            local AtMiningSpot = false
            local PlayerCoords = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.MiningSpots) do
                local Distance = #(v.Coords - PlayerCoords)
                if Distance < 2.0 then
                    AtMiningSpot, CurrentMining = true, k
                end
            end
            if not AtMiningSpot then
                if CurrentMining ~= nil then
                    CurrentMining = nil
                end
                Citizen.Wait(450)
            end
        else
            Citizen.Wait(450)
        end
    end
end)

-- // Events \\ --

RegisterNetEvent('fw-jobmanager:Client:Used:Pickaxe')
AddEventHandler('fw-jobmanager:Client:Used:Pickaxe', function()
    local CurrentMiningSpot = CurrentMining
    if CurrentMiningSpot ~= false and CurrentMiningSpot ~= nil then
        if not NowMining then
            local AlreadyMined = FW.SendCallback("fw-jobmanager:Server:CanMineThisSpot", CurrentMiningSpot)
            if AlreadyMined ~= nil and AlreadyMined ~= 'No' then
                NowMining = true
                TriggerEvent('fw-jobmanager:Client:DoMiningAnimation', true)
                TriggerServerEvent('fw-jobmanager:Server:Mining:SetState', CurrentMiningSpot, 'Busy', true)
                Citizen.SetTimeout(math.random(1500, 10000), function()
                    local Outcome = exports['fw-ui']:StartSkillTest(3, { 10, 15 }, { 3500, 5500 }, false)
                    if Outcome then
                        TriggerServerEvent('fw-jobmanager:Server:Mining:SetState', CurrentMiningSpot, 'Mined', true)
                        TriggerServerEvent('fw-jobmanager:Server:Mining:ReceiveGoods', AlreadyMined)
                    else
                        FW.Functions.Notify("Pas op, dadelijk heb je nog je tenen aan je pikhouweel zitten..", 'error')
                    end
                    TriggerServerEvent('fw-jobmanager:Server:Mining:SetState', CurrentMiningSpot, 'Busy', false)
                    TriggerEvent('fw-jobmanager:Client:DoMiningAnimation', false)
                    NowMining = false
                end)
            else
                FW.Functions.Notify("Dit plekje ziet er uitgehakt uit..", 'error')
            end
        else
            FW.Functions.Notify("Je bent al aan het mijnen!", 'error')
        end
    else
        FW.Functions.Notify("Dit ziet er niet zo intressant uit, misschien ergens anders kijken..", 'error')
    end
end)

RegisterNetEvent('fw-jobmanager:Client:DoMiningAnimation')
AddEventHandler('fw-jobmanager:Client:DoMiningAnimation', function(Bool)
    DoingAnimation = Bool
    if DoingAnimation then
        exports['fw-assets']:AddProp('Pickaxe')
        RequestAnimDict("melee@large_wpn@streamed_core")
        while not HasAnimDictLoaded("melee@large_wpn@streamed_core") do Citizen.Wait(4) end
        Citizen.CreateThread(function()
            while DoingAnimation do
                Citizen.Wait(4)
                TaskPlayAnim(PlayerPedId(), 'melee@large_wpn@streamed_core', 'ground_attack_on_spot', 3.0, -8.0, -1, 8, 0, false, false, false)
                Citizen.Wait(450)
                TriggerEvent('fw-misc:Client:Play:Audio', 'pickaxe')
                Citizen.Wait(1650)
            end
            StopAnimTask(PlayerPedId(), "melee@large_wpn@streamed_core", "ground_attack_on_spot", 1.0)
            exports['fw-assets']:RemoveProp()
        end)
    end
end)

RegisterNetEvent('fw-jobmanager:Client:MiningGrab')
AddEventHandler('fw-jobmanager:Client:MiningGrab', function(ItemName)
    TriggerServerEvent("fw-jobmanager:Server:MiningGrab")
end)

-- // Functions \\ --

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("mining-stuff", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 5.0,
        Position = vector4(-594.3, 2091.39, 130.60, 56.32),
        Model = 'cs_old_man2',
        Anim = {},
        Props = {},
        Options = {
            {
                Name = 'grab_pickaxe',
                Icon = 'fas fa-circle',
                Label = 'Pikhouweel Pakken!',
                EventType = 'Client',
                EventName = 'fw-jobmanager:Client:MiningGrab',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
end)