local BobcatInteriorId = nil

RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if #(GetEntityCoords(PlayerPedId()) - vector3(882.21, -2258.15, 30.46)) < 1.7 then
        if CurrentCops < Config.RequiredCopsBobcat or DataManager.Get("GlobalCooldown", false) == true then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end

        if DataManager.Get("HeistsDisabled", 0) == 1 then
            returnFW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if DataManager.Get(GetBobcatPrefix() .. "front-doors", 0) ~= 0 then
            return FW.Functions.Notify("Ziet er verbrand uit..", "error")
        end

        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end

        local Outcome = DoThermite(6, vector3(882.21, -2258.15, 30.46))
        if Outcome then
            DataManager.Set(GetBobcatPrefix().. "front-doors", 1)
            FW.TriggerServer("fw-heists:Server:Bobcat:Reset")
            TriggerServerEvent("fw-mdw:Server:SendAlert:Bobcat", GetEntityCoords(PlayerPedId()))

            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BOBCAT_MAIN_1', 0)
            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BOBCAT_MAIN_2', 0)
        end
    elseif #(GetEntityCoords(PlayerPedId()) - vector3(880.86, -2264.41, 30.47)) < 1.7 then
        local Outcome = DoThermite(6, vector3(880.86, -2264.41, 30.47))
        if Outcome then
            if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
                TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
            end

            TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BOBCAT_MAIN_3', 0)
            TriggerServerEvent("fw-phone:Server:Mails:AddMail", "Dark Market", "#Bobcat-427", "De deuren naar kluis van de Bobcat Security worden zometeen geopend...")

            Citizen.SetTimeout((1000 * 60) * 3, function()
                TriggerServerEvent("fw-heists:Server:SpawnBobcatSecurity")
                TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BOBCAT_MAIN_4', 0)
                TriggerServerEvent('fw-doors:Server:SetLockStateById', 'BOBCAT_MAIN_5', 0)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:Client:Used:Explosive')
AddEventHandler('fw-items:Client:Used:Explosive', function()
    if #(GetEntityCoords(PlayerPedId()) - vector3(890.7, -2284.56, 31.15)) > 1.5 then return end

    if DataManager.Get(GetBobcatPrefix() .. "front-doors", 0) == 0 then
        return FW.Functions.Notify("De kluis kan nog niet opgemaakt worden..", "error")
    end

    local Coords = vector3(890.47, -2284.56, 30.54)
    local Rotation = vector3(180.0, 180.0, 0.0)

    exports["fw-inventory"]:SetBusyState(true)
    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'explosive', 1, false)
    TriggerEvent('fw-assets:client:explosion:anim', Coords, Rotation)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    Citizen.SetTimeout(6000, function()
        exports["fw-inventory"]:SetBusyState(false)
        TriggerEvent('fw-assets:client:reset:explosion:anim')
        FW.Functions.Notify("Rennen voor je leven!!!!")

        if not exports['fw-police']:IsStatusAlreadyActive('explosive') then
            TriggerEvent('fw-police:Client:SetStatus', 'explosive', 350)
        end

        Citizen.SetTimeout(6000, function()
            TriggerServerEvent("fw-heists:Server:Bobcat:Explosion")
        end)
    end)
end)

RegisterNetEvent('fw-heists:Client:BobcatVaultExplosion')
AddEventHandler('fw-heists:Client:BobcatVaultExplosion', function()
    local PlayerCoords = GetEntityCoords(PlayerPedId())
	if #(PlayerCoords - vector3(890.80, -2284.75, 32.44)) < 100 then
        RequestNamedPtfxAsset('scr_josh3')
		while not HasNamedPtfxAssetLoaded('scr_josh3') do
			Citizen.Wait(1)
		end	
		UseParticleFxAssetNextCall('scr_josh3')
		local Explosion = StartParticleFxLoopedAtCoord("scr_josh3_explosion", 890.80, -2284.75, 32.44, 0.0, 0.0, 0.0, 3.0, false, false, false, 0)		
		PlaySoundFromCoord(-1, "MAIN_EXPLOSION_CHEAP", 890.80, -2284.75, 32.44, 0, 0, 100, 0)
	end
end)

RegisterNetEvent('fw-heists:Client:SetBobcatEntityset')
AddEventHandler('fw-heists:Client:SetBobcatEntityset', function(Exploded)
    SetBobcatEntitySet(Exploded)
end)

RegisterNetEvent("fw-heists:Client:SetBobcatSecurityAttrs")
AddEventHandler("fw-heists:Client:SetBobcatSecurityAttrs", function(NetIds, Source)
    SetBobcatPedAttrs(NetIds, GetPlayerServerId(PlayerId()) == Source)
end)

