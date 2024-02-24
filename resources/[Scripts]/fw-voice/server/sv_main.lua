RegisterNetEvent("fw-voice:Server:Transmission:State")
AddEventHandler("fw-voice:Server:Transmission:State", function(Context, Transmitting)
	TriggerClientEvent('fw-voice:Client:Transmission:State', -1, source, Context, Transmitting)
end)

RegisterNetEvent("fw-voice:Server:Transmission:State:Radio")
AddEventHandler("fw-voice:Server:Transmission:State:Radio", function(Group, Context, Transmitting, IsMult)
	local Source = source
	if IsMult then
		for k, v in pairs(Group) do
			TriggerClientEvent('fw-voice:Client:Transmission:State', v, Source, Context, Transmitting)
		end
	else
		TriggerClientEvent('fw-voice:Client:Transmission:State', Group, Source, Context, Transmitting)
	end
end)