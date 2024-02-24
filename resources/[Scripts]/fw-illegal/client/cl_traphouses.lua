local IsHoldingWeapon, IgnoredPeds = false, {}
local ShowingInteraction, InsideTraphouse, InsideTraphouseId, InteriorData = false, false, false, false

function LoadTraphouses()
    while not exports['fw-config']:IsConfigReady() do
        Citizen.Wait(4)
    end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return end

    for k, v in pairs(Data.traphouses) do
        exports['fw-ui']:AddEyeEntry("traphouse-" .. k, {
            Type = "Zone",
            SpriteDistance = 5.0,
            Distance = 2.5,
            ZoneData = {
                Center = vector3(v.x, v.y, v.z),
                Length = 1.0,
                Width = 1.0,
                Data = {
                    heading = v.w,
                    minZ = v.z - 1.0,
                    maxZ = v.z + 1.5,
                },
            },
            Options = {
                {
                    Name = "grab",
                    Icon = "fas fa-circle",
                    Label = "Naar binnen gaan",
                    EventType = "Client",
                    EventName = "fw-illegal:Client:EnterTraphouse",
                    EventParams = { TraphouseId = k },
                    Enabled = function()
                        local PlayerData = FW.Functions.GetPlayerData()
                        return PlayerData.job.name ~= 'police'
                    end,
                },
            }
        })
    end
end

RegisterNetEvent("fw-config:configLoaded")
AddEventHandler("fw-config:configLoaded", LoadTraphouses)

RegisterNetEvent("fw-config:configReady")
AddEventHandler("fw-config:configReady", LoadTraphouses)

-- Code

function IsNearTraphouse(TraphouseId, DistanceOverwrite)
    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return false end

    local Coords = GetEntityCoords(PlayerPedId())
    if TraphouseId then
        local Traphouse = Data.traphouses[TraphouseId]
        if #(Coords - vector3(Traphouse.x, Traphouse.y, Traphouse.z)) < (DistanceOverwrite or 5.0) then
            return TraphouseId
        end
    else
        for k, v in pairs(Data.traphouses) do
            if #(Coords - vector3(v.x, v.y, v.z)) < (DistanceOverwrite or 5.0) then
                return k
            end
        end
    end

    return false
end

function IsNpcRobbable(Ped)
    local IsEventPed = DecorGetBool(Ped, 'EventPed')
    if IsEventPed then
        return false
    end

    return IgnoredPeds[Ped] == nil
end

function SetInteraction(...)
    ShowingInteraction = true
    exports['fw-ui']:ShowInteraction(...)
end

function HideInteraction()
    ShowingInteraction = false
    exports['fw-ui']:HideInteraction()
end

function EnterTraphouse(TraphouseId)
    if InsideTraphouse then return end

    local Data = exports['fw-config']:GetModuleConfig("traphouses", false)
    if not Data then return false end

    local Coords = vector3(Data.traphouses[TraphouseId].x, Data.traphouses[TraphouseId].y, Data.traphouses[TraphouseId].z)

    InteriorData = exports['fw-interiors']:CreateInterior('shell_store3', vector3(Coords.x, Coords.y, -100.0))
    if InteriorData == nil or InteriorData[1] == nil then return FW.Functions.Notify("Kan traphouse interieur niet laden..", "error") end

    DoScreenFadeOut(250)
    while not IsScreenFadedOut(250) do Citizen.Wait(4) end

    InsideTraphouse = true
    InsideTraphouseId = TraphouseId

    local ExitCoords = {
        x = Coords.x + InteriorData[2].Exit.x,
        y = Coords.y + InteriorData[2].Exit.y,
        z = -101 + InteriorData[2].Exit.z
    }

    SetEntityCoords(PlayerPedId(), ExitCoords.x, ExitCoords.y, ExitCoords.z)
    SetEntityHeading(PlayerPedId(), GetEntityHeading(InteriorData[1]))

    exports['fw-sync']:SetClientSync(false)

    StartTraphouseLoop(Data.traphouses[TraphouseId], Coords)
end

