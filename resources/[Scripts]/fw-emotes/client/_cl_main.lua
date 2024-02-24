FW = exports['fw-core']:GetCoreObject()

-- Code

DisableEmotes = false
CurrentAnim, CurrentScenario, CurrentDance, CurrentProp, Forced, HasMenuOpen, HasEmotesLoaded = false, false, false, false, false, false, false
RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    local PlayerData = FW.Functions.GetPlayerData()

    if not HasEmotesLoaded then
        local PedModel = PlayerData.skin.Model
        if Config.PedEmotes[PedModel] ~= nil then
            print("Adding emotes for ped model: " .. PedModel)

            for k, v in pairs(Config.PedEmotes[PedModel]) do
                Config.Emotes[k] = v
            end
        end

        HasEmotesLoaded = true
        SendUIMessage("Emotes/SetEmotes", {Emotes = Config.Emotes})
    end
end)

Citizen.CreateThread(function()
    local PlayerData = FW.Functions.GetPlayerData()
    if not HasEmotesLoaded and PlayerData and PlayerData.citizenid then
        local PedModel = PlayerData.skin.Model
        if Config.PedEmotes[PedModel] ~= nil then
            print("Adding emotes for ped model: " .. PedModel)

            for k, v in pairs(Config.PedEmotes[PedModel]) do
                Config.Emotes[k] = v
            end
        end

        HasEmotesLoaded = true
        SendUIMessage("Emotes/SetEmotes", {Emotes = Config.Emotes})
    end

    while true do
        Citizen.Wait(4)
        if CurrentAnim or CurrentScenario or CurrentDance or CurrentProp then
            if IsControlJustReleased(0, 73) then
                TriggerEvent('fw-emotes:Client:StopDance')
                CancelEmote()
            end
        else
            Citizen.Wait(500)
        end
    end
end)

function SendUIMessage(Action, Data)
    SendNUIMessage({
        Action = Action,
        Data = Data
    })
end

function CancelEmote(ForceCancel)
    if (Forced and not ForceCancel) then
        return
    end

    if CurrentProp and exports['fw-assets']:GetPropStatus(CurrentProp)then
        exports['fw-assets']:RemoveProp()
        CurrentProp = false
    end

    if (not CurrentAnim and not CurrentScenario) then
        return
    end

    if CurrentScenario then
        ClearPedTasks(PlayerPedId())
    end

    if CurrentAnim then
        StopAnimTask(PlayerPedId(), CurrentAnim.Dict, CurrentAnim.Anim, 1.0)
    end

    TriggerEvent('fw-emotes:Client:StopChair')

    CurrentAnim, CurrentScenario = false, false
end

function PlayEmote(EmoteName, OverrideData, IsForced)
    if DisableEmotes then return end
    if FW.Functions.GetPlayerData().metadata.isdead or FW.Functions.GetPlayerData().metadata.ishandcuffed then
        return
    end

    if EmoteName == "c" or EmoteName == "cancel" then
        CancelEmote()
        return
    end

    local Data = OverrideData or Config.Emotes[EmoteName]
    if not Data then
        return FW.Functions.Notify("Emote '" .. EmoteName .. "' bestaat niet.", "error")
    end

    CancelEmote()

    TriggerEvent('fw-inventory:Client:ResetWeapon')

    Forced = IsForced

    Citizen.Wait(110)

    if Data.Scenario then
        ClearPedTasks(PlayerPedId())
        if EmoteName == "chair" then
            TaskStartScenarioAtPosition(PlayerPedId(), Data.Scenario, GetEntityCoords(PlayerPedId()) - vector3(0.0, 0.0, 0.5), GetEntityHeading(PlayerPedId()), 0, true, true)
        else
            TaskStartScenarioInPlace(PlayerPedId(), Data.Scenario, 0, true)
        end

        if EmoteName == 'maid' then
            local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())
            if not Entity or Entity <= 0 or EntityType ~= 2 or FW.Shared.HashVehicles[GetEntityModel(Entity)] == nil then goto Skip end

            Citizen.CreateThread(function()
                local Cleaning = true
                while Cleaning do
                    local DirtLevel = GetVehicleDirtLevel(Entity) - 0.3

                    if DirtLevel < 0.0 then Cleaning = false end
                    if CurrentScenario ~= Data.Scenario then Cleaning = false end
                    if not Entity then Cleaning = false end

                    SetVehicleDirtLevel(Entity, DirtLevel)
                    Citizen.Wait(1000)
                end
            end)

            ::Skip::
        end

        CurrentScenario = Data.Scenario
        return
    end

    if Data.Anim and Data.Dict then
        if not HasAnimDictLoaded(Data.Dict) then
            exports['fw-assets']:RequestAnimationDict(Data.Dict)
        end

        if Data.IsSynced then
            local Ped = GetPlayerPed(GetPlayerFromServerId(Data.Target))
            local Heading = GetEntityHeading(Ped)
            local Coords = GetOffsetFromEntityInWorldCoords(Ped, 0.0, 1.0, 0.0)

            if Data.SyncOffsetFront then
                Coords = GetOffsetFromEntityInWorldCoords(Ped, 0.0, Data.SyncOffsetFront, 0.0)
            end

            SetEntityHeading(PlayerPedId(), Heading - 180.0)
            SetEntityCoordsNoOffset(PlayerPedId(), Coords.x, Coords.y, Coords.z, 0)
        end

        TaskPlayAnim(
            PlayerPedId(),
            Data.Dict, Data.Anim,
            Data.BlendInSpeed ~= nil and Data.BlendInSpeed or 1.0,
            Data.BlendOutSpeed ~= nil and Data.BlendOutSpeed or 1.0,
            Data.Duration ~= nil and Data.Duration or (GetAnimDuration(Data.Dict, Data.Anim) * 1000),
            Data.Flag ~= nil and Data.Flag or 48,
            -1, 0, 0, 0
        )

        if Config.Props[EmoteName] then
            exports['fw-assets']:AddProp(Config.Props[EmoteName])
            CurrentProp = Config.Props[EmoteName]
        elseif EmoteName == 'notepad' then
            exports['fw-assets']:AddProp('Notepad')
            exports['fw-assets']:AddProp('Pencil')
            CurrentProp = 'Notepad'
        elseif EmoteName == 'danceglowstick' or EmoteName == 'danceglowstick2' or EmoteName == 'danceglowstick3' then
            exports['fw-assets']:AddProp('GlowstickLeft')
            exports['fw-assets']:AddProp('GlowstickRight')
            CurrentProp = 'GlowstickLeft'
        end

        CurrentAnim = Data

        Citizen.SetTimeout(Data.Duration ~= nil and Data.Duration or (GetAnimDuration(Data.Dict, Data.Anim) * 1000), function()
            if CurrentAnim and CurrentAnim.Anim == Data.Anim and CurrentAnim.Dict == Data.Dict then
                if Data.AutoCancel then
                    CancelEmote()
                    if EmoteName == 'suicidepill' then
                        SetEntityHealth(PlayerPedId(), 0)
                    end
                end
            end
        end)

        return
    elseif Data.IsPropEmote then
        exports['fw-assets']:AddProp(Data.Prop)
        CurrentProp = Data.Prop
        return
    elseif Data.Category == "Shared" then
        local Player, Distance = FW.Functions.GetClosestPlayer()
        if Player == -1 or Distance > 2.5 then
            return FW.Functions.Notify("Niemand in de buurt. (Misschien dichterbij staan)", "error")
        end

        FW.TriggerServer("fw-emotes:Server:SendRequest", Player, EmoteName)
        return
    end

    print("Invalid emote type")
