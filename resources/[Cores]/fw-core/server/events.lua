function GetPlayerIdentifiersWithoutIp(src)
	local Identifiers = GetPlayerIdentifiers(src)
	local Retval = {}
	for k, v in pairs(Identifiers) do
		if v:sub(1, 3) ~= "ip:" then
			table.insert(Retval, v)
		end
	end
	return Retval
end

AddEventHandler('playerDropped', function(reason) 
	local src = source
	TriggerClientEvent('FW:Client:OnPlayerUnload', src)
	TriggerEvent('fw-logs:Server:Log', 'joinleave', 'Player Left', ("User: [%s] - %s\nReason: %s"):format(src, GetPlayerName(src), reason), 'red')
	if reason ~= "Reconnecting" and src > 60000 then return false end
	if(src==nil or (FW.Players[src] == nil)) then return false end
	FW.Players[src].PlayerData.position = GetEntityCoords(GetPlayerPed(src))
	FW.Players[src].Functions.Save()
	FW.Players[src] = nil
end)

RegisterServerEvent("FW:Server:TriggerCallback")
AddEventHandler('FW:Server:TriggerCallback', function(name, cbId, ...)
	local src = source
	FW.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent("FW:Client:TriggerCallback", src, cbId, ...)
	end, ...)
end)

RegisterServerEvent("FW:ReduceFoodAndWater")
AddEventHandler('FW:ReduceFoodAndWater', function(data)
	local Player = FW.Functions.GetPlayer(source)
	if Player ~= nil then
		local NewHunger = Player.PlayerData.metadata["hunger"] - 2.0
		local NewThirst = Player.PlayerData.metadata["thirst"] - 2.0
		if NewHunger <= 0 then NewHunger = 0 end
		if NewThirst <= 0 then NewThirst = 0 end
		Player.Functions.SetMetaData("thirst", NewThirst)
		Player.Functions.SetMetaData("hunger", NewHunger)
		Player.Functions.Save()
	end
end)

RegisterServerEvent("FW:Salary")
AddEventHandler('FW:Salary', function(data)
	local Player = FW.Functions.GetPlayer(source)
	if Player ~= nil then
		Player.Functions.SetMetaData('paycheck', Player.PlayerData.metadata['paycheck'] + Player.PlayerData.job.payment)
	end
end)

