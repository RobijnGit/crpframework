FW.Functions = {}

FW.Functions.GetPlayerData = function(cb)
    if cb ~= nil then
        cb(FW.PlayerData)
    else
        return FW.PlayerData
    end
end

FW.Functions.GetCoords = function(entity)
    local coords = GetEntityCoords(entity, false)
    local heading = GetEntityHeading(entity)
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        a = heading
    }
end

FW.Functions.DeleteVehicle = function(Vehicle)
	FW.VSync.DeleteVehicle(Vehicle)
end

FW.Functions.Notify = function(Text, TextType, TimeOut)
    local TextType = TextType ~= nil and TextType or "primary"
    local TimeOut = TimeOut ~= nil and TimeOut or 5000
	local Data = {['Message'] = Text, ['Type'] = TextType, ['TimeOut'] = TimeOut}
	exports['fw-ui']:AddNotify(Data)
end

FW.Functions.OpenMenu = function(MenuData)
	exports['fw-ui']:OpenMenu(MenuData)
end

FW.Functions.OpenInput = function(InputData)
	return exports['fw-ui']:CreateInput(InputData)
end

FW.Functions.TriggerCallback = function(name, cb, ...)
	local cbId = name .. ":" .. tostring(math.random(1111, 9999))
	FW.ServerCallbacks[cbId] = cb
    TriggerServerEvent("FW:Server:TriggerCallback", name, cbId, ...)
end

FW.Functions.GetPlayers = function()
    local Retval = promise:new()

	FW.Functions.TriggerCallback("FW:Server:GetPlayers", function(Result)
		Retval:resolve(Result)
	end)

	return Citizen.Await(Retval)
end

FW.Functions.GetStreetLabel = function(Coords)
	local Coords = Coords or GetEntityCoords(PlayerPedId())
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, Coords.x, Coords.y, Coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local FirstStreetLabel = GetStreetNameFromHashKey(s1)
    local SecondStreetLabel = GetStreetNameFromHashKey(s2)
    if SecondStreetLabel ~= nil and SecondStreetLabel ~= "" then 
        FirstStreetLabel = FirstStreetLabel .. " " .. SecondStreetLabel
    end
    return FirstStreetLabel
end

FW.Functions.GetCardinalDirection = function()
    local heading = GetEntityHeading(PlayerPedId())
    if heading >= 315 or heading < 45 then
        return "Noordelijke Richting"
    elseif heading >= 45 and heading < 135 then
        return "Westelijke Richting"
    elseif heading >=135 and heading < 225 then
        return "Zuidelijke Richting"
    elseif heading >= 225 and heading < 315 then
        return "Oostelijke Richting"
    end
end

FW.Functions.GetVehicleColorLabel = function(Vehicle)
	if Vehicle <= 0 or not DoesEntityExist(Vehicle) then
		return "Onbekend"
	end

	local Color1, Color2 = GetVehicleColours(Vehicle)
	if Color1 == nil then return "Onbekend" end

	if Color2 == nil or FW.Shared.Colors[Color2] == nil then
		return FW.Shared.Colors[Color1]
	end

	return FW.Shared.Colors[Color1] .. " met " .. FW.Shared.Colors[Color2]
end

FW.Functions.EnumerateEntities = function(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
    end)
end

FW.Functions.GetVehicles = function()
    local Vehicles = {}
	for Vehicle in FW.Functions.EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle) do
		table.insert(Vehicles, Vehicle)
	end
	return Vehicles
end

FW.Functions.GetClosestVehicle = function(pCoords)	
	local Vehicles = FW.Functions.GetVehicles()
	local ClosesDistance, ClosestVehicle, Coords = -1, -1, Coords ~= nil and vector3(pCoords.x, pCoords.y, pCoords.z) or GetEntityCoords(PlayerPedId())
	for i=1, #Vehicles, 1 do
		local VehicleCoords = GetEntityCoords(Vehicles[i])
		local Distance = #(VehicleCoords - Coords)
		if ClosesDistance == -1 or ClosesDistance > Distance then
			ClosestVehicle  = Vehicles[i]
			ClosesDistance = Distance
		end
	end
	return ClosestVehicle, ClosesDistance
