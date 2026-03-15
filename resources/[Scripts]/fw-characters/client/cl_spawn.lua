local SpawnCam = false
local Spawning = false

RegisterNetEvent("fw-ui:appRestart")
AddEventHandler("fw-ui:appRestart", function(App)
    if not Spawning then return end
    if (App ~= "root" and App ~= "Spawn") then return end
    TriggerEvent("fw-charachters:Client:OpenSpawn", FW.Functions.GetPlayerData())
end)

-- Fill up for later.
Citizen.CreateThread(function()
    local Houses = FW.SendCallback("fw-housing:Server:GetHouses")
    for k, v in pairs(Houses) do
        Config.SpawnLocations[#Config.SpawnLocations + 1] = {
            Id = "house_" .. v.Id,
            Name = v.Adress,
            Icon = "house",
            Coords = {X = v.Coords.x, Y = v.Coords.y, Z = v.Coords.z, H = v.Coords.w},
            Color = "#85d573",
            Type = "House",
            Hidden = true
        }
    end
end)

RegisterNetEvent("fw-charachters:Client:OpenSpawn")
AddEventHandler("fw-charachters:Client:OpenSpawn", function(PlayerData)
    Spawning = true
    DoScreenFadeOut(0)

    Config.SpawnLocations[1].Coords = { X = PlayerData.position.x, Y = PlayerData.position.y, Z = PlayerData.position.z, H = 0.0 }

    -- Setup camera
    SetEntityCoords(PlayerPedId(), -3970.76, 2016.56, 500.91)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false)

    SpawnCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamRot(SpawnCam, -90.0, 0.0, 250.0, 2)
    SetCamCoord(SpawnCam, -3968.85, 2015.93, 502.22)
    SetFocusArea(-3968.85, 2015.93, 502.22, 0.0, 0.0, 0.0)
    StopCamShaking(SpawnCam, true)
    SetCamFov(SpawnCam, 50.0)
    SetCamActive(SpawnCam, true)
    RenderScriptCams(true, false, 0, true, true)

    DoScreenFadeIn(250)

    exports['fw-ui']:SetUIFocus(true, true)

    -- Get the spawn options
    local Houses = FW.SendCallback("fw-housing:Server:GetHouses")
    local SpawnLocations = {}

    local IsInJail = PlayerData.metadata.jailtime > 0

    if IsInJail or PlayerData.metadata.islifer then
        SpawnLocations = {
            {
                Id = "bolingbroke_penitentiary",
                Name = 'Bolingbroke Penitentiary',
                Icon = 'fas fa-voicemail',
                Coords = { X = 1845.903, Y = 2585.873, Z = 45.672 },
                Type = 'Jail',
                Hidden = false,
            },
        }

        if PlayerData.metadata.islifer then
            table.insert(SpawnLocations, {
                Id = "lastlocation",
                Name = "Last Location",
                Icon = 'fas fa-map-pin',
                Coords = { X = PlayerData.position.x, Y = PlayerData.position.y, Z = PlayerData.position.z, H = 0.0 },
                Type = 'Location',
                Hidden = false,
            })
        end
    else
        for k, v in pairs(Houses) do
            if not v.Owned then
                goto Skip
            end

            if v.Owner == PlayerData.citizenid or exports['fw-housing']:HasKeyToHouseId(v.Id, PlayerData.citizenid) then
                local IsLockdown = exports['fw-cityhall']:IsLockdownActive("housing-" .. v.Owner) or exports['fw-cityhall']:IsLockdownActive("housing-" .. v.DbId)
                if not IsLockdown then
                    SpawnLocations[#SpawnLocations + 1] = {
                        Id = "house_" .. v.Id,
                        Name = v.Adress,
                        Icon = "house",
                        Coords = {X = v.Coords.x, Y = v.Coords.y, Z = v.Coords.z, H = v.Coords.w},
                        Color = "#85d573",
                        Type = "House",
                        Hidden = false
                    }
                end
            end

            ::Skip::
        end

        for k, v in pairs(Config.SpawnLocations) do
            if not v.Hidden then
                if v.Id ~= "apartment" or not exports['fw-cityhall']:IsLockdownActive("apartments-" .. PlayerData.metadata.apartmentid) then
                    SpawnLocations[#SpawnLocations + 1] = v
                end
            end
        end
    end

    exports['fw-ui']:SendUIMessage("Spawn", "SetupSpawns", {
        Spawns = SpawnLocations,
    })
end)

