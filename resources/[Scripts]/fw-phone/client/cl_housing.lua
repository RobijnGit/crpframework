RegisterNUICallback("Housing/CanRealtor", function(Data, Cb)
    local Result = exports['fw-housing']:CanRealtor()
    Cb(Result)
end)

RegisterNUICallback("Housing/CreateHouse", function(Data, Cb)
    local Id = FW.Shared.RandomInt(6)
    Data.Name = (FW.Functions.GetStreetLabel()):lower() .. '-' .. Id
    Data.Adress = FW.Functions.GetStreetLabel() .. ' ' .. Id
    local Result = FW.SendCallback("fw-housing:Server:CreateHouse", Data)
    Cb(Result)
end)

RegisterNUICallback("Housing/EditHouse", function(Data, Cb)
    local CurrentHouse = exports['fw-housing']:GetCurrentHouse()
    if not CurrentHouse then return Cb(false) end

    local Result = FW.SendCallback("fw-housing:Server:EditHouse", Data, CurrentHouse)
    Cb(Result)
end)

RegisterNUICallback("Housing/GetCurrentHouse", function(Data, Cb)
    local Result = exports['fw-housing']:GetCurrentHouse()
    Cb(Result)
end)

RegisterNUICallback("Housing/GetHouses", function(Data, Cb)
    local Result = { QuickEdit = false }
    local Houses = FW.SendCallback("fw-phone:Server:Housing:GetHouses")
    Result.Houses = Houses

    local CurrentHouse = exports['fw-housing']:GetCurrentHouse()
    if CurrentHouse and exports['fw-housing']:IsInside() and exports['fw-housing']:HasKeyToCurrent() then Result.QuickEdit = true end

    Cb(Result)
end)

RegisterNUICallback("Housing/IsNearHouse", function(Data, Cb)
    local Result = false

    if Data.Id then
        local CurrentHouse = exports['fw-housing']:GetCurrentHouse()
        if CurrentHouse and CurrentHouse.Id == Data.Id then
            Result = (exports['fw-housing']:CanRealtor() or exports['fw-housing']:HasKeyToCurrent())
        else
            local House = exports['fw-housing']:GetHouse(Data.Id)
            if House then
                Result = #(GetEntityCoords(PlayerPedId()) - vector3(House.Coords.x, House.Coords.y, House.Coords.z)) <= 50.0 and (exports['fw-housing']:CanRealtor() or exports['fw-housing']:HasKeyToHouseId(Data.Id))
            end
        end
    else
        Result = exports['fw-housing']:IsInside() and (exports['fw-housing']:CanRealtor() or exports['fw-housing']:HasKeyToCurrent())
    end

    Cb(Result)
end)

RegisterNUICallback("Housing/IsNearAnyHouse", function(Data, Cb)
    local CurrentHouse = exports['fw-housing']:GetCurrentHouse()
    Cb(CurrentHouse and (exports['fw-housing']:CanRealtor() or exports['fw-housing']:HasKeyToCurrent()) or false)
end)

RegisterNUICallback("Housing/SetInteractLocation", function(Data, Cb)
    local CurrentHouse = exports['fw-housing']:GetCurrentHouse()

    if Data.Interaction ~= 'Furniture' then
        if Data.HouseId or CurrentHouse and CurrentHouse.Id then
            local House = exports['fw-housing']:GetHouse(Data.HouseId or CurrentHouse.Id)
            if exports['fw-housing']:IsInside() or #(GetEntityCoords(PlayerPedId()) - vector3(House.Coords.x, House.Coords.y, House.Coords.z)) <= 50.0 then
                TriggerServerEvent("fw-housing:Server:SetInteractLocation", Data.HouseId or CurrentHouse.Id, Data.Interaction, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()), exports['fw-housing']:IsInside())
            else
                FW.Functions.Notify("Dit is te ver..", "error")
            end
        end
    elseif Data.Interaction == "Garage" then
        if exports['fw-housing']:IsInside() then return FW.Functions.Notify("Garage moet wel buiten staan he..", "error") end
        TriggerServerEvent("fw-housing:Server:SetInteractLocation", Data.HouseId or CurrentHouse.Id, Data.Interaction, GetEntityCoords(PlayerPedId()), GetEntityHeading(PlayerPedId()))
    else
        if CurrentHouse and (not Data.HouseId or Data.HouseId == CurrentHouse.Id) and exports['fw-housing']:IsInside() then
            ClosePhone(true)
            Citizen.SetTimeout(100, function()
                TriggerEvent('fw-housing:Client:OpenFurniture', CurrentHouse.Id)
            end)
        end
    end

    Cb("Ok")
end)

RegisterNUICallback("Housing/SetGPS", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    SetNewWaypoint(House.Coords.x, House.Coords.y)

    Cb("Ok")
end)

RegisterNUICallback("Housing/ToggleLock", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    TriggerEvent('fw-housing:Client:LockProperty', Data.HouseId)

    Cb("Ok")
end)

RegisterNUICallback("Housing/SellHouse", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    local Result = FW.SendCallback("fw-housing:Server:SellHouse", Data.HouseId)
    Cb({Success = Result})
end)

RegisterNUICallback("Housing/PurchaseHouse", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    local Result = FW.SendCallback("fw-housing:Server:PurchaseHouse", Data.HouseId)
    Cb(Result)
end)

RegisterNUICallback("Housing/GetKeys", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    local Result = FW.SendCallback("fw-housing:Server:GetHousingKeys", Data.HouseId)
    Cb(Result)
end)

RegisterNUICallback("Housing/AddKeys", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    TriggerServerEvent("fw-housing:Server:SetKeyState", Data.HouseId, Data.Target, true)
    Cb("Ok")
end)

RegisterNUICallback("Housing/RemoveKeys", function(Data, Cb)
    local House = exports['fw-housing']:GetHouse(Data.HouseId)
    if not House then return end

    TriggerServerEvent("fw-housing:Server:SetKeyState", Data.HouseId, Data.Target, false)
    Cb("Ok")
end)

RegisterNUICallback("Housing/DeleteHouse", function(Data, Cb)
    local House = exports['fw-housing']:GetCurrentHouse()
    if House == nil then return end

    TriggerServerEvent("fw-housing:Server:DeleteHouse", House.Id)
    Cb("Ok")
end)

RegisterNUICallback("Housing/SellLocation", function(Data, Cb)
    local House = exports['fw-housing']:GetCurrentHouse()
    if House == nil then return end

    TriggerServerEvent("fw-housing:Server:SellLocation", House.Id, Data)
    Cb("Ok")
end)