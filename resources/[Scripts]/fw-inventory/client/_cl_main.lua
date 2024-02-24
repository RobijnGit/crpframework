FW = exports['fw-core']:GetCoreObject()

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

RegisterNetEvent("fw-ui:Client:refresh")
AddEventHandler("fw-ui:Client:refresh", function()
    -- Close Inventory
end)

RegisterNUICallback("LoadInventory", function(Data, Cb)
    -- Calculate Items with Tax.
    for k, v in pairs(Shared.Items) do
        if v.Price and v.Price > 0 then
            v.Price = FW.Shared.CalculateTax('Goods', v.Price)
        end
    end

    -- Request CustomTypes
    Shared.CustomTypes = FW.SendCallback("fw-inventory:Server:GetCustomTypes")

    -- Send all to UI.
    SendNUIMessage({
        Action = "SetItemsList",
        Items = Shared.Items,
        CustomTypes = Shared.CustomTypes
    })

    Cb("Ok")
end)

-- Code

IsInventoryBusy, HotbarCooldown, CurrentInventory, CurrentDropId = false, false, false, false

exports("CanOpenInventory", function()
    return not IsInventoryBusy
end)

exports("SetBusyState", function(Bool)
    IsInventoryBusy = Bool  
end)

Citizen.CreateThread(function()
    while true do
        DisableControlAction(0, 37, true)
        DisableControlAction(0, 157, true)
        DisableControlAction(0, 158, true)
        DisableControlAction(0, 160, true)
        DisableControlAction(0, 164, true)
        DisableControlAction(0, 165, true)

        local CanUseItem = not IsInventoryBusy
        if CanUseItem and IsDisabledControlJustReleased(0, 157) then -- Slot 1
            if not HotbarCooldown and not FW.Functions.GetPlayerData().metadata.isdead and not FW.Functions.GetPlayerData().metadata.ishandcuffed then
                FW.TriggerServer('fw-inventory:Server:UseItem', 1)
                HotbarCooldown = true
                Citizen.SetTimeout(350, function() HotbarCooldown = false end)
            end
        end

        if CanUseItem and IsDisabledControlJustReleased(0, 158) then -- Slot 2
            if not HotbarCooldown and not FW.Functions.GetPlayerData().metadata.isdead and not FW.Functions.GetPlayerData().metadata.ishandcuffed then
                FW.TriggerServer('fw-inventory:Server:UseItem', 2)
                HotbarCooldown = true
                Citizen.SetTimeout(350, function() HotbarCooldown = false end)
            end
        end

        if CanUseItem and IsDisabledControlJustReleased(0, 160) then -- Slot 3
            if not HotbarCooldown and not FW.Functions.GetPlayerData().metadata.isdead and not FW.Functions.GetPlayerData().metadata.ishandcuffed then
                FW.TriggerServer('fw-inventory:Server:UseItem', 3)
                HotbarCooldown = true
                Citizen.SetTimeout(350, function() HotbarCooldown = false end)
            end
        end

        if CanUseItem and IsDisabledControlJustReleased(0, 164) then -- Slot 4
            if not HotbarCooldown and not FW.Functions.GetPlayerData().metadata.isdead and not FW.Functions.GetPlayerData().metadata.ishandcuffed then
                FW.TriggerServer('fw-inventory:Server:UseItem', 4)
                HotbarCooldown = true
                Citizen.SetTimeout(350, function() HotbarCooldown = false end)
            end
        end

        if CanUseItem and IsDisabledControlJustReleased(0, 165) then -- Slot 5
            if not HotbarCooldown and not FW.Functions.GetPlayerData().metadata.isdead and not FW.Functions.GetPlayerData().metadata.ishandcuffed then
                FW.TriggerServer('fw-inventory:Server:UseItem', 5)
                HotbarCooldown = true
                Citizen.SetTimeout(350, function() HotbarCooldown = false end)
            end
        end

        local ClosestDropId, ClosestDropDistance = 0, 10.0
        local PlyPos = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Drops) do
            if v.ItemCount > 0 then
                DrawMarker(20, v.Coords.x, v.Coords.y, v.Coords.z - 0.8, 0, 0, 0, 0.0, 0, 0.0, 0.3, 0.4, 0.15, 252, 255, 255, 91, 0, 0, 0, 0)
            end

            if #(PlyPos - v.Coords) < ClosestDropDistance then
                ClosestDropId, ClosestDropDistance = k, #(PlyPos - v.Coords)
            end
        end

        if ClosestDropDistance < 2.0 then
            CurrentDropId = ClosestDropId
        else
            CurrentDropId = false
        end

        Citizen.Wait(4)
    end
