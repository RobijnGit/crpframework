function IsGov()
    local PlayerJob = FW.Functions.GetPlayerData().job.name
    return PlayerJob == 'police' or PlayerJob == 'judge'
end

function GetDepotSpot()
    for k, v in pairs(Config.DepotSpots) do
        if FW.Functions.IsSpawnPointClear(vector3(v.x, v.y, v.z), 2.5) then
            return v
        end
    end

    return false
end

RegisterNetEvent("fw-vehicles:Client:RequestImpound")
AddEventHandler("fw-vehicles:Client:RequestImpound", function(Data)
    local MenuItems = {}

    for k, v in pairs(Config.ImpoundList) do
        if not v.Gov or (v.Gov and IsGov()) then
            MenuItems[#MenuItems + 1] = {
                Title = v.Title,
                Desc = v.Desc,
                Data = { Event = 'fw-vehicles:Client:CheckRequestImpound', Type = 'Client', Vehicle = Data.Entity, ImpoundId = k },
            }
        end
    end

    FW.Functions.OpenMenu({
        Width = '70vh',
        MainMenuItems = MenuItems,
    })
end)

RegisterNetEvent("fw-vehicles:Client:CheckRequestImpound")
AddEventHandler("fw-vehicles:Client:CheckRequestImpound", function(Data)
    if Data.ImpoundId == #Config.ImpoundList then -- self 
        Citizen.SetTimeout(10, function()
            local Result = exports['fw-ui']:CreateInput({
                { Label = 'Reden', Icon = 'fas fa-heading', Name = 'Reason' },
                { Label = 'Rapport ID', Icon = 'fas fa-address-card', Name = 'ReportId' },
                { Label = 'Vrijgavekosten', Icon = 'fas fa-dollar-sign', Name = 'Fee' },
                { Label = 'Strikes (niet automatisch aangevuld)', Icon = 'fas fa-asterisk', Name = 'Strikes' },
                { Label = 'In beslag genomen tot (in uren - standaard 24u)', Icon = 'fas fa-clock', Name = 'RetainedUntil' },
            })

            if Result then
                FW.Functions.Progressbar("depot", "Voertuig naar depot sturen..", math.random(7000, 15000), false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = false,
                }, {
                    animDict = "random@mugging4",
                    anim = "struggle_loop_b_thief",
                    flags = 49,
                }, {}, {}, function() -- Done
                    TriggerServerEvent("fw-vehicles:Server:DepotVehicle", NetworkGetNetworkIdFromEntity(Data.Vehicle), Data.ImpoundId, Result)
                end, function()
                end)
            end
        end)
    else
        local Result = false
        if Data.ImpoundId ~= 1 then
            Citizen.Wait(10)
            Result = exports['fw-ui']:CreateInput({
                { Label = 'Rapport ID', Icon = 'fas fa-address-card', Name = 'ReportId' },
            })
        end

        if Data.ImpoundId ~= 1 and (not Result or not Result.ReportId) then
            return FW.Functions.Notify("Een rapport id moet ingevuld worden!")
        end

        FW.Functions.Progressbar("depot", "Voertuig naar depot sturen..", math.random(5000, 10000), false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = false,
        }, {
            animDict = "random@mugging4",
            anim = "struggle_loop_b_thief",
            flags = 49,
        }, {}, {}, function() -- Done
            TriggerServerEvent("fw-vehicles:Server:DepotVehicle", NetworkGetNetworkIdFromEntity(Data.Vehicle), Data.ImpoundId, Result)
        end, function()
        end)
    end
end)

RegisterNetEvent("fw-vehicles:Client:OpenDepot")
AddEventHandler("fw-vehicles:Client:OpenDepot", function(args)
    local MenuItems = {}

    MenuItems[#MenuItems + 1] = {
        Title = "Recentelijk in beslag genomen",
        Desc = "Lijst met de laatste 10 voertuigen die in het depot gezet zijn sinds laatste tsunami.",
        Data = { Event = 'fw-vehicles:Client:LookupRecentDepots', Type = 'Client'},
    }

    MenuItems[#MenuItems + 1] = {
        Title = "Persoonlijke Voertuigen",
        Desc = "Lijst met persoonlijke voertuigen die in het depot staan.",
        Data = { Event = 'fw-vehicles:Client:LookupPersonalDepot', Type = 'Client'},
    }

    MenuItems[#MenuItems + 1] = {
        Title = "Zoek op Kenteken",
        Desc = "Zoek op voertuigen met kentekenplaat.",
        Data = { Event = 'fw-vehicles:Client:LookupByPlate', Type = 'Client'},
    }

    MenuItems[#MenuItems + 1] = {
        Title = "Vraag om hulp",
        Desc = "",
        Data = { Event = 'fw-vehicles:Server:SendMessageToImpound', Type = 'Server'},
    }

    Citizen.SetTimeout(100, function()
        FW.Functions.OpenMenu({
            Width = '50vh',
            MainMenuItems = MenuItems,
        })
    end)
end)

