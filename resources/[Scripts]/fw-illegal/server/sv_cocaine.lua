local CoordsFetchers, CokeVehicles = {}, {}

FW.RegisterServer("fw-illegal:Server:FailedCocaine", function(Source)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Player.Functions.AddMoney('cash', 65000)
    Player.Functions.Notify("De telefoon werdt niet beantwoord.. Je kreeg 65k terug van het mannetje.", "error")
end)

FW.RegisterServer("fw-illegal:Server:CreateCokeDinghy", function(Source, Coords)
    local Plate = ("COK" .. FW.Shared.RandomInt(3) .. FW.Shared.RandomStr(2)):upper()
    local NetId = FW.Functions.SpawnVehicle(Source, "dinghy3", { x = Coords.x, y = Coords.y, z = Coords.z, a = Coords.w, }, false, Plate)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if CokeVehicles[Source] == nil then CokeVehicles[Source] = {} end
    table.insert(CokeVehicles[Source], { Vehicle = Vehicle })
end)

FW.RegisterServer("fw-illegal:Server:DeleteCokeVehicles", function(Source, Coords)
    if CokeVehicles[Source] == nil then return end

    for k, v in pairs(CokeVehicles[Source]) do
        while DoesEntityExist(v.Vehicle) do
            DeleteEntity(v.Vehicle)
            Citizen.Wait(200)
        end
    end
end)

FW.RegisterServer("fw-illegal:Server:BagCocaine", function(Source, Quantity, FromItem, ToItem)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Quantity or Quantity > 5 then return end

    if Player.Functions.RemoveItemByName(FromItem.Item, Quantity, true) and Player.Functions.RemoveItemByName('ammonium-bicarbonate', 1, true) then
        Player.Functions.AddItem("5gcocaine", math.floor(Quantity * 2))
    end
end)

FW.RegisterServer("fw-illegal:Server:LoadCrackpipe", function(Source, Quantity, FromItem, ToItem)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if not Quantity or Quantity > 5 then return end

    if Player.Functions.RemoveItemByName(FromItem.Item, Quantity, true) then
        Player.Functions.SetItemKV("crackpipe", ToItem.Slot, 'Uses', ToItem.Info.Uses + Quantity)
    end
end)

FW.RegisterServer("fw-illegal:Server:SetCrackpipeUses", function(Source, Slot, Uses)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end
    Player.Functions.SetItemKV("crackpipe", Slot, 'Uses', Uses)
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetCokeGuyCoords", function(Source, Cb)
    if CoordsFetchers[Source] then return Cb(false) end
    CoordsFetchers[Source] = true
    Cb(Config.CocaineRun)
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetCocaineSequence", function(Source, Cb)
    Cb(Config.CocaineSequence)
end)

FW.Functions.CreateCallback("fw-illegal:Server:GetCocaineSequenceCoords", function(Source, Cb, SequenceId)
    Cb(Config.SequenceCoords[SequenceId])
end)

FW.Functions.CreateCallback("fw-illegal:Server:CreateCokeVehicle", function(Source, Cb, Coords)
    local Plate = ("COKEC" .. math.random(100, 999)):upper()
    local NetId = FW.Functions.SpawnVehicle(Source, "glendale", { x = Coords.x, y = Coords.y, z = Coords.z, a = Coords.w, }, false, Plate)
    local Vehicle = NetworkGetEntityFromNetworkId(NetId)

    if CokeVehicles[Source] == nil then CokeVehicles[Source] = {} end
    table.insert(CokeVehicles[Source], { Vehicle = Vehicle })

    exports['fw-inventory']:AddItemToInventory('trunk' .. Plate, 'cocainebrick', 1, 1, false, false)

    Cb({NetId = NetId, Plate = Plate})
end)

FW.Functions.CreateUsableItem("cocainebrick", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    FW.TriggerServer("fw-inventory:Server:OpenInventory", Source, 'Crafting', 'CocaineBrick')
end)

FW.Functions.CreateUsableItem("bakingsoda", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    FW.TriggerServer("fw-inventory:Server:OpenInventory", Source, 'Crafting', 'BakingSoda')
end)

FW.Functions.CreateUsableItem("glass", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    FW.TriggerServer("fw-inventory:Server:OpenInventory", Source, 'Crafting', 'GlassPipes')
end)

FW.Functions.CreateUsableItem("crackpipe", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    TriggerClientEvent("fw-illegal:Client:UseCrackpipe", Source, Item)
end)