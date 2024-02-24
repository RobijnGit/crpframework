local HasDiscoveredEnabled, GraffitiBlips, DiscoveredSprays = false, {}, {}
local HasContestedEnabled, ContestedBlips = false, {}

RegisterNetEvent("fw-graffiti:Client:ScrubGraffiti")
AddEventHandler("fw-graffiti:Client:ScrubGraffiti", function(Data, Entity)
    if exports['fw-progressbar']:GetTaskBarStatus() then return end

    if not exports['fw-inventory']:HasEnoughOfItem('scrubbingcloth', 1) then
        return FW.Functions.Notify("Je hebt een schrobdoek nodig..", "error")
    end

    local Graffiti = Config.NearbyGraffitis[Entity]
    if not Graffiti then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    local Spray = Config.Sprays[Graffiti.Type]
    if not Spray then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    local CanBeScrubbed = not Spray.IsGang
    if Spray.IsGang then CanBeScrubbed = FW.SendCallback("fw-graffiti:Server:IsGangOnline", Graffiti.Type) end

    if not CanBeScrubbed then
        return FW.Functions.Notify("Je kan dit nu niet doen, probeer het later nog eens.")
    end

    if Spray.IsGang and CanBeScrubbed then
        FW.TriggerServer("fw-graffiti:Server:AlertSprayer", Graffiti.Type, "Scrub", FW.Functions.GetStreetLabel())
    end

    local DidRemove = FW.SendCallback("FW:RemoveItem", 'scrubbingcloth', 1, false, nil)
    if not DidRemove then return end

	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_MAID_CLEAN", 0, true)
    local Finished = FW.Functions.CompactProgressbar((60000) * 4, "Schrob, schrob, schrob 🧽💦", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    if Finished then
        FW.TriggerServer("fw-graffiti:Server:DestroySpray", Graffiti.Key)
    end
end)

RegisterNetEvent("fw-graffiti:Client:DiscoverGraffiti")
AddEventHandler("fw-graffiti:Client:DiscoverGraffiti", function(Data, Entity)
    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    if not Gang or Config.Sprays[Gang.Id] == nil then return end

    local Graffiti = Config.NearbyGraffitis[Entity]
    if not Graffiti then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    local Spray = Config.Sprays[Graffiti.Type]
    if not Spray then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    if not Spray.IsGang then
        return FW.Functions.Notify("De graffiti lijkt niet zo spannend te zijn..")
    end

    local Sprays = FW.SendCallback("fw-laptop:Server:Unknown:GetDiscoveredSprays", Gang.Id)
    for k, v in pairs(Sprays) do
        if v == Graffiti.Id then
            return FW.Functions.Notify("Je hebt deze graffiti al ontdekt..", "error")
        end
    end

    TriggerServerEvent("fw-laptop:Server:AddDiscovered", Gang.Id, Graffiti.Id)
end)

RegisterNetEvent("fw-graffiti:Client:ContestGraffiti")
AddEventHandler("fw-graffiti:Client:ContestGraffiti", function(Data, Entity)
    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    if not Gang or Config.Sprays[Gang.Id] == nil then return FW.Functions.Notify("Je kan dit niet..", "error") end

    if exports['fw-progressbar']:GetTaskBarStatus() then return end

    local Graffiti = Config.NearbyGraffitis[Entity]
    if not Graffiti then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    local Spray = Config.Sprays[Graffiti.Type]
    if not Spray then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    if not Spray.IsGang then return FW.Functions.Notify("Jij vindt dit intressant ja? Hmpf.") end

    local IsGangOnline = FW.SendCallback("fw-graffiti:Server:IsGangOnline", Graffiti.Type)
    if not IsGangOnline then
        return FW.Functions.Notify("Je kan dit nu niet doen, probeer het later nog eens.", "error")
    end

    local CanContestSpray = FW.SendCallback("fw-graffiti:Server:CanContestSpray", Gang.Id)
    if not CanContestSpray then
        return FW.Functions.Notify("Je hebt het contest limiet bereikt, probeer het later nog eens.", "error")
    end

    if not exports['fw-inventory']:HasEnoughOfItem('gang-spray', 1, Gang.Id) then
        return FW.Functions.Notify("Je hebt een spray nodig om deze graffiti over te spuiten..", "error")
    end

    local Result = FW.SendCallback("fw-graffiti:Server:SetSprayContested", false, Graffiti.Key)
    if Result then
        FW.Functions.Notify("Graffiti aan het veroveren..")
        FW.TriggerServer("fw-graffiti:Server:AlertSprayer", Graffiti.Type, "Contest", FW.Functions.GetStreetLabel())
    end
end)

RegisterNetEvent("fw-graffiti:Client:ClaimGraffiti")
AddEventHandler("fw-graffiti:Client:ClaimGraffiti", function(Data, Entity)
    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    if not Gang or Config.Sprays[Gang.Id] == nil then return FW.Functions.Notify("Je kan dit niet..", "error") end

    local CanClaimGraffiti = FW.SendCallback("fw-graffiti:Server:CanClaimGraffiti")
    if not CanClaimGraffiti then
        return FW.Functions.Notify("Ik denk dat ik nog even moet wachten voordat ik het overspuit..", "error")
    end

    local Graffiti = Config.NearbyGraffitis[Entity]
    if not Graffiti then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    local Spray = Config.Sprays[Graffiti.Type]
    if not Spray then return FW.Functions.Notify("De graffiti lijkt op kinderverf..", "error") end

    if not Spray.IsGang then return FW.Functions.Notify("Jij vindt dit intressant ja? Hmpf.") end

    IsPlacing = true
    SprayingAnim({255, 255, 255})

    local Finished = FW.Functions.CompactProgressbar(40000, "Lekker spuiten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    StopParticleFxLooped(SprayingParticle, true)
    DeleteObject(TempSpray); DeleteObject(SprayingCan)
    StopAnimTask(PlayerPedId(), "switch@franklin@lamar_tagging_wall", "lamar_tagging_exit_loop_lamar", 1.0)
    IsPlacing, SprayingParticle = false, false
    
    if Finished then
        FW.TriggerServer("fw-graffiti:Server:DestroySpray", Graffiti.Key)
        Citizen.Wait(1000)
        FW.TriggerServer("fw-graffiti:Server:CreateSpray", Gang.Id, Graffiti.Coords, Graffiti.Rotation, true)
    end
end)

RegisterNetEvent("fw-graffiti:Client:ToggleDiscovered")
AddEventHandler("fw-graffiti:Client:ToggleDiscovered", function()
    HasDiscoveredEnabled = not HasDiscoveredEnabled
    if HasDiscoveredEnabled then
        local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
        if not Gang or Config.Sprays[Gang.Id] == nil then return end

        local Sprays = FW.SendCallback("fw-laptop:Server:Unknown:GetDiscoveredSprays", Gang.Id)
        DiscoveredSprays = Sprays

        ShowDiscoveredSprays()
        FW.Functions.Notify("Enabled Discovered Sprays")
    else
        DeleteDiscoveredSprays()
        FW.Functions.Notify("Disabled Discovered Sprays")
    end
end)

RegisterNetEvent("fw-graffiti:Client:UpdateDiscovered")
AddEventHandler("fw-graffiti:Client:UpdateDiscovered", function(Data)
    if not HasDiscoveredEnabled then return end
    DiscoveredSprays = Data
    ShowDiscoveredSprays()
end)

RegisterNetEvent("fw-graffiti:Client:RemoveSpray")
AddEventHandler("fw-graffiti:Client:RemoveSpray", function()
    local IsAdmin = FW.SendCallback("fw-admin:Server:IsPlayerAdmin")
    if not IsAdmin then return end

    local Hit, Coords, Entity = exports['fw-ui']:RayCastGamePlayCamera(5.0)
    if not Hit or Entity == 0 or Entity == -1 or GetEntityType(Entity) ~= 3 then return FW.Functions.Notify("Dit is geen graffiti..", "error") end

    local Graffiti = Config.NearbyGraffitis[Entity]
    if not Graffiti then return FW.Functions.Notify("Geen graffiti gevonden..", "error") end

    local Spray = Config.Sprays[Graffiti.Type]
    if not Spray then return FW.Functions.Notify(Graffiti.Type .. " ongeldige spray..", "error") end

    FW.TriggerServer("fw-graffiti:Server:DestroySpray", Graffiti.Key)
end)

function ShowDiscoveredSprays()
    DeleteDiscoveredSprays()

    for k, v in pairs(DiscoveredSprays) do
        local Graffiti = GetGraffitiById(v)
        if not Graffiti then
            goto Skip
        end

        if not Config.Sprays[Graffiti.Type] then
            print(Graffiti.Type .. " invalid graffiti!")
            goto Skip
        end

        if not Config.Sprays[Graffiti.Type].IsGang then
            goto Skip
        end

        GraffitiBlips[Graffiti.Id] = AddBlipForRadius(Graffiti.Coords.x, Graffiti.Coords.y, Graffiti.Coords.z, 90.0)
        SetBlipHighDetail(GraffitiBlips[Graffiti.Id], true)
        SetBlipColour(GraffitiBlips[Graffiti.Id], Config.Sprays[Graffiti.Type].BlipColor)
        SetBlipAsShortRange(GraffitiBlips[Graffiti.Id], false)
        SetBlipAlpha(GraffitiBlips[Graffiti.Id], 130)

        ::Skip::
    end
end

function DeleteDiscoveredSprays()
    for k, v in pairs(GraffitiBlips) do
        RemoveBlip(v)
    end
    GraffitiBlips = {}
end

RegisterNetEvent("fw-graffiti:Client:ToggleContested")
AddEventHandler("fw-graffiti:Client:ToggleContested", function()
    HasContestedEnabled = not HasContestedEnabled
    if HasContestedEnabled then
        local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
        if not Gang or Config.Sprays[Gang.Id] == nil then return end

        local Sprays = FW.SendCallback("fw-graffiti:Server:GetContestedSprays", Gang.Id)
        ContestedSprays = Sprays

        ShowContestedSprays()
        FW.Functions.Notify("Enabled Contested Sprays")
    else
        DeleteContestedSprays()
        FW.Functions.Notify("Disabled Contested Sprays")
    end
end)

function ShowContestedSprays()
    DeleteContestedSprays()

    for k, v in pairs(ContestedSprays) do
        local Graffiti = GetGraffitiById(v)
        if not Graffiti then
            goto Skip
        end

        ContestedBlips[Graffiti.Id] = AddBlipForRadius(Graffiti.Coords.x, Graffiti.Coords.y, Graffiti.Coords.z, 50.0)
        SetBlipHighDetail(ContestedBlips[Graffiti.Id], true)
        SetBlipColour(ContestedBlips[Graffiti.Id], 1)
        SetBlipAsShortRange(ContestedBlips[Graffiti.Id], false)
        SetBlipAlpha(ContestedBlips[Graffiti.Id], 130)

        ::Skip::
    end
end

function DeleteContestedSprays()
    for k, v in pairs(ContestedBlips) do
        RemoveBlip(v)
    end
    ContestedBlips = {}
end