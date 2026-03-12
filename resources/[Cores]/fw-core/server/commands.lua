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

FW.Commands.Add("addpermission", "Assign a permission group to a player. (god/admin)", {{name="id", help="Player ID"}, {name="permission", help="Permission level (god | admin)"}}, true, function(source, args)
	local Player = FW.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if Player ~= nil then
		FW.Functions.AddPermission(Player.PlayerData.source, permission)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online.")	
	end
end, "god")

FW.Commands.Add("removepermission", "Remove permission group from a player.", {{name="id", help="Player ID"}}, true, function(source, args)
	local Player = FW.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		FW.Functions.RemovePermission(Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online.")	
	end
end, "god")

FW.Commands.Add("refreshpermissions", "Reload all permissions.", {}, false, function(source, args)
	FW.Functions.RefreshPerms()
end, "god")

FW.Commands.Add("ooc", "Send a out-of-character message, only use when necessary.", {}, false, function(source, args)
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

FW.Commands.Add("id", "Shows your server ID.", {}, false, function(source, args)
	local Player = FW.Functions.GetPlayer(source)
	TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Your server id is: "..source)
end)

FW.Commands.Add("login", "Reload your character (DEVELOPMENT ENVIRONMENT ONLY, NOT RECOMMENDED ON PRODUCTION!)", {}, false, function(Source, Args)
    TriggerClientEvent('FW:Client:OnPlayerLoaded', Source)
end, "god")