end

RegisterNetEvent("fw-emotes:Client:PlayEmote")
AddEventHandler("fw-emotes:Client:PlayEmote", PlayEmote)

RegisterNetEvent("fw-emotes:Client:CancelEmote")
AddEventHandler("fw-emotes:Client:CancelEmote", CancelEmote)

RegisterNetEvent("fw-emotes:Client:SetEmotesState")
AddEventHandler("fw-emotes:Client:SetEmotesState", function(Bool)
    DisableEmotes = Bool
end)

RegisterNetEvent('fw-emotes:Client:OpenEmotes')
AddEventHandler('fw-emotes:Client:OpenEmotes', function()
    --delay prevents it from registering the 'enter' press from chat into the menu UI and canceling/repeating current anim
    Citizen.SetTimeout(100, function()
        SendUIMessage("SetMenuVisibility", { Visible = true })
        SetNuiFocusKeepInput(true)
        SetNuiFocus(true, false)
        HasMenuOpen = true

        Citizen.CreateThread(function()
            while HasMenuOpen do

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

                if GetResourceKvpInt('emotes-showHelp') ~= 1 then
                    local Coords = GetEntityCoords(PlayerPedId())
                    DrawText3D(Coords + vector3(0, 0, 0.42), "Druk ~g~Arrow Left~s~ en ~g~Arrow Right~s~ om pagina te veranderen")
                    DrawText3D(Coords + vector3(0, 0, 0.28), "Druk ~g~Arrow Up~s~ en ~g~Arrown Down~s~ om te navigeren")
                    DrawText3D(Coords + vector3(0, 0, 0.14), "Druk ~g~Enter~s~ om de emote af te spelen")
                    DrawText3D(Coords - vector3(0, 0, 0.0), "Druk ~g~Backspace~s~ om het menu te sluiten")
                end
                
                Citizen.Wait(4)
            end
        end)
    end)
end)

RegisterNUICallback("Emotes/PlayNavSound", function(Data, Cb)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    Cb("Ok")
end)

RegisterNUICallback("Emotes/PlayConfirmSound", function(Data, Cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    Cb("Ok")
end)

RegisterNUICallback("Emotes/Close", function(Data, Cb)
    SendUIMessage("SetMenuVisibility", { Visible = false })
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    Citizen.SetTimeout(100, function()
        HasMenuOpen = false
    end)
    Cb("Ok")
end)

RegisterNUICallback("Emotes/ToggleHelp", function(Data, Cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    SetResourceKvpInt("emotes-showHelp", GetResourceKvpInt('emotes-showHelp') ~= 1 and 1 or 0)
    Cb("Ok")
end)

RegisterNUICallback("Emotes/Cancel", function(Data, Cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    CancelEmote()
    Cb("Ok")
end)

RegisterNUICallback("Emotes/PlayEmote", function(Data, Cb)
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    PlayEmote(Data.Emote)
    Cb("Ok")
end)

-- Utils
function DrawText3D(Coords, Text)
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextDropShadow()
    AddTextComponentString(Text)
    SetDrawOrigin(Coords.x, Coords.y, Coords.z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end