VehicleMods, CurrentBennyZone, CurrentRespray = {}, nil, nil
LoggedIn = false

FW = exports['fw-core']:GetCoreObject()
local AlreadyDoing, IsInBennysZone = false, false
IsEmployedAtMechanic, InVehicle, InBennys, IsAdmin, CurrentWheelfitmentIndex = false, false, false, false, 0

Citizen.CreateThread(function()
    exports['PolyZone']:CreateBox(Config.Zones, {
        name = "bennys",
        IsMultiple = true,
        debugPoly = false,
    })

    for k, v in pairs(Config.Zones) do
        if v.ShowBlip then
            local Blip = AddBlipForCoord(v.center.x, v.center.y, v.center.z)
            SetBlipSprite(Blip, 446)
            SetBlipDisplay(Blip, 4)
            SetBlipScale(Blip, 0.48)
            SetBlipAsShortRange(Blip, true)
            SetBlipColour(Blip, 0)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName('Benny\'s Original Motorworks')
            EndTextCommandSetBlipName(Blip)
        end
        if v.workbench ~= nil then
            RequestModel('prop_toolchest_05')
            while not HasModelLoaded('prop_toolchest_05') do
                Citizen.Wait(100)
            end
            local workbench = CreateObject(GetHashKey('prop_toolchest_05'), v.workbench.x, v.workbench.y, v.workbench.z, false, true, false)
            SetEntityHeading(workbench, -45.0)
        end
    end
end)

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    LoggedIn = true
end)

RegisterNetEvent('FW:Client:OnPlayerUnload')
AddEventHandler('FW:Client:OnPlayerUnload', function()
    LoggedIn = false
end)

-- Code

-- Events
-- RegisterNetEvent("baseevents:enteredVehicle")
-- AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
--     InVehicle = true

--     Citizen.CreateThread(function()
--         while InVehicle do

--             if not InBennys then
--                 local WheelFitment = exports['fw-vehicles']:GetVehicleMeta(Vehicle, 'WheelFitment')
--                 if WheelFitment then
--                     if WheelFitment.FLRotation ~= nil then SetVehicleWheelYRotation(Vehicle, 0, WheelFitment.FLRotation) end
--                     if WheelFitment.FRRotation ~= nil then SetVehicleWheelYRotation(Vehicle, 1, WheelFitment.FRRotation) end
--                     if WheelFitment.RLRotation ~= nil then SetVehicleWheelYRotation(Vehicle, 2, WheelFitment.RLRotation) end
--                     if WheelFitment.RRRotation ~= nil then SetVehicleWheelYRotation(Vehicle, 3, WheelFitment.RRRotation) end
--                 end
--             else
--                 Citizen.Wait(250)
--             end

--             Citizen.Wait(4)
--         end
--     end)
-- end)

-- RegisterNetEvent("baseevents:leftVehicle")
-- AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
--     InVehicle = false
-- end)

RegisterNetEvent('PolyZone:OnEnter', function(PolyData, Coords)
    if PolyData.name == 'bennys' then
        CurrentBennyZone = PolyData
        IsInBennysZone = true
        
        if CurrentBennyZone.data.Secret then return end

        Citizen.CreateThread(function()
            local ShowingInteraction = false
            while IsInBennysZone do
                local Vehicle = GetVehiclePedIsUsing(PlayerPedId())
                if Vehicle ~= 0 then
                    if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
                        if not ShowingInteraction then
                            exports['fw-ui']:ShowInteraction("Benny's")
                            ShowingInteraction = true
                        end
                    else
                        if ShowingInteraction then
                            ShowingInteraction = false
                            exports['fw-ui']:HideInteraction()
                        end
                    end
                else
                    if ShowingInteraction then
                        ShowingInteraction = false
                        exports['fw-ui']:HideInteraction()
                    end
                end

                Citizen.Wait(1000)
            end
        end)
    end
end)

RegisterNetEvent('PolyZone:OnExit', function(PolyData, Coords)
    if PolyData.name == 'bennys' then
        exports['fw-ui']:HideInteraction()
        CurrentBennyZone = nil
        IsInBennysZone = false
    end
end)

