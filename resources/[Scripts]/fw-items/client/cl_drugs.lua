local WeedTime, ArmorWeedTime, OnWeed = 0, 0, false

local WeedTimers = {
  ["default"] = { 7, 15 },
  ["1g"] = { 10, 20 },
  ["hashbrownies"] = { 12, 0 },
  ["spacecake"] = { 12, 0 },
  ["insideout"] = { 15, 90 },
  ["cone"] = { 15, 90 },
  ["splitter"] = { 15, 90 },
  ["cross"] = { 15, 90 },
  ["tulp"] = { 15, 90 },
  ["windmill"] = { 15, 90 },
}

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
  if FromItem.Item ~= 'weed-bag-1g' then return end
  if ToItem.Item ~= 'bong' then return end

  if exports['fw-inventory']:CalculateQuality(FromItem.Item, FromItem.CreateDate) <= 0 then
    return FW.Functions.Notify("Lekkere wiet wel gekkie..", "error")
  end

  if OnWeed then return FW.Functions.Notify("Je bent al high..", "error") end

  local Quantity = FromItem.Amount
  if not Quantity then return end

  exports['fw-inventory']:SetBusyState(true)
  exports['fw-assets']:AddProp("Bong")
  local Finished = FW.Functions.CompactProgressbar(3000, "Bong hitten...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, {
    animDict = "anim@safehouse@bong",
    anim = "bong_stage3",
    flags = 49,
  }, {}, {}, false)

  exports['fw-inventory']:SetBusyState(false)
  exports['fw-assets']:RemoveProp()
  if not Finished then return end

  local DidRemove = FW.SendCallback("FW:RemoveItem", "weed-bag-1g", 1)
  if not DidRemove then return FW.Functions.Notify("Waar is je wiet heen dan??", "error") end

  WeedTime, ArmorWeedTime = 15, 75
  TriggerServerEvent('fw-inventory:Server:DecayItem', "bong", ToItem.Slot, 3.0)
  TriggerEvent('fw-items:client:joint:effect', nil, true)
end)

RegisterNetEvent('fw-items:client:use:joint')
AddEventHandler('fw-items:client:use:joint', function(Item, Type)
  if exports['fw-progressbar']:GetTaskBarStatus() then return end
  if DoingSomething then return end
  if OnWeed then return FW.Functions.Notify("Je bent al high..", "error") end

  DoingSomething = true
  exports["fw-inventory"]:SetBusyState(true)

  local ProgressText = "Joint aansteken.."
  if Type == "spacecake" or Type == "hashbrownies" then
    ProgressText = "Eten.."
  end

  local Animation = {}
  if Type == "spacecake" or Type == "hashbrownies" then
    Animation = { animDict = "mp_player_inteat@burger", anim = "mp_player_int_eat_burger", flags = 49 }
  end

  local Finished = FW.Functions.CompactProgressbar(2500, ProgressText, false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, Animation, {}, {}, false)
  exports["fw-inventory"]:SetBusyState(false)
  DoingSomething = false

  if not Finished then return FW.Functions.Notify("Geannuleerd..", "error") end

  WeedTime = WeedTimers[Type][1]
  ArmorWeedTime = WeedTimers[Type][2]

  TriggerEvent('fw-items:server:add:addiction:weed')

  local DidRemove, Uses = false, Item.Info.Uses
  if Uses ~= nil and Uses == 0 then return end

  if Uses ~= nil and Uses > 1 then
    DidRemove = FW.SendCallback("fw-items:Server:RemoveUsesJoint", Item.Item, Item.CustomType, Item.Slot, Item.Info.Uses - 1)
  else
    DidRemove = FW.SendCallback("FW:RemoveItem", Type ~= "default" and "customjoint" or "joint", 1, false, Type ~= "default" and Type)
  end

  if not DidRemove then return end

  TriggerEvent('fw-items:client:joint:effect', Type, false)

  if not exports['fw-police']:IsStatusAlreadyActive('redeyes') then
    TriggerEvent('fw-police:Client:SetStatus', 'redeyes', 250)
  end

  if not exports['fw-police']:IsStatusAlreadyActive('weedsmell') then
      TriggerEvent('fw-police:Client:SetStatus', 'weedsmell', 250)
  end
end)

