FW, LoggedIn = exports['fw-core']:GetCoreObject(), false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(950, function() 
        LoggedIn = true
        DeleteDiscoveredSprays()

        Config.Graffitis = FW.SendCallback("fw-graffiti:Server:GetSprays")
    end)
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code
IsPlacing, SprayingParticle, SprayingCan = false, false, false

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    Config.Graffitis = FW.SendCallback("fw-graffiti:Server:GetSprays")

    while true do

        -- Add LoggedIn wait

        local PlayerPos = GetEntityCoords(PlayerPedId())

        for k, v in pairs(Config.Graffitis) do
            local Distance = #(PlayerPos - v.Coords)
            if Distance > 100.0 and v.Entity then
                DeleteObject(v.Entity)
                v.Entity = false
                Config.NearbyGraffitis[v.Entity] = nil
            elseif Distance < 100.0 and not v.Entity then
                local SprayData = Config.Sprays[v.Type]
                if SprayData then
                    v.Entity = CreateObjectNoOffset(SprayData.Model, v.Coords, false, false, false)
                    FreezeEntityPosition(v.Entity, true)
                    SetEntityRotation(v.Entity, v.Rotation.x, v.Rotation.y, v.Rotation.z)
                    Config.NearbyGraffitis[v.Entity] = v
                    Config.NearbyGraffitis[v.Entity].Key = k
                end
            end
        end

        Citizen.Wait(1000)
    end
end)

-- // Functions \\ --
function SprayingAnim(SprayColor)
    if SprayingCan then DeleteObject(SprayingCan) end

    local AnimDict, ShakeName, SprayName = "switch@franklin@lamar_tagging_wall", "lamar_tagging_wall_loop_lamar", "lamar_tagging_exit_loop_lamar"

    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do Citizen.Wait(4) end

    RequestModel("prop_cs_spray_can")
    while not HasModelLoaded("prop_cs_spray_can") do Citizen.Wait(4) end

    RequestNamedPtfxAsset("scr_playerlamgraff")
    while not HasNamedPtfxAssetLoaded("scr_playerlamgraff") do Citizen.Wait(4) end

    local PlyCoords = GetEntityCoords(PlayerPedId())
    SprayingCan = CreateObject("prop_cs_spray_can", PlyCoords.x, PlyCoords.y, PlyCoords.z, true, true, false)
    AttachEntityToEntity(SprayingCan, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0, -0.01, -0.012, 0, 0, 0, true, true, false, false, 2, true)

    Citizen.CreateThread(function()
        TaskPlayAnim(PlayerPedId(), AnimDict, ShakeName, 8.0, -8.0, -1, 8192, 0.0, false, false, false)
        Citizen.Wait(5500)
        TaskPlayAnim(PlayerPedId(), AnimDict, SprayName, 8.0, -2.0, -1, 8193, 0.0, false, false, false)
    
        if not SprayingParticle then
            UseParticleFxAssetNextCall("scr_playerlamgraff")
            SprayingParticle = StartParticleFxLoopedOnEntity("scr_lamgraff_paint_spray", SprayingCan, 0, 0, 0, 0, 0, 0, 1.0, false, false, false)
            SetParticleFxLoopedColour(SprayingParticle, SprayColor[1] / 255, SprayColor[2] / 255, SprayColor[3] / 255, 0)
            SetParticleFxLoopedAlpha(SprayingParticle, 0.25)
        end
    end)
end

function GetGraffitiById(Id)
    for k, v in pairs(Config.Graffitis) do
        if v.Id == Id then
            return v
        end
    end

    return false
end

function GetClosestGraffiti(GangOnly, Coords)
    local Pos = Coords or GetEntityCoords(PlayerPedId())
    local ClosestId, ClosestDistance = false, 0
    
    for k, v in pairs(Config.NearbyGraffitis) do
        if not v then goto Skip end
        local Distance = #(Pos - v.Coords)
        if (not ClosestId or Distance < ClosestDistance) and (not GangOnly or Config.Sprays[v.Type].IsGang) then
            ClosestId, ClosestDistance = v.Key, Distance
        end
        ::Skip::
    end

    return ((ClosestId and ClosestDistance < 90.0 and Config.Graffitis[ClosestId]) or false)
end

function IsGangSpray(Entity)
    if Config.NearbyGraffitis[Entity] == nil then return false end
    return Config.Sprays[Config.NearbyGraffitis[Entity].Type].IsGang
end
exports("IsGangSpray", IsGangSpray)

function IsPlayerInSprayGang(Entity)
    if Config.NearbyGraffitis[Entity] == nil then return false end

    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    return Gang and Gang.Id == Config.NearbyGraffitis[Entity].Type
end
exports("IsPlayerInSprayGang", IsPlayerInSprayGang)

function IsGraffitiContested(Entity)
    if Config.NearbyGraffitis[Entity] == nil then return false end
    return FW.SendCallback("fw-graffiti:Server:IsGraffitiContested", Config.NearbyGraffitis[Entity].Key)
end
exports("IsGraffitiContested", IsGraffitiContested)

function IsInGangTurf(GangId)
    local ClosestGraffiti = GetClosestGraffiti(true, GetEntityCoords(PlayerPedId()))
    return ClosestGraffiti and ClosestGraffiti.Type == GangId
end
exports("IsInGangTurf", IsInGangTurf)

-- // Events \\ --

