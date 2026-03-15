Citizen.CreateThread(function()
    -- local Result = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
    -- vector4(-297.46, -1332.25, 31.3, 306.24)
    exports['fw-ui']:AddEyeEntry("spray_guy", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.5,
        State = false,
        Position = vector4(-297.46, -1332.25, 30.3, 306.24),
        Model = 'a_m_y_cyclist_01',
        Options = {
            {
                Name = 'purchase_gang',
                Icon = 'fas fa-spray-can',
                Label = 'Purchase Gang Spray',
                EventType = 'Client',
                EventName = 'fw-graffiti:Client:PurchaseGangSpray',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'purchase_normal',
                Icon = 'fas fa-spray-can',
                Label = 'Purchase Normal Spray (' .. exports['fw-businesses']:NumberWithCommas(Config.SprayPrice) .. ')',
                EventType = 'Client',
                EventName = 'fw-graffiti:Client:PurchaseSpray',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'purchase_scrub',
                Icon = 'fas fa-broom',
                Label = 'Purchase Scrubbingcloth (' .. exports['fw-businesses']:NumberWithCommas(Config.ScrubPrice) .. ')',
                EventType = 'Server',
                EventName = 'fw-graffiti:Server:PurchaseScrubCloth',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })

    for k, v in pairs(Config.Sprays) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v.Model), {
            Type = 'Model',
            Model = v.Model,
            SpriteDistance = 10.0,
            Distance = 3.0,
            Options = {
                {
                    Name = 'scrub',
                    Icon = 'fas fa-soap',
                    Label = 'Scrub',
                    EventType = 'Client',
                    EventName = 'fw-graffiti:Client:ScrubGraffiti',
                    EventParams = {},
                    Enabled = function(Entity)
                        local PlayerData = FW.Functions.GetPlayerData()
                        return PlayerData.job.name == 'police' and PlayerData.job.onduty
                    end,
                },
                {
                    Name = 'claim',
                    Icon = 'fas fa-hand-holding',
                    Label = 'Claim',
                    EventType = 'Client',
                    EventName = 'fw-graffiti:Client:ClaimGraffiti',
                    EventParams = {},
                    Enabled = function(Entity)
                        if not exports['fw-graffiti']:IsGangSpray(Entity) then
                            return false
                        end
                        return exports['fw-graffiti']:IsGraffitiContested(Entity)
                    end,
                },
                {
                    Name = 'contest',
                    Icon = 'fas fa-hand-holding',
                    Label = 'Contest',
                    EventType = 'Client',
                    EventName = 'fw-graffiti:Client:ContestGraffiti',
                    EventParams = {},
                    Enabled = function(Entity)
                        return exports['fw-graffiti']:IsGangSpray(Entity) and not exports['fw-graffiti']:IsGraffitiContested(Entity) and not exports['fw-graffiti']:IsPlayerInSprayGang(Entity)
                    end,
                },
                {
                    Name = 'discover',
                    Icon = 'fas fa-eye',
                    Label = 'Discover',
                    EventType = 'Client',
                    EventName = 'fw-graffiti:Client:DiscoverGraffiti',
                    EventParams = {},
                    Enabled = function(Entity)
                        return exports['fw-graffiti']:IsGangSpray(Entity)
                    end,
                },
            }
        })
    end
end)