end)

FW.AddKeybind("openInventory", 'Inventory', 'Openen', 'Tab', function(IsPressed)
    if not IsPressed then return end
    if HotbarCooldown then return end
    if IsInventoryBusy then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData == nil then return end
    if PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] then return end

    local InVehicle, Plate, Vehicle = CheckVehicle()
    local NearContainer, Container = CheckContainer()

    -- InvType = Inventory Label/Type
    -- InvName = Inventory
    local InvType, InvName = 'Drop', false
    local MaxSlots, MaxWeight = 40, 250.0

    if Plate and not InVehicle then
        InvType = 'Glovebox'
        InvName = 'glovebox' .. GetVehicleNumberPlateText(Vehicle)
        MaxSlots, MaxWeight = 5, 70.0
    elseif Plate and InVehicle and GetVehicleClass(Vehicle) ~= 8 then
        InvType = 'Trunk'
        InvName = 'trunk' .. GetVehicleNumberPlateText(Vehicle)
        MaxSlots, MaxWeight = 65, GetVehicleTrunkWeight(Vehicle)
    elseif NearContainer then
        local ContainerPos = GetEntityCoords(Container)
        InvType = 'Robijn zijn Leven'
        InvName = 'HiddenContainer-' .. math.floor(ContainerPos.x) .. '/' .. math.floor(ContainerPos.y)
        MaxSlots, MaxWeight = 200, 2000.0
    elseif CurrentDropId then
        InvName = 'Drop-' .. CurrentDropId
    end

    FW.TriggerServer('fw-inventory:Server:OpenInventory', InvType, InvName, MaxSlots, MaxWeight)
end)

FW.AddKeybind("showActionbar", 'Inventory', 'Hotbar', 'Z', function(IsPressed)
    if IsPressed then
        TriggerEvent("fw-hud:Client:ShowCash")
        SendNUIMessage({
            Action = "InventoryHotbar",
            Visible = true,
            Items = FW.Functions.GetPlayerData().inventory
        })
    else
        SendNUIMessage({
            Action = "InventoryHotbar",
            Visible = false,
        })
    end
end)

-- Events
-- RegisterNetEvent("fw-inventory:Client:RefreshCustomTypes")
-- AddEventHandler("fw-inventory:Client:RefreshCustomTypes", function(CustomTypes)
--     Shared.CustomTypes = CustomTypes
--     SendNUIMessage({
--         Action = "SetCustomTypes",
--         CustomTypes = CustomTypes
--     })
-- end)

RegisterNetEvent("fw-inventory:Client:LoadInventory")
AddEventHandler("fw-inventory:Client:LoadInventory", function(OtherData)
    local PlayerData = FW.Functions.GetPlayerData()

    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)

    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)

    local PlyInventory = PlayerData.inventory
    -- local PlyInventory = FW.SendCallback("fw-inventory:Server:GetPlyItems") -- To test live requests, if it starts lagging again, revert this.

    SendNUIMessage({
        Action = "OpenInventory",
        Inventory = PlyInventory,
        OtherData = OtherData,
        HasLicense = PlayerData.metadata.licenses.weapon
    })

    CurrentInventory = OtherData

    if OtherData.Type == 'Trunk' then
        DoTrunkAnimation()
    elseif string.find(OtherData.Name, "Container") then
        DoContainerAnimation()
    else
        DoPickupAnimation()
    end
