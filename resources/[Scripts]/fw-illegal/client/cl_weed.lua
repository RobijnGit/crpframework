RegisterNetEvent('fw-illegal:Client:Open:Dry:Rack')
AddEventHandler('fw-illegal:Client:Open:Dry:Rack', function()
    if exports['fw-inventory']:CanOpenInventory() then
        Citizen.SetTimeout(450, function()
            FW.Functions.TriggerCallback("fw-illegal:Server:Is:Dryer:Busy", function(IsBusy)
                if not IsBusy then
                    FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'temp-dry-rack', 5, 1000)
                else
                    FW.Functions.Notify("De droger is bezig..", 'error')
                end
            end)
        end)
    end
end)

RegisterNetEvent('fw-items:Client:Used:Scales')
AddEventHandler('fw-items:Client:Used:Scales', function()
    if exports['fw-inventory']:CanOpenInventory() then
        Citizen.SetTimeout(450, function()
            FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Crafting', 'Scale')
        end)
    end
end)