local FW = exports['fw-core']:GetCoreObject()

FW.Functions.CreateUsableItem("radio", function(Source, Item)
    TriggerClientEvent('fw-radio:Client:Use:Radio', Source)
end)

FW.Functions.CreateUsableItem("pdradio", function(Source, Item)
    TriggerClientEvent('fw-radio:Client:Use:Radio', Source)
end)