RegisterNetEvent("fw-vehicles:Client:LookupRecentDepots")
AddEventHandler("fw-vehicles:Client:LookupRecentDepots", function()
    local Results = FW.SendCallback("fw-vehicles:Client:GetRecentDepots")
    local MenuItems = {}

    MenuItems[#MenuItems + 1] = {
        Title = "Terug",
        Data = { Event = 'fw-vehicles:Client:OpenDepot', Type = 'Client'},
    }

    MenuItems[#MenuItems + 1] = {
        CloseMenu = false,
        Title = "Opzoekresultaten",
        Desc = #Results .. " resultaten gevonden.",
        Data = { Event = '', Type = 'Client'},
    }

    for k, v in pairs(Results) do
        local VehicleData = FW.Shared.HashVehicles[v.Vehicle]
        if VehicleData == nil then goto Skip end

        MenuItems[#MenuItems + 1] = {
            Title = VehicleData.Name .. " | " .. v.Plate,
            Desc = "Datum: " .. v.ImpoundDate,
            Data = { Event = '', Type = 'Client'},
            SecondMenu = {
                {
                    CloseMenu = false,
                    Title = 'Voertuig Informatie',
                    Desc = ('Kenteken: %s | VIN: %s'):format(v.Plate, v.VIN),
                },
                {
                    CloseMenu = false,
                    Title = 'Depot Informatie',
                    Desc = ('Reden: %s | Uitgever: %s'):format(v.Reason, v.Issuer),
                },
                {
                    CloseMenu = false,
                    Title = 'Beslagname Informatie',
                    Desc = ('Strikes: %s | In beslag tot: %s'):format(v.Strikes, v.ReleaseTxt),
                },
                -- {
                --     CloseMenu = false,
                --     Title = 'Vrijgavekosten',
                --     Desc = ('Totale Kosten: %s | BTW: %s%%'):format(exports['fw-businesses']:NumberWithCommas(v.Fee), math.floor((FW.Shared.Tax['Goods'] - 1) * 100)),
                -- },
                {
                    CloseMenu = false,
                    Title = 'Vrijgavekosten',
                    Desc = ('Totale Kosten: %s'):format(exports['fw-businesses']:NumberWithCommas(v.Fee)),
                },
                {
                    CloseMenu = true,
                    Title = 'Voertuig Ophalen',
                    -- Desc = 'Door zelf op te halen wordt de vrijgavekosten verdubbeld tot ' .. exports['fw-businesses']:NumberWithCommas(v.Fee * 2) .. '<br/>Om dubbele kosten te voorkomen bel je een depotmedewerker.',
                    Data = { Event = "fw-vehicles:Client:TakeOutDepot", Type = "Client", Plate = v.Plate, SelfRetrieve = false },
                },
            }
        }

        -- local CurrentClock = exports['fw-businesses']:GetCurrentClock()
        -- if CurrentClock.ClockedIn and CurrentClock.Business == 'Los Santos Depot' then
        --     table.insert(MenuItems[#MenuItems].SecondMenu, {
        --         CloseMenu = true,
        --         Title = 'Voertuig Ophalen als Depot Medewerker',
        --         Desc = '',
        --         Data = { Event = "fw-vehicles:Client:TakeOutDepot", Type = "Client", Plate = v.Plate, SelfRetrieve = false },
        --     })
        -- end

        ::Skip::
    end

    Citizen.SetTimeout(100, function()
        FW.Functions.OpenMenu({
            Width = '50vh',
            MainMenuItems = MenuItems,
        })
    end)
end)

