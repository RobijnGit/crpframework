FW = FW or {}
FW.PlayerData = {}
FW.Config = Config
FW.Shared = Shared
FW.ServerCallbacks = {}

LoggedIn = false

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
	exports.spawnmanager:setAutoSpawn(false)
	LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- // Function \\ --

function GetCoreObject()
	return FW
end