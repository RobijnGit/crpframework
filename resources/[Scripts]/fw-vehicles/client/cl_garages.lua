local CurrentGarage, IsGovGarage, PreviewVehicle = false, false, false

Citizen.CreateThread(function()
    local HouseGarages = FW.SendCallback("fw-vehicles:Server:GetHouseGarages")
    for k, v in pairs(HouseGarages) do
        Config.Garages[k] = v
    end

    local GangGarages = exports['fw-misc']:GetGangGarages()
    for k, v in pairs(GangGarages) do
        Config.Garages[v.Gang] = {
            Blip = false,
            Zone = { vector3(v.Coords.x, v.Coords.y, v.Coords.z), 6.0, 5.0, v.Coords.w, v.Coords.z - 1.0, v.Coords.z + 1.5 },
            Spots = { v.Coords },
            IsGang = v.Gang,
        }
    end

    for k, v in pairs(Config.Garages) do
        exports['PolyZone']:CreateBox({ center = v.Zone[1], length = v.Zone[2], width = v.Zone[3], data = { Garage = k } }, {
            name = 'garage-' .. k,
            heading = v.Zone[4],
            minZ = v.Zone[5], maxZ = v.Zone[6],
            IsMultiple = false, debugPoly = false,
        }, function(IsInside, Zone, Point)
            if IsInside then
                local IsGov = string.sub(Zone.data.Garage, 1, 4) == "gov_"
                if IsGov and FW.Functions.GetPlayerData().job.name ~= 'police' and FW.Functions.GetPlayerData().job.name ~= 'doc' and FW.Functions.GetPlayerData().job.name ~= 'ems' then
                    goto Skip
                end

                if Config.Garages[Zone.data.Garage].IsHouse and FW.Functions.GetPlayerData().job.name ~= 'police' then
                    local HasKeys = FW.SendCallback("fw-housing:Server:HasKeys", Config.Garages[Zone.data.Garage].IsHouse)
                    if not HasKeys then
                        goto Skip
                    end
                end

                if Config.Garages[Zone.data.Garage].IsGang and FW.Functions.GetPlayerData().job.name ~= 'police' then
                    local Gang = FW.SendCallback("fw-laptop:Server:Unknown:GetPlayerGang")
                    if Gang.Id ~= Config.Garages[Zone.data.Garage].IsGang then
                        goto Skip
                    end
                end

                CurrentGarage = Zone.data.Garage
                IsGovGarage = IsGov
                exports['fw-ui']:ShowInteraction("Parkeerplaats")

                ::Skip::
            else
                CurrentGarage = nil
                exports['fw-ui']:HideInteraction()
            end
        end)

        if v.Blip then
            local Blip = AddBlipForCoord(v.Spots[1].x, v.Spots[1].y, v.Spots[1].z)
            SetBlipSprite(Blip, v.Blip.Sprite)
            SetBlipDisplay(Blip, 4)
            SetBlipScale(Blip, 0.5)
            SetBlipAsShortRange(Blip, true)
            SetBlipColour(Blip, v.Blip.Color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(v.Blip.Text)
            EndTextCommandSetBlipName(Blip)
        end
    end

    exports['PolyZone']:CreateBox({
        center = vector3(1002.51, -2310.7, 30.64),
        length = 1.8,
        width = 2.4,
    }, {
        name = "garage-depot",
        heading = 355,
        minZ = 29.64, maxZ = 32.04,

        center = vector3(1002.51, -2310.7, 30.64),
        IsMultiple = false, debugPoly = false,
    }, function(IsInside, Zone, Point)
        if IsInside then
            CurrentGarage = 'depot'
            exports['fw-ui']:ShowInteraction("[E] Voertuig Depot")

            Citizen.CreateThread(function()
                while CurrentGarage == 'depot' do

                    if IsControlJustPressed(0, 38) then
                        TriggerEvent('fw-vehicles:Client:OpenDepot')
                    end

                    Citizen.Wait(4)
                end
            end)
        else
            CurrentGarage = nil
            exports['fw-ui']:HideInteraction()
        end
    end)
end)

function GetClosestGarage()
    local Distance, Id = nil, 0
    local Coords = GetEntityCoords(PlayerPedId())

    for k, v in pairs(Config.Garages[CurrentGarage].Spots) do
        local Dist = #(Coords - vector3(v.x, v.y, v.z))
        if Distance == nil or Distance > Dist then
            Distance = Dist
            Id = k
        end
    end

    return Id, Distance
end

function IsNearParking()
    return CurrentGarage ~= nil and CurrentGarage ~= 'depot' and CurrentGarage or nil
end
exports("IsNearParking", IsNearParking)

RegisterNetEvent("fw-vehicles:Client:SpawnVehiclePhone")
AddEventHandler("fw-vehicles:Client:SpawnVehiclePhone", function(Plate)
    local Result = FW.SendCallback("fw-vehicles:Server:CanSpawnVehicle", Plate)
    if not Result then
        return FW.Functions.Notify("Kan voertuig niet plaatsen, track je voertuig om de locatie te vinden..", "error")
    end

    local Vehicle = FW.SendCallback("fw-vehicles:Server:GetVehicleByPlate", Plate)
    TriggerEvent('fw-vehicles:Client:SpawnVehicle', {Vehicle = Vehicle})
end)

RegisterNetEvent("fw-vehicles:Client:LoadHouseGarage")
AddEventHandler("fw-vehicles:Client:LoadHouseGarage", function(HouseId, Data)
    Config.Garages[HouseId] = Data

    exports['PolyZone']:CreateBox({ center = Data.Zone[1], length = Data.Zone[2], width = Data.Zone[3], data = { Garage = HouseId } }, {
        name = 'garage-' .. HouseId,
        heading = Data.Zone[4],
        minZ = Data.Zone[5], maxZ = Data.Zone[6],
        IsMultiple = false, debugPoly = false,
    }, function(IsInside, Zone, Point)
        if IsInside then
            CurrentGarage = Zone.data.Garage
            IsGovGarage = false
            exports['fw-ui']:ShowInteraction("Parkeerplaats")
        else
            CurrentGarage = nil
            exports['fw-ui']:HideInteraction()
        end
    end)
end)

RegisterNetEvent("fw-vehicles:Client:OpenGarage")
AddEventHandler("fw-vehicles:Client:OpenGarage", function(Data)
    local IsGov = string.sub(CurrentGarage, 1, 4) == "gov_"
    if IsGov and (FW.Functions.GetPlayerData().job.name == 'police' or FW.Functions.GetPlayerData().job.name == 'doc' or FW.Functions.GetPlayerData().job.name == 'ems') and not Data.Forced then
        TriggerEvent("fw-police:Client:GarageMenu", CurrentGarage)
        return
    end

    local HasDebts = false
    if Config.Garages[CurrentGarage].IsHouse then
        HasDebts = HasHousingOverdueDebts(Config.Garages[CurrentGarage].IsHouse)
    end
    
    if Config.Garages[CurrentGarage].IsGang then
        local Adress = exports['fw-misc']:GetAdressByGang(Config.Garages[CurrentGarage].IsGang)
        if Adress then
            HasDebts = HasHousingOverdueDebts(Adress)
        end
    end

    if HasDebts then
        return FW.Functions.Notify("Geen toegang..", "error")
    end

    local Vehicles = FW.SendCallback("fw-vehicles:Server:GetGarageVehicles", CurrentGarage, IsGov and Data.Owner or false)
    local MenuItems = {}

    for k, v in pairs(Vehicles) do
        local SharedVehicle = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
        local MetaData = json.decode(v.metadata)

        MenuItems[#MenuItems + 1] = {
            Icon = 'car',
            Title = SharedVehicle and SharedVehicle.Name or GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle))),
            Desc = ("Plate: %s | %s"):format(v.plate, v.state == 'in' and 'Binnen' or 'Buiten'),
            Data = { Event = 'fw-vehicles:Client:SpawnPreview', Type = 'Client', Vehicle = v },
            SecondMenu = {
                {
                    CloseMenu = true,
                    Disabled = v.state ~= 'in',
                    Title = 'Voertuig Meenemen',
                    Data = {Event = "fw-vehicles:Client:SpawnVehicle", Type = "Client", Vehicle = v },
                },
                {
                    Title = 'Voertuig Status',
                    Desc = ('%s | Engine: %s%% | Body: %s%%'):format(v.state == 'In' and 'Binnen' or 'Buiten', math.ceil(MetaData.Engine / 10), math.ceil(MetaData.Body / 10)),
                }
            },
        }
    end

    FW.Functions.OpenMenu({
        MainMenuItems = MenuItems,
        ReturnEvent = { Event = "fw-vehicles:Client:DeletePreview", Type = "Client" },
        CloseEvent = { Event = "fw-vehicles:Client:DeletePreview", Type = "Client" },
    })
