local CurrentlyPanning = false

local PanConfigs = {
    ['small'] = { Streak = 1, Multiplier = 1 },
    ['medium'] = { Streak = 2, Multiplier = 2 },
    ['large'] = { Streak = 3, Multiplier = 3 },
}

RegisterNetEvent("fw-items:Client:Used:GoldPan")
AddEventHandler("fw-items:Client:Used:GoldPan", function(Item)
    if CurrentlyPanning then return end
    if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then return end
    if not IsEntityInWater(PlayerPedId()) then return end
    if IsPedSwimming(PlayerPedId()) or IsPedSwimmingUnderWater(PlayerPedId()) then return end

    local Result = exports['fw-ui']:StartSkillTest(PanConfigs[Item.CustomType].Streak, { 10, 25 }, { 1500, 4500 }, false)
    if not Result then return end
    
    CurrentlyPanning = true
    Citizen.SetTimeout(11000, function()
        CurrentlyPanning = false
    end)

    TriggerServerEvent('fw-inventory:Server:DecayItem', Item.Item, Item.Slot, 1.25)

    local AnimDict, AnimName = 'amb@world_human_bum_wash@male@high@idle_a', 'idle_a'
    RequestAnimDict(AnimDict)
    while not HasAnimDictLoaded(AnimDict) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(), AnimDict, AnimName, 1.0, -1.0, -1, 1, false, false, false)

    Citizen.Wait(800)
    exports['fw-assets']:AddProp("goldpan")
    Citizen.Wait(3000)
    StopAnimTask(PlayerPedId(), AnimDict, AnimName, 1.0)
    exports['fw-assets']:RemoveProp()
    TriggerServerEvent("fw-misc:Server:GoldPanning:Loot", PanConfigs[Item.CustomType].Multiplier)
end)