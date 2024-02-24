local CurrentValues, Threads = {}, {}

Citizen.CreateThread(function()
	while true do
		if LoggedIn then
			for k, v in pairs(Threads) do
				local Result = load(v.Native)()
				if CurrentValues[v.Id] ~= Result then
					OnChange(v.Id, Result, Events)
				end
			end
		else
			Citizen.Wait(2000)
		end
		Citizen.Wait(500)
	end
end)

function FW.AddThreadLoop(Id, Native, Events)
	Threads[#Threads + 1] = {
		Id = Id,
		Native = "return " .. Native,
		Events = Events
	}

	RegisterNetEvent("FW:" .. Id .. ":OnThreadChange")
end

function OnChange(Id, Value, Events)
	CurrentValues[Id] = Value
	TriggerEvent('FW:' .. Id .. ':OnThreadChange', Value)
	if Events and Events[tostring(Value)] then
		TriggerEvent(Events[tostring(Value)], Value)
	end
end

FW.AddThreadLoop("Health", "GetEntityHealth(PlayerPedId())", {}) -- FW:Health:OnThreadChange
FW.AddThreadLoop("Armour", "GetPedArmour(PlayerPedId())", {}) -- FW:Armour:OnThreadChange
FW.AddThreadLoop("Talking", "NetworkIsPlayerTalking(PlayerId())", {}) -- FW:Talking:OnThreadChange
FW.AddThreadLoop("Vehicle", "GetVehiclePedIsIn(PlayerPedId())", {}) -- FW:Vehicle:OnThreadChange
FW.AddThreadLoop("EscMap", "IsPauseMenuActive()", {}) -- FW:EscMap:OnThreadChange
FW.AddThreadLoop("Underwater", "IsPedSwimmingUnderWater(PlayerPedId())", {}) -- FW:Underwater:OnThreadChange

-- Default Loops
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if LoggedIn then
			TriggerServerEvent("FW:ReduceFoodAndWater")
			Citizen.Wait((1000 * 60) * 8)
		else
			Citizen.Wait(5000)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4)
		if LoggedIn then
			if FW.Functions.GetPlayerData().metadata["hunger"] <= 1 or FW.Functions.GetPlayerData().metadata["thirst"] <= 1 then
				if not FW.Functions.GetPlayerData().metadata["isdead"] then
					local CurrentHealth = GetEntityHealth(PlayerPedId())
					SetEntityHealth(PlayerPedId(), CurrentHealth - math.random(3, 8))
				end
			end
			Citizen.Wait(math.random(5500, 8500))
		else
			Citizen.Wait(450)
		end
	end
end)