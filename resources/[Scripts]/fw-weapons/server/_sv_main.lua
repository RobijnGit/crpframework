local FW = exports['fw-core']:GetCoreObject()

-- Code

FW.Functions.CreateUsableItem("ammo", function(Source, Item)
	local Player = FW.Functions.GetPlayer(Source)
	if Player.Functions.GetItemBySlot(Item.Slot) ~= nil then
        TriggerClientEvent('fw-weapons:Client:AddAmmo', Source, Config.TypeToAmmo[Item.CustomType], Item.CustomType)
    end
end)

RegisterServerEvent("fw-weapons:Server:UpdateQuality")
AddEventHandler("fw-weapons:Server:UpdateQuality", function(Data)
    if Data == nil then return end
    if Config.DurabilityBlockedWeapons[Data.Item] then return end

    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local DecreaseChance = math.random(1, 3)
    if DecreaseChance ~= 2 then return end

    Player.Functions.DecayItem(Data.Item, Data.Slot, 0.1)
end)

RegisterServerEvent("fw-weapons:Server:UpdateWeapon")
AddEventHandler('fw-weapons:Server:UpdateWeapon', function(WeaponData, Amount)
    local Player = FW.Functions.GetPlayer(source)
    local Amount = tonumber(Amount)
    if WeaponData ~= nil then
        Player.Functions.SetItemKV(WeaponData.Item, WeaponData.Slot, "Ammo", Amount)
    end
end)

-- Functions
function GetWeaponList(Weapon)
    return Config.Weapons[Weapon]
end
exports("GetWeaponList", GetWeaponList)

function GetWeapons(Weapon)
    return Config.Weapons
end
exports("GetWeapons", GetWeapons)