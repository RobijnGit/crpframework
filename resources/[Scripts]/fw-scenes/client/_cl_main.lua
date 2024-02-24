FW, LoggedIn = exports['fw-core']:GetCoreObject(), false
local Scenes, ScenesEnabled, ForceRefresh = {}, true, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1250, function()
        LoggedIn = true
        ScenesEnabled = GetResourceKvpInt("fw_scene_disabled") ~= nil and GetResourceKvpInt("fw_scene_disabled") == 0 or true

        FW.Functions.TriggerCallback("fw-scenes:Server:GetScenes", function(Scenes)
            Config.Scenes = Scenes
        end)

        if ScenesEnabled then StartScenesLoop() end
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
    ScenesEnabled = false
end)

-- Code

FW.AddKeybind("toggleScenes", "Scenes", "Aan/Uit Zetten", "", function(IsPressed)
    if IsPressed then
        ScenesEnabled = not ScenesEnabled
        SetResourceKvpInt("fw_scene_disabled", ScenesEnabled and 0 or 1)
        FW.Functions.Notify("Scenes " .. (ScenesEnabled and "geactiveerd" or "gedeactiveerd"), ScenesEnabled and "success" or "error")
        if ScenesEnabled then StartScenesLoop() end
    end
end)

local PlacingScene = false
FW.AddKeybind("placeScene", "Scenes", "Plaatsen", "", function(IsPressed)
    if not ScenesEnabled then return end
    PlacingScene = IsPressed

    if PlacingScene then
        Citizen.CreateThread(function()
            local CanPlace, ScenePos, OffsetPos = true, vector3(0.0, 0.0, 0.0), vector3(0.0, 0.0, 0.0)
            while PlacingScene do
                if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
                    CanPlace = false
                    return
                end

                local Hit, Coords, _, SurfaceNormal = RayCastGamePlayCamera(7.0)
                if Hit then
                    ScenePos = Coords
                    OffsetPos = Coords + SurfaceNormal * 0.03
                    DrawMarker(28, Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 255, 0, 0, 100, false, false, 2, false, false, false)
                end

                Citizen.Wait(4)
            end

            if not CanPlace or #(ScenePos - vector3(0.0, 0.0, 0.0)) <= 1.0 then return end

            local ColorChoices = {}
            for k, v in pairs(Config.Colors) do
                ColorChoices[#ColorChoices + 1] = {
                    Icon = false,
                    Text = k,
                }
            end

            local Result = exports['fw-ui']:CreateInput({
                { Label = 'Tekst', Icon = 'fas fa-pencil-alt', Name = 'Text' },
                { Label = 'Kleur', Icon = 'fas fa-palette', Name = 'Color', Choices = ColorChoices },
                { Label = 'Afstand (0.1 - 10)', Icon = 'fas fa-people-arrows', Name = 'Distance', Type = 'Number' },
            })

            if Result then
                if #Result.Text > Config.MaxTextLength then
                    FW.Functions.Notify("Tekst is te lang.. (" .. #Result.Text .. "/" .. Config.MaxTextLength .. ")", "error")
                    return
                end

                if not Result.Color or Result.Color == '' then Result.Color = "wit" end
                if Config.Colors[Result.Color:lower()] == nil then
                    FW.Functions.Notify("Ongeldige kleur..", "error")
                    return
                end

                if not Result.Distance or Result.Distance == ''then Result.Distance = 5.0 end
                local Dist = tonumber(Result.Distance) + 0.0
                if Dist < 0.1 or Dist > 10.0 then
                    FW.Functions.Notify("Ongeldige afstand..", "error")
                    return
                end

                TriggerServerEvent("fw-scenes:Server:AddScene", Result, ScenePos, OffsetPos)
            end
        end)
    end
end)

FW.AddKeybind("deleteScene", "Scenes", "Verwijder dichtstbijzijnde", "", function(IsPressed)
    if not IsPressed or not ScenesEnabled then return end

    local PlayerCoords = GetEntityCoords(PlayerPedId())
    local ClosestScene, ClosestDist = -1, 0.0
    for k, v in pairs(Config.Scenes) do
        if ClosestScene == -1 or #(PlayerCoords - v.Coords) < ClosestDist then
            ClosestScene = k
            ClosestDist = #(PlayerCoords - v.Coords)
        end
    end

    if ClosestScene ~= -1 and ClosestDist <= 4.0 then
        TriggerServerEvent("fw-scenes:Server:RemoveScene", ClosestScene)
    end
end)

-- Events
RegisterNetEvent("fw-scenes:Client:UpdateScene")
AddEventHandler("fw-scenes:Client:UpdateScene", function(SceneId, Scene)
    if Scene then
        Config.Scenes[SceneId] = Scene
    else
        if Config.Scenes[SceneId] == nil then return end
        table.remove(Config.Scenes, SceneId)
        ForceRefresh = true
    end
end)

-- Functions
function StartScenesLoop()
    local DummyHash = GetHashKey("fw_scene_dummy")
    Citizen.CreateThread(function()
        local LastUpdate = 0
        local ScenesToDraw = {}
        while ScenesEnabled do
            local PlayerCoords = GetEntityCoords(PlayerPedId())

            if ForceRefresh or GetGameTimer() - LastUpdate >= 500 then
                ForceRefresh, LastUpdate, ScenesToDraw = false, GetGameTimer(), {}
                for k, v in pairs(Config.Scenes) do
                    if #(PlayerCoords - v.Coords) <= v.Distance then
                        exports['fw-assets']:RequestModelHash(DummyHash)
                        local LosObj = CreateObjectNoOffset(DummyHash, v.Offset, 0, 0, 0)
                        SetEntityCollision(LosObj, false, false)
                        FreezeEntityPosition(LosObj, true)
                        SetEntityAlpha(LosObj, 0)

                        if HasEntityClearLosToEntity(PlayerPedId(), LosObj, 17) then
                            local DrawId = #ScenesToDraw + 1
                            ScenesToDraw[DrawId] = {
                                Alpha = 0,
                                Coords = v.Coords,
                                Color = v.Color,
                                Text = string.gsub(v.Text, "\\n", "~n~")
                            }
                        end

                        DeleteObject(LosObj)
                    end
                end
            end

            for k, v in pairs(ScenesToDraw) do
                DrawText3D(v.Coords.x, v.Coords.y, v.Coords.z, #(PlayerCoords - v.Coords), v.Text, v.Color)
            end

            Citizen.Wait(4)
        end
    end)
end

function GetMapRange(S, A1, A2, B1, B2)
    return B1 + (S - A1) * (B2 - B1) / (A2 - A1)
end

function DrawText3D(X, Y, Z, Dist, Text, Color)
    if not Text then return end

    local OnScreen, _x, _y = World3dToScreen2d(X, Y, Z)
    if not OnScreen then return end

    local Scale = math.max(GetMapRange(Dist, 0, 10.0, 0.5, 0.1), 0.1)

    SetDrawOrigin(X, Y, Z, 0)
    local RgbColor = Config.Colors[Color] or Config.Colors['white']
    SetTextColour(RgbColor.r, RgbColor.g, RgbColor.b, 255)
    SetTextScale(0.0, Scale)
    SetTextFont(0)
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentSubstringPlayerName(Text)
    EndTextCommandDisplayText(0, 0)

    ClearDrawOrigin()
end

local function RotationToDirection(Rotation)
    local AdjustedRotation = vector3(
        math.pi / 180 * Rotation.x,
        math.pi / 180 * Rotation.y,
        math.pi / 180 * Rotation.z
    )
    local Direction = vector3(
        -math.sin(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)),
        math.cos(AdjustedRotation.z) * math.abs(math.cos(AdjustedRotation.x)),
        math.sin(AdjustedRotation.x)
    )
    return Direction
end

function RayCastGamePlayCamera(distance)
    local CamRot = GetGameplayCamRot()
    local CamCoord = GetGameplayCamCoord()
    local Direction = RotationToDirection(CamRot)
    local Destination = vector3(
        CamCoord.x + Direction.x * distance,
        CamCoord.y + Direction.y * distance,
        CamCoord.z + Direction.z * distance
    )
    local Ray = StartShapeTestRay(CamCoord.x, CamCoord.y, CamCoord.z, Destination.x, Destination.y, Destination.z, 17, -1, 0)
    local _, Hit, EndCoords, SurfaceNormal, EntityHit = GetShapeTestResult(Ray)
    return Hit, EndCoords, EntityHit, SurfaceNormal
end