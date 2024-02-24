local FW = exports['fw-core']:GetCoreObject()

RegisterNetEvent("fw-menu:Server:SaveWalkstyle")
AddEventHandler("fw-menu:Server:SaveWalkstyle", function(Walkstyle)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Walkstyle == 'default' then Walkstyle = false end
    Player.Functions.SetMetaData('walkstyle', Walkstyle)
end)

RegisterNetEvent("fw-menu:Server:SaveExpression")
AddEventHandler("fw-menu:Server:SaveExpression", function(Expression)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Expression == 'default' then Expression = false end
    Player.Functions.SetMetaData('Expression', Expression)
end)