end

FW.Functions.GetVehiclesInArea = function(Coords, Area)
	local Coords = vector3(Coords.x, Coords.y, Coords.z)
	local Vehicles, VehiclesInArea = FW.Functions.GetVehicles(), {}
	for i=1, #Vehicles, 1 do
		local VehicleCoords = GetEntityCoords(Vehicles[i])
		local Distance = #(VehicleCoords - Coords)
		if Distance <= Area then
			table.insert(VehiclesInArea, Vehicles[i])
		end
	end
	return VehiclesInArea
end

FW.Functions.IsSpawnPointClear = function(Coords, Radius)
	local Vehicles = FW.Functions.GetVehiclesInArea(Coords, Radius)
	if #Vehicles == 0 then
		return true
	end
end

FW.Functions.GetClosestPlayer = function(Coords)
	local ClosestDist, ClosestPly = 0, 0
	Coords = Coords or GetEntityCoords(PlayerPedId())

	local Players = FW.Functions.GetPlayers()
	for k, v in pairs(Players) do
		local Ply = GetPlayerPed(GetPlayerFromServerId(v.ServerId))
		if DoesEntityExist(Ply) and Ply ~= PlayerPedId() then
			if ClosestDist == 0 or ClosestDist > #(v.Coords - Coords) then
				ClosestDist = #(v.Coords - Coords)
				ClosestPly = v.ServerId
			end
		end
	end

	if ClosestPly == 0 or ClosestDist > 5.0 then return -1, -1 end

	return ClosestPly, ClosestDist
end

FW.Functions.GetPlayersFromCoords = function(Coords, Distance)
    local Players, Retval = FW.Functions.GetPlayers(), {}
	Coords, Distance = Coords or GetEntityCoords(PlayerPedId()), tonumber(Distance) or 5.0
	for k, v in pairs(Players) do
		if #(v.Coords - Coords) <= Distance then
			table.insert(Retval, v.ServerId)
		end
	end
    return Retval
end

FW.Functions.GetPeds = function(IgnoreList)
    local IgnoreList, Peds = IgnoreList ~= nil and IgnoreList or {}, {}
	for ped in FW.Functions.EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) do
		local found = false
        for j=1, #IgnoreList, 1 do
			if IgnoreList[j] == ped then
				found = true
			end
		end
		if not found then
			table.insert(Peds, ped)
		end
	end
	return Peds
end

FW.Functions.GetClosestPed = function(Coords, IgnoreList)
	local IgnoreList = IgnoreList ~= nil and IgnoreList or {}
	local ClosesPeds = FW.Functions.GetPeds(IgnoreList)
	local ClosestDistance, ClosestPed, Coords = -1, -1, Coords ~= nil and Coords or GetEntityCoords(PlayerPedId())
	for i=1, #ClosesPeds, 1 do
		local TargetCoords = GetEntityCoords(ClosesPeds[i])
		local Distance = #(TargetCoords - Coords)
		if ClosestDistance == -1 or ClosestDistance > Distance then
			ClosestPed = ClosesPeds[i]
			ClosestDistance = Distance
		end
	end
	return ClosestPed, ClosestDistance
end

FW.Functions.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel, cancelOnRagdoll)
    exports['fw-progressbar']:Progress({
        name = name:lower(),
        duration = duration,
        label = label,
        useWhileDead = useWhileDead,
        canCancel = canCancel,
        controlDisables = disableControls,
        animation = animation,
        prop = prop,
        propTwo = propTwo,
		cancelOnRagdoll = cancelOnRagdoll,
    }, function(cancelled)
        if not cancelled then
            if onFinish ~= nil then
                onFinish()
            end
        else
            if onCancel ~= nil then
                onCancel()
            end
        end
    end)
end

