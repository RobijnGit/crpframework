local CokeGuyCoords, CokeRunStarted, CallStatus, DropCoords = false, false, false, {}
DropoffBlip = false

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
    if FromItem.Item ~= '10gcocaine' then return end
    if ToItem.Item ~= 'ammonium-bicarbonate' then return end

    local Quantity = FromItem.Amount
    if not Quantity or Quantity > 5 then
        return FW.Functions.Notify("Hmm lijkt alsof ik niet zoveel kan doen..", "error")
    end

    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(5000 * Quantity, "Aan het opsplitsen in zakjes...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    if not Finished then return end

    FW.TriggerServer("fw-illegal:Server:BagCocaine", Quantity, FromItem, ToItem)
end)

RegisterNetEvent("fw-inventory:Client:OnItemInsert")
AddEventHandler("fw-inventory:Client:OnItemInsert", function(FromItem, ToItem)
    if FromItem.Item ~= '5gcrack' then return end
    if ToItem.Item ~= 'crackpipe' then return end

    local Quantity = FromItem.Amount
    if not Quantity then return end

    if ToItem.Info.Uses + Quantity > 5 then
        return FW.Functions.Notify("Hmm lijkt alsof ik niet zoveel kan doen..", "error")
    end

    exports['fw-inventory']:SetBusyState(true)

    local Finished = FW.Functions.CompactProgressbar(20000, "Crack pijp inpakken...", false, true, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, {}, {}, {}, false)
    exports['fw-inventory']:SetBusyState(false)
    if not Finished then return end

    FW.TriggerServer("fw-illegal:Server:LoadCrackpipe", Quantity, FromItem, ToItem)
end)

RegisterNetEvent("fw-illegal:Client:StartCocaineHeist")
AddEventHandler("fw-illegal:Client:StartCocaineHeist", function()
    if #(GetEntityCoords(PlayerPedId()) - vector3(CokeGuyCoords.x, CokeGuyCoords.y, CokeGuyCoords.z)) > 5.0 then
        return
    end

    if not exports['fw-sync']:BlackoutActive() or CokeRunStarted then
        return FW.Functions.Notify("De man zegt 'Ga weg mafketel!' en kijkt je van top tot teen aan.")
    end

    CokeRunStarted = FW.SendCallback("FW:RemoveCash", 100000)
    if not CokeRunStarted then
        return FW.Functions.Notify("De man zegt 'Hiermee ga je het niet redden' en gebaart dat je weg moet gaan.")
    end

    FW.Functions.Notify("De man zegt 'Gebruik ze verstandig' en overhandigt je een lijst met telefoonnummers.")

    DropCoords = {}
    CallStatus = 1
    SetupCocainePeeks()
    SetupPhoneCall()
end)

RegisterNetEvent("fw-illegal:Client:DoCocaineCall")
AddEventHandler("fw-illegal:Client:DoCocaineCall", function(Data, Entity)
    TriggerEvent('fw-sound:client:play', 'payphoneend', 1.0)

    if not Data.IsCorrect then
        if DropoffBlip and DoesBlipExist(DropoffBlip) then RemoveBlip(DropoffBlip) end
        CallStatus = 0
        CokeRunStarted = false
        DropCoords = {}
        FW.TriggerServer("fw-illegal:Server:FailedCocaine")
        return
    end

    FW.Functions.Notify("GPS geupdate.")
    CallStatus = CallStatus + 1

    if CallStatus > 4 then
        CreateDropoffBlip("Boot", vector3(1288.48, 3718.22, 30.26))
        FW.TriggerServer("fw-illegal:Server:CreateCokeDinghy", vector4(1288.48, 3718.22, 30.26, 36.33))
        GenerateVehicle(vector3(1288.48, 3718.22, 30.26), true)
        GenerateDropCoords()
    else
        SetupPhoneCall()
    end
end)

RegisterNetEvent("fw-illegal:Client:UseCrackpipe")
AddEventHandler("fw-illegal:Client:UseCrackpipe", function(Item)
    local Uses = Item.Info.Uses or 0
    if Uses <= 0 then
        return FW.Functions.Notify("Het lijkt erop dat het op is :(", "error")
    end

    local Outcome = exports['fw-ui']:StartSkillTest(1, { 12, 18 }, { 2400, 2500 }, false)

    if not Outcome then return end
    if not exports['fw-inventory']:HasEnoughOfItem('crackpipe', 1) then return end

    FW.TriggerServer("fw-illegal:Server:SetCrackpipeUses", Item.Slot, Uses - 1)

    exports['fw-assets']:AddProp('CrackPipe')
    local Finished = FW.Functions.CompactProgressbar(3000, "Crackje roken...", false, false, {disableMovement = false, disableCarMovement = false, disableMouse = false, disableCombat = true}, { animDict = "switch@trevor@trev_smoking_meth", anim = "trev_smoking_meth_loop", flags = 49 }, {}, {}, false)
    TriggerEvent("fw-fx:Client:DrugEffect", "Crack")
end)

function GeneratePhoneNumber()
    return "69 " .. tostring(FW.Shared.RandomInt(8))
end

