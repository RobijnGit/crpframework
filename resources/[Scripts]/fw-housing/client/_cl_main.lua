local FW, LoggedIn, ShowingInteraction = exports['fw-core']:GetCoreObject(), false, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code
local CurrentHouse, IsInside = nil, false
local HouseObject, HouseOffsets, HouseDecorations = nil, {}, {}

-- Events
RegisterNetEvent("fw-housing:Client:SyncHouse")
AddEventHandler("fw-housing:Client:SyncHouse", function(HouseId, Data)
    Config.Houses[HouseId] = Data
    if Data and CurrentHouse and CurrentHouse.Id == Data.Id then

        if IsInside and CurrentHouse.Decorations ~= Data.Decorations then
            UnloadInteriorDecorations()
        end

        CurrentHouse = Data

        Citizen.SetTimeout(150, function()
            if IsInside then
                LoadInteriorDecorations(Data.Decorations)
            end
        end)
    end
end)

-- Loops
Citizen.CreateThread(function()
    Citizen.SetTimeout(1000, function()
        FW.Functions.TriggerCallback("fw-housing:Server:GetHouses", function(Result) Config.Houses = Result end)
    end)

    while true do
        if LoggedIn and not IsInside then
            local ClosestHouse = GetClosestHouse()
            if ClosestHouse then
                if CurrentHouse == nil or CurrentHouse.Name ~= ClosestHouse.Name then
                    CurrentHouse = ClosestHouse
                end
            elseif CurrentHouse ~= nil then
                CurrentHouse = nil
            else
                Citizen.Wait(250)
            end
        end

        Citizen.Wait(250)
    end
end)

-- Functions
function CanRealtor()
    for k, v in pairs(Config.BusinessNames) do
        if exports['fw-businesses']:HasRolePermission(v, "ChargeExternal") then
            return true
        end
    end

    return false
end
exports("CanRealtor", CanRealtor)

function GetClosestHouse()
    local ClosestHouse, ClosestDistance = nil, 999

    local Coords = GetEntityCoords(PlayerPedId())
    for k, v in pairs(Config.Houses) do
        local FrontDistance = #(Coords - vector3(v.Coords.x, v.Coords.y, v.Coords.z))
        local BackDistance = 999.0
        if v.Locations.BackdoorOut and v.Locations.BackdoorIn then BackDistance = #(Coords - vector3(v.Locations.BackdoorOut.x, v.Locations.BackdoorOut.y, v.Locations.BackdoorOut.z)) end

        if FrontDistance <= 1.0 or BackDistance <= 1.0 then
            if ClosestDistance > FrontDistance or ClosestDistance > BackDistance then
                ClosestHouse, ClosestDistance = k, FrontDistance <= 1.0 and FrontDistance or BackDistance
            end
        end
    end

    return ClosestHouse ~= nil and Config.Houses[ClosestHouse] or false
end
exports("GetClosestHouse", GetClosestHouse)
exports("GetCurrentHouse", function() return CurrentHouse end)
exports("GetHouse", function(HouseId) return Config.Houses[HouseId] end)
exports("IsInside", function() return IsInside end)

function HasKeyToCurrent(Cid)
    local Cid = Cid or FW.Functions.GetPlayerData().citizenid
    if CurrentHouse == nil then return false end

    if not CurrentHouse.Owned and CanRealtor() then
        return true
    end

    if CurrentHouse.Owner == Cid then return true end

    local HasKey = false
    for k, v in pairs(CurrentHouse.Keyholders) do
        if v == Cid then
            HasKey = true
            break
        end
    end

    return HasKey
end
exports("HasKeyToCurrent", HasKeyToCurrent)

function HasKeyToHouseId(HouseId, Cid)
    local Cid = Cid or FW.Functions.GetPlayerData().citizenid
    if Config.Houses[HouseId] == nil then return false end

    if Config.Houses[HouseId].Owner == Cid then return true end

    local HasKey = false
    for k, v in pairs(Config.Houses[HouseId].Keyholders) do
        if v == Cid then
            HasKey = true
            break
        end
    end

    return HasKey
end
exports("HasKeyToHouseId", HasKeyToHouseId)