FW.Functions.CompactProgressbar = function(Duration, Label, UseWhileDead, CanCancel, DisableControls, Animation, Prop, PropTwo, CancelOnRagdoll)
	local Prom = promise:new()

    exports['fw-progressbar']:Progress({
        name = "sucking a dick",
        duration = Duration,
        label = Label,
        useWhileDead = UseWhileDead,
        canCancel = CanCancel,
        controlDisables = DisableControls,
        animation = Animation,
        prop = Prop,
        propTwo = PropTwo,
		cancelOnRagdoll = CancelOnRagdoll,
    }, function(Cancelled)
		Prom:resolve(not Cancelled)
    end)

	return Citizen.Await(Prom)
end

FW.Functions.SetVehiclePlate = function(Vehicle, Plate)
	local Vehicle, Plate = Vehicle, Plate
	NetworkRequestControlOfEntity(Vehicle)
	Citizen.SetTimeout(100, function()
		SetVehicleNumberPlateText(Vehicle, Plate)
	end)
end

local Throttles = {}
function FW.Throttled(Name, Time)
    if not Throttles[Name] then
        Throttles[Name] = true
        Citizen.SetTimeout(Time or 500, function() Throttles[Name] = false end)
        return false
    end

    return true
end

local KeyNames = {
    b_100 = 'Mouse 1', b_101 = 'Mouse 2', b_102 = 'Mouse 3', b_103 = 'Mouse 4', b_104 = 'Mouse 5', b_105 = 'Mouse 6', b_106 = 'Mouse 7', b_107 = 'Mouse 8', b_108 = 'Mouse left', b_109 = 'Mouse right', 
    b_110 = 'Mouse up', b_111 = 'Mouse down', b_112 = 'Mouse left/right', b_113 = 'Mouse up/down', b_114 = 'Mouse', b_115 = 'Scroll up', b_116 = 'Scroll down', b_117 = 'Scroll wheel', b_130 = 'Num -', b_131 = 'Num +',
    b_132 = 'Num .', b_133 = 'Num /', b_134 = 'Num *', b_135 = 'Num Enter', b_136 = 'Num 0', b_137 = 'Num 1', b_138 = 'Num 2', b_139 = 'Num 3', b_140 = 'Num 4', b_141 = 'Num 5',
    b_142 = 'Num 6', b_143 = 'Num 7', b_144 = 'Num 8', b_145 = 'Num 9', b_146 = 'Num =', b_147 = 'Num ,', b_148 = 'Num ÷', b_149 = 'Num x', b_150 = 'Intro', b_170 = 'F1',
    b_171 = 'F2', b_172 = 'F3', b_173 = 'F4', b_174 = 'F5', b_175 = 'F6', b_176 = 'F7', b_177 = 'F8', b_178 = 'F9', b_179 = 'F10', b_180 = 'F11',
    b_181 = 'F12', b_182 = 'F13', b_183 = 'F14', b_184 = 'F15', b_185 = 'F16', b_186 = 'F17', b_187 = 'F18', b_188 = 'F19', b_189 = 'F20', b_190 = 'F21',
    b_191 = 'F22', b_192 = 'F23', b_193 = 'F24', b_194 = 'Up Arrow', b_195 = 'Down Arrow', b_196 = 'Left Arrow', b_197 = 'Right Arrow', b_198 = 'Del', b_199 = 'Esc', b_200 = 'Ins',
    b_201 = 'End', b_202 = 'Suppr', b_203 = 'Échap', b_204 = 'Fin', b_205 = 'Entf', b_206 = 'Einfg', b_207 = 'Ende', b_208 = 'Canc', b_209 = 'Fine', b_210 = 'Supr',
    b_211 = 'Insertar', b_212 = 'Fin', b_213 = 'Supr', b_214 = 'Insertar', b_215 = 'Fin', b_216 = '¨', b_217 = '`', b_995 = '???', b_998 = '+', b_1000 = 'L Shift',
    b_1001 = 'R Shift', b_1002 = 'Tab', b_1003 = 'Enter', b_1004 = 'Backspace', b_1005 = 'Print Screen', b_1006 = 'Scroll Lock', b_1007 = 'Pause', b_1008 = 'Home', b_1009 = 'Page Up', b_1010 = 'Page Down',
    b_1011 = 'Num Lock', b_1012 = 'Caps', b_1013 = 'L Ctrl', b_1014 = 'R Ctrl', b_1015 = 'L Alt', b_1016 = 'R Alt', b_1017 = 'Menu', b_1018 = 'L Win', b_1019 = 'R Win', b_1020 = 'Imppr écran',
    b_1021 = 'Arrèt défil', b_1025 = 'Verr Numm', b_1026 = 'Verr Maj', b_1027 = 'Ctrl G', b_1028 = 'Ctrl D', b_1029 = 'Druck', b_1030 = 'Rollen ↓', b_1031 = 'Pos 1', b_1032 = 'Bild ↑', b_1033 = 'Bild ↓',
    b_1034 = 'Num ↓', b_1036 = 'Strg L', b_1037 = 'Strg R', b_1038 = 'Maiusc sx', b_1039 = 'Maiusc dx', b_1040 = 'Invio', b_1041 = 'Stampa', b_1042 = 'Bloc Scorr', b_1043 = 'Pausa', b_1045 = 'Pag ↑',
    b_1046 = 'Pag ↓', b_1047 = 'Bloc Num', b_1048 = 'Bloc Maiusc', b_1049 = 'Ctrl sx', b_1050 = 'Ctrl dx', b_1051 = 'Alt gr', b_1052 = 'Impr Pant', b_1053 = 'Bloq Despl', b_1054 = 'Pausa', b_1055 = 'Inicio',
    b_1056 = 'Re Pág', b_1057 = 'Av Pág', b_1058 = 'Bloq Num', b_1059 = 'Bloq Mayús', b_1060 = 'Ctrl I', b_1061 = 'Ctrl D', b_1062 = 'Menú', b_1063 = 'Impr Pant', b_1064 = 'Bloq Despl', b_1065 = 'Pausa',
    b_1066 = 'Inicio', b_1067 = 'Re Pág', b_1068 = 'Av Pág', b_1069 = 'Bloq Num', b_1070 = 'Mayús', b_1071 = 'Opsciones', b_1072 = 'Maj G', b_1073 = 'Maj D', b_1074 = 'Alt', b_1075 = 'Alt D',
    b_1076 = 'I Shift', b_1077 = 'D Shift', b_2000 = 'Space'
}

