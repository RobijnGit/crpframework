local Pumps = {
    "prop_gas_pump_1a", "prop_gas_pump_1b", "prop_gas_pump_1c", "prop_gas_pump_1d",
    "prop_gas_pump_old2", "prop_gas_pump_old3", "prop_vintage_pump"
}

local NearGasStation, GasStationClass, HasNozzle, FuelRates, InVehicle = false, false, false, {}, false

Citizen.CreateThread(function()
    for k, v in pairs(Config.FuelStations) do
        if v.blip then
            local Blip = AddBlipForCoord(v.center.x, v.center.y, v.center.z)
            SetBlipSprite(Blip, 361)
            SetBlipDisplay(Blip, 4)
            SetBlipScale(Blip, 0.4)
            SetBlipAsShortRange(Blip, true)
            SetBlipColour(Blip, 1)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName("Tankstation")
            EndTextCommandSetBlipName(Blip)
        end

        exports['PolyZone']:CreateBox({ center = v.center, length = v.length, width = v.width, data = v.data }, {
            name = 'gas-station-' .. k,
            heading = v.heading,
            minZ = v.minZ, maxZ = v.maxZ,
            IsMultiple = false, debugPoly = false,
        }, function(IsInside, Zone, Point)
            NearGasStation = IsInside

            if Zone.data and Zone.data.vehicleClass then
                GasStationClass = Zone.data.vehicleClass
            else
                GasStationClass = false
            end

            if not IsInside and HasNozzle then
                HasNozzle = false
                exports['fw-assets']:RemoveProp()
            end
        end)
    end

    for k, v in pairs(Pumps) do
        exports['fw-ui']:AddEyeEntry(GetHashKey(v), {
            Type = 'Model',
            Model = v,
            SpriteDistance = 10.0,
            Options = {
                {
                    Name = "use_pump",
                    Icon = 'fas fa-gas-pump',
                    Label = "Gebruik Benzinepomp",
                    EventType = "Client",
                    EventName = "fw-vehicles:Client:Fuel:UsePump",
                    EventParams = {},
                    Enabled = function(Entity)
                        return NearGasStation and not HasNozzle
                    end,
                },
                {
                    Name = "return_hose",
                    Icon = 'fas fa-hand-holding',
                    Label = "Slang Terugleggen",
                    EventType = "Client",
                    EventName = "fw-vehicles:Client:Fuel:ReturnHose",
                    EventParams = {},
                    Enabled = function(Entity)
                        return NearGasStation and HasNozzle
                    end,
                }
            }
        })
    end
end)


RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = true

    if GetEntityModel(Vehicle) == GetHashKey("airone") then
        if FuelRates[GetVehicleNumberPlateText(Vehicle)] ~= 5 then
            FuelRates[GetVehicleNumberPlateText(Vehicle)] = 5
        end
    elseif GetVehicleClass(Vehicle) == 8 then
        if FuelRates[GetVehicleNumberPlateText(Vehicle)] ~= 2 then
            FuelRates[GetVehicleNumberPlateText(Vehicle)] = 2
        end
    end

    Citizen.CreateThread(function()
        while InVehicle do
            if not IsVehicleEngineOn(Vehicle) then
                goto Skip
            end
            
            if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
                local Plate = GetVehicleNumberPlateText(Vehicle)
                local FuelLevel = GetVehicleMeta(Vehicle, 'Fuel')
                if FuelLevel ~= 0 then
                    if GetEntitySpeed(Vehicle) > 3 then
                        local NewLevel = FuelLevel - (0.3 * (FuelRates[Plate] or 1.0))
                        -- print("Fuel - Current: " .. FuelLevel .. " | New: " .. NewLevel .. " | Rate: " .. (FuelRates[Plate] or 1.0))
                        SetFuelLevel(Vehicle, NewLevel)
                        Citizen.Wait(12500)
                    end
                end
            end

            ::Skip::

            Citizen.Wait(1000)
        end
    end)
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = false
end)

RegisterNetEvent("fw-vehicles:Client:Fuel:UsePump")
AddEventHandler("fw-vehicles:Client:Fuel:UsePump", function()
    FW.Functions.OpenMenu({
        MainMenuItems = {
            {
                Icon = 'gas-pump',
                Title = "Benzinepomp",
                Desc = "Selecteer het soort benzine je wilt gebruiken",
                CloseMenu = false,
            },
            {
                Icon = 'info-circle',
                Title = "Regulier",
                Desc = "Octaan: 95 | Prijs per liter: " .. exports['fw-businesses']:NumberWithCommas(Config.FuelPrice),
                Data = { Event = 'fw-vehicles:Client:Fuel:GrabHose', Type = 'Client' },
                CloseMenu = true,
            },
        },
    })
end)

RegisterNetEvent("fw-vehicles:Client:Fuel:GrabHose")
AddEventHandler("fw-vehicles:Client:Fuel:GrabHose", function()
    HasNozzle = true
    exports['fw-assets']:AddProp('fuelnuzzle')

    Citizen.CreateThread(function()
        while HasNozzle do

            if not exports['fw-assets']:GetSpecificPropStatus('fuelnuzzle') then
                exports['fw-assets']:AddProp('fuelnuzzle')
            end

            Citizen.Wait(100)
        end
    end)
end)

RegisterNetEvent("fw-vehicles:Client:Fuel:ReturnHose")
AddEventHandler("fw-vehicles:Client:Fuel:ReturnHose", function()
    HasNozzle = false
    exports['fw-assets']:RemoveProp()
end)

