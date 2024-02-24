local InVehicle, HasOffer, IsBusy, TaxiBlip = false, false, false, false

RegisterNetEvent("baseevents:enteredVehicle")
AddEventHandler("baseevents:enteredVehicle", function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = true

    local Hash = GetEntityModel(Vehicle)
    if Hash ~= GetHashKey("taxi") then
        return
    end

    Citizen.CreateThread(function()
        while InVehicle do
            Citizen.Wait((1000 * 60) * 6)

            if GetPedInVehicleSeat(Vehicle, -1) == PlayerPedId() then
                if not HasOffer and not IsBusy then
                    FW.Functions.Notify("Er is een werkopdracht beschikbaar, druk op Y om te accepteren of op N om te weigeren.", "primary", 7000)
                    GiveOffer()
                end
            end
        end
    end)
end)

RegisterNetEvent("baseevents:leftVehicle")
AddEventHandler("baseevents:leftVehicle", function(Vehicle, Seat, DisplayName, NetId)
    InVehicle = false
end)

function GiveOffer()
    if HasOffer then return end
    if IsBusy then return end

    HasOffer = true
    Citizen.SetTimeout(15000, function()
        HasOffer = false
    end)

    Citizen.CreateThread(function()
        while HasOffer do
            if IsControlJustPressed(0, 246) then -- Y
                FW.Functions.Notify("Werkopdracht geaccepteerd! Zoek de reiziger op je kaart en haal hem op.")
                StartOffer()
                HasOffer = false
            end

            if IsControlJustPressed(0, 306) then -- N
                FW.Functions.Notify("Werkopdracht geweigerd!")
                HasOffer = false
            end
            Citizen.Wait(4)
        end
    end)
end

function StartOffer()
    if IsBusy then return end
    IsBusy = true

    local NetId, Pickup, Destination = table.unpack(FW.SendCallback("fw-jobmanager:Server:Taxi:CreatePed"))

    CreateTaxiBlip(Pickup, 198, true)

    while not NetworkDoesEntityExistWithNetworkId(NetId) do Citizen.Wait(100) end
    local Ped = NetToPed(NetId)

    SetBlockingOfNonTemporaryEvents(Ped, true)

    local HasPickedUp, HasDroppedOff = false, false

    Citizen.CreateThread(function()
        while true do
            local Coords = GetEntityCoords(PlayerPedId())

            if not HasPickedUp then
                local Vehicle = GetVehiclePedIsIn(PlayerPedId())
                if #(Coords - vector3(Pickup.x, Pickup.y, Pickup.z)) < 5.0 and GetEntitySpeed(Vehicle) < 2.0 then
                    local SeatId = GetFreeSeat(Vehicle)
                    if SeatId ~= false then
                        HasPickedUp = true
                        TaskEnterVehicle(Ped, Vehicle, -1, SeatId, 1.0, 1, 0)
                        CreateTaxiBlip(Destination, 1, true)
                    else
                        FW.Functions.Notify("Lijkt erop dat je geen ruimte hebt voor de reiziger..")
                    end
                end
            end

            if not HasDroppedOff then
                local Vehicle = GetVehiclePedIsIn(PlayerPedId())
                if #(Coords - vector3(Destination.x, Destination.y, Destination.z)) < 3.0 and GetEntitySpeed(Vehicle) < 2.0 then
                    HasDroppedOff = true
                    TaskLeaveVehicle(Ped, Vehicle, 0)
                    TaskWanderStandard(Ped, 10.0, 10)

                    Citizen.SetTimeout(15000, function()
                        FW.TriggerServer("fw-jobmanager:Server:Taxi:DeletePed", NetId, #(vector3(Pickup.x, Pickup.y, Pickup.z) - vector3(Destination.x, Destination.y, Destination.z)))
                    end)

                    break
                end
            end

            Citizen.Wait(1500)
        end

        IsBusy = false
        if DoesBlipExist(TaxiBlip) then
            RemoveBlip(TaxiBlip)
        end
    end)
end

function GetFreeSeat(Vehicle)
    local Seats = GetVehicleMaxNumberOfPassengers(Vehicle)
    local Retval = false

    for i = -1, Seats - 1, 1 do
        if IsVehicleSeatFree(Vehicle, i, true) then
            Retval = i
        end
    end

    if Retval == -1 then
        return false
    end

    return Retval
end

function CreateTaxiBlip(Coords, Sprite, Route)
    if DoesBlipExist(TaxiBlip) then
        RemoveBlip(TaxiBlip)
    end

    TaxiBlip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
    SetBlipSprite(TaxiBlip, Sprite)
    SetBlipColour(TaxiBlip, 5)
    SetBlipScale(TaxiBlip, 1.0)
    if Route then SetBlipRoute(TaxiBlip, true) end
    SetBlipRouteColour(TaxiBlip, 5)
    SetBlipAsShortRange(TaxiBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Taxi")
    EndTextCommandSetBlipName(TaxiBlip)
end