RegisterNetEvent("fw-items:client:use:lsd")
AddEventHandler("fw-items:client:use:lsd", function()
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("snort_coke", "Lekker Likken..", 3000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "mp_suicide",
                    anim = "pill",
                    flags = 49,
                },  {}, {}, function() -- Done
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 1.0)
                    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'lsd-strip', 1, false)
                    Effectlsd()
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    StopAnimTask(PlayerPedId(), "mp_suicide", "pill", 1.0)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end, true)
            end)
        end
    end
end)

RegisterNetEvent('fw-items:client:joint:effect')
AddEventHandler('fw-items:client:joint:effect', function(Type, isBong)
  if OnWeed then return end

  if not isBong and ArmorWeedTime > 0 and not IsPedInAnyVehicle(PlayerPedId(), false) then
    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
      TriggerEvent('fw-emotes:Client:PlayEmote', "weed")
    else
      TriggerEvent('fw-emotes:Client:PlayEmote', "dealer")
    end
  end

  Citizen.Wait(500)

  local WeedTimeout = WeedTime * 1000
  if (ArmorWeedTime * 1000 > WeedTimeout) then WeedTimeout = ArmorWeedTime * 1000 end

  OnWeed = true
  Citizen.SetTimeout(WeedTimeout, function()
    OnWeed = false
  end)

  Citizen.CreateThread(function()
    while WeedTime > 0 do
      WeedTime = WeedTime - 1
      TriggerServerEvent('fw-ui:Server:remove:stress', math.random(5, 8))
      Citizen.Wait(1000)
    end
  end)

  Citizen.CreateThread(function()
    local effect = 0
    while effect <= (ArmorWeedTime * 1000) do
      effect = effect + 100
  
      if not isBong and not IsPedUsingScenario(PlayerPedId(), "WORLD_HUMAN_DRUG_DEALER") then
        break
      end

      if GetPedArmour(PlayerPedId()) <= 100 then
        SetPedArmour(PlayerPedId(), GetPedArmour(PlayerPedId()) + 1)
      end
  
      Citizen.Wait(1000)
    end
    ClearPedTasks(PlayerPedId())
  end)
end)

-- SPUIT
RegisterNetEvent("fw-items:client:use:spuit")
AddEventHandler("fw-items:client:use:spuit", function()
  local Player, PlayerDist = FW.Functions.GetClosestPlayer()
  if PlayerDist ~= -1 and PlayerDist < 2 then
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("snort_coke", "Vloeistof naar binnen spuiten..", 3000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                  animDict = "amb@world_human_clipboard@male@idle_a",
                  anim = "idle_c",
                  flags = 49,
                }, {}, {}, function() -- Done
                  TriggerServerEvent("fw-items:server:use:spuit", Player)
                  DoingSomething = false
                  exports["fw-inventory"]:SetBusyState(false)
                  FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'herion_syringe', 1, false)
                  StopAnimTask(PlayerPedId(), "anim@amb@business@weed@weed_inspecting_high_dry@", "weed_inspecting_high_base_inspector", 1.0)
                end, function() -- Cancel
                  DoingSomething = false
                  exports["fw-inventory"]:SetBusyState(false)
                  StopAnimTask(PlayerPedId(), "anim@amb@business@weed@weed_inspecting_high_dry@", "weed_inspecting_high_base_inspector", 1.0)
                  FW.Functions.Notify("Geannuleerd..", "error")
              end)
          end)
      end
  end
else
  FW.Functions.Notify('Er is niemand bij je in de buurt..', 'error', 2500)
end
end)

RegisterNetEvent("fw-items:client:use:spuit:effect", function()
  EffectSpuit()
  SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 30)
end)

function EffectSpuit()
  Wait(math.random(1000,1500))
  AlienEffect()
  ShakeGameplayCam('DRUNK_SHAKE', 3.0)  
  AnimpostfxPlay("DeathFailOut", 100000, 0)
  Wait(100000)
  AnimpostfxStop("DeathFailOut")
  ShakeGameplayCam('DRUNK_SHAKE', 0.0)  
end
-- SPUIT

