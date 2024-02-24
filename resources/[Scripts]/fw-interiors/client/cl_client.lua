local FW = exports['fw-core']:GetCoreObject()
local SpawnedObjects, InsideInterior = {}, false

function DespawnInteriors()
    for k, v in pairs(SpawnedObjects) do
		SetEntityAsMissionEntity(v, true, true)
		DeleteObject(v)
		table.remove(SpawnedObjects, k)
    end
    SpawnedObjects, InsideInterior = {}, false
end
exports("DespawnInteriors", DespawnInteriors)

function CreateInterior(InteriorId, Coords, LoadProps)
	if not IsModelValid(InteriorId) then
		FW.Functions.Notify(("Interieur '%s' kan niet geladen worden.."):format(InteriorId))
        return false
    end

	if Config.Interiors[InteriorId] == nil then
		print("^3[INTERIOR WARNING]:^7 Couldn't find interior settings for '" .. InteriorId .. "'. This is not a major issue and may be ignored unless otherwise said.")
	end

	if LoadProps and Config.Interiors[InteriorId] == nil then
		print("^3[INTERIOR WARNING]:^7 Couldn't find interior props for '" .. InteriorId .. "'. This **WILL** cause requested props not loading.")
		LoadProps = false
	end

	RequestModel(InteriorId)
	while not HasModelLoaded(InteriorId) do Citizen.Wait(100) end

	local Shell = CreateObject(GetHashKey(InteriorId), Coords.x, Coords.y, Coords.z, false, false, false)
	local Offsets = Config.Interiors[InteriorId] ~= nil and Config.Interiors[InteriorId].Offsets or {}

	SetEntityHeading(Shell, 0.0)
	FreezeEntityPosition(Shell, true)
	SetEntityInvincible(Shell, true)

	if LoadProps then
		LoadInteriorProps(InteriorId, Coords)
	end

	table.insert(SpawnedObjects, Shell)
	InsideInterior = true

	return {
		Shell,
		Offsets
	}
end
exports("CreateInterior", CreateInterior)

function LoadInteriorProps(InteriorId, Coords)
    if Config.Interiors[InteriorId] == nil or Config.Interiors[InteriorId].Props == nil then return end

    Citizen.CreateThread(function()
        for k, v in pairs(Config.Interiors[InteriorId].Props) do
            local Prop = CreateObject(GetHashKey(v.Prop), Coords.x + v.Coords.x, Coords.y + v.Coords.y, Coords.z + v.Coords.z, false, false, false)
            SetEntityHeading(Prop, v.Coords.w)
            FreezeEntityPosition(Prop, true)
            table.insert(SpawnedObjects, Prop)
        end
    end)
end

function IsInsideInterior()
    return InsideInterior
end
exports("IsInsideInterior", IsInsideInterior)

RegisterNetEvent('onResourceStop', function(Resource)
    if Resource == GetCurrentResourceName() then
        for k, v in pairs(SpawnedObjects) do
            DeleteObject(v)
        end
    end
end)

--[[
	function round(value)
		return math.floor(value * 100) / 100
	end

	local Interior = false
	RegisterCommand("getOffset", function(Source, Args, Raw)
		local Coords = GetEntityCoords(PlayerPedId())
		local IntCoords = GetEntityCoords(Interior)
	
		local Offset = vector3(Coords.x - IntCoords.x, Coords.y - IntCoords.y, IntCoords.z - Coords.z)
		TriggerEvent("fw-admin:Client:CopyToClipboard", ("{ x = %s, y = %s, z = %s, h = %s },"):format(round(Offset.x), round(Offset.y), round(Offset.z), round(GetEntityHeading(PlayerPedId()))))
	end)
	
	RegisterCommand("testInterior", function(Source, Args, Raw)
		exports['fw-interiors']:DespawnInteriors()
		local Coords = GetEntityCoords(PlayerPedId())
		Coords = vector3(-1729.55, -2902.29, 13.94 - 35.0)
		local InteriorData = exports['fw-interiors']:CreateInterior(Args[1], Coords, true)
		if not InteriorData then return end
	
		local Offsets = InteriorData[2]
		Interior = InteriorData[1]
	
		SetEntityCoords(PlayerPedId(), Coords.x + Offsets.Exit.x, Coords.y + Offsets.Exit.y, Coords.z + Offsets.Exit.z)
		SetEntityHeading(PlayerPedId(), Offsets.Exit.h)
	end)
	
	RegisterCommand("getIntCoords", function(Source, Args, Raw)
		print(GetEntityCoords(SpawnedObjects[1]), GetEntityHeading(SpawnedObjects[1]))
	end)
]]