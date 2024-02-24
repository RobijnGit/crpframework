local PlantProps = {'bkr_prop_weed_01_small_01b', 'bkr_prop_weed_med_01a', 'bkr_prop_weed_med_01b', 'bkr_prop_weed_lrg_01a', 'bkr_prop_weed_lrg_01b'}

function InitZones()
    Citizen.CreateThread(function()
        local DryRack = FW.SendCallback("fw-heists:Server:GetPedCoords", "WeedDryRack")
        exports['fw-ui']:AddEyeEntry("weed-dry-rack", {
            Type = 'Zone',
            SpriteDistance = 5.0,
            Distance = 4.0,
            ZoneData = {
                Center = DryRack,
                Length = 1.3,
                Width = 1.5,
                Data = {
                    heading = 4,
                    minZ = DryRack.z - 1.0,
                    maxZ = DryRack.z + 1.0
                },
            },
            Options = {
                {
                    Name = 'dry_rack_inventory',
                    Icon = 'fas fa-archive',
                    Label = 'Drook Rek',
                    EventType = 'Client',
                    EventName = 'fw-illegal:Client:Open:Dry:Rack',
                    EventParams = {},
                    Enabled = function(Entity)
                        return true
                    end,
                },
                {
                    Name = 'dry_rack_start',
                    Icon = 'fas fa-play',
                    Label = 'Start Droog Process',
                    EventType = 'Client',
                    EventName = 'fw-illegal:Client:Start:Dry:Process',
                    EventParams = {},
                    Enabled = function(Entity)
                        return true
                    end,
                }
            }
        })
        for k, v in pairs(PlantProps) do
            exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
                Type = 'Model',
                Model = v,
                SpriteDistance = 1.0,
                Options = {
                    {
                        Name = 'plant_pick',
                        Icon = 'fas fa-sign-language',
                        Label = 'Pak Plant',
                        EventType = 'Client',
                        EventName = 'fw-illegal:Client:Plants:Pick:Plant',
                        EventParams = '',
                        Enabled = function(Entity)
                            if exports['fw-illegal']:IsPlantPickable(Entity) then
                                return true
                            else
                                return false
                            end
                        end,
                    },
                    {
                        Name = 'plant_check',
                        Icon = 'fas fa-cannabis',
                        Label = 'Controleer Plant',
                        EventType = 'Client',
                        EventName = 'fw-illegal:Client:Plants:Open:Context',
                        EventParams = '',
                        Enabled = function(Entity)
                            return true
                        end,
                    },
                    {
                        Name = 'plant_destroy',
                        Icon = 'fas fa-cut',
                        Label = 'Verwoest Plant',
                        EventType = 'Client',
                        EventName = 'fw-illegal:Client:Plants:Destroy',
                        EventParams = '',
                        Enabled = function(Entity)
                            local PlayerData = FW.Functions.GetPlayerData()
                            if PlayerData.job.name == 'police' and PlayerData.job.onduty then
                                return true
                            else
                                return false
                            end
                        end,
                    }
                }
            })
        end
    end)
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", InitZones)