function OpenDoorAnim()
    exports['fw-assets']:RequestAnimationDict('anim@heists@keycard@')
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(PlayerPedId())
end

function StartInsideLoop()
    Citizen.CreateThread(function()
        while IsInside do
            local MyCoords = GetEntityCoords(PlayerPedId())
            local HouseCoords = vector3(CurrentHouse.Coords.x, CurrentHouse.Coords.y, -100.0)

            local ExitCoords = vector3(HouseCoords.x + HouseOffsets.Exit.x, HouseCoords.y + HouseOffsets.Exit.y, HouseCoords.z + HouseOffsets.Exit.z + 1.0)
            if #(MyCoords - ExitCoords) <= 1.0 then
                DrawText3D(ExitCoords, "~g~[E]~s~ Verlaten")

                if IsControlJustReleased(0, 38) then
                    TriggerEvent('fw-housing:Client:LeaveHouse', false)
                end
            end

            if CurrentHouse.Locations.BackdoorOut and CurrentHouse.Locations.BackdoorIn then
                local BackdoorCoords = vector3(CurrentHouse.Locations.BackdoorIn.x, CurrentHouse.Locations.BackdoorIn.y, CurrentHouse.Locations.BackdoorIn.z)
                if #(MyCoords - BackdoorCoords) <= 1.0 then
                    DrawText3D(BackdoorCoords, "~g~[E]~s~ Verlaat via Achterdeur")
    
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('fw-housing:Client:LeaveHouse', true)
                    end
                end
            end

            if CurrentHouse.Locations.Stash then
                local StashCoords = CurrentHouse.Locations.Stash

                if #(MyCoords - StashCoords) <= 1.0 then
                    DrawText3D(StashCoords, "~g~[E]~s~ Opslag")
                    
                    if IsControlJustReleased(0, 38) then
                        local IsLockdown = CurrentHouse.Owned and (exports['fw-cityhall']:IsLockdownActive("housing-" .. CurrentHouse.Owner) or exports['fw-cityhall']:IsLockdownActive("housing-" .. CurrentHouse.DbId))
                        local PlayerData = FW.Functions.GetPlayerData()

                        if IsLockdown and PlayerData.job.name ~= "police" and PlayerData.job.name ~= "judge" then
                            FW.Functions.Notify("Huis is in lockdown!", "error")
                        else
                            local InventoryData = Config.InventoryData[Config.TierToModel[CurrentHouse.Tier]]
                            TriggerEvent("fw-misc:Client:PlaySound", 'general.stashOpen')
                            FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'housing-' .. CurrentHouse.Name, InventoryData.Slots, InventoryData.Weight)
                        end
                    end
                elseif #(MyCoords - StashCoords) <= 3.0 then
                    DrawText3D(StashCoords, "Opslag")
                end
            end

            if CurrentHouse.Locations.Wardrobe then
                local WardrobeCoords = CurrentHouse.Locations.Wardrobe

                if #(MyCoords - WardrobeCoords) <= 1.0 then
                    DrawText3D(WardrobeCoords, "~g~[E]~s~ Kledingkast / ~g~[G]~s~ Slapen")

                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('fw-clothes:Client:OpenOutfits', true)
                    end

                    if IsControlJustPressed(0, 47) then
                        TriggerEvent('fw-housing:Client:LeaveHouse', false)
                        Citizen.SetTimeout(500, function()
                            TriggerServerEvent('fw-apartments:Server:Logout')
                        end)
                    end
                elseif #(MyCoords - WardrobeCoords) <= 3.0 then
                    DrawText3D(WardrobeCoords, "Kledingkast / Slapen")
                end
            end

            Citizen.Wait(4)
        end
    end)
end

function DrawText3D(Coords, Text)
    local OnScreen, _X, _Y = World3dToScreen2d(Coords.x, Coords.y, Coords.z)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(Text)
    DrawText(_X, _Y)
    local Factor = (string.len(Text)) / 370
    DrawRect(_X, _Y + 0.0125, 0.015 + Factor, 0.03, 41, 11, 41, 68)
end