RegisterNetEvent("fw-heists:Client:LootBobcatCrate")
AddEventHandler("fw-heists:Client:LootBobcatCrate", function(Data)
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player ~= -1 and Distance < 3.0 then
        return FW.Functions.Notify("Er staat iemand in de buurt volgensmij..", "error")
    end

    Citizen.SetTimeout(math.random(100, 500), function()
        if DataManager.Get(GetBobcatPrefix() .. "crate-" .. Data.CrateId, 0) ~= 0 then
            return FW.Functions.Notify("Ziet er leeg uit..", "error")
        end

        DataManager.Set(GetBobcatPrefix() .. "crate-" .. Data.CrateId, 1)
        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end

        TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

        local Finished = FW.Functions.CompactProgressbar(25000, "Beroven...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { animDict = "anim@heists@ornate_bank@grab_cash_heels", anim = "grab", flags = 16 }, {}, {}, false)
        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
        DataManager.Set(GetBobcatPrefix() .. "crate-" .. Data.CrateId, Finished and 2 or 0)

        if Finished then
            FW.TriggerServer("fw-heists:Server:Bobcat:Loot", Data.CrateId)
        end
    end)
end)

function LoadBobcat()
    BobcatInteriorId = GetInteriorAtCoords(883.4142, -2282.372, 31.44168)
    RequestIpl("prologue06_int_np")
    SetBobcatEntitySet(DataManager.Get(GetBobcatPrefix() .. "vault", 0) == 1)
end

function SetBobcatEntitySet(Exploded)
    DeactivateInteriorEntitySet(BobcatInteriorId, Exploded and "np_prolog_clean" or "np_prolog_broken")
    ActivateInteriorEntitySet(BobcatInteriorId, Exploded and "np_prolog_broken" or "np_prolog_clean")
    RefreshInterior(BobcatInteriorId)
end

function SetBobcatPedAttrs(Peds, IsSource)
    Citizen.CreateThread(function()
        for k, v in pairs(Peds) do
            local Ped = NetworkGetEntityFromNetworkId(v)
            while not NetworkDoesEntityExistWithNetworkId(v) do Citizen.Wait(100) end

            DecorSetBool(Ped, 'ScriptedPed', true)
            SetEntityAsMissionEntity(Ped, 1, 1)
        
            local Interior = GetInteriorFromEntity(Ped)
            local RoomHash = GetRoomKeyFromEntity(Ped)
            ForceRoomForEntity(Ped, Interior, RoomHash)
            SetBlockingOfNonTemporaryEvents(Ped, true)
        
            -- Health & Armor
            SetEntityMaxHealth(Ped, 250)
            SetEntityHealth(Ped, 250)
            SetPedArmour(Ped, 25)
        
            -- Releationships
            SetPedRelationshipGroupHash(Ped, GetHashKey("HATES_PLAYER"))
            SetPedRelationshipGroupHash(PlayerPedId(), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(5, GetHashKey("HATES_PLAYER"), GetHashKey("PLAYER"))
            SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("HATES_PLAYER"))
        
            -- Weapons
            GiveWeaponToPed(Ped, GetHashKey("WEAPON_SMG"), 5000, true, true)
            SetCurrentPedWeapon(Ped, GetHashKey("WEAPON_SMG"), true)
            SetPedAmmo(Ped, GetHashKey("WEAPON_SMG"), 9999)
            SetAmmoInClip(Ped, GetHashKey("WEAPON_SMG"), 9999)
            SetPedShootRate(Ped, 450)
            
            -- Combat & Attack
            SetCanAttackFriendly(Ped, false, true)
            SetPedCombatMovement(Ped, 1)
            SetPedCombatRange(Ped, 0)
            SetPedAlertness(Ped, 3)
            TaskCombatPed(Ped, PlayerPedId(), 0, 16)
            
            -- Misc
            SetPedDropsWeaponsWhenDead(Ped, false)
            SetPedRandomComponentVariation(Ped, true)
            SetPedAsEnemy(Ped, true)
            SetPedSeeingRange(Ped, 150.0)
            SetPedHearingRange(Ped, 150.0)
            SetPedAlertness(Ped, 3)
            SetPedCanRagdollFromPlayerImpact(Ped, false)
            SetPedCanRagdoll(Ped, false)
        end
    end)
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("heist-bobcat-grab-smgs", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(881.35, -2282.6, 30.47),
            Length = 1.6,
            Width = 1.4,
            Data = {
                heading = 335,
                minZ = 29.47,
                maxZ = 31.02
            },
        },
        Options = {
            {
                Name = 'grab-weapons',
                Icon = 'fas fa-circle',
                Label = 'Pakken',
                EventType = 'Client',
                EventName = 'fw-heists:Client:LootBobcatCrate',
                EventParams = {CrateId = 1},
                Enabled = function(Entity)
                    return exports['fw-heists']:CanRobBobcatCrate()
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-bobcat-grab-pistols", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(882.58, -2285.71, 30.47),
            Length = 0.5,
            Width = 1.0,
            Data = {
                heading = 340,
                minZ = 29.87,
                maxZ = 30.67
            },
        },
        Options = {
            {
                Name = 'grab-weapons',
                Icon = 'fas fa-circle',
                Label = 'Pakken',
                EventType = 'Client',
                EventName = 'fw-heists:Client:LootBobcatCrate',
                EventParams = {CrateId = 2},
                Enabled = function(Entity)
                    return exports['fw-heists']:CanRobBobcatCrate()
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("heist-bobcat-grab-rifle", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        ZoneData = {
            Center = vector3(886.47, -2286.88, 30.47),
            Length = 0.8,
            Width = 1.0,
            Data = {
                heading = 0,
                minZ = 29.87,
                maxZ = 31.27
            },
        },
        Options = {
            {
                Name = 'grab-weapons',
                Icon = 'fas fa-circle',
                Label = 'Pakken',
                EventType = 'Client',
                EventName = 'fw-heists:Client:LootBobcatCrate',
                EventParams = {CrateId = 3},
                Enabled = function(Entity)
                    return exports['fw-heists']:CanRobBobcatCrate()
                end,
            }
        }
    })
end)

Citizen.CreateThread(function()
    LoadBobcat()
end)

function CanRobBobcatCrate()
    return DataManager.Get(GetBobcatPrefix() .. "vault", 0) == 1
end
exports("CanRobBobcatCrate", CanRobBobcatCrate)