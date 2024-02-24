local TestDrive, SpawningTestDrive = false, false

RegisterNUICallback("Cars/GetShopData", function(Data, Cb)
    local Result = FW.SendCallback("fw-businesses:Server:VehicleShop:GetShopData", CurrentNetwork)
    Cb(Result)
end)

RegisterNUICallback("Cars/GetVehicles", function(Data, Cb)
    local Result = FW.SendCallback("fw-phone:Server:GetVehicles", CurrentNetwork)
    Cb(Result)
end)

RegisterNUICallback("Cars/SetDisplay", function(Data, Cb)
    TriggerServerEvent("fw-businesses:Server:ChangeVehicle", CurrentNetwork, Data.Spot, Data.Vehicle)
    Cb("Ok")
end)

RegisterNUICallback("Cars/GetTestDriving", function(Data, Cb)
    Cb(TestDrive)
end)

RegisterNUICallback("Cars/TestDrive", function(Data, Cb)
    Cb("Ok")
    if TestDrive or SpawningTestDrive then
        return FW.Functions.Notify("Je hebt al een testrit buiten staan..", "error")
    end

    SpawningTestDrive = true

    local IsLockdown = exports['fw-cityhall']:IsLockdownActive("business-" .. CurrentNetwork)
    if IsLockdown and not exports['fw-cityhall']:IsGov() then
        SpawningTestDrive = false
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    end

    TriggerServerEvent("fw-businesses:Server:VehicleShop:TestDrive", CurrentNetwork, Data.Vehicle, false)
    local Result = FW.SendCallback("fw-businesses:Server:VehicleShop:GetShopData", CurrentNetwork)

    local Plate = tostring('TDRIVE' .. math.random(11, 99))
    local NetId = FW.SendCallback("FW:server:spawn:vehicle", Data.Vehicle, { x = Result.TestPos.x, y = Result.TestPos.y, z = Result.TestPos.z, a = Result.TestPos.w }, false, Plate)
    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    
    local Vehicle = NetToVeh(NetId)
    while not DoesEntityExist(Vehicle) do Citizen.Wait(100) end

    NetworkFadeInEntity(Vehicle, true)
    NetworkRequestControlOfEntity(Vehicle)

    TriggerServerEvent("fw-businesses:Server:AutoCare:LoadParts", Plate)
    exports['fw-vehicles']:SetVehicleKeys(Plate, true, false)
    exports['fw-vehicles']:SetFuelLevel(Vehicle, 100.0)

    Citizen.SetTimeout(1000, function()
        exports['fw-vehicles']:LoadVehicleMeta(Vehicle, nil)
        NetworkRegisterEntityAsNetworked(Vehicle)
        FW.Functions.SetVehiclePlate(Vehicle, Plate)
        TestDrive = Data
        TestDrive.Shop = CurrentNetwork
        TestDrive.Entity = Vehicle
        SpawningTestDrive = false
        TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)

        SendNUIMessage({
            Action = "Cars/SetTestDriving",
            TestDrive = TestDrive,
        })

        local Preset = FW.SendCallback("fw-businesses:Server:VehicleShop:GetPreset", TestDrive.Shop, TestDrive.Vehicle)
        if Preset and next(Preset) ~= nil then
            FW.VSync.ApplyVehicleMods(Vehicle, Preset)
        end
    end)
end)

RegisterNUICallback("Cars/ReturnCar", function(Data, Cb)
    TriggerServerEvent("fw-businesses:Server:VehicleShop:TestDrive", TestDrive.Shop, TestDrive.Vehicle, true)
    FW.VSync.DeleteVehicle(TestDrive.Entity)
    TestDrive = false
    SendNUIMessage({
        Action = "Cars/SetTestDriving",
        TestDrive = TestDrive,
    })
    Cb("Ok")
end)

RegisterNUICallback("Cars/SavePreset", function(Data, Cb)
    TriggerServerEvent("fw-businesses:Server:VehicleShop:SetPreset", TestDrive.Shop, TestDrive.Vehicle, FW.VSync.GetVehicleMods(TestDrive.Entity))
    Cb("Ok")
end)

RegisterNUICallback("Cars/Sell", function(Data, Cb)
    local IsLockdown = exports['fw-cityhall']:IsLockdownActive("business-" .. CurrentNetwork)
    if IsLockdown and not exports['fw-cityhall']:IsGov() then
        Cb("Ok")
        return FW.Functions.Notify("Bedrijf is in lockdown..", "error")
    end

    TriggerServerEvent("fw-businesses:Server:VehicleShop:SellVehicle", TestDrive, Data, VehToNet(TestDrive.Entity))
    Cb("Ok")
end)

RegisterNetEvent("fw-phone:Client:Cars:SetTestDrive")
AddEventHandler("fw-phone:Client:Cars:SetTestDrive", function(Data)
    TestDrive = Data
    SendNUIMessage({
        Action = "Cars/SetTestDriving",
        TestDrive = TestDrive,
    })
end)