RegisterNetEvent('fw-bennys:Client:OpenBennys', function(Admin)
    if not Admin and not CanOpenBennys(CurrentBennyZone.data.Authorized) then return FW.Functions.Notify("Deze Bennys kan jij niet gebruiken..", "error") end
    local Vehicle = GetVehiclePedIsUsing(PlayerPedId())
    InBennys, IsAdmin = true, Admin
    if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
        local IsMechanicOnline = FW.SendCallback("fw-bennys:Server:IsMechanicOnline")

        local PlayerData = FW.Functions.GetPlayerData()
        local IsGov = Admin or IsBennysGov(CurrentBennyZone.data.Authorized) and ((PlayerData.job.name == "police" or PlayerData.job.name == "ems" or PlayerData.job.name == "doc") and PlayerData.job.onduty)
        IsEmployedAtMechanic = IsGov or exports['fw-businesses']:IsPlayerInBusiness('Bennys Motorworks') or exports['fw-businesses']:IsPlayerInBusiness('Hayes Repairs') or exports['fw-businesses']:IsPlayerInBusiness('Harmony Repairs')
        if IsMechanicOnline and not IsEmployedAtMechanic and not IsAdmin then
            return FW.Functions.Notify("Spreek een van de voertuigreparatie bedrijven aan voor hulp.", "error")
        end

        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        VehicleMods = FW.VSync.GetVehicleMods(Vehicle)

        if not IsAdmin then SetEntityHeading(Vehicle, CurrentBennyZone.data ~= nil and CurrentBennyZone.data.Heading or CurrentBennyZone.offsetRot) end
        FreezeEntityPosition(Vehicle, true)
        SetNuiFocusKeepInput(true)
        SetNuiFocus(true, false)

        Citizen.CreateThread(function()
            while InBennys do
                DisableControlAction(0, 75, true)
                Citizen.Wait(4)
            end
        end)

        BuildMenu(Vehicle)
    else
        FW.Functions.Notify("Je moet in de bestuurderstoel zitten om Bennys te gebruiken.", "error")
    end
end)

RegisterNetEvent("fw-bennys:Client:SaveOutfit")
AddEventHandler("fw-bennys:Client:SaveOutfit", function(Data, Entity)
    if GetEntityType(Entity) ~= 2 then return end

    local IsOwned = FW.SendCallback("fw-vehicles:Server:GetVehicleByPlate", GetVehicleNumberPlateText(Entity)) ~= nil
    if not IsOwned then
        return FW.Functions.Notify("Kan niet bij dit voertuig..")
    end

    local Result = exports['fw-ui']:CreateInput({
        {
            Label = 'Slot',
            Icon = 'fas fa-sort-numeric-up-alt',
            Name = 'Slot',
            Type = 'number',
            Choices = {
                { Text = '1', Value = 1, },
                { Text = '2', Value = 2, },
            }
        },
    })

    if Result and Result.Slot then
        local Meta = exports['fw-vehicles']:GetVehicleMeta(Entity, 'Outfits')
        local ColorOne, ColorTwo = GetVehicleColours(Entity)
        local PearlescentColor, WheelColor = GetVehicleExtraColours(Entity)
        Meta[Result.Slot] = {
            Livery = GetVehicleMod(Entity, 48),
            ColorOne = ColorOne,
            ColorTwo = ColorTwo,
            DashboardColor = GetVehicleDashboardColour(Entity),
            PearlescentColor = PearlescentColor,
        }
        exports['fw-vehicles']:SetVehicleMeta(Entity, 'Outfits', Meta)
    end
end)

