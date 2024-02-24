FW, LoggedIn = exports['fw-core']:GetCoreObject(), false
CurrentCops, ShowingInteraction = 0, false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Citizen.SetTimeout(1000, function()
        LoggedIn = true
        InitBeehives()
        InitTea()
    end)
end)

RegisterNetEvent('fw-police:SetCopCount')
AddEventHandler('fw-police:SetCopCount', function(Amount)
    CurrentCops = Amount
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

Citizen.CreateThread(function()
    while true do

        local hasWeapon, CurrentWeapon = GetCurrentPedWeapon(PlayerPedId())
        if CurrentWeapon == GetHashKey("weapon_nightstick") then
            SetRelationshipBetweenGroups(2, "PLAYER", "PLAYER")
        else
            SetRelationshipBetweenGroups(1, "PLAYER", "PLAYER")
        end

        Citizen.Wait(0)
    end
end)

local PickingUpSnow = false
FW.AddKeybind("pickupSnowball", 'Wereld', 'Sneeuwbal maken', '', function(IsPressed)
    if not IsPressed or PickingUpSnow then return end
    if not exports['fw-sync']:SnowActive() then return end

    PickingUpSnow = true
    exports['fw-assets']:RequestAnimationDict('anim@mp_snowball')
    TaskPlayAnim(PlayerPedId(), 'anim@mp_snowball', 'pickup_snowball', 8.0, -1, -1, 0, 1, 0, 0, 0)
    Citizen.Wait(1950)

    local HasLauncher = exports['fw-inventory']:HasEnoughOfItem("weapon_snowballlauncher", 1)

    FW.TriggerServer("FW:AddItem", HasLauncher and "ammo" or "weapon_snowball", 1, false, false, true, HasLauncher and "Snowball" or false)
    PickingUpSnow = false
end)

RegisterNetEvent("esx:getSharedObject")
AddEventHandler("esx:getSharedObject", function()
    FW.TriggerServer("fw-misc:Server:ExploiterAlert", "esx", "started")
end)

RegisterNetEvent("QBCore:GetObject")
AddEventHandler("QBCore:GetObject", function()
    FW.TriggerServer("fw-misc:Server:ExploiterAlert", "qbcore", "started")
end)

AddEventHandler("onClientResourceStart", function(resourceName)
    FW.TriggerServer("fw-misc:Server:ExploiterAlert", resourceName, "started")
end)

AddEventHandler("onClientResourceStop", function(resourceName)
    FW.TriggerServer("fw-misc:Server:ExploiterAlert", resourceName, "stopped")
end)

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    local Coords = FW.SendCallback("fw-misc:Server:GetIllegalSellsCoords")
    exports['fw-ui']:AddEyeEntry("illegal-sells", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.5,
        Position = Coords,
        Model = 'g_m_y_salvagoon_02',
        Options = {
            {
                Name = "sell_illegal",
                Icon = "fas fa-dollar-sign",
                Label = "Verkoop Iets",
                EventType = "Client",
                EventName = "fw-misc:Client:SellSomething",
                EventParams = {},
                Enabled = function()
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry(GetHashKey("prop_toolchest_05"), {
        Type = 'Model',
        Model = "prop_toolchest_05",
        SpriteDistance = 10.0,
        Distance = 2.0,
        Options = {
            {
                Name = "open_crafting",
                Label = "Craften",
                EventType = "Client",
                EventName = "fw-misc:Client:OpenCrafting",
                EventParams = {},
                Enabled = function(Entity)
                    local ToolchestCoords = GetEntityCoords(Entity)
                    for k, v in pairs(Config.DisabledToolchests) do
                        if #(v - ToolchestCoords) < 3.0 then
                            return false
                        end
                    end

                    return true
                end,
            }
        }
    })

    local WeaponBenchCoords = FW.SendCallback("fw-heists:Server:GetPedCoords", "WeaponBench")
    exports['PolyZone']:CreateBox({
        center = WeaponBenchCoords,
        length = 1.8,
        width = 1.0,
    }, {
        name = "",
        heading = 316,
        minZ = 30.87,
        maxZ = 33.07,
        debugPoly = false,
    }, function(IsInside, Zone, Points)
        if not IsInside then
            ShowingInteraction = falser
            return
        end

        if not IsContainerWhitelisted() then
            return
        end

        ShowingInteraction = true
        exports['fw-ui']:ShowInteraction("[E] Craft")

        Citizen.CreateThread(function()
            while ShowingInteraction do
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('fw-misc:Client:OpenIllegalBench')
                end

                Citizen.Wait(4)
            end
            exports['fw-ui']:HideInteraction()
        end)
    end)

    local WeaponPartsCoords = FW.SendCallback("fw-heists:Server:GetPedCoords", "WeaponParts")
    exports['fw-ui']:AddEyeEntry("weaponparts", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 2.5,
        Position = WeaponPartsCoords,
        Model = 'g_m_y_korean_02',
        Options = {
            {
                Name = "talk",
                Icon = "fas fa-comment",
                Label = "Praten",
                EventType = "Client",
                EventName = "fw-misc:Client:TalkToWeaponDealer",
                EventParams = {},
                Enabled = function()
                    return true
                end,
            }
        }
    })
end)

RegisterNetEvent('fw-misc:Server:StealShoes')
AddEventHandler('fw-misc:Server:StealShoes', function()
    local Player, Distance = FW.Functions.GetClosestPlayer()
    if Player ~= -1 and Distance < 2.0 then
        exports['fw-assets']:RequestAnimationDict("random@domestic")
        TaskPlayAnim(PlayerPedId(), 'random@domestic', 'pickup_low',5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
        Citizen.Wait(1600)
        ClearPedTasks(PlayerPedId())
        TriggerServerEvent('fw-clothes:Server:StealShoes', Player)
    end
end)

RegisterNetEvent("fw-misc:Client:OpenCrafting")
AddEventHandler("fw-misc:Client:OpenCrafting", function()
    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'General')
    end
end)

RegisterNetEvent("fw-misc:Client:OpenIllegalBench")
AddEventHandler("fw-misc:Client:OpenIllegalBench", function()
    if exports['fw-inventory']:CanOpenInventory() and IsContainerWhitelisted() then

        local GetCraftingName = FW.SendCallback("fw-laptop:Server:Unknown:GetCraftingName")
        if not GetCraftingName then
            return FW.Functions.Notify("Je groep is nog niet bekend genoeg..", "error")
        end

        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'Illegal' .. GetCraftingName)
    end
end)

RegisterNetEvent("fw-misc:Client:SellSomething")
AddEventHandler("fw-misc:Client:SellSomething", function(Data, Entity)
    local AlreadySold = FW.SendCallback("fw-misc:Server:CanSellIllegal")
    if AlreadySold then
        return FW.Functions.Notify("Je hebt al iets verkocht.. Kom later terug..", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(15000, "Aan het verkopen, niet bewegen..", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    if not Finished then
        return
    end

    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(Entity)) > 2.0 then
        return FW.Functions.Notify("Je bent te ver weg idioot..", "error")
    end

    TriggerServerEvent("fw-misc:Server:SellSomething")
end)

local IsSwimmingBuff = false

RegisterNetEvent("fw-hud:Client:ApplyBuff")
AddEventHandler("fw-hud:Client:ApplyBuff", function(BuffId, Percentage)
    if BuffId ~= 'Swimming' then return end

    local RechargeRate = 30000 + (60000 * (1 - (Percentage / 100)))
    if IsSwimmingBuff then return end
    IsSwimmingBuff = true

    local RestorationCount = 0
    Citizen.CreateThread(function()
        while CurrentBuffs['Swimming'] do

            if IsPedSwimming(PlayerPedId()) then
                local CurrentStamina = (100 - GetPlayerSprintStaminaRemaining(PlayerId()))
    
                if CurrentStamina < 34 and RestorationCount < 1 then
                    RestorationCount = RestorationCount + 1
                    RestorePlayerStamina(PlayerId(), 1.0)
                end
    
                if RestorationCount > 0 then
                    Citizen.Wait(RechargeRate)
                    RestorationCount = 0
                end
            end

            Citizen.Wait(1000)
        end

        IsSwimmingBuff = false
    end)
end)

RegisterNetEvent("FW:Underwater:OnThreadChange")
AddEventHandler("FW:Underwater:OnThreadChange", function(Value)
    IsUnderwater = Value
    if not IsUnderwater then return end

    local OxygenHudId = exports['fw-hud']:GetHudId('Oxygen')
    exports['fw-hud']:SetHudData(OxygenHudId, 'Show', true)
    local LastHudValue = 100

    Citizen.CreateThread(function()
        while IsUnderwater do
            local NewHudValue = math.floor(10 * GetPlayerUnderwaterTimeRemaining(PlayerId()))
            if LastHudValue ~= NewHudValue then
                LastHudValue = NewHudValue
                exports['fw-hud']:SetHudValue(OxygenHudId, NewHudValue)
            end
            Citizen.Wait(4)
        end

        for i = 1, math.floor((100 - LastHudValue) / 10), 1 do
            if IsUnderwater then break end
            LastHudValue = LastHudValue + 10
            exports['fw-hud']:SetHudValue(OxygenHudId, LastHudValue)
            Citizen.Wait(400)
        end

        if IsUnderwater then return end
        exports['fw-hud']:SetHudValue(OxygenHudId, 100)
        Citizen.SetTimeout(1000, function()
            exports['fw-hud']:SetHudData(OxygenHudId, 'Show', false)
        end)
    end)
end)

RegisterNetEvent("fw-misc:Client:TalkToWeaponDealer")
AddEventHandler("fw-misc:Client:TalkToWeaponDealer", function()
    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    if not Gang or not next(Gang) then
        return FW.Functions.Notify("Kijkt je verward aan..", "error")
    end

    local MenuItems = {}
    local Prices = FW.SendCallback("fw-misc:Server:GetWeaponBodyPrices")

    MenuItems[#MenuItems + 1] = {
        Icon = 'info-circle',
        Title = "Wat zou je willen kopen?",
    }

    MenuItems[#MenuItems + 1] = {
        Title = "<div style='display: flex; justify-content: space-between;'><span>Rifle Body 1x</span><span>€" .. Prices.Rifle .. "</span></div>",
        Data = { Event = 'fw-misc:Client:PurchaseWeaponBody', Type = 'Client', BodyType = "Rifle" },
        -- Disabled = true,
    }
    MenuItems[#MenuItems + 1] = {
        Title = "<div style='display: flex; justify-content: space-between;'><span>SMG Body 1x</span><span>€" .. Prices.Smg .. "</span></div>",
        Data = { Event = 'fw-misc:Client:PurchaseWeaponBody', Type = 'Client', BodyType = "Smg" },
        -- Disabled = true,
    }
    MenuItems[#MenuItems + 1] = {
        Title = "<div style='display: flex; justify-content: space-between;'><span>Pistool Onderdelen 1x</span><span>€" .. Prices.Pistol .. "</span></div>",
        Data = { Event = 'fw-misc:Client:PurchaseWeaponBody', Type = 'Client', BodyType = "Pistol" },
    }
    MenuItems[#MenuItems + 1] = {
        Title = "<div style='display: flex; justify-content: space-between;'><span>Shotgun Body 1x</span><span>€" .. Prices.Shotgun .. "</span></div>",
        Data = { Event = 'fw-misc:Client:PurchaseWeaponBody', Type = 'Client', BodyType = "Shotgun" },
    }

    FW.Functions.OpenMenu({MainMenuItems = MenuItems})
end)

RegisterNetEvent("fw-misc:Client:PurchaseWeaponBody")
AddEventHandler("fw-misc:Client:PurchaseWeaponBody", function(Data)
    Citizen.Wait(100)
    local Result = exports['fw-ui']:CreateInput({
        { Label = 'Aantal', Name = 'Amount', Type = 'Number' }
    })

    if not Result or not tonumber(Result.Amount) then
        return FW.Functions.Notify("Ongeldig aantal..", "error")
    end

    FW.TriggerServer('fw-misc:Server:PurchaseWeaponBody', Data.BodyType, tonumber(Result.Amount))
end)

function IsContainerWhitelisted()
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name == "police" and PlayerData.job.onduty then
        return true
    end

    local Cid = PlayerData.citizenid
    for k, v in pairs(Config.ContainerBlacklist) do
        if Cid == v then return false end
    end

    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    return Gang and Gang.Id
end
exports("IsContainerWhitelisted", IsContainerWhitelisted)

function HasHousingOverdueDebts(HouseName)
	local Debts = FW.SendCallback("fw-misc:Server:GetOverdueDebts", "Maintenance", "Housing")
	for k, v in pairs(Debts) do
		if json.decode(v.debt_data).Name == HouseName then
			return true
		end
	end
	return false
end