RegisterNetEvent("fw-afk:server:KickForAFK")
AddEventHandler("fw-afk:server:KickForAFK", function()
    local src = source
	DropPlayer(src, 'Je werd gekickt omdat je te lang AFK was')
end)

FW.Functions.CreateCallback('fw-afk:Server:GetPermissions', function(Source, Cb)
    Cb(FW.Functions.GetPermission(Source))
end)