RegisterNetEvent("fw-vehicles:Client:LookupPersonalDepot")
AddEventHandler("fw-vehicles:Client:LookupPersonalDepot", function()
    local Results = FW.SendCallback("fw-vehicles:Server:GetDepotVehicles")
    local MenuItems = {}

    MenuItems[#MenuItems + 1] = {
        Title = "Terug",
        Data = { Event = 'fw-vehicles:Client:OpenDepot', Type = 'Client'},
    }

    MenuItems[#MenuItems + 1] = {
        CloseMenu = false,
        Title = "Opzoekresultaten",
        Desc = #Results .. " resultaten gevonden.",
        Data = { Event = '', Type = 'Client'},
    }

    for k, v in pairs(Results) do
        local VehicleData = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        if VehicleData == nil then goto Skip end

        local ImpoundData = json.decode(v.impounddata)

        MenuItems[#MenuItems + 1] = {
            Title = VehicleData.Name .. " | " .. v.plate,
            Desc = "Datum: " .. ImpoundData.ImpoundDate,
            Data = { Event = '', Type = 'Client'},
            SecondMenu = {
                {
                    CloseMenu = false,
                    Title = 'Voertuig Informatie',
                    Desc = ('Kenteken: %s | VIN: %s'):format(v.plate, v.vinnumber),
                },
                {
                    CloseMenu = false,
                    Title = 'Depot Informatie',
                    Desc = ('Reden: %s | Uitgever: %s'):format(ImpoundData.Reason, ImpoundData.Issuer),
                },
                {
                    CloseMenu = false,
                    Title = 'Beslagname Informatie',
                    Desc = ('Strikes: %s | In beslag tot: %s'):format(ImpoundData.Strikes, ImpoundData.ReleaseTxt),
                },
                {
                    CloseMenu = false,
                    Title = 'Vrijgavekosten',
                    Desc = ('Totale Kosten: %s'):format(exports['fw-businesses']:NumberWithCommas(ImpoundData.Fee)),
                },
                {
                    CloseMenu = true,
                    Title = 'Voertuig Ophalen',
                    -- Desc = 'Door zelf op te halen wordt de vrijgavekosten verdubbeld tot ' .. exports['fw-businesses']:NumberWithCommas(ImpoundData.Fee * 2) .. '<br/>Om dubbele kosten te voorkomen bel je een depotmedewerker.',
                    Data = { Event = "fw-vehicles:Client:TakeOutDepot", Type = "Client", Plate = v.plate, SelfRetrieve = false },
                },
            }
        }

        -- local CurrentClock = exports['fw-businesses']:GetCurrentClock()
        -- if CurrentClock.ClockedIn and CurrentClock.Business == 'Los Santos Depot' then
        --     table.insert(MenuItems[#MenuItems].SecondMenu, {
        --         CloseMenu = true,
        --         Title = 'Voertuig Ophalen als Depot Medewerker',
        --         Data = { Event = "fw-vehicles:Client:TakeOutDepot", Type = "Client", Plate = v.plate, SelfRetrieve = false },
        --     })
        -- end

        ::Skip::
    end
    
    Citizen.SetTimeout(100, function()
        FW.Functions.OpenMenu({
            Width = '50vh',
            MainMenuItems = MenuItems,
        })
    end)
end)

RegisterNetEvent("fw-vehicles:Client:LookupByPlate")
AddEventHandler("fw-vehicles:Client:LookupByPlate", function()
    Citizen.SetTimeout(100, function()
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Kenteken', Icon = 'fas fa-closed-captioning', Name = 'Plate' },
        })
    
        if Result and #Result.Plate == 8 then
            local Vehicle = FW.SendCallback("fw-vehicles:Server:GetVehicleByPlate", Result.Plate)
            if Vehicle == nil or Vehicle.state ~= 'depot' then
                return FW.Functions.Notify("Geen zoekresultaten gevonden.", "error")
            end

            local MenuItems = {}
        
            MenuItems[#MenuItems + 1] = {
                Title = "Terug",
                Data = { Event = 'fw-vehicles:Client:OpenDepot', Type = 'Client'},
            }
        
            local VehicleData = FW.Shared.HashVehicles[GetHashKey(Vehicle.vehicle)]
            local ImpoundData = json.decode(Vehicle.impounddata)
    
            MenuItems[#MenuItems + 1] = {
                Title = VehicleData.Name .. " | " .. Vehicle.plate,
                Desc = "Datum: " .. ImpoundData.ImpoundDate,
                Data = { Event = '', Type = 'Client'},
                SecondMenu = {
                    {
                        CloseMenu = false,
                        Title = 'Voertuig Informatie',
                        Desc = ('Kenteken: %s | VIN: %s'):format(Vehicle.plate, Vehicle.vinnumber),
                    },
                    {
                        CloseMenu = false,
                        Title = 'Depot Informatie',
                        Desc = ('Reden: %s | Uitgever: %s'):format(ImpoundData.Reason, ImpoundData.Issuer),
                    },
                    {
                        CloseMenu = false,
                        Title = 'Beslagname Informatie',
                        Desc = ('Strikes: %s | In beslag tot: %s'):format(ImpoundData.Strikes, ImpoundData.ReleaseTxt),
                    },
                    {
                        CloseMenu = false,
                        Title = 'Vrijgavekosten',
                        Desc = ('Totale Kosten: %s'):format(exports['fw-businesses']:NumberWithCommas(ImpoundData.Fee)),
                    },
                    {
                        CloseMenu = true,
                        Title = 'Voertuig Ophalen',
                        -- Desc = 'Door zelf op te halen wordt de vrijgavekosten verdubbeld tot ' .. exports['fw-businesses']:NumberWithCommas(ImpoundData.Fee * 2) .. '<br/>Om dubbele kosten te voorkomen bel je een depotmedewerker.',
                        Data = { Event = "fw-vehicles:Client:TakeOutDepot", Type = "Client", Plate = Vehicle.plate, SelfRetrieve = false },
                    },
                }
            }
    
            -- local CurrentClock = exports['fw-businesses']:GetCurrentClock()
            -- if CurrentClock.ClockedIn and CurrentClock.Business == 'Los Santos Depot' then
            --     table.insert(MenuItems[#MenuItems].SecondMenu, {
            --         CloseMenu = true,
            --         Title = 'Voertuig Ophalen als Depot Medewerker',
            --         Data = { Event = "fw-vehicles:Client:TakeOutDepot", Type = "Client", Plate = Vehicle.plate, SelfRetrieve = false },
            --     })
            -- end
            
            Citizen.SetTimeout(100, function()
                FW.Functions.OpenMenu({
                    Width = '50vh',
                    MainMenuItems = MenuItems,
                })
            end)
        end
    end)