-- NARCOSE
RegisterNetEvent("fw-items:client:use:narcose")
AddEventHandler("fw-items:client:use:narcose", function()
  local Player, PlayerDist = FW.Functions.GetClosestPlayer()
  if PlayerDist ~= -1 and PlayerDist < 2 then
    if not exports['fw-progressbar']:GetTaskBarStatus() then
        if not DoingSomething then
            DoingSomething = true
            exports["fw-inventory"]:SetBusyState(true)
            Citizen.SetTimeout(1000, function()
                FW.Functions.Progressbar("snort_coke", "Vloeistof naar binnen spuiten..", 3000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                  animDict = "amb@world_human_clipboard@male@idle_a",
                  anim = "idle_c",
                  flags = 16,
                }, {}, {}, function() -- Done
                    TriggerServerEvent("fw-items:server:use:narcose", Player)
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    FW.Functions.TriggerCallback('FW:RemoveItem', function() end, 'narcose_syringe', 1, false)
                    StopAnimTask(PlayerPedId(), "anim@amb@business@weed@weed_inspecting_high_dry@", "weed_inspecting_high_base_inspector", 1.0)
                end, function() -- Cancel
                    DoingSomething = false
                    exports["fw-inventory"]:SetBusyState(false)
                    StopAnimTask(PlayerPedId(), "anim@amb@business@weed@weed_inspecting_high_dry@", "weed_inspecting_high_base_inspector", 1.0)
                    FW.Functions.Notify("Geannuleerd..", "error")
                end)
            end)
        end
    end
  else
    FW.Functions.Notify('Er is niemand bij je in de buurt..', 'error', 2500)
  end
end)

RegisterNetEvent("fw-items:client:use:narcose:effect", function()
  EffectNarcose()
end)

function EffectNarcose()
  Wait(math.random(1000,2000))
  ShakeGameplayCam('DRUNK_SHAKE', 1.5)  
  AnimpostfxPlay("DeathFailOut", 50000, 0)
  AnimpostfxPlay("DeathFailOut", 50000, 0)
  AnimpostfxPlay("DeathFailOut", 50000, 0)
  AnimpostfxPlay("DeathFailOut", 50000, 0)
  AnimpostfxPlay("DeathFailOut", 50000, 0)
  AnimpostfxPlay("DrugsDrivingIn", 50000, 0)
  AnimpostfxPlay("DrugsDrivingIn", 50000, 0)
  Wait(50000)
  AnimpostfxStop("DeathFailOut")
  AnimpostfxStop("DrugsDrivingIn")
  ShakeGameplayCam('DRUNK_SHAKE', 0.0)  
end
-- NARCOSE

function WhiteWidowEffect()
  local startStamina = 20
  SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
  while startStamina > 0 do 
      Citizen.Wait(400)
      if math.random(1, 100) < 20 then
          RestorePlayerStamina(PlayerId(), 1.0)
      end
      startStamina = startStamina - 1
      if math.random(1, 100) < 10 and IsPedRunning(PlayerPedId()) then
          SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
      end
      if math.random(1, 300) < 10 then
          Citizen.Wait(math.random(10, 11))
      end
  end
  if IsPedRunning(PlayerPedId()) then
    SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
  end
  startStamina = 0
  SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function AK47Effect()
  local startStamina = 10
  SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
  while startStamina > 0 do 
      Citizen.Wait(350)
      if math.random(1, 100) < 20 then
          RestorePlayerStamina(PlayerId(), 1.0)
      end
      startStamina = startStamina - 1
      if math.random(1, 100) < 10 and IsPedRunning(PlayerPedId()) then
          SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
      end
      if math.random(1, 300) < 10 then
          Citizen.Wait(math.random(10, 11))
      end
  end
  if IsPedRunning(PlayerPedId()) then
    SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
  end
  startStamina = 0
  SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function CokeBagEffect()
  local startStamina = 20
  AlienEffect()
  SetRunSprintMultiplierForPlayer(PlayerId(), 1.2)
  while startStamina > 0 do 
      Citizen.Wait(1000)
      if GetPedArmour(PlayerPedId()) <= 100 then
         SetPedArmour(PlayerPedId(), GetPedArmour(PlayerPedId()) + 2)
      end
      if GetEntityHealth(PlayerPedId()) <= 200 then
        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 2)
      end
      if math.random(1, 100) < 20 then
          RestorePlayerStamina(PlayerId(), 1.0)
      end
      startStamina = startStamina - 1
      if math.random(1, 100) < 10 and IsPedRunning(PlayerPedId()) then
          SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
      end
      if math.random(1, 300) < 10 then
          AlienEffect()
          Citizen.Wait(math.random(3000, 6000))
      end
  end
  if IsPedRunning(PlayerPedId()) then
    SetPedToRagdoll(PlayerPedId(), math.random(1000, 3000), math.random(1000, 3000), 3, 0, 0, 0)
  end
  startStamina = 0
  SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