end)

RegisterNetEvent("fw-inventory:Client:OpenTrunk")
AddEventHandler("fw-inventory:Client:OpenTrunk", function(Data, Entity)
    if HotbarCooldown then return end
    if IsInventoryBusy then return end

    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData == nil then return end
    if PlayerData.metadata['isdead'] or PlayerData.metadata['ishandcuffed'] then return end

    local InvType, InvName = 'Trunk', 'trunk' .. GetVehicleNumberPlateText(Entity)
    local MaxSlots, MaxWeight = 65, GetVehicleTrunkWeight(Entity)

    FW.TriggerServer('fw-inventory:Server:OpenInventory', InvType, InvName, MaxSlots, MaxWeight)
end)

RegisterNetEvent("fw-inventory:Client:UpdateInvSlot")
AddEventHandler("fw-inventory:Client:UpdateInvSlot", function(Slot)
    if not CurrentInventory then
        return
    end

    SendNUIMessage({
        Action = "UpdateSlot",
        SlotId = Slot,
        Data = FW.Functions.GetPlayerData().inventory[Slot]
    })
end)

RegisterNetEvent('fw-inventory:Client:ShowActionBox')
AddEventHandler("fw-inventory:Client:ShowActionBox", function(Text, Item, Amount, CustomType)
    SendNUIMessage({
        Action = "InventoryBox",
        Text = Text,
        Item = Item,
        Amount = Amount,
        CustomType = CustomType,
    })
end)

RegisterNetEvent("fw-inventory:Client:SetDropData")
AddEventHandler("fw-inventory:Client:SetDropData", function(DropId, Data)
    Config.Drops[DropId] = Data
end)

RegisterNetEvent("fw-inventory:Client:SetDropItemCount")
AddEventHandler("fw-inventory:Client:SetDropItemCount", function(DropId, ItemCount)
    if Config.Drops[DropId] ~= nil then
        Config.Drops[DropId].ItemCount = ItemCount
    end
end)

