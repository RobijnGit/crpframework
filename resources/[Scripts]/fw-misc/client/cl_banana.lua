local isTransformedToMonkey = false
local AllowedCid = {
    ['2009'] = GetConvar("sv_serverCode") == "dev",
    ['2006'] = true,
    ['3129'] = true,
    ['2033'] = true,
    ['2035'] = true,
    ['2880'] = true,
    ['4068'] = true,
}

local CidToPed = {
    ['2006'] = 'a_c_cow',
    ['3129'] = 'a_c_deer',
    ['2035'] = 'a_c_mtlion',
    ['4068'] = 'cs_orleans',
}

function showNonLoopParticle(dict, particleName, coords, scale)
	-- Request the particle dictionary.
	RequestNamedPtfxAsset(dict)
	-- Wait for the particle dictionary to load.
	while not HasNamedPtfxAssetLoaded(dict) do
		Citizen.Wait(0)
	end
	-- Tell the game that we want to use a specific dictionary for the next particle native.
	UseParticleFxAssetNextCall(dict)
	-- Create a new non-looped particle effect, we don't need to store the particle handle because it will
	-- automatically get destroyed once the particle has finished it's animation (it's non-looped).
	SetParticleFxNonLoopedColour(particleHandle, 0, 255, 0 ,0)
	return StartParticleFxNonLoopedAtCoord(particleName, coords, 0.0, 0.0, 0.0, scale, false, false, false)
end

RegisterNetEvent("fw-misc:Client:BananaSwitchFx")
AddEventHandler("fw-misc:Client:BananaSwitchFx", function(Coords)
    ForceLightningFlash()
    for i = 1, 3, 1 do
        showNonLoopParticle("scr_prologue", "scr_prologue_ceiling_debris", Coords, 2.0)
    end
end)

RegisterNetEvent("fw-misc:Client:TransformMonkey")
AddEventHandler("fw-misc:Client:TransformMonkey", function()
    local Cid = FW.Functions.GetPlayerData().citizenid
    if not AllowedCid[Cid] then
        return FW.Functions.Notify("Hoe pel ik zo'n gouden banaan?", "error")
    end

    TriggerServerEvent("fw-misc:Server:BananaSwitchFx", GetEntityCoords(PlayerPedId()) + vector3(0, 0, 1))

    Citizen.Wait(750)

    if isTransformedToMonkey then
        TriggerEvent('fw-clothes:Client:LoadSkin', nil)
        NetworkFadeInEntity(PlayerPedId(), true)
    else
        local Model = CidToPed[Cid]
        RequestModel(Model)
        while not HasModelLoaded(Model) do Citizen.Wait(100) end
        SetPlayerModel(PlayerId(), Model)
        SetPedDefaultComponentVariation(PlayerPedId())
        Citizen.Wait(150)
        NetworkFadeInEntity(PlayerPedId(), true)

        Citizen.SetTimeout(500, function()
            if FW.Functions.GetPlayerData() ~= nil and FW.Functions.GetPlayerData().metadata ~= nil then
                SetPedArmour(PlayerPedId(), FW.Functions.GetPlayerData().metadata.armor)
                SetEntityMaxHealth(PlayerPedId(), 200)
                SetEntityHealth(PlayerPedId(), FW.Functions.GetPlayerData().metadata.health)
                SetPlayerLockonRangeOverride(PlayerId(), 0.0)
            end
        end)
    end

    isTransformedToMonkey = not isTransformedToMonkey
end)