end

function AlienEffect()
  StartScreenEffect("DrugsMichaelAliensFightIn", 3.0, 0)
  Citizen.Wait(math.random(6000, 9000))
  StartScreenEffect("DrugsMichaelAliensFight", 3.0, 0)
  Citizen.Wait(math.random(6000, 9000))  
  StartScreenEffect("DrugsMichaelAliensFightOut", 3.0, 0)
  StopScreenEffect("DrugsMichaelAliensFightIn")
  StopScreenEffect("DrugsMichaelAliensFight")
  StopScreenEffect("DrugsMichaelAliensFightOut")
end

function Effectlsd()
  Wait(math.random(2000,5000))
  AnimpostfxPlay("DrugsDrivingIn", 10000, 0)
  Wait(10000)
  AnimpostfxStop("DrugsDrivingIn")
  DoLsd(60000);
end

local Mario = {
  cols = {
    [16] =  {r=55,  g=55,   b=55},
    [18] =  {r=55,  g=55,   b=135},
    [24] =  {r=55,  g=95,   b=135},
    [52] =  {r=95,  g=55,   b=55},
    [67] =  {r=95,  g=135,  b=175},
    [88] =  {r=135, g=55,   b=55},
    [95] =  {r=135, g=95,   b=95},
    [124] = {r=175, g=55,   b=55},
    [133] = {r=175, g=95,   b=175},
    [173] = {r=215, g=135,  b=95},
    [203] = {r=255, g=95,   b=95},
    [210] = {r=255, g=135,  b=135},
    [216] = {r=255, g=175,  b=135},
    [222] = {r=255, g=215,  b=135},
    [231] = {r=255, g=255,  b=255},
  },
  bits = {
    {
      133,133,133,133,88,88,88,88,88,88,133,133,133,133,133,133,
      133,133,133,88,124,222,222,124,124,124,88,133,133,133,133,133,
      133,133,133,88,124,231,231,203,203,203,124,88,133,133,133,133,
      133,133,88,88,88,88,88,88,88,203,203,124,88,88,133,133,
      133,88,124,203,203,203,203,124,124,88,203,203,124,124,88,133,
      133,88,88,88,88,88,88,88,88,88,124,203,203,124,88,133,
      133,133,133,95,231,231,210,231,231,210,88,88,88,88,88,133,
      133,133,133,95,231,67,216,67,231,210,210,52,52,95,133,133,
      133,133,133,95,231,16,216,16,231,216,210,52,52,216,95,133,
      133,133,95,216,216,216,216,216,216,216,52,52,52,216,95,133,
      133,133,16,210,216,216,210,210,16,216,216,52,210,95,133,133,
      133,16,16,16,210,210,16,16,16,16,216,210,210,52,52,133,
      133,133,133,16,16,16,16,16,216,216,210,210,52,52,133,133,
      133,133,133,133,95,210,210,210,210,210,210,95,133,133,133,133,
      133,133,95,95,24,18,88,88,88,18,18,88,88,88,133,133,
      133,95,231,24,18,124,124,124,18,24,203,203,203,124,88,133,
      95,231,222,18,124,203,203,18,24,124,95,95,95,203,124,88,
      95,222,222,18,124,124,124,18,24,95,231,231,231,95,124,88,
      133,95,18,24,18,18,18,24,95,231,231,231,231,222,95,88,
      133,133,18,222,67,67,222,222,95,231,231,231,222,222,95,133,
      133,52,52,222,67,67,222,222,67,95,222,222,222,95,133,133,
      52,173,173,52,24,67,67,67,67,24,95,95,95,52,133,133,
      52,95,95,173,52,67,24,24,67,67,24,24,18,95,52,133,
      52,52,95,95,52,24,24,18,24,67,67,67,18,95,52,52,
      52,52,95,95,52,24,18,18,18,24,24,67,18,95,95,52,
      133,52,52,95,52,18,133,133,133,18,18,24,18,173,95,52,
      133,52,52,52,133,133,133,133,133,133,133,18,18,173,95,52,
      133,133,133,133,133,133,133,133,133,133,133,133,133,52,52,133
    },
    {
      133,133,133,133,88,88,88,88,88,88,133,133,133,133,133,133,
      133,133,133,88,124,222,222,124,124,124,88,133,133,133,133,133,
      133,133,133,88,124,231,231,203,203,203,124,88,133,133,133,133,
      133,133,88,88,88,88,88,88,88,203,203,124,88,88,133,133,
      133,88,124,203,203,203,203,124,124,88,203,203,124,124,88,133,
      133,88,88,88,88,88,88,88,88,88,124,203,203,124,88,133,
      133,133,133,95,231,231,210,231,231,210,88,88,88,88,88,133,
      133,133,133,95,231,67,216,67,231,210,210,52,52,95,133,133,
      133,133,133,95,231,16,216,16,231,216,210,52,52,216,95,133,
      133,133,95,216,216,216,216,216,216,216,52,52,52,216,95,133,
      133,133,16,210,216,216,210,210,16,216,216,52,210,95,133,133,
      133,16,16,16,210,210,16,16,16,16,216,210,210,52,52,133,
      133,133,133,16,16,16,16,16,216,216,210,210,52,52,133,133,
      133,133,133,133,95,210,210,210,210,210,210,95,133,133,133,133,
      133,133,133,133,18,88,88,88,18,18,88,88,88,133,133,133,
      133,133,95,18,124,124,124,18,95,95,95,203,203,88,133,133,
      133,95,231,18,124,203,203,95,231,231,231,95,203,203,88,133,
      133,95,222,18,124,124,95,231,231,231,231,222,95,124,88,133,
      133,95,18,24,18,18,95,231,231,231,222,222,95,124,88,133,
      133,133,18,222,67,67,222,95,222,222,222,95,88,88,133,133,
      133,133,18,222,67,67,222,222,95,95,95,24,24,18,133,133,
      133,18,24,24,67,67,24,24,67,67,24,24,18,133,133,133,
      133,52,52,24,24,24,24,18,24,67,67,24,18,52,133,133,
      52,173,173,52,24,24,24,18,24,24,24,24,52,95,52,133,
      52,95,95,173,52,24,18,133,18,24,24,24,52,95,52,133,
      133,52,95,95,95,52,133,133,133,52,52,52,173,95,52,133,
      133,133,52,95,95,52,133,133,52,173,173,95,95,52,133,133,
      133,133,133,52,52,52,133,133,52,52,52,52,52,133,133,133
    },
    {
      133,133,133,133,88,88,88,88,88,88,133,133,133,133,133,133,
      133,133,133,88,124,222,222,124,124,124,88,133,133,133,133,133,
      133,133,133,88,124,231,231,203,203,203,124,88,133,133,133,133,
      133,133,88,88,88,88,88,88,88,124,203,124,88,88,133,133,
      133,88,124,203,203,203,203,124,124,88,203,203,124,124,88,133,
      133,88,88,88,88,88,88,88,88,88,124,203,203,124,88,133,
      133,133,133,95,231,231,210,231,231,210,88,88,88,88,88,133,
      133,133,133,95,231,67,216,67,231,210,210,52,52,95,133,133,
      133,133,133,95,231,16,216,16,231,216,210,52,52,210,95,133,
      133,133,95,216,216,216,216,216,216,216,52,52,52,210,95,133,
      133,133,16,210,216,216,210,210,16,216,216,52,210,95,133,133,
      133,16,16,16,210,210,16,16,16,16,216,210,210,52,52,133,
      133,133,133,16,16,16,16,16,216,216,210,210,52,52,133,133,
      133,133,133,133,95,210,210,210,210,210,210,95,133,133,133,133,
      133,133,133,133,18,88,95,95,95,88,88,88,88,133,133,133,
      133,133,133,18,88,95,231,231,231,95,203,203,124,88,133,133,
      133,133,133,18,95,231,231,231,231,222,95,203,203,88,133,133,
      133,133,18,88,95,231,231,231,222,222,95,203,124,88,133,133,
      133,133,18,18,18,95,222,222,222,95,124,124,124,88,133,133,
      133,133,18,222,67,222,95,95,95,88,88,88,88,18,133,133,
      133,133,18,222,67,222,222,67,24,24,24,24,24,18,133,133,
      133,133,133,18,67,67,67,67,67,24,24,24,18,133,133,133,
      133,133,133,18,24,18,67,67,67,24,24,24,18,133,133,133,
      133,133,133,133,18,24,18,67,24,24,24,18,133,133,133,133,
      133,133,133,133,18,18,18,18,18,18,18,18,133,133,133,133,
      133,133,133,133,52,95,52,173,173,95,95,52,133,133,133,133,
      133,133,133,52,95,52,173,173,95,95,95,52,133,133,133,133,
      133,133,133,52,52,52,52,52,52,52,52,52,133,133,133,133 
    }, 
  }, 
} 
 