RegisterNetEvent('fw-inventory:Client:UseWeapon')
AddEventHandler('fw-inventory:Client:UseWeapon', function(ItemData)
    local WeaponName, Ammo = ItemData.Item, ItemData.Info.Ammo or 0
    local CurrentWeapon = GetSelectedPedWeapon(PlayerPedId())

    if string.find(ItemData.Info.Serial, "arcadetdm-") and not exports['fw-arcade']:IsInTDM() then
        return
    end

    if GetHashKey(WeaponName) == CurrentWeapon then
        TriggerEvent('fw-inventory:Client:ShowActionBox', 'Gebruikt', WeaponName, 1)
        local HolsterDict, HolsterAnim, AnimWait = "reaction@intimidation@1h", "outro", (GetAnimDuration("reaction@intimidation@1h", "outro") * 1000) - 2200
        local JobName = FW.Functions.GetPlayerData().job.name
        if (JobName == 'police' or JobName == 'storesecurity' or JobName == 'doc') and FW.Functions.GetPlayerData().job.onduty then
            HolsterDict, HolsterAnim, AnimWait = "reaction@intimidation@cop@unarmed", "intro", 600
        end

        RequestAnimDict(HolsterDict)
        while not HasAnimDictLoaded(HolsterDict) do Citizen.Wait(10) end

        TaskPlayAnim(PlayerPedId(), HolsterDict, HolsterAnim, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
        Citizen.Wait(AnimWait)
        StopAnimTask(PlayerPedId(), HolsterDict, HolsterAnim, 1.0)

        TriggerEvent('fw-weapons:Client:SetWeaponData', false)

        NetworkSetFriendlyFireOption(true)
        RemoveAllPedWeapons(PlayerPedId(), true)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        TriggerEvent('fw-assets:Client:Attach:Items')
        return
    end

    if WeaponName == "weapon_huntingrifle" and not exports['fw-jobmanager'].InsideHuntingZone() then return end

    TriggerEvent('fw-inventory:Client:ShowActionBox', 'Gebruikt', WeaponName, 1)
    local HolsterDict, HolsterAnim, AnimWait = "reaction@intimidation@1h", "intro", 900
    local JobName = FW.Functions.GetPlayerData().job.name
    if (JobName == 'police' or JobName == 'storesecurity' or JobName == 'doc') and FW.Functions.GetPlayerData().job.onduty then
        HolsterDict, HolsterAnim, AnimWait = "reaction@intimidation@cop@unarmed", "intro", 600
    end

    RequestAnimDict(HolsterDict)
    while not HasAnimDictLoaded(HolsterDict) do Citizen.Wait(10) end

    TaskPlayAnim(PlayerPedId(), HolsterDict, HolsterAnim, 1.0, 1.0, -1, 50, 0, 0, 0, 0)
    Citizen.Wait(AnimWait)
    StopAnimTask(PlayerPedId(), HolsterDict, HolsterAnim, 1.0)

    if Config.Throwables[GetHashKey(WeaponName)] then Ammo = 1 end

    GiveWeaponToPed(PlayerPedId(), GetHashKey(WeaponName), Ammo, false, false)
    SetPedAmmo(PlayerPedId(), GetHashKey(WeaponName), Ammo)
    SetCurrentPedWeapon(PlayerPedId(), GetHashKey(WeaponName), true)

    if WeaponName == 'weapon_m4' then
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(WeaponName), GetHashKey('COMPONENT_AT_AR_FLSH_REH'))
    elseif WeaponName == 'weapon_glock' then
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(WeaponName), GetHashKey('COMPONENT_AT_PI_FLSH'))
    elseif WeaponName == 'weapon_fn57' then
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(WeaponName), GetHashKey('COMPONENT_AT_PI_FLSH_02'))
    elseif WeaponName == 'weapon_rubberslug' then
        SetPedWeaponTintIndex(PlayerPedId(), GetHashKey(WeaponName), 6)
    end

    local HasOldSilencer = HasEnoughOfItem('silencer_oilcan', 1)
    if Config.Attachments['silencer_oilcan'][WeaponName] and HasOldSilencer then
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(WeaponName), GetHashKey(Config.Attachments['silencer_oilcan'][WeaponName]))
    end

    local HasNewSilencer = HasEnoughOfItem('silencer', 1)
    if Config.Attachments['silencer'][WeaponName] and HasNewSilencer then
        GiveWeaponComponentToPed(PlayerPedId(), GetHashKey(WeaponName), GetHashKey(Config.Attachments['silencer'][WeaponName]))
    end

    if WeaponName == 'weapon_huntingrifle' then
        NetworkSetFriendlyFireOption(false)
    else
        NetworkSetFriendlyFireOption(true)
    end

    SetWeaponsNoAutoswap(true)
    TriggerEvent('fw-weapons:Client:SetWeaponData', ItemData)
    TriggerEvent('fw-assets:Client:Attach:Items')
end)

RegisterNetEvent("fw-inventory:Client:ResetWeapon")
AddEventHandler("fw-inventory:Client:ResetWeapon", function()
    Citizen.SetTimeout(100, function()
        DisablePlayerFiring(PlayerId(), false)
        SetPlayerCanDoDriveBy(PlayerId(), true)
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
        RemoveAllPedWeapons(PlayerPedId(), true)
        TriggerEvent('fw-weapons:Client:SetWeaponData', false)

        Citizen.SetTimeout(100, function()
            TriggerEvent('fw-assets:Client:Attach:Items')
        end)
    end)
end)

RegisterNetEvent("fw-inventory:Client:CheckWeapon")
AddEventHandler("fw-inventory:Client:CheckWeapon", function(WeaponItem)
    if GetSelectedPedWeapon(PlayerPedId()) == GetHashKey(WeaponItem) then
        TriggerEvent('fw-inventory:Client:ResetWeapon')
    end

    Citizen.SetTimeout(500, function()
        TriggerEvent('fw-assets:Client:Attach:Items')
    end)
end)

