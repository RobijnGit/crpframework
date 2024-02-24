local SentAlert = false
local SentSafeAlert = false

RegisterNetEvent("fw-heists:Client:Stores:RobRegister")
AddEventHandler("fw-heists:Client:Stores:RobRegister", function(Data, Entity)
    if CurrentCops < Config.RequiredCopsStores then
        return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    if DataManager.Get("HeistsDisabled", 0) == 1 then
        return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    local Item = exports['fw-inventory']:GetItemByName('lockpick') or exports['fw-inventory']:GetItemByName('advlockpick')
    if not Item then
        return FW.Functions.Notify("Je mist een lockpick..")
    end

    local RegId = GetRegisterIdByCoords(GetEntityCoords(Entity))
    if RegId == nil then
        return FW.Functions.Notify("Deze kassa kan niet opengebroken worden..", "error")
    end

    local IsRegisterRobbed = FW.SendCallback("fw-heists:Server:Stores:GetRegisterState", RegId)
    if IsRegisterRobbed then
        return FW.Functions.Notify("Deze kassa is/wordt al opengebroken..", "error")
    end

    if math.random() < 0.8 and not SentAlert then
        TriggerServerEvent("fw-mdw:Server:SendAlert:StoreHeist", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel())
        SentAlert = true

        Citizen.SetTimeout(30000, function()
            SentAlert = false
        end)
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(1, 3))
    TriggerServerEvent("fw-heists:Server:SetRegisterState", 'Busy', RegId, true)
    TriggerEvent('fw-assets:client:lockpick:animation', true)

    if math.random(1, 100) > 75 and not IsWearingHandshoes() then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Outcome = exports['fw-ui']:StartSkillTest(8, { 10, 15 }, { 1500, 3000 }, false)
    TriggerEvent('fw-assets:client:lockpick:animation', false)
    if not Outcome then
        TriggerServerEvent("fw-heists:Server:SetRegisterState", 'Busy', RegId, false)
        exports['fw-assets']:RemoveLockpickChance(Item.Item == 'advlockpick')
        return FW.Functions.Notify("Je bent gefaald, loser.", "error")
    end

    TriggerServerEvent("fw-heists:Server:SetRegisterState", 'Robbed', RegId, true)
    TriggerServerEvent("fw-heists:Server:Stores:ReceiveReward", RegId)
end)

RegisterNetEvent("fw-heists:Client:Stores:InspectRegister")
AddEventHandler("fw-heists:Client:Stores:InspectRegister", function(Data, Entity)
    local RegId = GetRegisterIdByCoords(GetEntityCoords(Entity))
    if RegId == nil then
        return FW.Functions.Notify("Ziet eruit als een kassa..", "error")
    end

    local IsRegisterRobbed = FW.SendCallback("fw-heists:Server:Stores:GetRegisterState", RegId)
    if IsRegisterRobbed then
        FW.Functions.Notify("Deze kassa ziet er opengebroken uit!", "error")
    else
        FW.Functions.Notify("Ziet eruit als een kassa..", "success")
    end
end)

function GetRegisterIdByCoords(Coords)
    for k, v in pairs(Config.Registers) do
        if #(Coords - v.Coords) < 1.3 then
            return k
        end
    end

    return nil
end

exports("GetRegisterIdByCoords", GetRegisterIdByCoords)

