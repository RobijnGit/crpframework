function showNonLoopParticle(dict, particleName, coords, scale)
	-- Request the particle dictionary.
	RequestNamedPtfxAsset(dict)
	-- Wait for the particle dictionary to load.
	while not HasNamedPtfxAssetLoaded(dict) do
		Citizen.Wait(0)
	end
	-- Tell the game that we want to use a specific dictionary for the next particle native.
	UseParticleFxAssetNextCall(dict)
	-- Create a new non-looped particle effect, we don't need to store the particle handle because it will
	-- automatically get destroyed once the particle has finished it's animation (it's non-looped).
	SetParticleFxNonLoopedColour(particleHandle, 0, 255, 0 ,0)
	return StartParticleFxNonLoopedAtCoord(particleName, coords, 0.0, 0.0, 0.0, scale, false, false, false)
end

function showLoopParticle(dict, particleName, coords, scale, time)
	-- Request the particle dictionary.
	RequestNamedPtfxAsset(dict)
	-- Wait for the particle dictionary to load.
	while not HasNamedPtfxAssetLoaded(dict) do
		Citizen.Wait(0)
	end
	-- Tell the game that we want to use a specific dictionary for the next particle native.
	UseParticleFxAssetNextCall(dict)
	-- Create a new non-looped particle effect, we don't need to store the particle handle because it will
	-- automatically get destroyed once the particle has finished it's animation (it's non-looped).
	local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords, 0.0, 0.0, 0.0, scale, false, false, false)
	SetParticleFxLoopedColour(particleHandle, 0, 255, 0 ,0)
	Citizen.Wait(time)
	StopParticleFxLooped(particleHandle, false)
	return particleHandle
end

RegisterCommand('particles', function(source, args)
	-- defalut scale = 1.0, defalut show all particleFx
	local scale = tonumber(args[1]) or 1.0
	local keyword = args[2] or ''
	TriggerServerEvent("getParticlesData", keyword, scale)
end, false)	

RegisterNetEvent("receivedParticlesData")
AddEventHandler("receivedParticlesData", function(dicts, particleNames, scale)
	-- Create a new thread.
	Citizen.CreateThread(function()
		-- local offset = vector3(5.0, 5.0, 1.0)
		local offset = vector3(0.0, 0.0, 1.0)
		local coords = GetEntityCoords(PlayerPedId(), true) + offset

		-- show debug box 50Hz
		-- Citizen.CreateThread(function()
		-- 	while true do
		-- 		DrawBox(coords, coords+vector3(0.1,0.1,0.1),255,0,0,255)
		-- 		Citizen.Wait(20)
		-- 	end
		-- end)

		-- Check received data from server
		local particleTotal = 0
		for _,v in ipairs(dicts) do
			for _, vv in ipairs(particleNames[v]) do
				-- print(v.." : "..vv)
				particleTotal = particleTotal + 1
			end
		end

		-- if we get any particle data, loop though then
		if particleTotal > 0 then
			local particleCnt = 0
			for _,dict in ipairs(dicts) do
				for _, particleName in ipairs(particleNames[dict]) do
					particleCnt = particleCnt + 1
					TriggerEvent('chat:addMessage', {
						color = { 255, 0, 0},
						multiline = true,
						args = {"TestBot", "["..particleCnt.."/"..particleTotal.."] "..dict.." :  "..particleName.."  scale: "..scale}
					})
					-- try non loop particle fx first 
					local nonloopreturn = showNonLoopParticle(dict, particleName, coords, scale)
					TriggerEvent('chat:addMessage', {
						color = { 255, 0, 0},
						multiline = true,
						args = {"Try Non Looped : "..nonloopreturn}
					})
					-- wait 10ms
					Citizen.Wait(10)
					-- try looped particle fx second
					local particleHandle = showLoopParticle(dict, particleName, coords, scale, 1000)
					TriggerEvent('chat:addMessage', {
						color = { 255, 0, 0},
						multiline = true,
						args = {"Try Looped : "..particleHandle}
					})
					-- Wait 2s till next particles fx
					Citizen.Wait(2000)
					-- clear chat buffer to avoid lag (noticible when particleTotal > 500 on my crappy machine)
					TriggerEvent('chat:clear')
				end
			end
			TriggerEvent('chat:addMessage', {
				color = { 255, 0, 0},
				multiline = true,
				args = {"TestBot", "All tests done"}
			})
		else
			TriggerEvent('chat:addMessage', {
				color = { 255, 0, 0},
				multiline = true,
				args = {"TestBot", "No particle contains the keyword you specifed"}
			})
		end
	end)
end)