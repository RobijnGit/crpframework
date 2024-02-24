RegisterServerEvent('fw-assets:server:set:dui:url')
AddEventHandler('fw-assets:server:set:dui:url', function(DuiId, URL)
    if Config.SavedDuiData[DuiId] then Config.SavedDuiData[DuiId].DuiUrl = URL end
    TriggerClientEvent('fw-assets:client:set:dui:url', -1, DuiId, URL)
end)

RegisterServerEvent('fw-assets:server:set:dui:data')
AddEventHandler('fw-assets:server:set:dui:data', function(DuiId, DuiData)
    Config.SavedDuiData[DuiId] = DuiData
    TriggerClientEvent('fw-assets:client:set:dui:data', -1, DuiId, Config.SavedDuiData[DuiId])
end)