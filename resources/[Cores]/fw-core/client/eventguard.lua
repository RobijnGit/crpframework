FW.EventGuard = {}
FW.EventGuard.Token = nil

local Spawned = false
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4)
		if NetworkIsSessionStarted() and not Spawned then
			Spawned = true
			TriggerEvent('fw-core:Server:Player:Spawned')
			Citizen.SetTimeout(500, function()
				TriggerServerEvent('fw-core:Server:EventGuard:LoadToken')
			end)
		else
			Citizen.Wait(450)
		end
	end
end)

RegisterNetEvent("fw-core:Client:EventGuard:SetToken")
AddEventHandler("fw-core:Client:EventGuard:SetToken", function(Token)
    if FW.EventGuard.Token == nil then
        FW.EventGuard.Token = Token
        print("^1EventGuard: Set Token..^7")
    else
        print("^1EventGuard: Tried to set token, but the token was already set..^7")
    end
end)

FW.TriggerServer = function(Name, ...)
    if not FW.EventGuard.Token then
        return
    end

    TriggerServerEvent(Name, FW.EventGuard.Token, ...)
end