-- Zones
RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("prop_till_01"), {
        Type = 'Model',
        Model = 'prop_till_01',
        SpriteDistance = 3.0,
        Distance = 1.0,
        Options = {
            {
                Name = 'heist_steal_register',
                Icon = 'fas fa-screwdriver',
                Label = 'Openbreken',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Stores:RobRegister',
                EventParams = '',
                Enabled = function(Entity)
                    if exports['fw-heists']:GetRegisterIdByCoords(GetEntityCoords(Entity)) ~= nil then
                        return true
                    end

                    return false
                end,
            },
            {
                Name = 'heist_check_register',
                Icon = 'fas fa-search',
                Label = 'Inspecteren',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Stores:InspectRegister',
                EventParams = '',
                Enabled = function(Entity)
                    local Player = FW.Functions.GetPlayerData()
                    if exports['fw-heists']:GetRegisterIdByCoords(GetEntityCoords(Entity)) ~= nil then
                        return (Player.job.name == 'police' or Player.job.name == 'storesecurity') and Player.job.onduty
                    end

                    return false
                end,
            },
        }
    })

    for k, v in pairs(Config.Safes) do
        exports['fw-ui']:AddEyeEntry("store_safes_" .. k, {
            Type = 'Zone',
            SpriteDistance = 10.0,
            Distance = 5.0,
            State = false,
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
                    Name = 'crack',
                    Icon = 'fas fa-user-secret',
                    Label = 'Kluis Openbreken',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:CrackSafe',
                    EventParams = { SafeId = k },
                    Enabled = function(Entity)
                        return true
                    end,
                },
                {
                    Name = 'open',
                    Icon = 'fas fa-box-open',
                    Label = 'Kluis Openen',
                    EventType = 'Server',
                    EventName = 'fw-heists:Server:RewardSafe',
                    EventParams = { SafeId = k },
                    Enabled = function(Entity)
                        return true
                    end,
                },
                {
                    Name = 'check',
                    Icon = 'fas fa-search',
                    Label = 'Inspecteren',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:Stores:InspectSafe',
                    EventParams = { SafeId = k },
                    Enabled = function(Entity)
                        local PlayerData = FW.Functions.GetPlayerData()
                        return (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity') and PlayerData.job.onduty
                    end,
                },
                {
                    Name = 'close',
                    Icon = 'fas fa-lock',
                    Label = 'Alarm Uitschakelen',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:Stores:ResetSafe',
                    EventParams = { SafeId = k },
                    Enabled = function(Entity)
                        local PlayerData = FW.Functions.GetPlayerData()
                        return (PlayerData.job.name == 'police' or PlayerData.job.name == 'storesecurity') and PlayerData.job.onduty
                    end,
                },
            }
        })
    end
end)

RegisterNetEvent("fw-heists:Client:CrackSafe")
AddEventHandler("fw-heists:Client:CrackSafe", function(Data)
    if CurrentCops < Config.RequiredCopsStores then
        return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
    end

    if not Data.SafeId then
        return
    end

    local State = FW.SendCallback("fw-heists:Server:GetSafeState", Data.SafeId)
    if State ~= 0 then
        return FW.Functions.Notify("Je kan de kluis nu niet openbreken..")
    end

    local Item = exports['fw-inventory']:GetItemByName("heist-safecracking")
    if not Item then
        return FW.Functions.Notify("Je mist een Safe Cracking Tool...", "error")
    end

    if not SentSafeAlert then
        TriggerServerEvent("fw-mdw:Server:SendAlert:StoreHeist", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), true)
        SentSafeAlert = true

        Citizen.SetTimeout(30000, function()
            SentSafeAlert = false
        end)
    end

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-safecracking', Item.Slot, 50.0)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    FW.TriggerServer("fw-heists:Store:SetSafeState", Data.SafeId, 1)

    local Success = SafeCrack(5)
    if not Success or Success == 'Escaped' then
        FW.TriggerServer("fw-heists:Store:SetSafeState", Data.SafeId, 0)
        return
    end

    FW.TriggerServer("fw-heists:Store:SetSafeState", Data.SafeId, 2)
end)

RegisterNetEvent("fw-heists:Client:Stores:InspectSafe")
AddEventHandler("fw-heists:Client:Stores:InspectSafe", function(Data)
    local State = FW.SendCallback("fw-heists:Server:GetSafeState", Data.SafeId)
    if State ~= 0 then
        FW.Functions.Notify("Zichtbare inbraaksporen op de kluis..", "error")
    else
        FW.Functions.Notify("Kluis ziet eruit als een kluis..")
    end
end)

RegisterNetEvent("fw-heists:Client:Stores:ResetSafe")
AddEventHandler("fw-heists:Client:Stores:ResetSafe", function(Data)
    local PlayerData = FW.Functions.GetPlayerData()
    if PlayerData.job.name ~= 'police' and PlayerData.job.name ~= 'storesecurity' and not PlayerData.job.onduty then
        return
    end

    FW.TriggerServer("fw-heists:Store:SetSafeState", Data.SafeId, 0)
    FW.Functions.Notify("Alarm is uitgeschakeld!", "error")
end)