local CreatedTables = {}
local IsPlacing, IsCooking, CookingEntity = false, false, nil
local ExplodeThisCook = false
local CurrentStage = 0

Citizen.CreateThread(function()
    while true do
        local Coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.MethTables) do
            -- Only process 100 per frame.
            if k % 100 == 0 then
                Citizen.Wait(0)
            end

            if #(Coords - v.Coords) < (50.0) then
                if not CreatedTables[v.Id] then
                    if CreatedTables[v.Id] then
                        DeleteObject(CreatedTables[v.Id].Object)
                        CreatedTables[v.Id] = nil
                    end

                    local TableObject = CreateTable(v.Coords, v.Rotation)

                    CreatedTables[v.Id] = {
                        Object = TableObject,
                    }
                end
            elseif CreatedTables[v.Id] then
                DeleteObject(CreatedTables[v.Id].Object)
                CreatedTables[v.Id] = nil
            end
        end

        Citizen.Wait(2000)
    end
end)

RegisterNetEvent("fw-illegal:Client:SetMethTableData")
AddEventHandler("fw-illegal:Client:SetMethTableData", function(Type, TableId, TableData)
    if not LoggedIn then return end
    if Type == "Set" then
        for k, v in pairs(Config.MethTables) do
            if v.Id == TableId then
                Config.MethTables[k] = TableData
                return
            end
        end

        table.insert(Config.MethTables, TableData)
    elseif Type == "Remove" then
        for k, v in pairs(Config.MethTables) do
            if v.Id == TableId then
                table.remove(Config.MethTables, k)
                break
            end
        end

        if CreatedTables[TableId] and CreatedTables[TableId].Object then
            DeleteObject(CreatedTables[TableId].Object)
            CreatedTables[TableId] = nil
        end
    end
end)

RegisterNetEvent("fw-illegal:Client:Meth:PlaceTable")
AddEventHandler("fw-illegal:Client:Meth:PlaceTable", function(Item)
    if IsPlacing then
        return
    end

    if not exports['fw-inventory']:HasEnoughOfItem('methtable', 1) then
        return FW.Functions.Notify("Je mist een tafel.", "error")
    end

    IsPlacing = true
    local DidPlace, Coords, Rotation = table.unpack(DoEntityPlacer('v_ret_ml_tableb', 10.0, true, true, nil))
    if not DidPlace then
        IsPlacing = false
        return
    end

    if exports['fw-interiors']:IsInsideInterior() then
        IsPlacing = false
        return FW.Functions.Notify("Je kan de chemische dampen in een gesloten ruimte niet aan..", "error")
    end

    local Finished = FW.Functions.CompactProgressbar(5000, "Tafel plaatsen...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", anim = "machinic_loop_mechandplayer", flags = 1 }, {}, {}, false)
	StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)

	if not Finished then
        IsPlacing = false
        return
    end

    FW.TriggerServer("fw-illegal:Server:PlaceMethTable", Coords, Rotation)
    IsPlacing = false
end)

RegisterNetEvent("fw-illegal:Client:PickupMethTable")
AddEventHandler("fw-illegal:Client:PickupMethTable", function(Data, Entity)
    IsCooking, CookingEntity, CurrentStage = false, false, 0

    local TableData = GetMethTableByEntity(Entity)
    if not TableData then return end

    local Finished = FW.Functions.CompactProgressbar(30000, "Tafel oppakken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", anim = "machinic_loop_mechandplayer", flags = 1 }, {}, {}, false)
	StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
	if not Finished then return end

    FW.TriggerServer("fw-illegal:Server:DestroyMethTable", TableData.Id)
end)