end)

RegisterNetEvent("fw-vehicles:Client:GarageActions")
AddEventHandler("fw-vehicles:Client:GarageActions", function()
    Citizen.SetTimeout(10, function()
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'BSN', Icon = 'fas fa-id-card', Name = 'Cid' },
        })

        if not Result or not Result.Cid then
            return FW.Functions.Notify("Geannuleerd.")
        end

        local Vehicles = FW.SendCallback("fw-vehicles:Server:GetVehiclesFromCid", Result.Cid, CurrentGarage)
        if #Vehicles == 0 then
            return FW.Functions.Notify("Garage is leeg..", "error")
        end

        local MenuItems = {}

        for k, v in pairs(Vehicles) do
            local SharedVehicle = FW.Shared.HashVehicles[GetHashKey(v.vehicle)]
            local MetaData = json.decode(v.metadata)
    
            MenuItems[#MenuItems + 1] = {
                Icon = 'car',
                Title = SharedVehicle and SharedVehicle.Name or GetLabelText(GetDisplayNameFromVehicleModel(GetHashKey(v.vehicle))),
                Desc = ("Plate: %s | %s"):format(v.plate, v.state == 'in' and 'Binnen' or 'Buiten'),
                SecondMenu = {
                    {
                        CloseMenu = true,
                        Disabled = v.state == 'depot',
                        Title = 'Voertuig Meenemen',
                        Data = {Event = "fw-vehicles:Client:SpawnVehicle", Type = "Client", OnLockdown = true, Vehicle = v },
                    },
                    {
                        Title = 'Voertuig Status',
                        Desc = ('%s | Engine: %s%% | Body: %s%%'):format(v.state == 'In' and 'Binnen' or 'Buiten', math.ceil(MetaData.Engine / 10), math.ceil(MetaData.Body / 10)),
                    },
                    {
                        CloseMenu = true,
                        Title = 'Toggle Voertuig Lockdown',
                        Data = {Event = "fw-vehicles:Server:ToggleLockdown", Type = "Server", Plate = v.plate },
                    },
                },
            }
        end
    
        FW.Functions.OpenMenu({
            MainMenuItems = MenuItems,
            ReturnEvent = { Event = "fw-vehicles:Client:DeletePreview", Type = "Client" },
            CloseEvent = { Event = "fw-vehicles:Client:DeletePreview", Type = "Client" },
        })
    end)