RegisterNetEvent("fw-misc:Client:TakeBananas")
AddEventHandler("fw-misc:Client:TakeBananas", function()
    local Cid = FW.Functions.GetPlayerData().citizenid
    if not AllowedCid[Cid] then
        return FW.Functions.Notify("Hoe pluk ik die boom?", "error")
    end

    local CanPluckBananas = FW.SendCallback("fw-misc:Server:CanPluckBananas")
    if not CanPluckBananas.Success then
        return FW.Functions.Notify(CanPluckBananas.Msg, "error")
    end

    local Finished = FW.Functions.CompactProgressbar(5000, "Oogsten...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = "plant_floor", animDict = "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", flags = 48 }, {}, {}, false)
    StopAnimTask(PlayerPedId(), "weapons@first_person@aim_rng@generic@projectile@thermal_charge@", "plant_floor", 1.0)

    if not Finished then return end

    FW.TriggerServer("fw-misc:Server:PluckBananas")
end)

RegisterNetEvent("fw-misc:Client:WaterBananaTree")
AddEventHandler("fw-misc:Client:WaterBananaTree", function()
    local Cid = FW.Functions.GetPlayerData().citizenid
    if not AllowedCid[Cid] then
        return
    end

    local HasWateringCan = exports['fw-inventory']:HasEnoughOfItem("farming-wateringcan", 1)
    if not HasWateringCan then return FW.Functions.Notify("Je mist een gieter..", "error") end

    local WateringCan = exports['fw-inventory']:GetItemByName("farming-wateringcan")
    if WateringCan == nil then return end

    if WateringCan.Info.Capacity ~= nil and WateringCan.Info.Capacity < 1.0 then
        return FW.Functions.Notify("De gieter is leeg..", "error")
    end

    local WaterValue = FW.SendCallback("fw-misc:Server:GetBananaTreeWater")
    if WaterValue > 75 then
        return FW.Functions.Notify("Boom heeft al genoeg water..", "error")
    end

    exports['fw-inventory']:SetBusyState(true)
    exports['fw-assets']:AddProp('wateringcan')

    local Finished = FW.Functions.CompactProgressbar(7000, "Boom water geven...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, { anim = 'fire', animDict = 'weapon@w_sp_jerrycan', flags = 49 }, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    exports['fw-assets']:RemoveProp()

    if Finished then
        TriggerServerEvent("fw-misc:Server:Farming:SetWateringCanCapacity", WateringCan.Slot, (WateringCan.Info.Capacity ~= nil and WateringCan.Info.Capacity or 100.0) - 1.0)
        TriggerServerEvent("fw-misc:Server:WaterBananaTree")
    end
end)

RegisterNetEvent("fw-misc:Client:CheckBananaWater")
AddEventHandler("fw-misc:Client:CheckBananaWater", function()
    local Cid = FW.Functions.GetPlayerData().citizenid
    if not AllowedCid[Cid] then
        return
    end

    local WaterValue = FW.SendCallback("fw-misc:Server:GetBananaTreeWater")
    if WaterValue > 75 then
        FW.Functions.Notify("De bananenboom is aardig nat.")
    elseif WaterValue > 50 then
        FW.Functions.Notify("De bananenboom is vochtig.")
    elseif WaterValue > 25 then
        FW.Functions.Notify("De bananenboom is bijna droog.")
    else
        FW.Functions.Notify("Ik zou de bananboom wel wat water geven als ik jou was..")
    end
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("pr_banana_tree", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 1.5,
        State = false,
        ZoneData = {
            Center = vector3(380.93, 802.16, 187.68),
            Length = 0.6,
            Width = 0.6,
            Data = {
                heading = 0,
                minZ = 187.48,
                maxZ = 188.73
            },
        },
        Options = {
            {
                Name = 'banana',
                Icon = 'fas fa-monkey',
                Label = 'Bananen plukken',
                EventType = 'Client',
                EventName = 'fw-misc:Client:TakeBananas',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'check_water',
                Icon = 'fas fa-circle',
                Label = 'Water controleren',
                EventType = 'Client',
                EventName = 'fw-misc:Client:CheckBananaWater',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'water',
                Icon = 'fas fa-faucet',
                Label = 'Water geven',
                EventType = 'Client',
                EventName = 'fw-misc:Client:WaterBananaTree',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })
end)

-- 
local MaterialHashes = {
    [-124769592] = true, [223086562] = true, [-309121453] = true,
    [435688960] = true, [-461750719] = true, [581794674] = true,
    [627123000] = true, [-700658213] = true, [-840216541] = true,
    [-913351839] = true, [930824497] = true,[1109728704] = true,
    [-1286696947] = true, [1333033863] = true, [-1595148316] = true,
    [-1833527165] = true, [-1885547121] = true, [-1915425863] = true,
    [-1942898710] = true, [-2041329971] = true, [-2073312001] = true,
    [2128369009] = true,
}

RegisterNetEvent("fw-misc:Client:UsedTrowel")
AddEventHandler("fw-misc:Client:UsedTrowel", function()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' or PlayerData.metadata.department ~= 'BCSO' then
        return
    end

    local Coords = GetEntityCoords(PlayerPedId())
    local RayHandle = StartExpensiveSynchronousShapeTestLosProbe(Coords.x, Coords.y, Coords.z, Coords.x, Coords.y, Coords.z - 2.0, 1, 0, 4)
    local _, Hit, _, _, MaterialHash, _ = GetShapeTestResultIncludingMaterial(RayHandle)

    if not MaterialHashes[MaterialHash] then
        IsDetecting = false
        return FW.Functions.Notify("Ik betwijfel of hier wat ligt..", "error")
    end

    ClearPedTasks(PlayerPedId())
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(8000, "Steentje maken...", false, true, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    ClearPedTasks(PlayerPedId())
    exports['fw-inventory']:SetBusyState(false)

    if not Finished then return end
    LastDetectCoords = vector3(0.0, 0.0, 0.0)
    FW.TriggerServer("fw-misc:Server:CreateSandstone")
end)