local Cubes = {} 
local LastPedInteraction = 0 
local LastPedTurn 
local MarioInit 
local PedSpawned 
 
local MarioState = 1 
local MarioTimer = 0 
local MarioLength = 15 
local MarioAlpha = 0 
local MarioAdder = 1 
local MarioZOff = -20.0 
local MarioZAdd = 0.01

DoLsd = function(time)
   Citizen.CreateThread(function()
    AnimpostfxPlay("DMT_flight", time, 1)
   end)

  InitCubes()

  local step = 0
  local timer = GetGameTimer() 
  local ped = PlayerPedId()
  local lastPos = GetEntityCoords(ped)

  while GetGameTimer() - timer < time do

    DrawToons()
    DrawCubes()
    if MarioInit and not PedSpawned then 
      PedSpawned = true
      Citizen.CreateThread(InitPed)
    end
    Wait(0)
end

  ClearTimecycleModifier()
  ShakeGameplayCam('DRUNK_SHAKE', 0.0)  
  SetPedMotionBlur(PlayerPedId(), false)

  AnimpostfxStop("DMT_flight")
  AnimpostfxPlay("DrugsDrivingOut", 3000, 0)
  Wait(3000) 
  AnimpostfxStop("DrugsDrivingOut")

  Cubes = {}

  LastPedInteraction = 0
  LastPedTurn = nil
  MarioInit = nil
  PedSpawned = nil

  MarioState = 1
  MarioTimer = 0
  MarioLength = 15
  MarioAlpha = 0
  MarioAdder = 1
  MarioZOff = -20.0
  MarioZAdd = 0.01
