FW = exports['fw-core']:GetCoreObject()
CurrentRoomId, ApartmentOffset, ShowingInteraction = 0, {}, false

-- Loops
local InApartmentsZone = false
Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox({ center = vector3(-271.15, -957.91, 31.22), length = 2.2, width = 1.4 }, {
        name = "apartments", heading = 27.0,
        minZ = 30.22, maxZ = 33.02,
    }, function(IsInside, Zone, Point)
        InApartmentsZone = IsInside
        if not IsInside then
            if ShowingInteraction then HideInteraction() end
            return
        end
    
        SetInteraction('[E] Appartement Betreden, [G] Meer Opties')
        
        Citizen.CreateThread(function()
            while InApartmentsZone do
                if IsControlJustReleased(0, 38) then
                    local PlayerData = FW.Functions.GetPlayerData()
                    if exports['fw-cityhall']:IsLockdownActive("apartments-" .. PlayerData.metadata.apartmentid) then
                        FW.Functions.Notify("Je kan dit nu niet doen..", "error")
                    else
                        InApartmentsZone = false
                        EnterApartment('Player', false)
                        if ShowingInteraction then HideInteraction() end
                    end
                end

                if IsControlJustReleased(0, 47) then
                    local PlayerData = FW.Functions.GetPlayerData()
                    local LockedResult = FW.SendCallback("fw-apartments:Server:IsApartmentLocked", PlayerData.metadata.apartmentid)
                    local UnlockedApartments, UnlockedApartmentsChildren = FW.SendCallback("fw-apartments:Server:GetUnlockedAparments"), {}

                    for RoomId, Unlocked in pairs(UnlockedApartments) do
                        if Unlocked then
                            table.insert(UnlockedApartmentsChildren, {
                                Icon = 'building',
                                Title = 'Apartment # ' .. RoomId,
                                CloseMenu = true,
                                Data = {
                                    Event = 'fw-apartments:Client:EnterApartment',
                                    Type = 'Client',
                                    RoomId = RoomId
                                }
                            })
                        end
                    end

                    local ContextItems = {
                        {
                            Icon = LockedResult.Unlocked and 'lock' or 'unlock',
                            Title = LockedResult.Unlocked and 'Vergrendelen' or 'Ontgrendelen',
                            Desc = 'Vergrendel/Ontgrendel je appartement.',
                            Disabled = exports['fw-cityhall']:IsLockdownActive("apartments-" .. PlayerData.metadata.apartmentid),
                            Data = {
                                Event = "fw-apartments:Client:LockApartment",
                                Type = "Client",
                                RoomId = PlayerData.metadata.apartmentid
                            }
                        },
                        {
                            Icon = 'building',
                            Title = 'Appartementen',
                            Desc = 'Bekijk / Betreed ontgrendelde appartementen.',
                            Data = { Event = '', Type = 'Client' },
                            SecondMenu = UnlockedApartmentsChildren
                        },
                    }

                    if PlayerData.job.name == "police" or PlayerData.job.name == "judge" then
                        local LockedRoomIds = FW.SendCallback("fw-apartments:Server:GetApartmentsLockdown")
                        
                        ContextItems[#ContextItems + 1] = {
                            Icon = 'door-closed',
                            Title = 'Lockdown Appartementen',
                            Desc = 'Bekijk / Betreed appartementen die op lockdown staan.',
                            Data = { Event = '', Type = 'Client' },
                            SecondMenu = LockedRoomIds
                        }
                    end

                    FW.Functions.OpenMenu({ MainMenuItems = ContextItems })
                end

                Citizen.Wait(4)
            end
        end)
    end)
end)

-- Events
RegisterNetEvent('fw-apartments:Client:LockApartment', function(Data)
    TriggerServerEvent('fw-apartments:Server:SetApartmentLocked', Data.RoomId)
end)

RegisterNetEvent('fw-apartments:Client:EnterApartment', function(Data)
    local PlayerData = FW.Functions.GetPlayerData()

    if exports['fw-cityhall']:IsLockdownActive("apartments-" .. Data.RoomId) and PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'judge' then
        FW.Functions.Notify("Je kan dit nu niet doen..", "error")
    else
        EnterApartment(Data.RoomId, false)
    end
end)

RegisterNetEvent("fw-apartments:Client:CreateCharacter")
AddEventHandler("fw-apartments:Client:CreateCharacter", function()
    FreezeEntityPosition(PlayerPedId(), false)
    TriggerEvent('fw-clothes:Client:CreateCharacter')
end)

RegisterNetEvent("fw-apartment:Client:WakeUp")
AddEventHandler("fw-apartment:Client:WakeUp", function()
    EnterApartment('Player', true)
end)

-- Functions
function SetInteraction(...)
    ShowingInteraction = true
    exports['fw-ui']:ShowInteraction(...)
end

function HideInteraction()
    ShowingInteraction = false
    exports['fw-ui']:HideInteraction()
end