end)

RegisterNetEvent("fw-vehicles:Client:ParkVehicle")
AddEventHandler("fw-vehicles:Client:ParkVehicle", function(Data)
    local VehiclePlate = GetVehicleNumberPlateText(Data.Entity)
    local IsOwner = FW.SendCallback("fw-vehicles:Server:IsVehicleOwner", VehiclePlate, CurrentGarage)

    local IsVehicleLocked = FW.SendCallback("fw-vehicles:Server:IsVehicleLocked", VehiclePlate)
    if IsVehicleLocked then
        IsOwner = true
    end

    if not IsOwner then
        FW.Functions.Notify("Voertuig kan hier niet geparkeerd worden..", "error")
        return
    end

    if IsGovGarage and not IsGovVehicle(Data.Entity) then
        return FW.Functions.Notify("Voertuig kan hier niet geparkeerd worden..", "error")
    end

    if (IsThisModelAHeli(GetEntityModel(Data.Entity)) or IsThisModelAPlane(GetEntityModel(Data.Entity))) and CurrentGarage ~= 'airport_1' then
        return FW.Functions.Notify("Hier past geen luchtvaartuig in..", "error")
    end

    TriggerServerEvent("fw-vehicles:Server:ParkVehicle", VehToNet(Data.Entity), CurrentGarage, FW.VSync.GetVehicleDamage(Data.Entity))
end)

RegisterNetEvent("fw-vehicles:Client:SpawnPreview")
AddEventHandler("fw-vehicles:Client:SpawnPreview", function(Data)
    if PreviewVehicle then
        FW.VSync.DeleteVehicle(PreviewVehicle)
        PreviewVehicle = nil
    end

    local Model = Data.Vehicle.vehicle
    local MetaData = json.decode(Data.Vehicle.metadata)

    RequestModel(Model)
    while not HasModelLoaded(Model) do
        Citizen.Wait(4)
    end

    local Id, Dist = GetClosestGarage()
    local Spot = Config.Garages[CurrentGarage].Spots[Id]

    PreviewVehicle = CreateVehicle(Model, Spot.x, Spot.y, Spot.z, Spot.w, false, false)

    SetEntityHeading(PreviewVehicle, Spot.w)
    FreezeEntityPosition(PreviewVehicle, true)
    SetEntityAlpha(PreviewVehicle, 150, false)
    SetEntityCollision(PreviewVehicle, false, true)
    SetVehicleModKit(PreviewVehicle, 0)

    FW.VSync.ApplyVehicleMods(PreviewVehicle, 'Request', Data.Vehicle.plate, 'Player')
end)

RegisterNetEvent("fw-vehicles:Client:DeletePreview")
AddEventHandler("fw-vehicles:Client:DeletePreview", function(Data)
    if PreviewVehicle then
        FW.VSync.DeleteVehicle(PreviewVehicle)
        PreviewVehicle = nil
    end
end)

