AnimatingDoor = false
function AnimateObjectHeading(Object, Heading)
    AnimatingDoor = true
    local CurrentHeading = GetEntityHeading(Object)

    local StartTime = GetGameTimer()
    local EndTime = StartTime + 1000

    Citizen.CreateThread(function()
        while GetGameTimer() < EndTime do
            local ElapsedTime = GetGameTimer() - StartTime
            local T = ElapsedTime / (EndTime - StartTime)

            local LerpHeading = LerpAngle(CurrentHeading, Heading, T)
            SetEntityHeading(Object, LerpHeading)

            Citizen.Wait(0)
        end

        SetEntityHeading(Object, Heading)
        FreezeEntityPosition(Object, true)
        AnimatingDoor = false
    end)
end

function LerpAngle(StartAngle, EndAngle, T)
    local Difference = math.abs(EndAngle - StartAngle)
    if Difference > 180 then
        if StartAngle < EndAngle then
            StartAngle = StartAngle + 360
        else
            EndAngle = EndAngle + 360
        end
    end

    local LerpedAngle = (1 - T) * StartAngle + T * EndAngle
    return LerpedAngle % 360
end

function SafeCrack(Difficulty)
    local Promise = promise:new()

    exports['minigame-safecrack']:StartSafeCrack(Difficulty, function(Outcome)
        Promise:resolve(Outcome)
    end)

    return Citizen.Await(Promise)
end