RegisterNetEvent("fw-illegal:Client:StartCookingMeth")
AddEventHandler("fw-illegal:Client:StartCookingMeth", function(Data, Entity)
    if IsCooking then
        return FW.Functions.Notify("Je bent al aan het kokkenrellen..")
    end

    local TableData = GetMethTableByEntity(Entity)
    if not TableData then return end

    if TableData.Owner ~= FW.Functions.GetPlayerData().citizenid then
        return FW.Functions.Notify("Dit is niet jouw tafel..")
    end

    if TableData.LastCook + ((60 * 60) * 1.5) > GetCloudTimeAsInt() then -- 1 hour and 30 minutes
        return FW.Functions.Notify("De tafel wordt schoongemaakt, wacht nog even.", "error")
    end

    local Result = exports['fw-minigames']:StartSliderMinigame({
        { min = 0, max = 100, step = 1, value = 0 },
        { min = 0, max = 100, step = 1, value = 0 },
        { min = 0, max = 100, step = 1, value = 0 },
    })

    local Success = FW.SendCallback("fw-illegal:Server:StartCookingMeth", TableData.Id, Result)
    if Success then
        FW.Functions.Notify("Gestart met koken.")
        CurrentStage = 1
        IsCooking = true
        CookingEntity = Entity
        ExplodeThisCook = math.random(1, 300) == 23
    end
end)

RegisterNetEvent("fw-illegal:Client:DoMethCook")
AddEventHandler("fw-illegal:Client:DoMethCook", function(Data, Entity)
    local TableData = GetMethTableByEntity(Entity)
    if not TableData then return end

    if not IsCooking then
        return
    end

    if CurrentStage ~= Data.Stage then
        return
    end

    local DoExplode = false
    if TableData.Owner ~= FW.Functions.GetPlayerData().citizenid then
        return FW.Functions.Notify("Dit is niet jouw tafel..")
    end

    local Time, Text, Dict, Anim = 30000, "Doing absolutely nothing " .. Data.Stage, "", ""
    if Data.Stage == 1 then
        Time, Text, Dict, Anim = 30000, "Goederen klaarmaken", "anim@heists@prison_heiststation@", "pickup_bus_schedule"
    elseif Data.Stage == 2 then
        Time, Text, Dict, Anim = 45000, "Goederen combineren", "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle"
        if ExplodeThisCook and math.random(1, 100) > 80 then DoExplode, ExplodeThisCook = true, false end
    elseif Data.Stage == 3 then
        Time, Text, Dict, Anim = 25000, "Water mengen", "weapon@w_sp_jerrycan", "fire"
        if ExplodeThisCook and math.random(1, 100) > 70 then DoExplode, ExplodeThisCook = true, false end
    elseif Data.Stage == 4 then
        Time, Text, Dict, Anim = 60000, "Oplosmiddel toevoegen", "weapon@w_sp_jerrycan", "fire"
        if ExplodeThisCook and math.random(1, 100) > 50 then DoExplode, ExplodeThisCook = true, false end
    elseif Data.Stage == 5 then
        Time, Text, Dict, Anim = 120000, "Product kristalliseren", "random@train_tracks", "idle_e"
        if ExplodeThisCook and math.random(1, 100) > 30 then DoExplode, ExplodeThisCook = true, false end
    elseif Data.Stage == 6 then
        Time, Text, Dict, Anim = 60000, "Product inpakken", "anim@heists@prison_heiststation@", "pickup_bus_schedule"
    end

    if DoExplode then
        Citizen.SetTimeout(Time / 2, function()
            AddExplosion(GetEntityCoords(CookingEntity), GRENADE, 4.0, true, false, 1.0)
            IsCooking, CookingEntity, CurrentStage = false, false, 0
        end)
    end

    local Finished = FW.Functions.CompactProgressbar(Time, Text, false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = Dict, anim = Anim, flags = 1 }, {}, {}, false)
	StopAnimTask(PlayerPedId(), Dict, Anim, 1.0)
	if not Finished or DoExplode then return end

    if Data.Stage >= 6 then
        IsCooking, CookingEntity, CurrentStage = false, false, 0
        FW.TriggerServer("fw-illegal:Server:RewardMethTable", TableData.Id)

        if not exports['fw-police']:IsStatusAlreadyActive('chemicals') then
            TriggerEvent('fw-police:Client:SetStatus', 'chemicals', 250)
        end

        return
    else
        CurrentStage = CurrentStage + 1
    end