function StartTraphouseLoop(TraphouseData, Coords)
    local Offsets = {}

    for k, v in pairs(InteriorData[2]) do
        Offsets[k] = vector3(Coords.x + v.x, Coords.y + v.y, -100.0 + v.z)
    end

    Citizen.CreateThread(function()
        DoScreenFadeIn(250)
        while InsideTraphouse do
            local PlayerCoords = GetEntityCoords(PlayerPedId())

            local ExitDistance = #(Offsets.Exit - PlayerCoords)
            local StorageDistance = #(Offsets.Traphouse - PlayerCoords)

            local NearAnything = false
            local InteractType = "Exit"

            if ExitDistance <= 0.8 then
                NearAnything = true
                InteractType = "Exit"
            elseif StorageDistance <= 0.8 then
                NearAnything = true
                InteractType = "Storage"
            end

            if NearAnything then
                if not ShowingInteraction then
                    if InteractType == "Exit" then
                        SetInteraction("[E] Verlaten", "primary")
                    elseif InteractType == "Storage" then
                        SetInteraction("[E] Traphouse Acties", "primary")
                    end
                end

                if IsControlJustReleased(0, 38) then
                    if InteractType == "Exit" then
                        DoScreenFadeOut(250)
                        while not IsScreenFadedOut(250) do Citizen.Wait(4) end

                        InsideTraphouse, InsideTraphouseId = false, false
                        exports['fw-interiors']:DespawnInteriors()

                        SetEntityCoords(PlayerPedId(), TraphouseData.x, TraphouseData.y, TraphouseData.z - 1.0)
                        SetEntityHeading(PlayerPedId(), TraphouseData.w)

                        if ShowingInteraction then
                            HideInteraction()
                        end

                        exports['fw-sync']:SetClientSync(true)
                        DoScreenFadeIn(250)
                    elseif InteractType == "Storage" then

                        local ContextItems = {}
                        local Result = FW.SendCallback("fw-illegal:Server:GetTraphouseData", InsideTraphouseId)

                        local PlayerData = FW.Functions.GetPlayerData()
                        if Result.owner ~= PlayerData.citizenid then
                            ContextItems[#ContextItems + 1] = {
                                Title = "Traphouse Takeover",
                                Desc = "Neem de traphouse over voor €5,000!",
                                Disabled = PlayerData.money.cash < 5000,
                                Data = {
                                    Event = 'fw-illegal:Client:TraphouseTakeover',
                                    Type = 'Client',
                                },
                            }
                        else
                            ContextItems[#ContextItems + 1] = {
                                Title = "Code aanpassen",
                                Desc = "Verander de pincode van de traphouse.",
                                Data = {
                                    Event = 'fw-illegal:Client:ChangeTraphouseCode',
                                    Type = 'Client',
                                },
                            }

                            ContextItems[#ContextItems + 1] = {
                                Title = "Opslag",
                                Desc = "Open de opslag om te verkopen.",
                                Data = {
                                    Event = 'fw-illegal:Client:OpenTraphouseStorage',
                                    Type = 'Client',
                                },
                            }

                            ContextItems[#ContextItems + 1] = {
                                Title = "Traphouse Legen",
                                Desc = Result.cash <= 5000 and "Je hebt nog niet genoeg cash om op te halen.." or ("Neem %s cash mee."):format(exports['fw-businesses']:NumberWithCommas(Result.cash)),
                                Disabled = Result.cash <= 5000,
                                Data = {
                                    Event = 'fw-illegal:Client:TakeTraphouseCash',
                                    Type = 'Client',
                                },
                            }
                        end

                        FW.Functions.OpenMenu({
                            MainMenuItems = ContextItems
                        })
                    end

                    ::Skip::
                end
            elseif ShowingInteraction then
                HideInteraction()
            end

            Citizen.Wait(4)
        end
    end)
end