-- Functions
function CloseInventory()
    FW.TriggerServer("fw-inventory:Server:UpdateInventory", CurrentInventory)
    
    SetTimecycleModifier('default')
    SetNuiFocus(false, false)
    SendNUIMessage({ Action = "CloseInventory" })
    
    CurrentInventory = false

    HotbarCooldown = true
    Citizen.SetTimeout(100, function()
        HotbarCooldown = false
    end)

    if IsEntityPlayingAnim(PlayerPedId(), 'amb@prop_human_bum_bin@idle_a', 'idle_a', 3) then
        StopAnimTask(PlayerPedId(), 'amb@prop_human_bum_bin@idle_a', 'idle_a', 1.0)
    end
    if IsEntityPlayingAnim(PlayerPedId(), 'mini@repair', 'fixing_a_player', 3) then
        StopAnimTask(PlayerPedId(), 'mini@repair', 'fixing_a_player', 1.0)
    end
    if IsEntityPlayingAnim(PlayerPedId(), 'pickup_object', 'putdown_low', 3) then
        StopAnimTask(PlayerPedId(), 'pickup_object', 'putdown_low', 1.0)
    end
end

function GetVehicleTrunkWeight(Entity)
    local VehicleClass = GetVehicleClass(Entity)
    local Min, Max = GetModelDimensions(GetEntityModel(Entity))
    local VehicleVolume = (Max.x - Min.x) * (Max.y - Min.y) * (Max.z - Min.z)
    local Seats = GetVehicleModelNumberOfSeats(GetEntityModel(Entity))

    local ClassModifier = Config.TrunkSpaces[VehicleClass][1]
    local BaseModifier = Config.TrunkSpaces[VehicleClass][2]
    local MaxModifier = Config.TrunkSpaces[VehicleClass][3]

    if BaseModifier == 0 then return end
    local VehSeatMod = (BaseModifier * Seats) / 3
    local VehicleWeightCalc = VehicleVolume * ClassModifier + VehSeatMod

    local TrunkWeight = math.ceil(VehicleWeightCalc / 50) * 50
    if TrunkWeight > MaxModifier then TrunkWeight = MaxModifier end
    return TrunkWeight
end

function CheckVehicle()
    local Hit, Pos, Entity = exports['fw-ui']:RayCastGamePlayCamera(3.5)

    if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
        local Vehicle = GetVehiclePedIsIn(PlayerPedId())
        return false, GetVehicleNumberPlateText(Vehicle), Vehicle
    elseif GetVehiclePedIsIn(PlayerPedId()) == 0 and Entity ~= 0 and GetEntityType(Entity) == 2 and GetVehicleDoorLockStatus(Entity) < 2 then
        local Coords = GetEntityCoords(PlayerPedId())
        local TrunkCoords = GetWorldPositionOfEntityBone(Entity, GetEntityBoneIndexByName(Entity, "boot"))
        if TrunkCoords == vector3(0, 0, 0) then TrunkCoords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -2.5, 0.0) end

        if Config.BackEngine[GetEntityModel(Entity)] then
            TrunkCoords = GetWorldPositionOfEntityBone(Entity, GetEntityBoneIndexByName(Entity, "bonnet"))
            if TrunkCoords == vector3(0, 0, 0) then TrunkCoords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, 2.5, 0.0) end
        end

        if #(Coords - TrunkCoords) < 1.5 then return true, GetVehicleNumberPlateText(Entity), Entity end
    end

    return false, nil, nil
end

function CheckContainer()
    local Hit, Pos, Entity = exports['fw-ui']:RayCastGamePlayCamera(3.5)

    if Entity ~= 0 and GetEntityType(Entity) == 3 then 
        if Config.Dumpsters[GetEntityModel(Entity)] then
            return true, Entity
        end
    end

    return false, nil