RegisterNetEvent("fw-vehicles:Client:SpawnVehicle")
AddEventHandler("fw-vehicles:Client:SpawnVehicle", function(Data)
    local IsVehicleLocked = FW.SendCallback("fw-vehicles:Server:IsVehicleLocked", Data.Vehicle.plate)
    if Data.OnLockdown and not IsVehicleLocked then
        return FW.Functions.Notify("De valet kan het voertuig niet uit de garage halen zonder bevel..")
    end

    if not Data.OnLockdown and IsVehicleLocked then
        return FW.Functions.Notify("Het voertuig staat op lockdown en kan niet uit de garage gehaald worden.", "error")
    end

    if HasOverdueDebts(Data.Vehicle.citizenid) and not Data.OnLockdown then
        if PreviewVehicle then
            FW.VSync.DeleteVehicle(PreviewVehicle)
            PreviewVehicle = nil
        end

        TriggerServerEvent("fw-phone:Server:Mails:AddMail", "De Staat van Los Santos", "Kennisgeving van inbeslagname", "U heeft onderhoudskosten openstaan voor dit voertuig. Als deze niet worden afbetaald, kan dit leiden tot permanente inbeslagname van eigendom aan de staat van Los Santos. Zodra openstaande onderhoudskosten zijn betaald, worden uw sleutels aan u geretourneerd.")
        return
    end

    local Model = Data.Vehicle.vehicle
    local MetaData = json.decode(Data.Vehicle.metadata)

    RequestModel(Model)
    while not HasModelLoaded(Model) do
        Citizen.Wait(4)
    end
    
    local Spot = vector4(0.0, 0.0, 0.0, 0.0)
    if CurrentGarage then
        local Id, Dist = GetClosestGarage()
        Spot = Config.Garages[CurrentGarage].Spots[Id]
    else
        local Coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.75, 0)
        Spot = vector4(Coords.x, Coords.y, Coords.z, GetEntityHeading(PlayerPedId()) + 90)
    end

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Model, { x = Spot.x, y = Spot.y, z = Spot.z, a = Spot.w }, false, Data.Vehicle.plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    
    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    if PreviewVehicle then
        FW.VSync.DeleteVehicle(PreviewVehicle)
        PreviewVehicle = nil
    end

    SetEntityVisible(Vehicle, false)
    NetworkRequestControlOfEntity(Vehicle)
    
    exports['fw-vehicles']:SetVehicleKeys(Data.Vehicle.plate, true, false)
    exports['fw-vehicles']:SetFuelLevel(Vehicle, MetaData.Fuel)
    TriggerServerEvent('fw-vehicles:Server:SetVehicleState', Data.Vehicle.plate, 'out', NetId)
    
    Citizen.SetTimeout(750, function()
        if MetaData.Damage ~= nil then
            FW.VSync.DoVehicleDamage(Vehicle, MetaData.Damage, {Engine = MetaData.Engine, Body = MetaData.Body})
        end

        SetVehicleModKit(Vehicle, 0)
        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, Data.Vehicle.plate)
        FW.VSync.ApplyVehicleMods(Vehicle, 'Request', Data.Vehicle.plate, 'Player')
        TriggerServerEvent("fw-businesses:Server:AutoCare:LoadParts", Data.Vehicle.plate)
        TriggerServerEvent("fw-vehicles:Server:LoadVehicleMeta", NetId, MetaData)
        SetEntityVisible(Vehicle, true)

        if not MetaData.WheelFitment then return end

        Citizen.CreateThread(function()
            local LastFetch = GetGameTimer()
            local WheelFitment = MetaData.WheelFitment
            while DoesEntityExist(Vehicle) and WheelFitment do
                if LastFetch + 5000 < GetGameTimer() then
                    LastFetch = GetGameTimer()
                    WheelFitment = exports['fw-vehicles']:GetVehicleMeta(Vehicle, "WheelFitment")
                end

                if not exports['fw-bennys']:GetIsInBennysZone() then
                    if WheelFitment.Width then SetVehicleWheelWidth(Vehicle, WheelFitment.Width) end
                    if WheelFitment.FLOffset then SetVehicleWheelXOffset(Vehicle, 0, WheelFitment.FLOffset) end
                    if WheelFitment.FROffset then SetVehicleWheelXOffset(Vehicle, 1, WheelFitment.FROffset) end
                    if WheelFitment.RLOffset then SetVehicleWheelXOffset(Vehicle, 2, WheelFitment.RLOffset) end
                    if WheelFitment.RROffset then SetVehicleWheelXOffset(Vehicle, 3, WheelFitment.RROffset) end
                end

                Citizen.Wait(4)
            end
        end)
    end)
end)