RegisterNetEvent("fw-illegal:Client:TraphouseTakeover")
AddEventHandler("fw-illegal:Client:TraphouseTakeover", function()
    local Result = FW.SendCallback("fw-illegal:Server:CanDoTraphouseTakeover", InsideTraphouseId)
    if not Result then
        return FW.Functions.Notify("Je kan de traphouse nu niet overnemen..")
    end

    local MyCoords = GetEntityCoords(PlayerPedId())
    local Finished = FW.Functions.CompactProgressbar(300000, "Traphouse aan het overnemen, niet bewegen..", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = false}, {}, {}, {}, false)

    if not Finished or #(MyCoords - GetEntityCoords(PlayerPedId())) > 2.0 then
        return
    end

    local Paid = FW.SendCallback("FW:RemoveCash", 5000)
    if not Paid then
        return FW.Functions.Notify("Je hebt niet genoeg cash..", "error")
    end

    FW.TriggerServer("fw-illegal:Server:TakeoverTraphouse", InsideTraphouseId)
end)

RegisterNetEvent("fw-illegal:Client:ChangeTraphouseCode")
AddEventHandler("fw-illegal:Client:ChangeTraphouseCode", function()
    local Result = FW.SendCallback("fw-illegal:Server:GetTraphouseData", InsideTraphouseId)

    local PlayerData = FW.Functions.GetPlayerData()
    if Result.owner ~= PlayerData.citizenid then
        return
    end

    local Result = exports['fw-ui']:CreateInput({
        { Label = "Nieuwe Code", Name = "Code", Icon = "user-lock", Type = "password" }
    })

    if Result and Result.Code ~= '' then
        FW.TriggerServer("fw-illegal:Server:ChangeTraphouseCode", InsideTraphouseId, Result.Code)
    end
end)

RegisterNetEvent("fw-illegal:Client:OpenTraphouseStorage")
AddEventHandler("fw-illegal:Client:OpenTraphouseStorage", function()
    local Result = FW.SendCallback("fw-illegal:Server:GetTraphouseData", InsideTraphouseId)

    local PlayerData = FW.Functions.GetPlayerData()
    if Result.owner ~= PlayerData.citizenid then
        return
    end

    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Traphouse Opslag', "traphouse-" .. InsideTraphouseId, 2, 10)
        TriggerEvent("fw-misc:Client:PlaySound", 'general.stashOpen')
    end
end)

RegisterNetEvent("fw-illegal:Client:TakeTraphouseCash")
AddEventHandler("fw-illegal:Client:TakeTraphouseCash", function()
    local Result = FW.SendCallback("fw-illegal:Server:GetTraphouseData", InsideTraphouseId)

    local PlayerData = FW.Functions.GetPlayerData()
    if Result.owner ~= PlayerData.citizenid then
        return
    end

    local MyCoords = GetEntityCoords(PlayerPedId())
    local Finished = FW.Functions.CompactProgressbar(10000, "Traphouse legen..", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = false}, {}, {}, {}, false)

    if not Finished or #(MyCoords - GetEntityCoords(PlayerPedId())) > 2.0 then
        return
    end

    FW.TriggerServer("fw-illegal:Server:TakeTraphouseCash", InsideTraphouseId)
end)

RegisterNetEvent("fw-illegal:Client:EnterTraphouse")
AddEventHandler("fw-illegal:Client:EnterTraphouse", function(Data)
    if not Data.TraphouseId then return end
    if not IsNearTraphouse(Data.TraphouseId) then return end

    Citizen.Wait(5)

    TriggerEvent('fw-emotes:Client:PlayEmote', "code", nil, true)
    local Result = exports['fw-ui']:CreateInput({
        { Label = "Code", Name = "Code", Icon = "user-lock", Type = "password" }
    })

    local Success = FW.SendCallback('fw-illegal:Server:CheckTraphouseCode', Data.TraphouseId, Result.Code)
    TriggerEvent("fw-emotes:Client:CancelEmote", true)
    if not Success then
        return FW.Functions.Notify("Code is incorrect.", "error")
    end

    EnterTraphouse(Data.TraphouseId)
end)

