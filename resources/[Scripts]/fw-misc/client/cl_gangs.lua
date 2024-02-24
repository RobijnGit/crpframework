RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    for k, v in pairs(Config.GangsStashes) do
        exports['fw-ui']:AddEyeEntry("gang-stash-" .. k, {
            Type = 'Zone',
            SpriteDistance = 5.0,
            Distance = 1.5,
            ZoneData = {
                Center = v.center,
                Length = v.length,
                Width = v.width,
                Data = {
                    heading = v.heading,
                    minZ = v.minZ,
                    maxZ = v.maxZ
                },
            },
            Options = {
                {
                    Name = 'open',
                    Icon = 'fas fa-box-open',
                    Label = 'Open',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:OpenGangStash',
                    EventParams = { Gang = v.Gang },
                    Enabled = function(Entity)
                        return true
                    end,
                },
            }
        })
    end
end)

RegisterNetEvent("fw-misc:Client:OpenGangStash")
AddEventHandler("fw-misc:Client:OpenGangStash", function(Data)
    local PlayerJob = FW.Functions.GetPlayerData().job
    if PlayerJob.name == 'police' then
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Auth Code', Icon = 'fas fa-ellipsis-h', Name = 'Code', Type = 'password' },
        })

        if Result and Result.Code then
            local Success = FW.SendCallback("fw-misc:Server:Gangs:IsAuthCodeCorrect", Result.Code, Data.Gang)
            if not Success then
                return FW.Functions.Notify("Dit is niet de goede code..", "error")
            end

            if exports['fw-inventory']:CanOpenInventory() then
                FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'gang-stash-' .. Data.Gang, 100, 1000)
            end
        end

        return
    end

    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    if Gang.Id ~= Data.Gang then
        return FW.Functions.Notify("Geen toegang..", "error")
    end

    if HasHousingOverdueDebts(exports['fw-misc']:GetAdressByGang(Data.Gang)) then
        return FW.Functions.Notify("Geen toegang..", "error")
    end
    
    if exports['fw-inventory']:CanOpenInventory() then
        FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'gang-stash-' .. Data.Gang, 100, 1000)
    end
end)

exports("GetGangGarages", function()
    return Config.GangGarages
end)

exports("GetAdressByGang", function(GangId)
    for k, v in pairs(Config.GangHouses) do
        if v.GangId == GangId then
            return v.Adress
        end
    end
    return false
end)