FW.Commands = {}
FW.Commands.List = {}
FW.Commands.MutedGlobalOOC = {}

FW.Commands.Add = function(name, help, arguments, argsrequired, callback, permission) -- [name] = command name (ex. /givemoney), [help] = help text, [arguments] = arguments that need to be passed (ex. {{name="id", help="ID of a player"}, {name="amount", help="amount of money"}}), [argsrequired] = set arguments required (true or false), [callback] = function(source, args) callback, [permission] = rank or job of a player
	if type(name) ~= "table" then
		name = { name }
	end

	for k, cmd in ipairs(name) do
		FW.Commands.List[cmd:lower()] = {
			name = cmd:lower(),
			permission = permission ~= nil and permission:lower() or "user",
			help = help,
			arguments = arguments,
			argsrequired = argsrequired,
			callback = callback,
		}
	end
end

FW.Commands.Refresh = function(source)
	local Player = FW.Functions.GetPlayer(tonumber(source))
	if Player ~= nil then
		for command, info in pairs(FW.Commands.List) do
			if FW.Functions.HasPermission(source, "god") or FW.Functions.HasPermission(source, FW.Commands.List[command].permission) then
				TriggerClientEvent('chat:addSuggestion', source, "/"..command, info.help, info.arguments)
			end
		end
	end
end

FW.Commands.Add("addpermission", "Geef permissie aan iemand (god/admin)", {{name="id", help="ID van de speler"}, {name="permission", help="Permission level"}}, true, function(source, args)
	local Player = FW.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if Player ~= nil then
		FW.Functions.AddPermission(Player.PlayerData.source, permission)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Speler is niet online!")	
	end
end, "god")

FW.Commands.Add("removepermission", "Haal permissie weg van iemand", {{name="id", help="ID van de speler"}}, true, function(source, args)
	local Player = FW.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		FW.Functions.RemovePermission(Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Speler is niet online!")	
	end
end, "god")

FW.Commands.Add("refreshpermissions", "Herlaad de permissions", {}, false, function(source, args)
	FW.Functions.RefreshPerms()
end, "god")

FW.Commands.Add("ooc", "Lokaal Out Of Character chat bericht (alleen gebruiken wanneer nodig)", {}, false, function(source, args)
	local Player = FW.Functions.GetPlayer(source)
	if Player == nil then return end

	local MyCoords = GetEntityCoords(GetPlayerPed(source))
	local message = table.concat(args, " ")
	for k, v in pairs(FW.GetPlayers()) do
		if (FW.Functions.HasPermission(v.ServerId, "admin") and FW.Functions.IsOptin(v.ServerId)) or #(MyCoords - v.Coords) <= 50.0 then
			TriggerClientEvent('chatMessage', v.ServerId, "OOC | " .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. " ["..source.."]", "normal", message)
		end
	end
end)

FW.Commands.Add("id", "Zie wat je id is.", {}, false, function(source, args)
	local Player = FW.Functions.GetPlayer(source)
	TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Jouw id: "..source)
end)

FW.Commands.Add("login", "Herlaad je karakter (DEVELOPMENT ENVIRONMENT ONLY, DUS NIET GEBRUIKEN OP LIVE!)", {}, false, function(Source, Args)
    TriggerClientEvent('FW:Client:OnPlayerLoaded', Source)
end, "god")