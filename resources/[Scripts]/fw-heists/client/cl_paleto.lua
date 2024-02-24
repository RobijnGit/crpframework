local NearPaletoPowerbox, NearPaletoBank, DoingPaletoVault = false, false, false

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("hei_prop_hst_usb_drive"), {
        Type = 'Model',
        Model = 'hei_prop_hst_usb_drive',
        Distance = 2.0,
        Options = {
            {
                Name = 'grab_usb',
                Icon = 'fas fa-usb-drive',
                Label = 'Oppakken',
                EventType = 'Server',
                EventName = 'fw-heists:Server:Paleto:GrabUSB',
                EventParams = {},
                Enabled = function(Entity)
                    return NearPaletoBank
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("paleto_plug_usb_1", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = vector3(-104.54, 6479.22, 31.63),
            Length = 0.5,
            Width = 0.2,
            Data = {
                heading = 330,
                minZ = 31.48,
                maxZ = 31.98
            },
        },
        Options = {
            {
                Name = 'plug_usb',
                Icon = 'fas fa-laptop-code',
                Label = 'USB Inpluggen',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Paleto:PlugUsb',
                EventParams = { PC = 1 },
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("paleto_plug_usb_2", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = vector3(-106.18, 6473.61, 31.63),
            Length = 0.5,
            Width = 0.1,
            Data = {
                heading = 325,
                minZ = 31.48,
                maxZ = 31.98
            },
        },
        Options = {
            {
                Name = 'plug_usb',
                Icon = 'fas fa-laptop-code',
                Label = 'USB Inpluggen',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Paleto:PlugUsb',
                EventParams = { PC = 2 },
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("paleto_code_panel_1", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = vector3(-92.85, 6463.77, 31.63),
            Length = 0.3,
            Width = 0.6,
            Data = {
                heading = 50,
                minZ = 31.43,
                maxZ = 31.63,
            },
        },
        Options = {
            {
                Name = 'try_code',
                Icon = 'fas fa-terminal',
                Label = 'Kluis alarm paneel',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Paleto:TryCode',
                EventParams = { Panel = 1 },
                Enabled = function(Entity)
                    return exports['fw-heists']:GetPaletoState() == 2
                end,
            }
        }
    })

    exports['fw-ui']:AddEyeEntry("paleto_code_panel_2", {
        Type = 'Zone',
        SpriteDistance = 10.0,
        Distance = 5.0,
        State = false,
        ZoneData = {
            Center = vector3(-94.48, 6462.57, 32.53),
            Length = 0.3,
            Width = 0.6,
            Data = {
                heading = 320,
                minZ = 31.43,
                maxZ = 31.63,
            },
        },
        Options = {
            {
                Name = 'try_code',
                Icon = 'fas fa-terminal',
                Label = 'Kluis alarm paneel',
                EventType = 'Client',
                EventName = 'fw-heists:Client:Paleto:TryCode',
                EventParams = { Panel = 2 },
                Enabled = function(Entity)
                    return exports['fw-heists']:GetPaletoState() == 2
                end,
            }
        }
    })

    exports['PolyZone']:CreateBox({
        center = Config.Paleto.PowerBox.center,
        length = Config.Paleto.PowerBox.length,
        width = Config.Paleto.PowerBox.width,
    }, {
        name = "heist-paleto-powerbox",
        heading = Config.Paleto.PowerBox.heading,
        minZ = Config.Paleto.PowerBox.minZ,
        maxZ = Config.Paleto.PowerBox.maxZ,
    }, function(IsInside, Zone, Points)
        NearPaletoPowerbox = IsInside
        if IsInside then
            exports['fw-ui']:ShowInteraction('Elektriciteitskast')
        else
            exports['fw-ui']:HideInteraction()
        end
    end)
    
    exports['PolyZone']:CreateBox({
        center = vector3(-113.51, 6471.21, 32.7),
        length = 50,
        width = 50,
    }, {
        name = "heist-paleto-bank",
        heading = 45,
        minZ = 28.9,
        maxZ = 44.3
    }, function(IsInside, Zone, Points)
        NearPaletoBank = IsInside
    end)

    for k, v in pairs(Config.Paleto.Loot) do
        exports['fw-ui']:AddEyeEntry("heist-fleeca-paleto-loot-" .. k, {
            Type = 'Zone',
            SpriteDistance = 10.0,
            Distance = 1.5,
            ZoneData = {
                Center = v.Zone.center,
                Length = v.Zone.length,
                Width = v.Zone.width,
                Data = {
                    heading = v.Zone.heading,
                    minZ = v.Zone.minZ,
                    maxZ = v.Zone.maxZ
                },
            },
            Options = {
                {
                    Name = 'get_loot',
                    Icon = 'fas fa-th',
                    Label = 'Overvallen',
                    EventType = 'Client',
                    EventName = 'fw-heists:Client:RobPaletoLoot',
                    EventParams = { LootId = v.Id },
                    Enabled = function(Entity)
                        return exports['fw-heists']:GetPaletoState() == 4
                    end,
                }
            }
        })
    end
end)

RegisterNetEvent("fw-items:Clent:Used:HeavyThermite")
AddEventHandler("fw-items:Clent:Used:HeavyThermite", function()
    if NearPaletoPowerbox then
        if Config.Paleto.State ~= 0 then
            return FW.Functions.Notify("Ziet er verbrand uit..", "error")
        end
        
        if DataManager.Get("HeistsDisabled", 0) == 1 then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end
    
        if CurrentCops < Config.RequiredCopsPaleto then
            return FW.Functions.Notify("Je kan dit nu niet doen..", "error")
        end

        if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
            TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
        end

        local Outcome = exports['fw-ui']:StartThermite(7)
        if Outcome then
            FW.Functions.TriggerCallback('FW:RemoveItem', function(DidRemove)
                if not DidRemove then return end
                TriggerServerEvent('fw-heists:Server:SetPaletoState', 1)
                TriggerServerEvent("fw-mdw:Server:SendAlert:Paleto", GetEntityCoords(PlayerPedId()))
                DoThermiteEffect(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.3, 0))
            end, 'heavy-thermite', 1, nil, '')
        end
    end
end)

RegisterNetEvent("fw-heists:Client:HeistLaptopUsed")
AddEventHandler("fw-heists:Client:HeistLaptopUsed", function(Laptop)
    if #(GetEntityCoords(PlayerPedId()) - vector3(-102.22, 6463.17, 31.63)) > 1.5 then return end
    if Laptop ~= "blue" then return FW.Functions.Notify("Dit lijkt niet de goeie laptop te zijn...", "error") end
    if Config.Paleto.State ~= 3 then return FW.Functions.Notify("Schakel eerst het alarm uit van de kluis...", "error") end

    local Item = exports["fw-inventory"]:GetItemByName('heist-laptop', 'blue')
    if Item == nil then return FW.Functions.Notify("Dit lijkt niet de goeie laptop te zijn...", "error") end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-laptop', Item.Slot, 33.33)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Outcome = ShapeMinigame(20, 5, 5)
    if not Outcome then return end

    TriggerServerEvent('fw-heists:Server:SetPaletoState', 4)
    TriggerServerEvent("fw-phone:Server:Mails:AddMail", "Dark Market", "#Paleto-563", "De kluis van de Blaine Countys Savings Bank wordt zometeen geopend...")
end)

RegisterNetEvent("fw-heists:Client:Paleto:PlugUsb")
AddEventHandler("fw-heists:Client:Paleto:PlugUsb", function(Data, Entity)
    if not exports['fw-inventory']:HasEnoughOfItem('heist-usb', 1, 'black') then return FW.Functions.Notify("Ik mis een zwarte USB...", "error") end

    if not exports['fw-inventory']:HasEnoughOfItem('heist-decrypter-adv', 1) then
        return FW.Functions.Notify("Je mist een Advanced Decrypter!", "Error")
    end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    local Success = exports['fw-ui']:StartUntangle({
        Dots = 10,
        Timeout = 12000,
    })

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-decrypter-adv', nil, 33.33)

    if Success then
        local DidRemove = FW.SendCallback("FW:RemoveItem", 'heist-usb', 1, nil, 'black')
        if not DidRemove then return FW.Functions.Notify("Ik mis een zwarte USB...", "error") end

        local PCCode = FW.SendCallback("fw-heists:Server:Paleto:GetPCCode", Data.PC)
        if not PCCode or PCCode.Shown then return FW.Functions.Notify("De computer reageert niet op de USB...", "error") end
    
        exports['fw-ui']:SetTextDisplay(PCCode.Code)
    end
end)

RegisterNetEvent("fw-heists:Client:Paleto:TryCode")
AddEventHandler("fw-heists:Client:Paleto:TryCode", function(Data, Entity)
    if Config.Paleto.State ~= 2 then return end

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    if not exports['fw-inventory']:HasEnoughOfItem('heist-electronic-kit-adv', 1) then
        return FW.Functions.Notify("Je mist een Advanced Electronic Kit!", "Error")
    end

    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-electronic-kit-adv', nil, 33.33)

    local Result = exports['fw-ui']:CreateInput({
        { Label = 'USB Code', Icon = 'fas fa-bug', Name = 'Code' },
    })

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    if Result and Result.Code then
        local PCCode = FW.SendCallback("fw-heists:Server:Paleto:GetPCCode", Data.Panel)
        if not PCCode then return FW.Functions.Notify("Kluis alarm is uitgeschakeld...", "error") end
        if PCCode.Code ~= Result.Code then
            return PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
        end

        PlaySoundFrontend(-1, "Pin_Good", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
        TriggerServerEvent("fw-heists:Server:Paleto:CorrectCode", Data.Panel)
    end
end)

RegisterNetEvent("fw-heists:Client:RobPaletoLoot")
AddEventHandler("fw-heists:Client:RobPaletoLoot", function(Data, Entity)
    if Config.Paleto.State ~= 4 then return end

    if Config.Paleto.Loot[Data.LootId].State ~= 0 then return end
    if not exports['fw-inventory']:HasEnoughOfItem('heist-drill-adv', 1) then return end
    TriggerServerEvent('fw-inventory:Server:DecayItem', 'heist-drill-adv', nil, math.random(10, 20) + 0.0)

    TriggerServerEvent("fw-heists:Server:SetPaletoLootState", Data.LootId, 1)

    if not IsWearingHandshoes() and math.random(1, 100) <= 85 then
        TriggerServerEvent("fw-police:Server:CreateEvidence", "Fingerprint")
    end

    TriggerServerEvent('fw-ui:Server:gain:stress', math.random(6, 12))

    local GridOutcome = exports['fw-ui']:StartGridMinigame(4)
    if not GridOutcome then
        TriggerServerEvent("fw-heists:Server:SetPaletoLootState", Data.LootId, 0)
        return
    end

    local DrillOutcome = DrillMinigame()
    if not DrillOutcome then
        TriggerServerEvent("fw-heists:Server:SetPaletoLootState", Data.LootId, 0)
        return
    end

    TriggerServerEvent("fw-heists:Server:PaletoLootReward", Data.LootId)
end)

RegisterNetEvent("fw-heists:Client:SyncPaleto")
AddEventHandler("fw-heists:Client:SyncPaleto", function(NewData)
    Config.Paleto = NewData
end)

function GetPaletoState()
    return Config.Paleto.State
end
exports("GetPaletoState", GetPaletoState)