end

InitPed = function()
  local plyPed = PlayerPedId()
  local pos = GetEntityCoords(plyPed)

  local randomAlt     = math.random(0,359)
  local randomDist    = math.random(50,80)
  local spawnPos      = pos + PointOnSphere(0.0,randomAlt,randomDist)

  while World3dToScreen2d(spawnPos.x,spawnPos.y,spawnPos.z) and not IsPointOnRoad(spawnPos.x,spawnPos.y,spawnPos.z) do 
    randomAlt   = math.random(0,359)
    randomDist  = math.random(50,80)
    spawnPos    = GetEntityCoords(PlayerPedId()) + PointOnSphere(0.0,randomAlt,randomSphere)
    Citizen.Wait(0)
  end 
end

InitCubes = function()
  for i=1,40,1 do
    local r = math.random(5,255)
    local g = math.random(5,255)
    local b = math.random(5,255)
    local a = math.random(50,100)

    local x = math.random(1,180)
    local y = math.random(1,359)
    local z = math.random(15,35)

    Cubes[i] = {pos=PointOnSphere(x,y,z),points={x=x,y=y,z=z},col={r=r, g=g, b=b, a=a}}
  end  

  ShakeGameplayCam('DRUNK_SHAKE', 0.0) 
  SetTimecycleModifierStrength(0.0) 
  SetTimecycleModifier("BikerFilter")
  SetPedMotionBlur(PlayerPedId(), true)


  local counter = 4000
  local tick = 0
  while tick < counter do
    tick = tick + 1
    local plyPos = GetEntityCoords(PlayerPedId())
    local adder = 0.1 * (tick/40)
    SetTimecycleModifierStrength(math.min(0.05 * (tick/(counter/40)),1.5))
    ShakeGameplayCam('DRUNK_SHAKE', math.min(0.1 * (tick/(counter/40)),1.5))  
    for k,v in pairs(Cubes) do
      local pos = plyPos + v.pos
      DrawBox(pos.x+adder,pos.y+adder,pos.z+adder,pos.x-adder,pos.y-adder,pos.z-adder, v.col.r,v.col.g,v.col.g,v.col.a)
      local points = {x=v.points.x+0.1,y=v.points.y+0.1,z=v.points.z}
      Cubes[k].points = points
      Cubes[k].pos = PointOnSphere(points.x,points.y,points.z)
    end
    Wait(0)
  end