RegisterNetEvent("fw-vehicles:Client:Fuel:RefuelVehicle")
AddEventHandler("fw-vehicles:Client:Fuel:RefuelVehicle", function()
    if not NearGasStation or not HasNozzle then return end

    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())
    if Entity <= 0 or EntityType ~= 2 then return end

    local FuelLevel = GetVehicleFuelLevel(Entity)
    if 100 - FuelLevel < 5 then return FW.Functions.Notify("Je tank zit nog vol..", "error") end

    local IsBillPaid = FW.SendCallback("fw-vehicles:Server:Fuel:IsBillPaid", GetVehicleNumberPlateText(Entity))

    FW.Functions.OpenMenu({
        MainMenuItems = {
            {
                Icon = 'info-circle',
                Title = "Voertuig Tanken",
                Desc = "Brandstof Aantal: " .. math.ceil(100 - FuelLevel) .. " | Totale Kosten: " .. exports['fw-businesses']:NumberWithCommas(FW.Shared.CalculateTax("Gas", (100 - FuelLevel) * Config.FuelPrice)),
            },
            {
                Icon = "gas-pump",
                Title = "Start met Tanken",
                Data = { Event = 'fw-vehicles:Client:Fuel:StartRefuel', Type = 'Client', Liters = 100 - FuelLevel },
                Disabled = not IsBillPaid,
            },
            {
                Icon = "credit-card",
                Title = "Verstuur Rekening",
                Data = { Event = 'fw-vehicles:Client:Fuel:SendBill', Type = 'Client', SelfServe = false },
                Disabled = IsBillPaid,
            },
            {
                Icon = "portrait",
                Title = "Zelfbediening",
                Data = { Event = 'fw-vehicles:Client:Fuel:SendBill', Type = 'Client', SelfServe = true },
                Disabled = IsBillPaid,
            },
        },
    })
end)

RegisterNetEvent("fw-vehicles:Client:Fuel:SendBill")
AddEventHandler("fw-vehicles:Client:Fuel:SendBill", function(Data)
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())
    if Entity <= 0 or EntityType ~= 2 then return end

    local FuelLevel = GetVehicleFuelLevel(Entity)
    if 100 - FuelLevel < 5 then return FW.Functions.Notify("Je tank zit nog vol..", "error") end

    local Plate = GetVehicleNumberPlateText(Entity)
    local Liters = 100 - FuelLevel

    if Data.SelfServe then
        TriggerServerEvent('fw-vehicles:Server:Fuel:SendBill', Plate, FW.Functions.GetPlayerData().citizenid, Liters)
    else
        Citizen.SetTimeout(250, function()
            local Result = exports['fw-ui']:CreateInput({
                { Label = 'BSN', Icon = 'fas fa-user', Name = 'Cid' },
            })

            if Result and Result.Cid then
                TriggerServerEvent('fw-vehicles:Server:Fuel:SendBill', Plate, Result.Cid, Liters)
            end
        end)
    end
end)

RegisterNetEvent("fw-vehicles:Client:Fuel:StartRefuel")
AddEventHandler("fw-vehicles:Client:Fuel:StartRefuel", function(Data)
    local Entity, EntityType, EntityCoords = exports['fw-ui']:GetEntityPlayerIsLookingAt(4.0, 0.2, 286, PlayerPedId())
    if Entity <= 0 or EntityType ~= 2 then return end

    local Fueling = true
    Citizen.CreateThread(function()
        while Fueling do
            if IsVehicleEngineOn(Entity) then
                AddExplosion(GetEntityCoords(Entity), EXPLOSION_CAR, 4.0, true, false, 20.0)
                TriggerServerEvent('fw-mdw:Server:SendAlert:Explosion', GetEntityCoords(Entity), FW.Functions.GetStreetLabel())
                FW.Functions.Notify('Tanken met de motor aan klinkt niet als een goed idee..', 'error')

                if not exports['fw-police']:IsStatusAlreadyActive('gasoline') then
                    TriggerEvent('fw-police:Client:SetStatus', 'gasoline', 300)
                end
            end

            Citizen.Wait(250)
        end
    end)

    FW.Functions.Progressbar("fuel", "Aan het tanken...", 500 * Data.Liters, false, false, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "timetable@gardener@filling_can",
        anim = "gar_ig_5_filling_can",
        flags = 49,
    }, {}, {}, function() -- Done
        Fueling = false
        local Plate = GetVehicleNumberPlateText(Entity)
        SetFuelLevel(Entity, 100.0)
        StopAnimTask(PlayerPedId(), "timetable@gardener@filling_can", "gar_ig_5_filling_can", 1.0)
        TriggerServerEvent("fw-vehicles:Server:Fuel:SetPaidState", Plate)
    end, function()
        Fueling = false
    end, true)
end)

function SetFuelLevel(Vehicle, Amount)
    if Amount == nil then Amount = 100 end
    if Amount < 0 then Amount = 0 end
    if Amount > 100 then Amount = 100 end
    SetVehicleFuelLevel(Vehicle, Amount + 0.0)
    SetVehicleMeta(Vehicle, 'Fuel', Amount + 0.0)
end
exports("SetFuelLevel", SetFuelLevel)

function GetFuelRate(Plate)
    return FuelRates[Plate] or 1.0
end
exports("GetFuelRate", GetFuelRate)

function SetFuelRateOnVehicle(Plate, Rate)
    FuelRates[Plate] = Rate
end
exports("SetFuelRateOnVehicle", SetFuelRateOnVehicle)

exports("CanRefuel", function()
    return NearGasStation and HasNozzle
end)

exports("CanRefuelAircraft", function(Entity)
    return NearGasStation and GetVehicleClass(Entity) == GasStationClass
end)