end)

RegisterNetEvent("fw-illegal:Client:CutMeth")
AddEventHandler("fw-illegal:Client:CutMeth", function(Item)
    if not exports['fw-inventory']:HasEnoughOfItem('emptybaggies') then
        return
    end

    if not exports['fw-inventory']:HasEnoughOfItem('scales') then
        return
    end

    if not exports['fw-inventory']:HasEnoughOfItem('methcured') then
        return
    end

    local Finished = FW.Functions.CompactProgressbar(1000, "Inpakken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    if not Finished then return end

    FW.TriggerServer("fw-illegal:Server:CutMethReward", Item)
end)

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
    if FromItem.Item ~= '1gmeth' then return end
    if ToItem.Item ~= 'methpipe' then return end

    local Quantity = FromItem.Amount
    if not Quantity then return end
    if Quantity > 1 then
        return FW.Functions.Notify("Hmm lijkt alsof ik niet zoveel kan doen..", "error")
    end
    
    if ToItem.Info.Uses + Quantity > 4 then
        return FW.Functions.Notify("Volgensmij zit hij vol..", "error")
    end

    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(10000, "Meth pijp inpakken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    if not Finished then return end

    FW.TriggerServer("fw-illegal:Server:LoadMethpipe", Quantity, FromItem, ToItem)
end)

RegisterNetEvent("fw-illegal:Client:UseMethpipe")
AddEventHandler("fw-illegal:Client:UseMethpipe", function(Item)
    local Uses = Item.Info.Uses or 0
    if Uses <= 0 then
        return FW.Functions.Notify("Het lijkt erop dat het op is :(", "error")
    end

    local Outcome = exports['fw-ui']:StartSkillTest(1, { 12, 18 }, { 2400, 2500 }, true)

    if not Outcome then return end
    if not exports['fw-inventory']:HasEnoughOfItem('methpipe', 1) then return end

    local Purity = FW.SendCallback("fw-illegal:Server:SetMethpipeUses", Item.Slot)

    exports['fw-assets']:AddProp('CrackPipe')
    local Finished = FW.Functions.CompactProgressbar(1500, "Methje roken...", false, false, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "switch@trevor@trev_smoking_meth", anim = "trev_smoking_meth_loop", flags = 49 }, {}, {}, false)
    TriggerEvent("fw-fx:Client:DrugEffect", "Meth", {Purity = Purity})
end)

AddEventHandler("onResourceStop", function()
    for k, v in pairs(CreatedTables) do
        if v.Object then
            DeleteObject(v.Object)
        end
    end
end)

