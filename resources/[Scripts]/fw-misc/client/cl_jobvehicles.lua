RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry("pdm_purchase_job_vehicle", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 10.0,
        Distance = 1.5,
        Position = vector4(-46.73, -1105.29, 26.26, 114.9),
        Model = 's_m_m_highsec_01',
        Scenario = "WORLD_HUMAN_CLIPBOARD",
        Options = {
            {
                Name = 'pdm-job-store',
                Icon = 'fas fa-car',
                Label = 'Voertuigen',
                EventType = 'Client',
                EventName = 'fw-misc:Client:OpenJobVehicleStore',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            }
        }
    })
end)

RegisterNetEvent("fw-misc:Client:OpenJobVehicleStore")
AddEventHandler("fw-misc:Client:OpenJobVehicleStore", function()
    local MenuItems = {}

    for k, v in pairs(Config.JobVehicles) do
        local SharedData = FW.Shared.HashVehicles[GetHashKey(v)]
        if SharedData == nil then goto Skip end
        MenuItems[#MenuItems + 1] = {
            Icon = 'car',
            Title = SharedData.Name,
            Desc = exports['fw-businesses']:NumberWithCommas(SharedData.Price),
            Data = { Event = 'fw-misc:Server:PurchaseJobVehicle', Type = 'Server', Vehicle = v }
        }

        ::Skip::
    end

    if exports['fw-businesses']:IsPlayerInBusiness('Burger Shot') then
        local Foodbike = FW.Shared.HashVehicles[GetHashKey("foodbike")]
        MenuItems[#MenuItems + 1] = {
            Icon = 'car',
            Title = Foodbike.Name,
            Desc = exports['fw-businesses']:NumberWithCommas(Foodbike.Price),
            Data = { Event = 'fw-misc:Server:PurchaseJobVehicle', Type = 'Server', Vehicle = "foodbike" }
        }

        -- local Speedo = FW.Shared.HashVehicles[GetHashKey("nspeedo")]
        -- MenuItems[#MenuItems + 1] = {
        --     Icon = 'car',
        --     Title = Speedo.Name,
        --     Desc = exports['fw-businesses']:NumberWithCommas(Speedo.Price),
        --     Data = { Event = 'fw-misc:Server:PurchaseJobVehicle', Type = 'Server', Vehicle = "nspeedo" }
        -- }
    end

    local Job = FW.Functions.GetPlayerData().job
    if Job.name == "news" then
        local SharedData = FW.Shared.HashVehicles[GetHashKey("newsvan")]

        MenuItems[#MenuItems + 1] = {
            Icon = 'car',
            Title = SharedData.Name,
            Desc = exports['fw-businesses']:NumberWithCommas(SharedData.Price),
            Data = { Event = 'fw-misc:Server:PurchaseJobVehicle', Type = 'Server', Vehicle = "newsvan" }
        }
    end

    -- if exports['fw-businesses']:IsPlayerInBusiness('Hayes Repairs') or exports['fw-businesses']:IsPlayerInBusiness('Bennys Motorworks') then
        local SharedData = FW.Shared.HashVehicles[GetHashKey("flatbed")]

        MenuItems[#MenuItems + 1] = {
            Icon = 'car',
            Title = SharedData.Name,
            Desc = exports['fw-businesses']:NumberWithCommas(SharedData.Price),
            Data = { Event = 'fw-misc:Server:PurchaseJobVehicle', Type = 'Server', Vehicle = "flatbed" }
        }
    -- end

    Citizen.SetTimeout(450, function()
        FW.Functions.OpenMenu({ MainMenuItems = MenuItems })
    end)
end)

RegisterNetEvent("fw-misc:Client:SpawnJobVehicle")
AddEventHandler("fw-misc:Client:SpawnJobVehicle", function(Model, Plate)
    local Coords = vector4(-11.59, -1081.5, 27.14, 249.79)

    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Model, { x = Coords.x, y = Coords.y, z = Coords.z, a = Coords.w }, false, Plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    
    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    NetworkFadeInEntity(Vehicle, true)
    NetworkRequestControlOfEntity(Vehicle)

    exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
    exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)

    Citizen.SetTimeout(1000, function()
        FW.Functions.Notify("Het voertuig staat klaar achter de PDM")
        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)
        TriggerServerEvent("fw-businesses:Server:AutoCare:LoadParts", Plate, { Engine = 100, Axle = 100, Transmission = 100, FuelInjectors = 100, Clutch = 100, Brakes = 100 })
        TriggerServerEvent("fw-vehicles:Server:LoadVehicleMeta", NetId, nil)
    end)
end)