function ShapeMinigame(Time, Puzzles, Amount)
    local PlayerCoords = GetEntityCoords(PlayerPedId())
    local AnimModels, AnimProps = { [1] = GetHashKey("hei_p_m_bag_var22_arm_s"), [2] = GetHashKey("hei_prop_hst_laptop") }, {}
    exports['fw-assets']:RequestAnimationDict("anim@heists@ornate_bank@hack")
    exports['fw-assets']:RequestModelHash("hei_p_m_bag_var22_arm_s")
    exports['fw-assets']:RequestModelHash("hei_prop_hst_laptop")
    local NetSceneOne = NetworkCreateSynchronisedScene(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.6, GetEntityRotation(PlayerPedId()), 2, false, false, 1065353216, 0, 1.3)
    local BagProp = CreateObject(AnimModels[1], GetEntityCoords(PlayerPedId()), 1, 1, 0)
    local LaptopProp = CreateObject(AnimModels[2], GetEntityCoords(PlayerPedId()), 1, 1, 0)
    table.insert(AnimProps, BagProp)
    table.insert(AnimProps, LaptopProp)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), NetSceneOne, "anim@heists@ornate_bank@hack", "hack_enter", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(BagProp, NetSceneOne, "anim@heists@ornate_bank@hack", "hack_enter_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(LaptopProp, NetSceneOne, "anim@heists@ornate_bank@hack", "hack_enter_laptop", 4.0, -8.0, 1)
    local NetSceneTwo = NetworkCreateSynchronisedScene(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.6, GetEntityRotation(PlayerPedId()), 2, false, true, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), NetSceneTwo, "anim@heists@ornate_bank@hack", "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(BagProp, NetSceneTwo, "anim@heists@ornate_bank@hack", "hack_loop_bag", 4.0, -8.0, 1)
    NetworkAddEntityToSynchronisedScene(LaptopProp, NetSceneTwo, "anim@heists@ornate_bank@hack", "hack_loop_laptop", 4.0, -8.0, 1)
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(200)
    NetworkStartSynchronisedScene(NetSceneOne)
    Citizen.Wait(6300)
    NetworkStartSynchronisedScene(NetSceneTwo)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Promise = promise:new()
    exports['minigame-shape']:StartShapeGame(Time, Puzzles, Amount, function(Outcome)
        Promise:resolve(Outcome)

        Citizen.SetTimeout(1500, function()
            local NetScene = NetworkCreateSynchronisedScene(PlayerCoords.x, PlayerCoords.y, PlayerCoords.z + 0.6, GetEntityRotation(PlayerPedId()), 2, false, false, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(PlayerPedId(), NetScene, "anim@heists@ornate_bank@hack", "hack_exit", 1.5, -4.0, 1, 16, 1148846080, 0)
            NetworkAddEntityToSynchronisedScene(BagProp, NetScene, "anim@heists@ornate_bank@hack", "hack_exit_bag", 4.0, -8.0, 1)
            NetworkAddEntityToSynchronisedScene(LaptopProp, NetScene, "anim@heists@ornate_bank@hack", "hack_exit_laptop", 4.0, -8.0, 1)
            NetworkStartSynchronisedScene(NetScene)
            Citizen.Wait(4600)
            NetworkStopSynchronisedScene(NetScene)
            ClearPedTasks(PlayerPedId())
            FreezeEntityPosition(PlayerPedId(), false)
            for k, v in pairs(AnimProps) do
                NetworkRequestControlOfEntity(v)
                DeleteEntity(v)
            end
        end)
    end)

    return Citizen.Await(Promise)
end

function DoThermiteEffect(Coords)
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") do Citizen.Wait(4) end

    RequestModel("hei_prop_heist_thermite")
    while not HasModelLoaded("hei_prop_heist_thermite") do Citizen.Wait(4) end

    local HeistThermite = CreateObject(GetHashKey("hei_prop_heist_thermite"), Coords.x, Coords.y, Coords.z, true, true, true)
    SetEntityRotation(HeistThermite, 90.0, 0.0, 0.0)
    SetEntityCollision(HeistThermite, false, true)
    FreezeEntityPosition(HeistThermite, true)
    Citizen.Wait(1500)
    TriggerServerEvent('fw-assets:Server:Fx:Thermite', Coords, true)
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 6000, 49, 1, 0, 0, 0)
    Citizen.Wait(2000)
    ClearPedTasks(PlayerPedId())
    Citizen.Wait(11000)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    NetworkRequestControlOfEntity(HeistThermite)
    DeleteEntity(HeistThermite)
end

function DoThermite(Size, Coords)
    if AlreadyThermiting then return end
    AlreadyThermiting = true

    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") do Citizen.Wait(4) end

    RequestModel("hei_p_m_bag_var22_arm_s")
    while not HasModelLoaded("hei_p_m_bag_var22_arm_s") do Citizen.Wait(4) end

    RequestModel("hei_prop_heist_thermite")
    while not HasModelLoaded("hei_prop_heist_thermite") do Citizen.Wait(4) end

    Citizen.Wait(100)
    local Rotation = GetEntityRotation(PlayerPedId())
    HeistBagScene = NetworkCreateSynchronisedScene(Coords.x, Coords.y, Coords.z, Rotation.x, Rotation.y, Rotation.z, 2, false, false, 1065353216, 0, 1.3)
    
    local HeistBag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), Coords.x, Coords.y, Coords.z,  true,  true, false)
    SetEntityCollision(HeistBag, false, true)
    NetworkAddPedToSynchronisedScene(PlayerPedId(), HeistBagScene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(HeistBag, HeistBagScene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    NetworkStartSynchronisedScene(HeistBagScene)

    Citizen.Wait(1500)

    local HeistThermite = CreateObject(GetHashKey("hei_prop_heist_thermite"), Coords.x, Coords.y, Coords.z + 0.2,  true,  true, true)
    SetEntityCollision(HeistThermite, false, true)
    AttachEntityToEntity(HeistThermite, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    Citizen.Wait(4000)
    DeleteEntity(HeistBag)

    DetachEntity(HeistThermite, 1, 1)
    FreezeEntityPosition(HeistThermite, true)

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    local Outcome = exports['fw-ui']:StartThermite(Size)
    AlreadyThermiting = false

    if Outcome then
        local DidRemove = FW.SendCallback("FW:RemoveItem", "heavy-thermite", 1)
        if not DidRemove then return false end

        TriggerServerEvent('fw-assets:Server:Fx:Thermite', Coords, true)
        TaskPlayAnim(Ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
        TaskPlayAnim(Ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 6000, 49, 1, 0, 0, 0)
        Citizen.Wait(2000)
        ClearPedTasks(Ped)
        Citizen.Wait(11000)
    end

    NetworkRequestControlOfEntity(HeistThermite)
    DeleteEntity(HeistThermite)
    return Outcome
end

function DrillMinigame()
    local Promise = promise:new()

    exports['fw-assets']:RequestAnimationDict("anim@heists@fleeca_bank@drilling")
    TaskPlayAnim(PlayerPedId(), 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' , 3.0, 3.0, -1, 1, 0, false, false, false)
    exports['fw-assets']:AddProp('Drill')

    exports['minigame-drill']:StartDrilling(function(Outcome)
        exports['fw-assets']:RemoveProp()
        exports["fw-inventory"]:SetBusyState(false)
        StopAnimTask(PlayerPedId(), "anim@heists@fleeca_bank@drilling", "drill_straight_idle", 1.0)

        Promise:resolve(Outcome)
    end)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    return Citizen.Await(Promise)
end
exports("DrillMinigame", DrillMinigame)