end

function DoContainerAnimation()
    RequestAnimDict("amb@prop_human_bum_bin@idle_a")
    while not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_a") do Citizen.Wait(4) end
    TaskPlayAnim(PlayerPedId(), 'amb@prop_human_bum_bin@idle_a', 'idle_a', 1.0, 1.0, -1, 1, 0, false, false, false)
end

function DoTrunkAnimation()
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do Citizen.Wait(4) end
    TaskPlayAnim(PlayerPedId(), 'mini@repair', 'fixing_a_player', 1.0, -1.0, -1, 16, 0, false, false, false)
end

function DoPickupAnimation()
    RequestAnimDict("pickup_object")
    while not HasAnimDictLoaded("pickup_object") do Citizen.Wait(4) end
    TaskPlayAnim(PlayerPedId(),'pickup_object', 'putdown_low', 5.0, 1.5, 1.0, 48, 0, false, false, false)
    Citizen.Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end
exports("DoPickupAnimation", DoPickupAnimation)

exports("IsThrowable", function(Hash)
    return Config.Throwables[Hash]
end)

-- NUI Callback

RegisterNUICallback("StealMoney", function(Data, Cb)
    if CurrentInventory then
        FW.TriggerServer("fw-inventory:Server:StealMoney", CurrentInventory)
    end
    Cb("Ok")
end)

RegisterNUICallback("CloseInventory", function(Data, Cb)
    CloseInventory()
    Cb("Ok")
end)

RegisterNUICallback("FetchMoney", function(Data, Cb)
    Cb(FW.Functions.GetPlayerData().money.cash)
end)

RegisterNUICallback("UseItem", function(Data, Cb)
    Citizen.SetTimeout(250, function()
        FW.TriggerServer('fw-inventory:Server:UseItem', tonumber(Data.Slot), true)
    end)

    Cb('Ok')
end)

RegisterNUICallback("CanBuyWeapon", function(Data, Cb)
    local Result = FW.SendCallback("fw-inventory:Server:CanBuyWeapon")
    Cb(Result)
end)

RegisterNUICallback("HasCraftingItems", function(Data, Cb)
    local ItemsChecked, ItemCraft = 0, Shared.Items[Data.ItemName].Craft

    -- Check if custom type is sent, if so check if it exists and has Craft property.
    if Data.CustomType and Shared.CustomTypes[Data.ItemName] and Shared.CustomTypes[Data.ItemName][Data.CustomType] and Shared.CustomTypes[Data.ItemName][Data.CustomType].Craft then
        ItemCraft = Shared.CustomTypes[Data.ItemName][Data.CustomType].Craft
    end

    for k, v in pairs(ItemCraft) do
        if HasEnoughOfItem(v.Item, (v.Amount * Data.Amount), v.CustomType) then
            ItemsChecked = ItemsChecked + 1
        end
    end

    Cb(ItemsChecked == #ItemCraft)
end)

RegisterNUICallback("IsProcessing", function(Data, Cb)
    local Result = FW.SendCallback("fw-inventory:Server:IsProcessing")
    Cb(Result)
end)

RegisterNUICallback("MoveItem", function(Data, Cb)
    FW.TriggerServer("fw-inventory:Server:DoItemMovement", "Move", Data)
    Cb("Ok")
end)

RegisterNUICallback("SwapItem", function(Data, Cb)
    FW.TriggerServer("fw-inventory:Server:DoItemMovement", "Swap", Data)
    Cb("Ok")
end)

RegisterNUICallback("InsertItem", function(Data)
    local FromItem, ToItem = Data.FromItem, Data.ToItem
    TriggerEvent("fw-inventory:Client:OnItemInsert", Data.IsReversed and ToItem or FromItem, Data.IsReversed and FromItem or ToItem)
    TriggerServerEvent("fw-inventory:Server:OnItemInsert", Data.IsReversed and ToItem or FromItem, Data.IsReversed and FromItem or ToItem)
end)