RegisterNetEvent("fw-graffiti:Client:PlaceSpray")
AddEventHandler("fw-graffiti:Client:PlaceSpray", function(Type, IsAdmin)
    if IsPlacing or exports['fw-progressbar']:GetTaskBarStatus() then return end
    IsPlacing = true

    if not Config.Sprays[Type] then
        return FW.Functions.Notify("Spraytype bestaat niet.", "error")
    end

    local _Admin = IsAdmin and FW.SendCallback("fw-admin:Server:IsPlayerAdmin")
    DoGraffitiPlacer(Config.Sprays[Type].Model, 4.0, false, true, nil, function(Placed, Coords, Rotation)
        if not Placed then
            IsPlacing = false
            return
        end
        
        local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
        local HasGangReachedLimit = FW.SendCallback("fw-laptop:Server:Unknown:HasGangReachedLimit", Type)
        if not _Admin and Config.Sprays[Type].IsGang and HasGangReachedLimit then
            IsPlacing = false
            return FW.Functions.Notify("Je groep heeft het dagelijks limiet bereikt, probeer morgen nog een keer.", "error")
        end

        local ClosestGraffiti = GetClosestGraffiti(true, Coords)

        if ClosestGraffiti and ClosestGraffiti.Type ~= Type and Config.Sprays[Type].IsGang then
            IsPlacing = false
            return FW.Functions.Notify("Je kan geen sprays plaatsen op vijandig territorium!", "error")
        end

        if exports['fw-island']:GetIslandActive() then
            IsPlacing = false
            return FW.Functions.Notify("Je kan geen sprays plaatsen op vijandig territorium!", "error")
        end

        if ClosestGraffiti and ClosestGraffiti.Type == Type and Config.Sprays[Type].IsGang and #(GetEntityCoords(PlayerPedId()) - ClosestGraffiti.Coords) < 75.0 then
            IsPlacing = false
            return FW.Functions.Notify("Je bent te dichtbij een andere spray!", "error")
        end

        TaskTurnPedToFaceCoord(PlayerPedId(), Coords.x, Coords.y, Coords.z, 1)
        Citizen.Wait(250)

        SprayingAnim(Config.Sprays[Type].SprayColor)

        local Alpha = 0
        local TempSpray = CreateObjectNoOffset(Config.Sprays[Type].Model, Coords, false, false, false)
        FreezeEntityPosition(TempSpray, true)
        SetEntityRotation(TempSpray, Rotation.x, Rotation.y, Rotation.z)
        SetEntityAlpha(TempSpray, 0, false)

        Citizen.CreateThread(function()
            while Alpha < 255 do
                Alpha = Alpha + 51
                SetEntityAlpha(TempSpray, Alpha, false)
                Citizen.Wait(7956)
            end
        end)

        local Finished = FW.Functions.CompactProgressbar(40000, "Lekker spuiten...", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
        StopParticleFxLooped(SprayingParticle, true)
        DeleteObject(TempSpray); DeleteObject(SprayingCan)
        StopAnimTask(PlayerPedId(), "switch@franklin@lamar_tagging_wall", "lamar_tagging_exit_loop_lamar", 1.0)
        IsPlacing, SprayingParticle = false, false
        
        if not Finished then return end
        FW.TriggerServer("fw-graffiti:Server:CreateSpray", Type, Coords, Rotation, _Admin)
    end)
end)

RegisterNetEvent("fw-graffiti:Client:AddSpray")
AddEventHandler("fw-graffiti:Client:AddSpray", function(SprayId, SprayData)
    -- add logged in check

    Config.Graffitis[SprayId] = SprayData
end)

RegisterNetEvent("fw-graffiti:Client:DestroyGraffiti")
AddEventHandler("fw-graffiti:Client:DestroyGraffiti", function(SprayId)
    -- add logged in check

    if not Config.Graffitis[SprayId] then
        return
    end

    if Config.Graffitis[SprayId].Entity then
        Config.NearbyGraffitis[Config.Graffitis[SprayId].Entity] = false
        DeleteObject(Config.Graffitis[SprayId].Entity)
    end

    table.remove(Config.Graffitis, SprayId)
end)

RegisterNetEvent("fw-graffiti:Client:PurchaseGangSpray")
AddEventHandler("fw-graffiti:Client:PurchaseGangSpray", function()
    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    if not Gang or Config.Sprays[Gang.Id] == nil then return end

    local MenuItems = {
        {
            Icon = 'spray-can',
            Title = Config.Sprays[Gang.Id].Name .. " Spray (" .. exports['fw-businesses']:NumberWithCommas(Config.GangSprayPrice) .. ")",
            Data = { Event = 'fw-graffiti:Server:PurchaseSpray', Type = 'Server', Spray = Gang.Id },
        }
    }

    Citizen.SetTimeout(50, function()
        FW.Functions.OpenMenu({MainMenuItems = MenuItems})
    end)
end)

RegisterNetEvent("fw-graffiti:Client:PurchaseSpray")
AddEventHandler("fw-graffiti:Client:PurchaseSpray", function()
    local MenuItems = {}

    for k, v in pairs(Config.Sprays) do
        if not v.IsGang and (not v.IsBusiness or exports['fw-businesses']:IsPlayerInBusiness(k)) then
            MenuItems[#MenuItems + 1] = {
                Icon = 'spray-can',
                Title = v.Name .. " Spray",
                Data = { Event = 'fw-graffiti:Server:PurchaseSpray', Type = 'Server', Spray = k },
            }
        end
    end

    Citizen.SetTimeout(50, function()
        FW.Functions.OpenMenu({MainMenuItems = MenuItems})
    end)
end)

AddEventHandler("onResourceStop", function()
    for k, v in pairs(Config.Graffitis) do
        if v.Entity then
            DeleteObject(v.Entity)
        end
    end
end)