RegisterNetEvent("fw-bennys:Client:SwapOutfit")
AddEventHandler("fw-bennys:Client:SwapOutfit", function(Data, Entity)
    if GetEntityType(Entity) ~= 2 then return end

    local IsOwned = FW.SendCallback("fw-vehicles:Server:GetVehicleByPlate", GetVehicleNumberPlateText(Entity)) ~= nil
    if not IsOwned then
        return FW.Functions.Notify("Kan niet bij dit voertuig..")
    end

    local Result = exports['fw-ui']:CreateInput({
        {
            Label = 'Slot',
            Icon = 'fas fa-sort-numeric-up-alt',
            Name = 'Slot',
            Type = 'number',
            Choices = {
                { Text = '1', Value = 1, },
                { Text = '2', Value = 2, },
            }
        },
    })

    if Result and Result.Slot then
        local Meta = exports['fw-vehicles']:GetVehicleMeta(Entity, 'Outfits')
        local Outfit = Meta[Result.Slot]
        if not Outfit then
            return FW.Functions.Notify("Je hebt geen outfit opgeslagen op slot " .. Result.Slot)
        end

        local Finished = FW.Functions.CompactProgressbar(60000, "Outfitje swappen..", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
        if not Finished then return end

        local WheelColor = GetVehicleExtraColours(Entity)
        SetVehicleColours(Entity, Outfit.ColorOne, Outfit.ColorTwo)
        SetVehicleMod(Entity, 48, Outfit.Livery)
        SetVehicleDashboardColor(Entity, Outfit.DashboardColor)
        SetVehicleExtraColours(Entity, Outfit.PearlescentColor, WheelColor)
    end
end)

local NeonState = false
RegisterNetEvent("fw-bennys:Client:ToggleNeon")
AddEventHandler("fw-bennys:Client:ToggleNeon", function()
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    if not Vehicle then return end

    NeonState = not NeonState
    if NeonState then
        DisableVehicleNeonLights(Vehicle, true)
    else
        DisableVehicleNeonLights(Vehicle, false)
    end
end)

-- Functions
function Round(Value, Decimals)
    return Decimals and math.floor((Value * 10 ^ Decimals) + 0.5) / (10 ^ Decimals) or math.floor(Value + 0.5)
end

function GetModPrice(Name, ModIndex)
    local Multiplier = 1.0
    if IsEmployedAtMechanic then Multiplier = 0.7 end

    local Price = nil
    if ModIndex ~= nil and type(Config.Prices[Name]) == 'table' then
        Price = Config.Prices[Name][ModIndex] ~= nil and Config.Prices[Name][ModIndex] or Config.Prices[Name][#Config.Prices[Name]]
    elseif Config.Prices[Name] then
        Price = Config.Prices[Name]
    end

    return (Price ~= nil and math.floor(Price * Multiplier) or nil)
end

function GetIsInBennysZone()
    return IsInBennysZone
end

function CloseBennys(Data, Cb)
    InBennys, IsAdmin = false, false
    local Vehicle = GetVehiclePedIsUsing(PlayerPedId())
    FreezeEntityPosition(Vehicle, false)
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    SendNUIMessage({
        Action = 'SetVisibility',
        Bool = false,
    })
    if Cb then Cb('Ok') end
end

function CanOpenBennys(Authorized)
    if not Authorized then return true end

    if Authorized.Job then
        local MyJob = FW.Functions.GetPlayerData().job.name
        for k, Job in pairs(Authorized.Job) do
            if Job == MyJob then
                return true
            end
        end
    end

    if Authorized.Business then
        for k, Business in pairs(Authorized.Business) do
            if exports['fw-businesses']:IsPlayerInBusiness(Business) then
                return true
            end
        end
    end

    return false
end

function IsBennysGov(Authorized)
    if not Authorized then return false end

    if Authorized.Job then
        for k, Job in pairs(Authorized.Job) do
            if Job == "police" or Job == "ems" or Job == "doc" then
                return true
            end
        end
    end

    return false
end

-- NUI
RegisterNUICallback("CloseBennys", CloseBennys)

RegisterNUICallback("PlaySoundFrontend", function(Data, Cb)
    PlaySoundFrontend(-1, Data.Name, Data.Set, true)
end)

RegisterNUICallback('PreviewUpgrade', function(Data, Cb)
    if Data.Menu == "WheelFitment" then
        CurrentWheelfitmentIndex = Data.Index
        return
    end

    local MenuItem = Menu.GetMenu(Data.Menu)
    if MenuItem == nil then return end

    if Data.Menu == 'ResprayMenu' then
        if Data.Index == 1 then
            CurrentRespray = 'Primary'
        elseif Data.Index == 2 then
            CurrentRespray = 'Secondary'
        elseif Data.Index == 3 then
            CurrentRespray = 'Pearlescent'
        elseif Data.Index == 4 then
            CurrentRespray = 'WheelColor'
        elseif Data.Index == 5 then
            CurrentRespray = 'Dashboard'
        elseif Data.Index == 6 then
            CurrentRespray = 'Interior'
        end
    end

    MenuItem = MenuItem.Items[Data.Index]
    if MenuItem == nil then return end
    
    if MenuItem.Data == nil then return end
    if MenuItem.Data.ModType == nil then return end
    if MenuItem.Data.ModIndex == nil then return end
    
    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    local ModType = MenuItem.Data.ModType
    local ModIndex = MenuItem.Data.ModIndex
    FW.VSync.ApplyVehicleMods(Vehicle, VehicleMods, GetVehicleNumberPlateText(Vehicle), true)
    
    if ModType == 'Windows' then
        SetVehicleWindowTint(Vehicle, ModIndex)
    elseif ModType == 'PlateIndex' then
        SetVehicleNumberPlateTextIndex(Vehicle, ModIndex)
    elseif ModType == 'Extra' then
        SetVehicleExtra(Vehicle, ModIndex, false)
    elseif ModType == 'NeonSide' then
        SetVehicleNeonLightEnabled(Vehicle, ModIndex, true)
    elseif ModType == 'NeonColor' then
        SetVehicleNeonLightsColour(Vehicle, ModIndex.R, ModIndex.G, ModIndex.B)
    elseif ModType == 'Respray' then
        local ColorPrimary, ColorSecondary = GetVehicleColours(Vehicle)
        local PearlescentColor, WheelColor = GetVehicleExtraColours(Vehicle)
        if CurrentRespray == 'Primary' then
            SetVehicleColours(Vehicle, ModIndex, ColorSecondary)
        elseif CurrentRespray == 'Secondary' then
            SetVehicleColours(Vehicle, ColorPrimary, ModIndex)
        elseif CurrentRespray == 'Dashboard' then
            SetVehicleDashboardColor(Vehicle, ModIndex)
        elseif CurrentRespray == 'Interior' then
            SetVehicleInteriorColor(Vehicle, ModIndex)
        elseif CurrentRespray == 'Pearlescent' then
            SetVehicleExtraColours(Vehicle, ModIndex, WheelColor)
        elseif CurrentRespray == 'WheelColor' then
            SetVehicleExtraColours(Vehicle, PearlescentColor, ModIndex)
        end
    elseif ModType == 'Wheels' then
        if MenuItem.Data.WheelType ~= nil then
            Citizen.SetTimeout(20, function() -- If this isn't here, its not updated???
                if GetVehicleWheelType(Vehicle) ~= MenuItem.Data.WheelType then
                    SetVehicleWheelType(Vehicle, MenuItem.Data.WheelType)
                end
                SetVehicleMod(Vehicle, 23, ModIndex, false)
                SetVehicleMod(Vehicle, 24, ModIndex, false)
            end)
        end
    elseif ModType == 'XenonColor' then
        SetVehicleXenonLightsColor(Vehicle, ModIndex)
    elseif ModType == 22 then
        ToggleVehicleMod(Vehicle, 22, ModIndex == 1)
    else
        Citizen.SetTimeout(10, function()
            SetVehicleMod(Vehicle, ModType, ModIndex)
        end)
    end
    
    FW.VSync.SetVehicleFixed(Vehicle)
    Cb('Ok')
end)

RegisterNUICallback('PurchaseUpgrade', function(Data, Cb)
    if AlreadyDoing then return end
    if Data.Menu == 'WheelFitment' then return end

    local Vehicle = GetVehiclePedIsIn(PlayerPedId())
    local Plate = GetVehicleNumberPlateText(Vehicle)
    local Button = Menu.GetMenu(Data.Menu).Items[tonumber(Data.Index)]
    local Cash = FW.Functions.GetPlayerData().money.cash

    if Data.Menu == 'Repair' then
        if tonumber(Button.Data.Costs) > Cash then
            return FW.Functions.Notify("Je hebt niet genoeg cash..", "error")
        end

        local BodyHealth = GetVehicleBodyHealth(Vehicle)
        local EngineHealth = GetVehicleEngineHealth(Vehicle)

        local MissingBodyHealth = 1000.0 - BodyHealth
        local MissingEngineHealth = 1000.0 - EngineHealth

        SetVehicleHandbrake(Vehicle, true)

        if MissingEngineHealth > 50 then
            local Finished = FW.Functions.CompactProgressbar(5000 + (MissingEngineHealth / 50), "Motor repareren...", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
            if Finished then
                SetVehicleEngineHealth(Vehicle, EngineHealth + MissingEngineHealth)
                SetVehiclePetrolTankHealth(Vehicle, 1000.0)
            end
        end

        if MissingBodyHealth > 50 then
            local Finished = FW.Functions.CompactProgressbar(5000 + (MissingBodyHealth / 50), "Body repareren...", false, false, {disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
            if Finished then
                SetVehicleDeformationFixed(Vehicle)
                SetVehicleBodyHealth(Vehicle, BodyHealth + MissingBodyHealth)
            end
        end

        if GetVehicleBodyHealth(Vehicle) >= 900 and GetVehicleEngineHealth(Vehicle) >= 900 then
            FW.VSync.SetVehicleFixed(Vehicle)
        end

        SetVehicleHandbrake(Vehicle, false)

        if not IsAdmin then
            FW.SendCallback("FW:RemoveCash", tonumber(Button.Data.Costs))
            TriggerEvent('fw-misc:Client:PlaySoundEntity', 'vehicle.garageWrench', NetworkGetNetworkIdFromEntity(Vehicle), true, nil)

            Menu.RemoveMenu("Repair")
            if InBennys then BuildMenu(Vehicle) end
        end
    else
        if Button.Id == "Wheels" and (VehicleMods['Wheels'] == Button.Data.WheelType and VehicleMods['ModFrontWheels'] == Button.Data.ModIndex) then
            return FW.Functions.Notify("Modificatie is al geinstalleerd..", "error")
        elseif Button.Id ~= "Wheels" and VehicleMods[Button.Id] == Button.Data.ModIndex then
            return FW.Functions.Notify("Modificatie is al geinstalleerd..", "error")
        elseif Button.Id ~= "Wheels" and VehicleMods[Button.Data.ModType] == Button.Data.ModIndex then
            return FW.Functions.Notify("Modificatie is al geinstalleerd..", "error")
        end


        -- if VehicleMods['Neon'] ~= nil and Button.Data.ModType == 'NeonSide' and  VehicleMods['Neon'][Button.Data.ModIndex+1] == 1 then
        --     return FW.Functions.Notify("Modificatie is al geinstalleerd..", "error")
        -- end
        
        -- if VehicleMods['NeonColor'] ~= nil then
        --     local oldR, oldG, oldB = table.unpack(VehicleMods['NeonColor'])
        --     local oldRGB = {R= oldR, G= oldG, B = oldB}
        -- end

        -- if oldRGB ~= nil and Button.Data.ModType == 'NeonColor' and json.encode(oldRGB) == json.encode(Button.Data.ModIndex) then
        --     return FW.Functions.Notify("Modificatie is al geinstalleerd..", "error")
        -- end

        if Button.Id == "ResprayColor" then
            local ColorPrimary, ColorSecondary = VehicleMods['ColorOne'], VehicleMods['ColorTwo']
            local PearlescentColor, WheelColor = VehicleMods['PearlescentColor'], VehicleMods['WheelColor']
            local DashboardColor, InteriorColor = VehicleMods['DashboardColor'], VehicleMods['InteriorColor']

            if CurrentRespray == 'Primary' and Button.Data.ModIndex == ColorPrimary then
                return FW.Functions.Notify("Je auto is al gespoten in deze kleur..", "error")
            elseif CurrentRespray == 'Secondary' and Button.Data.ModIndex == ColorSecondary then
                return FW.Functions.Notify("Je auto is al gespoten in deze kleur..", "error")
            elseif CurrentRespray == 'Dashboard' and Button.Data.ModIndex == DashboardColor then
                return FW.Functions.Notify("Je auto is al gespoten in deze kleur..", "error")
            elseif CurrentRespray == 'Interior' and Button.Data.ModIndex == InteriorColor then
                return FW.Functions.Notify("Je auto is al gespoten in deze kleur..", "error")
            elseif CurrentRespray == 'Pearlescent' and Button.Data.ModIndex == PearlescentColor then
                return FW.Functions.Notify("Je auto is al gespoten in deze kleur..", "error")
            elseif CurrentRespray == 'WheelColor' and Button.Data.ModIndex == WheelColor then
                return FW.Functions.Notify("Je auto is al gespoten in deze kleur..", "error")
            end
        end

        local Costs = tonumber(Button.Data.Costs)
        if not Costs then
            Costs = 0
        end

        if type(Button.Data.Costs) == 'number' and Costs > 0 and not IsAdmin then
            if Costs > Cash then
                return FW.Functions.Notify("Je hebt niet genoeg cash..", "error")
            end

            FW.SendCallback("FW:RemoveCash", Costs)
        end

        if Data.Menu == 'ResprayMetallic' or Data.Menu == 'ResprayMetal' or Data.Menu == 'ResprayMatte' then
            TriggerEvent('fw-misc:Client:PlaySoundEntity', 'vehicle.garageRespray', NetworkGetNetworkIdFromEntity(Vehicle), true, nil)
        else
            TriggerEvent('fw-misc:Client:PlaySoundEntity', 'vehicle.garageWrench', NetworkGetNetworkIdFromEntity(Vehicle), true, nil)
        end
        if Button.Data.ModType == 'Extra' then
            if VehicleMods['ModExtras'][Button.Data.ModIndex] == 0 then
                SetVehicleExtra(Vehicle, Button.Data.ModIndex, true)
            else
                SetVehicleExtra(Vehicle, Button.Data.ModIndex, false)
            end

            Menu.UpdateMenuSecondText(Data.Menu, Data.Index, IsVehicleExtraTurnedOn(Vehicle, Button.Data.ModIndex) and "ON" or "OFF")
        elseif Button.Data.ModType == 'Wheels' and Button.Data.WheelType == GetVehicleWheelType(Vehicle) then
            -- Bugs out with other wheel types
            -- Stock wheels are returned with -1, just like GetVehicleMod when the mod is empty
            local _bModInstalled = false
            if GetVehicleMod(Vehicle, 23) ~= -1 and GetVehicleMod(Vehicle, 23) == Button.Data.ModIndex then _bModInstalled = true end
            if GetVehicleMod(Vehicle, 24) ~= -1 and GetVehicleMod(Vehicle, 24) == Button.Data.ModIndex then _bModInstalled = true end
            Button.Installed = _bModInstalled
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        elseif Button.Data.ModType == 'PlateIndex' then
            Button.Installed = GetVehicleNumberPlateTextIndex(Vehicle) == Button.Data.ModIndex
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        elseif Button.Data.ModType == 18 then
            ToggleVehicleMod(Vehicle, 18, not IsToggleModOn(Vehicle, 18))
            Button.Installed = IsToggleModOn(Vehicle, 18)
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        elseif Button.Data.ModType == 22 then
            Button.Installed = IsToggleModOn(Vehicle, 22)
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        elseif Button.Data.ModType == 'XenonColor' then
            Button.Installed = GetVehicleHeadlightsColour(Vehicle) == Button.Data.ModIndex
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        elseif Button.Data.ModType == 'NeonColor' then
            local r, g, b = GetVehicleNeonLightsColour(Vehicle)
            local _oRGB = {R = r, G = g, B = b}
            Button.Installed = json.encode(_oRGB) == json.encode(Button.Data.ModIndex) 
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        -- elseif Button.Data.ModType == 'NeonSide' and IsVehicleNeonLightEnabled(Vehicle, Data.ModIndex) then
        --     Button.Installed = true
        --     Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        else
            Button.Installed = GetVehicleMod(Vehicle, Button.Data.ModType) == Button.Data.ModIndex
            Menu.UpdateMenuPopulation(Data.Menu, Data.Index, Button)
        end

        VehicleMods = FW.VSync.GetVehicleMods(Vehicle)

        local IsOwner = FW.SendCallback("fw-vehicles:Server:IsVehicleOwner", Plate)
        local IsEmployedAtMechanic = exports['fw-businesses']:IsPlayerInBusiness('Bennys Motorworks') or exports['fw-businesses']:IsPlayerInBusiness('Hayes Repairs')
        if not IsOwner and not IsEmployedAtMechanic then
            return
        end

        local ModsSaved = FW.SendCallback("fw-bennys:Server:SaveMods", NetworkGetNetworkIdFromEntity(Vehicle), VehicleMods, Plate, Button)
        if not ModsSaved then
            -- CloseBennys()
            FW.Functions.Notify("Er ging iets fout tijdens op opslaan van de modificaties! (Kosten: " .. Button.Data.Costs .. ")", "error", 7000)
        end

        ::Cancel::
    end

    Cb('Ok')
end)

exports('GetIsInBennysZone', GetIsInBennysZone)

exports('IsInSecretBennys', function()
    return IsInBennysZone and CurrentBennyZone.data.Secret
end)