FW = exports['fw-core']:GetCoreObject()
LoggedIn = false

local SpawnCam, Peds, InCharacterSelection = false, {}, false
local IsUiReady = false

-- todo: add logout spots

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

RegisterNetEvent("fw-ui:appRestart")
AddEventHandler("fw-ui:appRestart", function(App)
    if not InCharacterSelection then return end
    if App ~= "root" and App ~= "Characters" then return end

    HideSelector()
    Citizen.Wait(50)
    OpenSelector()
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    IsUiReady = true
end)

Citizen.CreateThread(function()
	while true do
		if NetworkIsSessionStarted() and IsUiReady then
            Citizen.Wait(750)
            ShutdownLoadingScreenNui(); ShutdownLoadingScreen()
			OpenSelector()
            break
		end
        Citizen.Wait(4)
	end
end)

function OpenSelector()
    if InCharacterSelection then return end

    InCharacterSelection = true
    exports['fw-ui']:SetUIFocus(true, true)
    exports['fw-sync']:SetClientSync(false, {Time = 18, Weather = "FOGGY"})

    DoScreenFadeOut(0)
    while not IsScreenFadedOut() do Citizen.Wait(10) end

    SetEntityCoords(PlayerPedId(), Config.HideCoords)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false)

    SpawnCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", Config.CamCoords.x, Config.CamCoords.y, Config.CamCoords.z, 0.0, 0.0, Config.CamCoords.w, 33.0, false, false)
    SetCamActive(SpawnCam, true)
    RenderScriptCams(true, true, 0, true, false, false)

    Citizen.Wait(1000)
    BuildCharacters()
end

function HideSelector()
    InCharacterSelection = false
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage('Characters', 'SetVisibility', {
        Visible = false
    })

    DoScreenFadeOut(0)

    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)

    SetCamActive(SpawnCam, false)
    DestroyCam(SpawnCam)

    for i = 1, #Peds, 1 do
        DeletePed(Peds[i])
    end
end

function BuildCharacters()
    local Characters = FW.SendCallback("fw-characters:Server:GetCharacters")
    local AllowOverride = FW.SendCallback("fw-characters:Server:AllowOverride")

    exports['fw-ui']:SendUIMessage('Characters', 'LoadCharacters', {
        Characters = Characters,
        AllowOverride = AllowOverride
    })

    for i = 1, 6, 1 do
        local Model = "player_zero"
        
        local PedPos = Config.PedCoords[i]
        if not PedPos then
            goto Skip
        end

        if Peds[i] then
            DeletePed(Peds[i])
        end

        if Characters[i] and Characters[i].Skin then
            Model = Characters[i].Skin.Model
        end

        -- ig_frans_dobbelen crashes CreatePed native, don't know why. Its the only model that does it...
        if Model == "ig_frans_dobbelen" then
            Model = "a_m_m_golfer_01"
        end

        exports['fw-assets']:RequestModelHash(Model)

        local Ped = CreatePed(0, Model, PedPos.x, PedPos.y, PedPos.z, 0.0, false, false)
        local Heading = GetHeadingFromVector_2d(Config.CamCoords.x - PedPos.x, Config.CamCoords.y - PedPos.y)
        SetEntityHeading(Ped, Heading)

        SetEveryoneIgnorePlayer(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)
        SetPedConfigFlag(Ped, 410, true)
        SetEntityCanBeDamagedByRelationshipGroup(Ped, false, GetHashKey('PLAYER'))
        SetEntityAsMissionEntity(Ped, true, true)

        if Characters[i] and Characters[i].Skin then
            TriggerEvent("fw-clothes:Client:LoadSkin", {
                Ped = Ped,
                Clothes = Characters[i].Skin.Clothes
            })
        else
            SetEntityAlpha(Ped, 180, false)
        end

        Peds[i] = Ped

        ::Skip::
    end

    Citizen.Wait(6000)

    exports['fw-ui']:SendUIMessage('Characters', 'SetVisibility', {
        Visible = true
    })

    if IsScreenFadedOut() then
        DoScreenFadeIn(500)
    end
end

RegisterNetEvent('fw-characters:Client:ShowSelector')
AddEventHandler('fw-characters:Client:ShowSelector', OpenSelector)

RegisterNetEvent("fw-characters:Client:RefreshCharacters")
AddEventHandler("fw-characters:Client:RefreshCharacters", BuildCharacters)

RegisterNUICallback("Characters/CreateCharacter", function(Data, Cb)
    if FW.Throttled("create-character", 1000) then
        return
    end

    HideSelector()
    local Result = FW.SendCallback("fw-character:Server:CreateCharacter", Data)
    Cb(Result)
end)

RegisterNUICallback("Characters/DeleteCharacter", function(Data, Cb)
    DoScreenFadeOut(0)
    FW.TriggerServer("fw-characters:Server:DeleteCharacter", Data)
    Cb("Ok")
end)

RegisterNUICallback("Characters/PlayCharacter", function(Data, Cb)
    HideSelector()
    FW.TriggerServer("fw-characters:Server:PlayCharacter", Data)
    Cb("Ok")
end)

AddEventHandler("onResourceStop", function()
    for i = 1, #Peds, 1 do
        DeletePed(Peds[i])
    end
end)