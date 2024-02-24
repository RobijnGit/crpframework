local LastAlertSent = 0
local MaxContainerWeight = 1000
local CompatibleItems = {
    ["plastic"] = true,
    ["metalscrap"] = true,
    ["copper"] = true,
    ["aluminum"] = true,
    ["steel"] = true,
    ["rubber"] = true,
    ["glass"] = true,
    ["electronics"] = true,
}

RegisterNetEvent('FW:Client:OnPlayerLoaded')
AddEventHandler('FW:Client:OnPlayerLoaded', function()
    Config.Containers = FW.SendCallback("fw-misc:Server:GetContainers")
    SetupContainers()
end)

RegisterNetEvent("fw-misc:Client:SyncContainer")
AddEventHandler("fw-misc:Client:SyncContainer", function(ContainerId, Key, Value)
    Config.Containers[ContainerId][Key] = Value
end)

RegisterNetEvent("fw-misc:Client:OpenContainer")
AddEventHandler("fw-misc:Client:OpenContainer", function(Data)
    local ContainerData = Config.Containers[Data.ContainerId]
    if ContainerData == nil then return end

    Citizen.SetTimeout(250, function()
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Container Pincode', Icon = 'fas fa-ellipsis-h', Name = 'Code', Type = 'password' },
        })

        if Result and Result.Code and ContainerData.Pin == Result.Code then
            PlaySoundFrontend(-1, "Pin_Good", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")

            local ContainerMeta = FW.SendCallback("fw-misc:Server:GetContainerMeta", Data.ContainerId)
            local ContainerWeight = 0

            local PromptOptions = {
                { Value = "Add", Text = "Materialen toevoegen" },
                { Value = "WithdrawAll", Text = "Alle materialen opnemen" },
            }

            for k, v in pairs(ContainerMeta) do
                if CompatibleItems[k] and v > 0 then
                    local ItemData = exports['fw-inventory']:GetItemData(k)
                    ContainerWeight = ContainerWeight + (ItemData.Weight * v)
                    table.insert(PromptOptions, {
                        Value = "Withdraw:" .. k,
                        Text = "Opnemen: " .. ItemData.Label .. " - " .. v
                    })
                end
            end

            local Result = exports['fw-ui']:CreateInput({
                {
                    Label = "Actie",
                    Name = "Action",
                    Choices = PromptOptions,
                },
                {
                    Label = "Aantal",
                    Name = "Value"
                }
            })

            if not Result or not Result.Action or Result.Action == '' then
                return
            end

            if Result.Action == "Add" then
                if tonumber(Result.Value) <= 0 then return end
                local DepositWeight = 0

                for k, v in pairs(CompatibleItems) do
                    local Quantity = exports['fw-inventory']:GetItemCount(k)
                    if Quantity ~= 0 then
                        local ItemData = exports['fw-inventory']:GetItemData(k)
                        local DepositQuantity = math.min(tonumber(Result.Value), Quantity)
                        DepositWeight = DepositWeight + (ItemData.Weight * DepositQuantity)

                        if (ContainerWeight + DepositWeight) > MaxContainerWeight then
                            return FW.Functions.Notify("Je kan maar maximaal 1000 kg aan materialen in deze container stoppen..", "error")
                        end

                        local DidRemove = FW.SendCallback("FW:RemoveItem", k, DepositQuantity)
                        if DidRemove then
                            ContainerMeta[k] = ((ContainerMeta[k] or 0) + DepositQuantity)
                        end
                    end
                end

                FW.Functions.Notify("Materialen toegevoegd!", "success")
                FW.TriggerServer("fw-misc:Server:SaveContainerMeta", Data.ContainerId, ContainerMeta)
            elseif Result.Action == "WithdrawAll" then
                local AddItems = {}

                for k, v in pairs(CompatibleItems) do
                    if ContainerMeta[k] and ContainerMeta[k] > 0 then
                        AddItems[k] = ContainerMeta[k]
                        ContainerMeta[k] = 0
                    end
                end

                FW.TriggerServer("fw-misc:Server:SaveContainerMeta", Data.ContainerId, ContainerMeta, AddItems)
            elseif string.find(Result.Action, "Withdraw:") then
                if tonumber(Result.Value) <= 0 then return end

                local ItemName = string.match(Result.Action, ":(.+)")
                if not ContainerMeta[ItemName] or ContainerMeta[ItemName] <= 0 then
                    return
                end

                local Quantity = math.min(tonumber(Result.Value), ContainerMeta[ItemName])
                ContainerMeta[ItemName] = ContainerMeta[ItemName] - Quantity

                FW.TriggerServer("FW:AddItem", ItemName, Quantity, false, false, true)
                FW.TriggerServer("fw-misc:Server:SaveContainerMeta", Data.ContainerId, ContainerMeta)
            end
        else
            PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
        end
    end)
end)