end

DrawCubes = function()
  local position = GetEntityCoords(PlayerPedId())
  local adder = 10
  for k,v in pairs(Cubes) do
    local addX = 0.1
    local addY = 0.1

    if k%4 == 0 then
      addY = -0.1
    elseif k%3 == 0 then
      addX = -0.1
    elseif k%2 == 0 then
      addX = -0.1
      addY = -0.1
    end

    local pos = position + v.pos
    DrawBox(pos.x+adder,pos.y+adder,pos.z+adder,pos.x-adder,pos.y-adder,pos.z-adder, v.col.r,v.col.g,v.col.g,v.col.a)
    local points = {x=v.points.x+addX,y=v.points.y+addY,z=v.points.z}
    Cubes[k].points = points
    Cubes[k].pos = PointOnSphere(points.x,points.y,points.z)
  end
end

DrawToons = function()
  local plyPed = PlayerPedId()
  local plyPos = GetEntityCoords(plyPed)

  local infront = vector3(plyPos.x+35.0, plyPos.y-8.0,plyPos.z)
  local behind  = vector3(plyPos.x-35.0, plyPos.y-8.0,plyPos.z)

  if (GetGameTimer() - MarioTimer) > 1000 then
    MarioTimer = GetGameTimer()
    MarioState = MarioState + MarioAdder

    if MarioState > #Mario.bits then
      MarioAdder = -1
      MarioState = 2
    elseif MarioState <= 0 then
      MarioState = 2
      MarioAdder = 1
    end
  end

  DrawMario(infront)
  DrawMario(behind)
end

DrawMario = function(loc)
  local height = 0
  local width = 0

  if MarioZOff < 0.0 then MarioZOff = MarioZOff + MarioZAdd; end
  for k = #Mario.bits[MarioState],1,-1 do
    local v = Mario.bits[MarioState][k]
    local pos = vector3(loc.x,loc.y+width,loc.z+height)
    local col = Mario.cols[v]    

    if MarioAlpha < 255 then
      if not MarioInit then MarioInit = true; end
      MarioAlpha = MarioAlpha + 0.001
    end

    if v ~= 133 then
      DrawBox(pos.x+0.5,pos.y+0.5,pos.z+0.5 + MarioZOff, pos.x-0.5,pos.y-0.5,pos.z-0.5 + MarioZOff, col.r,col.g,col.b,math.floor(MarioAlpha))
    end

    width = width + 1
    if width > MarioLength then
      width = 0
      height = height + 1
    end
  end
end

GetVecDist = function(v1,v2)
  if not v1 or not v2 or not v1.x or not v2.x then return 0; end
  return math.sqrt(  ( (v1.x or 0) - (v2.x or 0) )*(  (v1.x or 0) - (v2.x or 0) )+( (v1.y or 0) - (v2.y or 0) )*( (v1.y or 0) - (v2.y or 0) )+( (v1.z or 0) - (v2.z or 0) )*( (v1.z or 0) - (v2.z or 0) )  )
end

PointOnSphere = function(alt,azu,radius,orgX,orgY,orgZ)
  local toradians = 0.017453292384744
  alt,azu,radius,orgX,orgY,orgZ = ( tonumber(alt or 0) or 0 ) * toradians, ( tonumber(azu or 0) or 0 ) * toradians, tonumber(radius or 0) or 0, tonumber(orgX or 0) or 0, tonumber(orgY or 0) or 0, tonumber(orgZ or 0) or 0
  if      vector3
  then
      return
      vector3(
           orgX + radius * math.sin( azu ) * math.cos( alt ),
           orgY + radius * math.cos( azu ) * math.cos( alt ),
           orgZ + radius * math.sin( alt )
      )
  end
end