function GenerateDropCoords()
    for i = 1, 4, 1 do
        DropCoords[i] = vector3(-3374.06, math.random(1,2184) + 1.00, -1.0)
    end

    for i = 1, 4, 1 do
        GenerateVehicle(DropCoords[i])
    end

    Citizen.SetTimeout((1000 * 60) * 10, function()
        FW.TriggerServer("fw-illegal:Server:DeleteCokeVehicles")
    end)

    if DropoffBlip and DoesBlipExist(DropoffBlip) then RemoveBlip(DropoffBlip) end
end

function InitCocaine()
    local Coords = FW.SendCallback("fw-illegal:Server:GetCokeGuyCoords")
    if not Coords then return end
    CokeGuyCoords = Coords

    exports['fw-ui']:AddEyeEntry("coke_heist_ped", {
        Type = 'Entity',
        EntityType = 'Ped',
        SpriteDistance = 5.0,
        Position = vector4(Coords.x, Coords.y, Coords.z, Coords.w),
        Model = "s_m_y_garbage",
        Options = {
            {
                Name = 'start_cocaine',
                Icon = 'fas fa-circle',
                Label = 'Geef me 100k (:',
                EventType = 'Client',
                EventName = 'fw-illegal:Client:StartCocaineHeist',
                EventParams = {},
                Enabled = function(Entity)
                    return true
                end,
            },
        }
    })
end

RegisterNetEvent("fw-ui:Ready")
AddEventHandler("fw-ui:Ready", InitCocaine)

function IsCorrectPayphone(PayphoneId)
    local Coords = FW.SendCallback("fw-illegal:Server:GetCocaineSequenceCoords", CallStatus)
    return CallStatus == PayphoneId and #(GetEntityCoords(PlayerPedId()) - Coords) < 3.0
end
exports("IsCorrectPayphone", IsCorrectPayphone)

function SetupPhoneCall()
    local Coords = FW.SendCallback("fw-illegal:Server:GetCocaineSequenceCoords", CallStatus)
    CreateDropoffBlip("Telefooncel", Coords)
end

function CreateDropoffBlip(Text, Coords)
    if DropoffBlip and DoesBlipExist(DropoffBlip) then RemoveBlip(DropoffBlip) end

    DropoffBlip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
    SetBlipSprite(DropoffBlip, 306)
    SetBlipScale(DropoffBlip, 0.8)
    SetBlipColour(DropoffBlip, 3)
    SetBlipAsShortRange(DropoffBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Text)
    EndTextCommandSetBlipName(DropoffBlip)
end

function GenerateVehicle(Coords, IgnoreSpawn)
    if not IgnoreSpawn then
        CreateDropoffBlip("Voertuig", Coords)
        FW.Functions.TriggerCallback("fw-illegal:Server:CreateCokeVehicle", function(Data)
            while not NetworkDoesEntityExistWithNetworkId(Data.NetId) do Citizen.Wait(100) end
            local Vehicle = NetToVeh(Data.NetId)
        
            -- just to make sure you get the correct plate cuz inv
            Citizen.SetTimeout(500, function()
                SetVehicleNumberPlateText(Vehicle, Data.Plate)

                RequestNamedPtfxAsset("wpn_flare")
                while not HasNamedPtfxAssetLoaded("wpn_flare") do Citizen.Wait(4) end
                UseParticleFxAssetNextCall("wpn_flare")

                local FlareParticle = StartParticleFxLoopedAtCoord("proj_heist_flare_trail", Coords.x, Coords.y, Coords.z + 1.5, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0)
                SetParticleFxLoopedColour(FlareParticle, 1.0, 0.2, 0.2, 0)
                SetParticleFxLoopedAlpha(FlareParticle, 1.0)

                Citizen.SetTimeout((1000 * 60) * 20, function()
                    StopParticleFxLooped(FlareParticle, true)
                end)
            end)
        end, Coords)
    end

    local Timeout = 60 * 20 -- 20 minutes
    while Timeout > 0 do
        Citizen.Wait(1000)
        Timeout = Timeout - 1

        if #(GetEntityCoords(PlayerPedId()) - Coords) < 300.0 then
            return true
        end
    end

    return false
end

function SetupCocainePeeks()
    local Sequences = FW.SendCallback("fw-illegal:Server:GetCocaineSequence")
    for i = 1, 16, 1 do
        local PayphoneId = 0
        if i > 4 and i <= 8 then
            PayphoneId = 1
        elseif i > 8 and i <= 12 then
            PayphoneId = 2
        elseif i > 12 then
            PayphoneId = 3
        end

        exports['fw-ui']:AddOptionToPeek(GetHashKey("prop_phonebox_04"), {
            Name = 'cocaine_call_' .. i,
            Icon = 'fas fa-phone',
            Label = 'Bel ' .. GeneratePhoneNumber(),
            EventType = 'Client',
            EventName = 'fw-illegal:Client:DoCocaineCall',
            EventParams = { IsCorrect = Sequences[PayphoneId + 1] == i - (4 * PayphoneId) },
            Enabled = function(Entity)
                return exports['fw-illegal']:IsCorrectPayphone(PayphoneId + 1)
            end,
        })
    end
end

Citizen.CreateThread(function()
    InitCocaine()
end)