function EnterApartment(RoomId, WakeUp)
    if RoomId == 'Player' then RoomId = FW.Functions.GetPlayerData().metadata.apartmentid end
    CurrentRoomId = tonumber(RoomId)

    ApartmentOffset = FW.SendCallback("fw-apartments:Server:GetApartmentOffset", CurrentRoomId)
    if ApartmentOffset == nil then
        ApartmentOffset = {
            x = math.random(30, 150),
            y = math.random(30, 150),
        }
        TriggerServerEvent('fw-apartments:Server:SetOffset', ApartmentOffset, CurrentRoomId)
    end

    InteriorData = exports['fw-interiors']:CreateInterior('gabz_pinkcage', vector3(Config.ApartmentCoords.x + ApartmentOffset.x, Config.ApartmentCoords.y + ApartmentOffset.y, -100.0))
    if InteriorData == nil or InteriorData[1] == nil then return FW.Functions.Notify("Kan appartement interieur niet laden..", "error") end

    DoScreenFadeOut(250)
    while not IsScreenFadedOut(250) do Citizen.Wait(4) end

    local ExitCoords = {
        x = Config.ApartmentCoords.x + ApartmentOffset.x + InteriorData[2].Exit.x,
        y = Config.ApartmentCoords.y + ApartmentOffset.y + InteriorData[2].Exit.y,
        z = -101 + InteriorData[2].Exit.z
    }

    exports['fw-sync']:SetClientSync(false)

    if WakeUp then
        -- Sofa
        local SofaCoords = vector3(
            Config.ApartmentCoords.x + ApartmentOffset.x + InteriorData[2].Sofa.x,
            Config.ApartmentCoords.y + ApartmentOffset.y + InteriorData[2].Sofa.y,
            -101 + InteriorData[2].Sofa.z
        )

        SetEntityCoords(PlayerPedId(), SofaCoords.x, SofaCoords.y, SofaCoords.z)
        SetEntityHeading(PlayerPedId(),  InteriorData[2].Sofa.h)

        RequestAnimDict("switch@franklin@bed")
        while not HasAnimDictLoaded("switch@franklin@bed") do Citizen.Wait(4) end

        Citizen.Wait(1000)

        TaskPlayAnim(PlayerPedId(), "switch@franklin@bed", "sleep_getup_rubeyes", 1.0, 1.0, -1, 1, 0, 0, 0, 0)

        Citizen.SetTimeout(750, function()
            DoScreenFadeIn(250)
            Citizen.Wait((GetAnimDuration("switch@franklin@bed", "sleep_getup_rubeyes") * 1000) - 2000)
            StopAnimTask(PlayerPedId(), "switch@franklin@bed", "sleep_getup_rubeyes", 1.0)
        end)
    else
        SetEntityCoords(PlayerPedId(), ExitCoords.x, ExitCoords.y, ExitCoords.z)
        SetEntityHeading(PlayerPedId(), GetEntityHeading(InteriorData[1]))
    end

    StartApartmentLoop()
end

function StartApartmentLoop()
    local Offsets = {}

    for k, v in pairs(InteriorData[2]) do
        Offsets[k] = vector3(Config.ApartmentCoords.x + ApartmentOffset.x + v.x, Config.ApartmentCoords.y + ApartmentOffset.y + v.y, -100.0 + v.z)
    end

    local InApartment = true
    Citizen.CreateThread(function()
        DoScreenFadeIn(250)
        while InApartment do
            local PlayerCoords = GetEntityCoords(PlayerPedId())

            local ExitDistance = #(Offsets.Exit - PlayerCoords)
            local StorageDistance = #(Offsets.Stash - PlayerCoords)
            local ClosetDistance = #(Offsets.Wardrobe - PlayerCoords)
            local LogoutDistance = #(Offsets.Logout - PlayerCoords)

            local NearAnything = false
            local InteractType = "Exit"

            if ExitDistance <= 0.8 then
                NearAnything = true
                InteractType = "Exit"
            elseif StorageDistance <= 0.8 then
                NearAnything = true
                InteractType = "Storage"
            elseif ClosetDistance <= 0.8 then
                NearAnything = true
                InteractType = "Closet"
            elseif LogoutDistance <= 0.8 then
                NearAnything = true
                InteractType = "Logout"
            end

            if NearAnything then
                if not ShowingInteraction then
                    if InteractType == "Exit" then
                        SetInteraction("[E] Verlaten", "primary")
                    end
                    if InteractType == "Storage" then
                        SetInteraction("[E] Opslag", "primary")
                    end
                    if InteractType == "Closet" then
                        SetInteraction("[E] Kledingkast", "primary")
                    end
                    if InteractType == "Logout" then
                        SetInteraction("[E] Slapen", "primary")
                    end
                end

                if IsControlJustReleased(0, 38) then
                    local IsLockdownActive = exports['fw-cityhall']:IsLockdownActive("apartments-" .. CurrentRoomId)
                    if InteractType ~= "Exit" then
                        local PlayerData = FW.Functions.GetPlayerData()
                        if IsLockdownActive and PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'judge' then
                            FW.Functions.Notify("Je kan dit nu niet doen..", "error")
                            goto Skip
                        end
                    end

                    if InteractType == "Exit" then
                        DoScreenFadeOut(250)
                        while not IsScreenFadedOut(250) do Citizen.Wait(4) end

                        InApartment = false
                        exports['fw-interiors']:DespawnInteriors()
                        SetEntityCoords(PlayerPedId(), Config.ApartmentCoords.x, Config.ApartmentCoords.y, Config.ApartmentCoords.z - 1.0)
                        SetEntityHeading(PlayerPedId(), 300.0)

                        if ShowingInteraction then HideInteraction() end
                        exports['fw-sync']:SetClientSync(true)
                        DoScreenFadeIn(250)
                    elseif InteractType == "Storage" then
                        if exports['fw-inventory']:CanOpenInventory() then
                            FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Apartment Stash', "apartment-" .. CurrentRoomId, 30, 250)
                            TriggerEvent("fw-misc:Client:PlaySound", 'general.stashOpen')
                        end
                    elseif InteractType == "Closet" then
                        TriggerEvent('fw-clothes:Client:OpenOutfits', true)
                    elseif InteractType == "Logout" then
                        InApartment = false
                        exports['fw-interiors']:DespawnInteriors()
                        TriggerServerEvent('fw-apartments:Server:Logout')
                        if ShowingInteraction then HideInteraction() end
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