function InitMeth()
    Config.MethTables = FW.SendCallback("fw-illegal:Server:GetMethTables")

    exports['fw-ui']:AddEyeEntry(GetHashKey('v_ret_ml_tableb'), {
        Type = 'Model',
        Model = 'v_ret_ml_tableb',
        SpriteDistance = 5.0,
        Distance = 2.0,
        Options = {
            {
                Name = 'start',
                Icon = 'fas fa-thermometer-full',
                Label = 'Start met Koken',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:StartCookingMeth',
                EventParams = '',
                Enabled = function(Entity)
                    return (not exports['fw-illegal']:IsCookingMeth(Entity))
                end,
            },
            {
                Name = 'destroy',
                Icon = 'fas fa-arrow-up',
                Label = 'Tafel Oppaken',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:PickupMethTable',
                EventParams = '',
                Enabled = function(Entity)
                    return true
                end,
            },
            {
                Name = 'prepare',
                Icon = 'fas fa-thermometer-full',
                Label = 'Goederen klaarmaken',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:DoMethCook',
                EventParams = {Stage = 1},
                Enabled = function(Entity)
                    local _IsCooking = exports['fw-illegal']:IsCookingMeth(Entity)
                    local _CurrentStage = exports['fw-illegal']:GetCurrentCookingStage(Entity)
                    return _IsCooking and _CurrentStage == 1
                end,
            },
            {
                Name = 'combine',
                Icon = 'fas fa-thermometer-full',
                Label = 'Goederen combineren',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:DoMethCook',
                EventParams = {Stage = 2},
                Enabled = function(Entity)
                    local _IsCooking = exports['fw-illegal']:IsCookingMeth(Entity)
                    local _CurrentStage = exports['fw-illegal']:GetCurrentCookingStage(Entity)
                    return _IsCooking and _CurrentStage == 2
                end,
            },
            {
                Name = 'water',
                Icon = 'fas fa-thermometer-full',
                Label = 'Meng met water',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:DoMethCook',
                EventParams = {Stage = 3},
                Enabled = function(Entity)
                    local _IsCooking = exports['fw-illegal']:IsCookingMeth(Entity)
                    local _CurrentStage = exports['fw-illegal']:GetCurrentCookingStage(Entity)
                    return _IsCooking and _CurrentStage == 3
                end,
            },
            {
                Name = 'solvent',
                Icon = 'fas fa-thermometer-full',
                Label = 'Voeg oplosmiddel toe',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:DoMethCook',
                EventParams = {Stage = 4},
                Enabled = function(Entity)
                    local _IsCooking = exports['fw-illegal']:IsCookingMeth(Entity)
                    local _CurrentStage = exports['fw-illegal']:GetCurrentCookingStage(Entity)
                    return _IsCooking and _CurrentStage == 4
                end,
            },
            {
                Name = 'crystalize',
                Icon = 'fas fa-thermometer-full',
                Label = 'Product kristalliseren',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:DoMethCook',
                EventParams = {Stage = 5},
                Enabled = function(Entity)
                    local _IsCooking = exports['fw-illegal']:IsCookingMeth(Entity)
                    local _CurrentStage = exports['fw-illegal']:GetCurrentCookingStage(Entity)
                    return _IsCooking and _CurrentStage == 5
                end,
            },
            {
                Name = 'pack',
                Icon = 'fas fa-thermometer-full',
                Label = 'Product inpakken',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:DoMethCook',
                EventParams = {Stage = 6},
                Enabled = function(Entity)
                    local _IsCooking = exports['fw-illegal']:IsCookingMeth(Entity)
                    local _CurrentStage = exports['fw-illegal']:GetCurrentCookingStage(Entity)
                    return _IsCooking and _CurrentStage == 6
                end,
            },
        }
    })
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", InitMeth)

function CreateTable(Coords, Rotation)
    local Model = "v_ret_ml_tableb"
    exports['fw-assets']:RequestModelHash(Model)

    local TableObject = CreateObject(Model, Coords.x, Coords.y, Coords.z, false, false, false)
    FreezeEntityPosition(TableObject, true)
    SetEntityHeading(TableObject, Rotation + 0.0)

    return TableObject
end

function GetMethTableByEntity(Entity)
    for k, v in pairs(CreatedTables) do
        if v.Object and v.Object == Entity then
            for i, j in pairs(Config.MethTables) do
                if j.Id == k then
                    return j
                end
            end
        end
    end
    return false
end

function IsCookingMeth(Entity)
    return IsCooking and CookingEntity == Entity
end
exports("IsCookingMeth", IsCookingMeth)

function GetCurrentCookingStage(Entity)
    return IsCooking and CookingEntity == Entity and CurrentStage or false
end
exports("GetCurrentCookingStage", GetCurrentCookingStage)

-- RegisterCommand("anim", function(source, args)
--     ClearPedTasksImmediately(PlayerPedId())

--     local Dict, Anim = args[1], args[2]

--     RequestAnimDict(Dict)
--     while not HasAnimDictLoaded(Dict) do Wait(4) end

--     TaskPlayAnim(PlayerPedId(), Dict, Anim, 8.0, -8, -1, 1, 0, 0, 0, 0)
-- end)