RegisterNUICallback('Spawn/SelectSpawn', function(Data, Cb)
    exports['fw-sync']:SetClientSync(true)

    local SpawnData = GetSpawnData(Data.Id)

    DoScreenFadeOut(250)
    while not IsScreenFadedOut() do Citizen.Wait(3) end

    SetCamActive(Config.Cam, false)
    DestroyCam(Config.Cam, true)
    RenderScriptCams(false, false, 1, true, true)

    Spawning = false
    exports['fw-ui']:SetUIFocus(false, false)
    exports['fw-ui']:SendUIMessage('Spawn', 'HideSpawn', {})

    Citizen.Wait(2000)

    if not LoggedIn then
        TriggerEvent('FW:Client:OnPlayerLoaded')
    end
    
    if SpawnData == nil then return end

    if SpawnData.Type == 'Location' then
        SetEntityCoords(PlayerPedId(), SpawnData.Coords.X, SpawnData.Coords.Y, SpawnData.Coords.Z)
        DoLoginCamera(SpawnData.Coords.X, SpawnData.Coords.Y, SpawnData.Coords.Z)
        
        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            FreezeEntityPosition(PlayerPedId(), true)
            Citizen.Wait(1)
        end
        
        SetCamActive(LoginCamera, false)
        DestroyCam(LoginCamera, true)
        RenderScriptCams(false, false, 1, true, true)
        SetFocusEntity(PlayerPedId())
        
        SetEntityVisible(PlayerPedId(), true)
        FreezeEntityPosition(PlayerPedId(), false)
        
        Citizen.Wait(1000)
        DoScreenFadeIn(2500)
    elseif SpawnData.Type == 'Apartment' then
        SetEntityVisible(PlayerPedId(), true)
        SetFocusEntity(PlayerPedId())

        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            FreezeEntityPosition(PlayerPedId(), true)
            Citizen.Wait(1)
        end

        Citizen.SetTimeout(500, function()
            FreezeEntityPosition(PlayerPedId(), false)
            Citizen.Wait(2500)
            TriggerEvent('fw-apartments:Client:EnterApartment', {RoomId = 'Player'}, false)
        end)
    elseif SpawnData.Type == 'Jail' then
        SetEntityVisible(PlayerPedId(), true)
        SetFocusEntity(PlayerPedId())

        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            FreezeEntityPosition(PlayerPedId(), true)
            Citizen.Wait(1)
        end

        Citizen.SetTimeout(500, function()
            FreezeEntityPosition(PlayerPedId(), false)
            Citizen.Wait(1250)
            TriggerEvent('fw-prison:Client:SetJail', true)
        end)
    elseif SpawnData.Type == 'House' then
        SetEntityCoords(PlayerPedId(), SpawnData.Coords.X, SpawnData.Coords.Y, SpawnData.Coords.Z)
        SetEntityVisible(PlayerPedId(), true)
        SetFocusEntity(PlayerPedId())
        DoLoginCamera(SpawnData.Coords.X, SpawnData.Coords.Y, SpawnData.Coords.Z)

        while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
            FreezeEntityPosition(PlayerPedId(), true)
            Citizen.Wait(1)
        end

        SetCamActive(LoginCamera, false)
        DestroyCam(LoginCamera, true)
        RenderScriptCams(false, false, 1, true, true)
        SetFocusEntity(PlayerPedId())

        Citizen.SetTimeout(1000, function()
            FreezeEntityPosition(PlayerPedId(), false)
            TriggerEvent('fw-housing:Client:EnterProperty', nil, true)
            Citizen.Wait(1000)
            DoScreenFadeIn(2500)
        end)
    end

    Config.Cam = nil
    Cb('Ok')
end)

function DoLoginCamera(X, Y, Z)
    local CamAngle, I = -90.0, 2500
    DoScreenFadeOut(1)
    LoginCamera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetFocusArea(X, Y, Z, 0.0, 0.0, 0.0)
    SetCamActive(LoginCamera, true)
    RenderScriptCams(true, false, 0, true, true)
    DoScreenFadeIn(1500)

    while I > 1 do
        local Factor = I / 50
        if I < 1 then I = 1 end
        I = I - Factor

        SetCamCoord(LoginCamera, X, Y, Z + I)
        if I < 1200 then DoScreenFadeIn(600) end
        if I < 90.0 then CamAngle = I - I - I end
        if I < 25.0 then DoScreenFadeOut(600) end
        SetCamRot(LoginCamera, CamAngle, 0.0, 0.0)

        Citizen.Wait(GetFrameTime() * 16.666)
    end
end

function GetSpawnData(Id)
    local Retval = nil

    for k, v in pairs(Config.SpawnLocations) do
        if v.Id == Id then
            Retval = v
        end
    end

    return Retval
end

function AddLocation(Id, Data)
    Data.Id = Id
    table.insert(Config.SpawnLocations, Data)
end

function RemoveLocation(Id)
    for k, v in pairs(Config.SpawnLocations) do
        if v.Id == Id then
            table.remove(Config.SpawnLocations, k)
        end
    end
end