end)

RegisterNetEvent('fw-vehicles:Client:TakeOutDepot')
AddEventHandler('fw-vehicles:Client:TakeOutDepot', function(Data)
    local CanRetreive = FW.SendCallback("fw-vehicles:Server:CanRetreiveVehicle", Data.Plate)
    if not CanRetreive then return FW.Functions.Notify("Dit voertuig kan nog niet vrijgegeven worden.", "error") end

    local VehicleData = FW.SendCallback("fw-vehicles:Server:GetVehicleByPlate", Data.Plate)

    local PlayerData = FW.Functions.GetPlayerData()
    local IsPd = VehicleData.citizenid == 'gov_pd' and PlayerData.job.name == "police"
    local IsEms = VehicleData.citizenid == 'gov_ems' and PlayerData.job.name == "ems"
    local IsDoc = VehicleData.citizenid == 'gov_doc' and PlayerData.job.name == "doc"

    if VehicleData.citizenid ~= PlayerData.citizenid and not IsPd and not IsEms and not IsDoc then
        FW.Functions.Notify("De werknemer kijkt je aan en zegt dat dit niet jouw voertuig is.", "error")
        return
    end

    local Spot = GetDepotSpot()
    if Spot == false then return end

    local HasPaid = FW.SendCallback("fw-vehicles:Server:PayReleaseFee", VehicleData.plate, Data.SelfRetrieve and json.decode(VehicleData.impounddata).Fee * 2 or json.decode(VehicleData.impounddata).Fee)
    if not HasPaid then
        FW.Functions.Notify("Je hebt niet genoeg bank balans.", "error")
        return
    end

    local Model = VehicleData.vehicle
    local MetaData = json.decode(VehicleData.metadata)

    RequestModel(Model)
    while not HasModelLoaded(Model) do
        Citizen.Wait(4)
    end

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Model, { x = Spot.x, y = Spot.y, z = Spot.z, a = Spot.w }, false, VehicleData.plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    
    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end
    SetEntityVisible(Vehicle, false)
    NetworkRequestControlOfEntity(Vehicle)

    TriggerServerEvent("fw-businesses:Server:AutoCare:LoadParts", VehicleData.plate)
    exports['fw-vehicles']:SetVehicleKeys(VehicleData.plate, true, false)
    exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)
    TriggerServerEvent('fw-vehicles:Server:SetVehicleState', VehicleData.plate, 'out', NetId)

    Citizen.SetTimeout(500, function()
        if MetaData.Damage ~= nil then
            FW.VSync.DoVehicleDamage(Vehicle, MetaData.Damage, {Engine = MetaData.Engine, Body = MetaData.Body})
        end

        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, VehicleData.plate)
        FW.VSync.ApplyVehicleMods(Vehicle, 'Request', VehicleData.plate, 'Police')
        TriggerServerEvent("fw-vehicles:Server:LoadVehicleMeta", NetId, MetaData)
        SetEntityVisible(Vehicle, true)

        FW.Functions.Notify("Voertuig staat buiten..", "success")
    end)
end)