function HasOverdueDebts(Adress)
	local Debts = FW.SendCallback("fw-misc:Server:GetOverdueDebts", "Maintenance", "Housing")
	for k, v in pairs(Debts) do
		if json.decode(v.debt_data).Name == Adress then
			return true
		end
	end
	return false
end

function _RequestModel(Model)
    if not IsModelValid(Model) then
        return print("^1ERROR: Failed to load '" .. Model .. "' model!")
    end

    RequestModel(Model)
    local Attempts = 0
    while Attempts < 100 and not HasModelLoaded(Model) do
        Attempts = Attempts + 1
        Citizen.Wait(100)
    end

    if not HasModelLoaded(Model) then
        print("^1ERROR: Failed to load '" .. Model .. "' model!")
    end

    return true
end

function LoadInteriorDecorations(Decorations)
    print("Loading decorations", #Decorations)
    print(json.encode(Decorations))
    for k, v in pairs(Decorations) do
        if _RequestModel(v.Model) then
            local DecorId = #HouseDecorations + 1
            HouseDecorations[DecorId] = CreateObjectNoOffset(v.Model, v.Coords.x, v.Coords.y, v.Coords.z, false, false, false, true, true)
            SetEntityRotation(HouseDecorations[DecorId], v.Rot.x, v.Rot.y, v.Rot.z, 0, true)
            FreezeEntityPosition(HouseDecorations[DecorId], true)
        else
            print("FAILED TO SPAWN MODEL: " .. v.Model, "DATA: " .. json.encode(v))
        end
    end
end

function UnloadInteriorDecorations()
    for k, v in pairs(HouseDecorations) do
        DeleteEntity(v)
    end

    HouseDecorations = {}
end

-- Events
RegisterNetEvent("fw-housing:Client:LockProperty")
AddEventHandler("fw-housing:Client:LockProperty", function(HouseId, IsDetcord)
    local House = CurrentHouse
    if House == nil then House = Config.Houses[HouseId] end

    if House.Locked and not IsDetcord and not HasKeyToCurrent() then return end
    if not IsDetcord and HasOverdueDebts(House.Adress) then
        TriggerServerEvent("fw-phone:Server:Mails:AddMail", "De Staat van Los Santos", "Kennisgeving van inbeslagname", "U heeft twee of meer onderhoudskosten openstaan voor deze woning. Als deze niet worden afbetaald, kan dit leiden tot permanente inbeslagname van eigendom aan de staat van Los Santos. Zodra openstaande onderhoudskosten zijn betaald, worden uw sleutels aan u en uw huurders geretourneerd.")
        return
    end

    FW.Functions.TriggerCallback("fw-housing:Server:LockProperty", function(HasLocked)
        if HasLocked then
            FW.Functions.Notify(("Huis %s."):format(House.Locked and "ontgrendeld" or "vergrendeld"), House.Locked and "success" or "error")
        end
    end, House.Id, IsDetcord)
end)

RegisterNetEvent("fw-housing:Client:EnterProperty")
AddEventHandler("fw-housing:Client:EnterProperty", function(HouseId, Forced)
    if HouseId and Config.Houses[HouseId] then
        CurrentHouse = Config.Houses[HouseId]
    end

    if CurrentHouse == nil then
        return
    end

    if not Forced and CurrentHouse.Locked then return end

    local Coords = GetEntityCoords(PlayerPedId())

    if not CurrentHouse.Tier then
        return FW.Functions.Notify("Huis heeft nog geen tier..", "error")
    end

    if not CurrentHouse.Owned and not CanRealtor() then
        return FW.Functions.Notify("Jij kan hier niet naar binnen..", "error")
    end

    local IsLockdown = CurrentHouse.Owned and (exports['fw-cityhall']:IsLockdownActive("housing-" .. CurrentHouse.Owner) or exports['fw-cityhall']:IsLockdownActive("housing-" .. CurrentHouse.DbId))
    local PlayerData = FW.Functions.GetPlayerData()

    if IsLockdown and PlayerData.job.name ~= "police" and PlayerData.job.name ~= "judge" then
        return FW.Functions.Notify("Huis is in lockdown!", "error")
    end

    local IsBackdoor = false
    if CurrentHouse.Locations.BackdoorOut and CurrentHouse.Locations.BackdoorIn and #(Coords - vector3(CurrentHouse.Locations.BackdoorOut.x, CurrentHouse.Locations.BackdoorOut.y, CurrentHouse.Locations.BackdoorOut.z)) <= 1.0 then
        IsBackdoor = true
    end
    IsInside = true

    if CurrentHouse.Tier ~= 15 then
        TriggerEvent("fw-misc:Client:PlaySound", 'general.doorOpen')
    end

    local HouseCoords = vector3(CurrentHouse.Coords.x, CurrentHouse.Coords.y, -100.0)
    local Interior = exports['fw-interiors']:CreateInterior(Config.TierToModel[CurrentHouse.Tier], HouseCoords, false)
    HouseObject, HouseOffsets = Interior[1], Interior[2]
    
    OpenDoorAnim()
    Citizen.Wait(350)
    StartInsideLoop()
    LoadInteriorDecorations(CurrentHouse.Decorations)

    exports['fw-sync']:SetClientSync(false)
    if CurrentHouse.Tier ~= 15 then
        TriggerEvent("fw-misc:Client:PlaySound", 'general.doorClose')
    else
        Citizen.SetTimeout(100, function()
            TriggerEvent("fw-misc:Client:PlaySoundCoords", 'general.elevator', GetEntityCoords(PlayerPedId()), 25.0, true)
        end)
    end
    
    if IsBackdoor then
        SetEntityCoords(PlayerPedId(), CurrentHouse.Locations.BackdoorIn.x, CurrentHouse.Locations.BackdoorIn.y, CurrentHouse.Locations.BackdoorIn.z)
        SetEntityHeading(PlayerPedId(), CurrentHouse.Locations.BackdoorIn.w)
    else
        SetEntityCoords(PlayerPedId(), HouseCoords.x + HouseOffsets.Exit.x, HouseCoords.y + HouseOffsets.Exit.y, HouseCoords.z + HouseOffsets.Exit.z)
        SetEntityHeading(PlayerPedId(), HouseOffsets.Exit.h)
    end
    SetGameplayCamRelativeHeading(0.0)
end)

RegisterNetEvent("fw-housing:Client:LeaveHouse")
AddEventHandler("fw-housing:Client:LeaveHouse", function(IsBackdoor)
    if CurrentHouse == nil then return end
    local Coords = GetEntityCoords(PlayerPedId())

    if CurrentHouse.Tier ~= 15 then
        TriggerEvent("fw-misc:Client:PlaySound", 'general.doorOpen')
    end

    OpenDoorAnim()
    Citizen.Wait(350)
    exports['fw-sync']:SetClientSync(true)

    if CurrentHouse.Tier ~= 15 then
        TriggerEvent("fw-misc:Client:PlaySound", 'general.doorClose')
    else
        Citizen.SetTimeout(100, function()
            TriggerEvent("fw-misc:Client:PlaySoundCoords", 'general.elevator', GetEntityCoords(PlayerPedId()), 25.0, true)
        end)
    end
    
    if IsBackdoor then
        SetEntityCoords(PlayerPedId(), CurrentHouse.Locations.BackdoorOut.x, CurrentHouse.Locations.BackdoorOut.y, CurrentHouse.Locations.BackdoorOut.z)
        SetEntityHeading(PlayerPedId(), CurrentHouse.Locations.BackdoorOut.w)
    else
        SetEntityCoords(PlayerPedId(), CurrentHouse.Coords.x, CurrentHouse.Coords.y, CurrentHouse.Coords.z)
        SetEntityHeading(PlayerPedId(), CurrentHouse.Coords.w)
    end
    SetGameplayCamRelativeHeading(0.0)
    UnloadInteriorDecorations()
    IsInside = false

    exports['fw-interiors']:DespawnInteriors()
    HouseObject, HouseOffsets = false, {}
end)

RegisterNetEvent("fw-housing:Client:OpenFurniture")
AddEventHandler("fw-housing:Client:OpenFurniture", function(HouseId)
    TriggerEvent('fw-editor:Client:SetState', true, HouseDecorations)
end)