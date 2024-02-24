local Containers = {}

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", function()
    exports['fw-ui']:AddEyeEntry(GetHashKey("prop_container_ld_d"), {
        Type = 'Model',
        Model = 'prop_container_ld_d',
        SpriteDistance = 10.0,
        Distance = 8.0,
        Options = {
            {
                Name = 'rob',
                Icon = 'fas fa-circle',
                Label = 'Container Openbreken',
                EventType = 'Client',
                EventName = 'fw-misc:Client:OpenStrandedContainer',
                EventParams = {},
                Enabled = function(Entity)
                    local MyCoords = GetEntityCoords(PlayerPedId())
                    local FrontCoords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -6.2, 1.5)
                    local BackCoords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, 6.2, 1.5)

                    if #(MyCoords - FrontCoords) > 2.0 and #(MyCoords - BackCoords) > 2.0 then
                        return false
                    end

                    return FW.SendCallback("fw-misc:Server:IsStrandedContainer", NetworkGetNetworkIdFromEntity(Entity))
                end,
            },
            {
                Name = 'loot',
                Icon = 'fas fa-circle',
                Label = 'Loot pakken',
                EventType = 'Client',
                EventName = 'fw-misc:Client:LootStrandedContainer',
                EventParams = {},
                Enabled = function(Entity)
                    local MyCoords = GetEntityCoords(PlayerPedId())
                    local FrontCoords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, -6.2, 1.5)
                    local BackCoords = GetOffsetFromEntityInWorldCoords(Entity, 0.0, 6.2, 1.5)

                    if #(MyCoords - FrontCoords) > 2.0 and #(MyCoords - BackCoords) > 2.0 then
                        return false
                    end

                    local isStrandedContainer = FW.SendCallback("fw-misc:Server:IsStrandedContainer", NetworkGetNetworkIdFromEntity(Entity))
                    if not isStrandedContainer then return end

                    local ContainerState = FW.SendCallback("fw-misc:Server:GetStrandedContainerState")
                    return ContainerState >= 2
                end,
            }
        }
    })
end)

RegisterNetEvent("fw-misc:Client:OpenStrandedContainer")
AddEventHandler("fw-misc:Client:OpenStrandedContainer", function()
    local Item = exports['fw-inventory']:GetItemByName("heavy-cutters")
    if not Item then
        return FW.Functions.Notify("Je mist een betonschaar.", "error")
    end

    local ContainerState = FW.SendCallback("fw-misc:Server:GetStrandedContainerState")
    if ContainerState == 1 then
        return FW.Functions.Notify("Iemand anders is de container al aan het openbreken..", "error")
    end

    if ContainerState >= 2 then
        return FW.Functions.Notify("De container is al opengebroken..", "error")
    end

    FW.TriggerServer("fw-misc:Server:SetStrandedContainerState", 1)

    TriggerEvent("fw-assets:client:lockpick:animation", true)
    local Outcome = exports['fw-ui']:StartSkillTest(math.random(6, 9), {10, 15}, { 1500, 3000 }, true)
    TriggerEvent("fw-assets:client:lockpick:animation", false)

    if not Outcome then
        FW.TriggerServer("fw-misc:Server:SetStrandedContainerState", 0)
        if math.random() < 0.2 then
            FW.SendCallback("FW:RemoveItem", "heavy-cutters", 1, Item.Slot)
        end
        return
    end

    local NewContainerState = FW.SendCallback("fw-misc:Server:GetStrandedContainerState")
    if NewContainerState == 2 then
        return FW.Functions.Notify("Iemand anders heeft de container al opengebroken..", "error")
    end

    FW.TriggerServer("fw-misc:Server:SetStrandedContainerState", 2)
end)

RegisterNetEvent("fw-misc:Client:LootStrandedContainer")
AddEventHandler("fw-misc:Client:LootStrandedContainer", function()
    local ContainerState = FW.SendCallback("fw-misc:Server:GetStrandedContainerState")
    if ContainerState == 1 then
        return FW.Functions.Notify("Iemand anders is de container al aan het openbreken..", "error")
    end

    if ContainerState == 2 then
        return FW.Functions.Notify("Nog even wachten..", "error")
    end

    if ContainerState == 4 then
        return FW.Functions.Notify("Container is al leeggetrokken..", "error")
    end

    if ContainerState ~= 3 then
        return
    end

    local Stealing = true
    exports['fw-assets']:AddProp('HeistBag')
    FW.Functions.Progressbar("rob", "Stelen..", 60000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash_heels",
        anim = "grab",
        flags = 16
    }, {}, {}, function()
        Stealing = false
        FW.TriggerServer("fw-misc:Server:GiveContainerLoot")
        FW.TriggerServer("fw-misc:Server:SetStrandedContainerState", 4)
    end, function()
        Stealing = false
    end)

    Citizen.CreateThread(function()
        while Stealing do
            TriggerServerEvent('fw-ui:Server:gain:stress', math.random(2, 3))
            Citizen.Wait(6500)
        end

        StopAnimTask(PlayerPedId(), "anim@heists@ornate_bank@grab_cash_heels", "grab", 1.0)
        exports['fw-assets']:RemoveProp()
    end)

end)

RegisterNetEvent("fw-misc:Client:SetStrandedContainerBlip")
AddEventHandler("fw-misc:Client:SetStrandedContainerBlip", function(Coords)
    local Blip = AddBlipForRadius(Coords.x, Coords.y, Coords.z, 700.0)
    SetBlipHighDetail(Blip, true)
    SetBlipRotation(Blip, 0)
    SetBlipColour(Blip, 0)
    SetBlipAlpha(Blip, 100)

    local Alpha = 100
    Citizen.CreateThread(function()
        while Alpha > 0 do

            Alpha = Alpha - 1
            SetBlipAlpha(Blip, Alpha)

            Citizen.Wait((60 * 1000) * 3)
        end

        RemoveBlip(Blip)
    end)
end)