RegisterServerEvent('fw-assets:Server:Tackle:Player')
AddEventHandler('fw-assets:Server:Tackle:Player', function(Target)
    if Target ~= nil then
        TriggerClientEvent('fw-assets:Client:Get:Tackled', Target)
    end
end)
