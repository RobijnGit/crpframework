RegisterNetEvent('fw-nightvision:toggle')
AddEventHandler('fw-nightvision:toggle', function()
	local Player = PlayerPedId()

	if not HasNightVision then
		HasNightVision = true
		TriggerEvent("fw-misc:Client:PlaySound", 'items.nightvision')
		SetNightvision(true)
        TaskPlayAnim(Player, "mp_masks@standard_car@ds@", "put_on_mask", 2.0, 2.0, 800, 51, 0, false, false, false)
        SetPedComponentVariation(Player, 1, 132, 0, 0)
	elseif HasNightVision then
		SetNightvision(false)
		HasNightVision = false
        TaskPlayAnim(Player, "mp_masks@standard_car@ds@", "put_on_mask", 2.0, 2.0, 800, 51, 0, false, false, false)
        SetPedComponentVariation(Player, 1, 0, 0, 0)
    end
end)