RegisterNetEvent("fw-weapons:Client:SetWeaponData")
AddEventHandler("fw-weapons:Client:SetWeaponData", function(Data)
    IsHoldingWeapon = Data and Data.Item
    if not IsHoldingWeapon then return end

    local CurrentTraphouse, IsRobbingNpc = false, false

    Citizen.CreateThread(function()
        while IsHoldingWeapon do
            CurrentTraphouse = IsNearTraphouse(false, 100.0)
            Citizen.Wait(5000)
        end
    end)

    Citizen.CreateThread(function()
        while IsHoldingWeapon do

            if CurrentTraphouse and not IsRobbingNpc then
                local Aiming, TargetPed = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if Aiming and TargetPed ~= 0 and not IsPedAPlayer(TargetPed) and GetPedType(TargetPed) ~= 28 and not IsPedInAnyVehicle(TargetPed) then
                    local MyCoords = GetEntityCoords(PlayerPedId())
                    local DistanceBetweenPeds = #(MyCoords - GetEntityCoords(TargetPed))
                    if DistanceBetweenPeds < 4.0 and IsNpcRobbable(TargetPed) then
                        IgnoredPeds[TargetPed] = true
                        IsRobbingNpc = true
                        ClearPedTasks(TargetPed)
                        ClearPedSecondaryTask(TargetPed)
                        TaskTurnPedToFaceEntity(TargetPed, PlayerPedId(), 3.0)
                        TaskSetBlockingOfNonTemporaryEvents(TargetPed, true)
                        SetPedFleeAttributes(TargetPed, 0, 0)
                        SetPedCombatAttributes(TargetPed, 17, 1)

                        SetPedSeeingRange(TargetPed, 0.0)
                        SetPedHearingRange(TargetPed, 0.0)
                        SetPedAlertness(TargetPed, 0)
                        SetPedKeepTask(TargetPed, true)

                        Citizen.Wait(2000)

                        exports['fw-assets']:RequestAnimationDict("missfbi5ig_22")

                        if math.random() < 0.2 then
                            TriggerServerEvent("fw-mdw:Server:SendAlert:CivilianRobbery", MyCoords, FW.Functions.GetStreetLabel(), IsPedMale(TargetPed) and 'Man' or 'Vrouw')
                        end

                        while IsRobbingNpc do
                            if not IsEntityPlayingAnim(TargetPed, "missfbi5ig_22", "hands_up_anxious_scientist", 3) then
                                TaskPlayAnim(TargetPed, "missfbi5ig_22", "hands_up_anxious_scientist", 5.0, 1.0, -1, 1, 0, 0, 0, 0)
                                Citizen.Wait(1000)
                            end

                            local MyCoords = GetEntityCoords(PlayerPedId())
                            local DistanceBetweenPeds = #(MyCoords - GetEntityCoords(TargetPed))

                            if DistanceBetweenPeds > 15.0 then
                                IsRobbingNpc = false
                            end

                            if math.random(1000) < 15 and DistanceBetweenPeds < 7.0 then
                                exports['fw-assets']:RequestAnimationDict("mp_common")
                                TaskPlayAnim(TargetPed, "mp_common", "givetake1_a", 1.0, 1.0, -1, 1, 0, 0, 0, 0 )

                                if math.random(1, 100) < 95 then
                                    FW.TriggerServer("fw-illegal:Server:RobTraphouseCode", CurrentTraphouse, PedToNet(TargetPed))
                                elseif math.random(1, 100) > 25 then
                                    FW.TriggerServer("fw-illegal:Server:RobNPC", PedToNet(TargetPed))
                                end

                                Citizen.Wait(1200)
                                IsRobbingNpc = false
                            end

                            Citizen.Wait(100)
                        end

                        ClearPedTasks(TargetPed)
                        Citizen.Wait(5000)
                        TaskWanderStandard(TargetPed, 10.0, 10)
                        AddShockingEventAtPosition(99, GetEntityCoords(TargetPed), 0.5)
                    end
                end
            else
                Citizen.Wait(500)
            end

            Citizen.Wait(100)
        end
    end)
end)

Citizen.CreateThread(LoadTraphouses)