RegisterServerEvent('FW:Server:SetMetaData')
AddEventHandler('FW:Server:SetMetaData', function(Meta, Data)
	local Player = FW.Functions.GetPlayer(source)
	if Player ~= nil then 
		if Meta == 'hunger' or Meta == 'thirst' then
			if Data >= 100 then
				Data = 100
			elseif Data <= 0 then
				Data = 0
			end
		end
		Player.Functions.SetMetaData(Meta, Data)
	end
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = FW.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if FW.Commands.List[command] ~= nil then
			local Player = FW.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (FW.Functions.HasPermission(source, "god") or FW.Functions.HasPermission(source, FW.Commands.List[command].permission)) then
					if (FW.Commands.List[command].argsrequired and #FW.Commands.List[command].arguments ~= 0 and args[#FW.Commands.List[command].arguments] == nil) then
						TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Alle argumenten moeten ingevuld worden!")
						local agus = ""
						for name, help in pairs(FW.Commands.List[command].arguments) do
							agus = agus .. " ["..help.name.."]"
						end
						TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						FW.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Je hebt geen toegang tot dit commando..")
				end
			end
		end
	end
end)

RegisterServerEvent('FW:CallCommand')
AddEventHandler('FW:CallCommand', function(command, args)
	if FW.Commands.List[command] ~= nil then
		local Player = FW.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (FW.Functions.HasPermission(source, "god")) or (FW.Functions.HasPermission(source, FW.Commands.List[command].permission)) or (FW.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (FW.Commands.List[command].argsrequired and #FW.Commands.List[command].arguments ~= 0 and args[#FW.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Alle argumenten moeten ingevuld worden!")
					local agus = ""
					for name, help in pairs(FW.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					FW.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Je hebt geen toegang tot dit commando..")
			end
		end
	end
end)

RegisterServerEvent("FW:AddCommand")
AddEventHandler('FW:AddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	FW.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterServerEvent("FW:ToggleDuty")
AddEventHandler('FW:ToggleDuty', function(Source)
	local src = Source ~= nil and Source or source
	local Player = FW.Functions.GetPlayer(src)
	if not Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('FW:Notify', src, "Je bent nu in dienst!")
		TriggerClientEvent("FW:Client:SetDuty", src, true)
		if Player.PlayerData.job.name == 'police' then
			TriggerEvent("fw-police:server:UpdateCurrentCops")
		elseif Player.PlayerData.job.name == 'doc' then
			TriggerEvent("fw-prison:server:UpdateCurrentDOCs")
		end
	else
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('FW:Notify', src, "Je bent nu uit dienst!")
		TriggerClientEvent("FW:Client:SetDuty", src, false)
		if Player.PlayerData.job.name == 'police' then
			TriggerEvent("fw-police:server:UpdateCurrentCops")
		elseif Player.PlayerData.job.name == 'doc' then
			TriggerEvent("fw-prison:server:UpdateCurrentDOCs")
		end
	end
end)

RegisterServerEvent("FW:Server:Receive:paycheck")
AddEventHandler('FW:Server:Receive:paycheck', function()
	local Player = FW.Functions.GetPlayer(source)
	if Player.PlayerData.metadata['paycheck'] > 0 then
		Player.Functions.AddMoney('cash', Player.PlayerData.metadata['paycheck'])
		Player.Functions.SetMetaData('paycheck', 0)
	else
		TriggerClientEvent('FW:Notify', source, "Je hebt geen salaris om op te halen..", "error")
	end
end)

Citizen.CreateThread(function()
	exports['ghmattimysql']:execute("SELECT * FROM `server_extra`", {}, function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				FW.Config.Server.PermissionList[v.steam] = {
					steam = v.steam,
					license = v.license,
					permission = v.permission,
					optin = true,
				}
			end
		end
	end)
end)

FW.Functions.CreateCallback('FW:HasItem', function(source, cb, ItemName)
	local Player = FW.Functions.GetPlayer(source)
	if Player ~= nil then
		if Player.Functions.HasEnoughOfItem(ItemName, 1) ~= nil then
			cb(true)
		else
			cb(false)
		end
	end
end)	

FW.Functions.CreateCallback('FW:RemoveItem', function(Source, Cb, ItemName, Amount, Slot, CustomType)
	local Player = FW.Functions.GetPlayer(Source)
	local Amount = Amount ~= nil and Amount or 1
	local Slot = Slot ~= nil and Slot or false
	local Retval = false
	if Slot then
		Retval = Player.Functions.RemoveItem(ItemName, Amount, Slot, true, CustomType)
	else
		Retval = Player.Functions.RemoveItemByName(ItemName, Amount, true, CustomType)
	end

	Cb(Retval)
end)	

FW.Functions.CreateCallback('FW:AddItem', function(source, cb, ItemName, Amount, Slot)
	local Player = FW.Functions.GetPlayer(source)
	local Amount = Amount ~= nil and Amount or 1
	local Slot = Slot ~= nil and Slot or false
	if Player.Functions.AddItem(ItemName, Amount, Slot, true) then
		cb(true)
	else
		cb(false)
	end
end)

FW.Functions.CreateCallback('FW:RemoveCash', function(source, cb, amount)
    local Player = FW.Functions.GetPlayer(source)
    if Player.Functions.RemoveMoney("cash", amount) then
        cb(true)
    else 
        cb(false)
    end
end)

FW.Functions.CreateCallback('FW:Get:Specific:Player:Coords', function(Source, Cb, ServerId)
    local Player = FW.Functions.GetPlayer(Source)
	if Player == nil then return end

	local Coords = GetEntityCoords(GetPlayerPed(Source))
	Cb(Coords)
end)

FW.Functions.CreateCallback('FW:server:spawn:vehicle', function(source, cb, Model, Coords, IsAdmin, Plate)
	local SpawnVehicle = FW.Functions.SpawnVehicle(source, Model, Coords, IsAdmin, Plate)
	cb(SpawnVehicle)
end)

FW.Functions.CreateCallback('FW:Server:GetVehicleMods', function(Source, Cb, Plate)
	local Result = nil
	Result = exports['ghmattimysql']:executeSync("SELECT `mods` FROM `player_vehicles` WHERE `plate` = @Plate", {
		['@Plate'] = Plate,
	})

	if Result and Result[1] and Result[1].mods then
		Cb(json.decode(Result[1].mods))
	else
		Cb(false)
	end
end)