function FW.GetCustomizedKey(CommandString)
	local RawKey = GetControlInstructionalButton(2, GetHashKey("+fw_" .. CommandString) | 0x80000000, true)

	local NormalKey = string.gsub(RawKey, "^t_", "")
	if NormalKey ~= RawKey then
		return NormalKey
	elseif KeyNames[RawKey] then
		return KeyNames[RawKey]
	else
		return RawKey
	end
end

function FW.AddKeybind(CommandString, Category, Description, DefaultParameter, OnKey, Event, IsHold, DefaultWrapper)
	local Pressed = false
	RegisterCommand('+fw_'..CommandString, function()
		if IsPauseMenuActive() then return end
		if IsHold and Pressed then return end
		Pressed = true

		if OnKey then OnKey(true) end
		if Event ~= nil and Event ~= '' then TriggerEvent(Event, true) end
	end, false)

	RegisterCommand('-fw_'..CommandString, function()
		if IsPauseMenuActive() then return end
		if IsHold then Pressed = false end

		if OnKey then OnKey(false) end
		if Event ~= nil and Event ~= '' then TriggerEvent(Event, false) end
	end, false)

	RegisterKeyMapping('+fw_'..CommandString, Category..' - ' .. Description, DefaultWrapper or 'keyboard', DefaultParameter)
end

function FW.SendCallback(Event, ...)
    local Promise = promise:new()

	FW.Functions.TriggerCallback(Event, function(Result)
		Promise:resolve(Result)
	end, ...)
    
    return Citizen.Await(Promise)
end

function FW.GetCitizenIdFromPlayer(ServerId)
	local Cid = FW.SendCallback("FW:Server:GetCitizenIdByServerId", ServerId)
	return Cid
end