RegisterNetEvent("fw-misc:Client:ChangePincode")
AddEventHandler("fw-misc:Client:ChangePincode", function(Data)
    local ContainerData = Config.Containers[Data.ContainerId]
    if ContainerData == nil then return end

    if not exports['fw-businesses']:HasRolePermission("Cortainer", "StashAccess") then
        return FW.Functions.Notify("Geen toegang..", "error")
    end
    
    Citizen.SetTimeout(250, function()
        local Result = exports['fw-ui']:CreateInput({
            { Label = 'Huidige Pincode', Icon = 'fas fa-ellipsis-h', Name = 'Code', Type = 'password' },
            { Label = 'Nieuwe Pincode', Icon = 'fas fa-ellipsis-h', Name = 'NewCode', Type = 'password' },
        })

        if Result and Result.Code and ContainerData.Pin == Result.Code then
            TriggerServerEvent("fw-misc:Server:ChangeContainerCode", Data.ContainerId, Result.NewCode)
            PlaySoundFrontend(-1, "Pin_Good", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
        else
            PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")
        end
    end)
end)

-- RegisterNetEvent("fw-misc:Client:TransferOwnership")
-- AddEventHandler("fw-misc:Client:TransferOwnership", function(Data)
--     local ContainerData = Config.Containers[Data.ContainerId]
--     if ContainerData == nil then return end

--     if not exports['fw-businesses']:HasRolePermission("Cortainer", "StashAccess") then
--         return FW.Functions.Notify("Geen toegang..", "error")
--     end

--     local Result = exports['fw-ui']:CreateInput({
--         { Label = 'BSN', Icon = 'fas fa-heading', Name = 'Cid' },
--     })

--     if Result and Result.Cid then
--         TriggerServerEvent("fw-misc:Server:SetContainerOwnership", Data.ContainerId, Result.Cid)
--     end
-- end)

-- RegisterNetEvent("fw-misc:Client:HackContainer")
-- AddEventHandler("fw-misc:Client:HackContainer", function(Data)
--     local HasSecurityHackingDevice = exports['fw-inventory']:HasEnoughOfItem("security_hacking_device", 1)
--     if not HasSecurityHackingDevice then return FW.Functions.Notify("Je mist een apperaatje..", "error") end
--     if not exports['fw-inventory']:HasEnoughOfItem('heist-drill-basic', 1) then return FW.Functions.Notify("Je mist een drill..", "error") end

--     local ContainerData = Config.Containers[Data.ContainerId]
--     if ContainerData == nil then return end

--     if CurrentCops < Config.RequiredCopsContainerHack then return FW.Functions.Notify("Je kan dit nu niet doen..", "error") end

--     local CanRobContainer = FW.SendCallback("fw-misc:Server:IsContainerRobbable", Data.ContainerId)
--     if not CanRobContainer then return FW.Functions.Notify("Je kijkt naar de container en merkt dat het slot al beschadigd is..", "error") end

--     if GetGameTimer() - LastAlertSent > 10000 then
--         LastAlertSent = GetGameTimer()
--         TriggerServerEvent("fw-mdw:Server:SendAlert:Container", GetEntityCoords(PlayerPedId()), FW.Functions.GetStreetLabel(), ContainerData.Grade)
--     end

--     local Item = exports["fw-inventory"]:GetItemByName('security_hacking_device', '')
--     if Item == nil then return FW.Functions.Notify("Waar is je apperaatje nou ineens heen?", "error") end
--     TriggerServerEvent('fw-inventory:Server:DecayItem', 'security_hacking_device', Item.Slot, 66.66)

--     local Outcome = exports['fw-ui']:StartThermite(10)
--     if not Outcome then return PlaySoundFrontend(-1, "Pin_Bad", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS") end
--     PlaySoundFrontend(-1, "Pin_Good", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS")

--     TriggerServerEvent('fw-misc:Server:Container:SetContainerHack', Data.ContainerId)

--     Citizen.SetTimeout(4500, function()
--         local DrillOutcome = exports['fw-heists']:DrillMinigame()
--         if not DrillOutcome then
--             return
--         end

--         local Item = exports["fw-inventory"]:GetItemByName('security_hacking_device')
--         if Item == nil then return FW.Functions.Notify("Waar is je apperaatje nou ineens heen?", "error") end
--         TriggerServerEvent('fw-inventory:Server:DecayItem', 'security_hacking_device', Item.Slot, 66.66)

--         if exports['fw-inventory']:CanOpenInventory() then
--             FW.TriggerServer('fw-inventory:Server:OpenInventory', 'Stash', 'Container-' .. ContainerData.ContainerId, Config.ContainerSizes[ContainerData.Grade].Slots, Config.ContainerSizes[ContainerData.Grade].Weight)
--         end
--     end)
-- end)

function SetupContainers()
    for k, v in pairs(Config.Containers) do
        exports['fw-ui']:AddEyeEntry("container-" .. v.ContainerId, {
            Type = 'Zone',
            SpriteDistance = 5.0,
            Distance = 1.5,
            ZoneData = {
                Center = vector3(v.Coords.x, v.Coords.y, v.Coords.z),
                Length = 0.5,
                Width = 2.5,
                Data = {
                    heading = v.Coords.w,
                    minZ = v.Coords.z - 1.0,
                    maxZ = v.Coords.z + 1.5
                },
            },
            Options = {
                {
                    Name = 'open',
                    Icon = 'fas fa-box-open',
                    Label = 'Container Openen',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:OpenContainer',
                    EventParams = { ContainerId = k },
                    Enabled = function(Entity)
                        return true
                    end,
                },
                {
                    Name = 'change_pin',
                    Icon = 'fas fa-circle',
                    Label = 'Pincode Veranderen',
                    EventType = 'Client',
                    EventName = 'fw-misc:Client:ChangePincode',
                    EventParams = { ContainerId = k },
                    Enabled = function(Entity)
                        return exports['fw-businesses']:HasRolePermission("Cortainer", "StashAccess")
                    end,
                },
                -- {
                --     Name = 'hack',
                --     Icon = 'fas fa-user-secret',
                --     Label = 'Container Hacken',
                --     EventType = 'Client',
                --     EventName = 'fw-misc:Client:HackContainer',
                --     EventParams = { ContainerId = k },
                --     Enabled = function(Entity)
                --         return exports['fw-inventory']:HasEnoughOfItem('security_hacking_device', 1)
                --     end,
                -- },
            }
        })
    end
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", SetupContainers)