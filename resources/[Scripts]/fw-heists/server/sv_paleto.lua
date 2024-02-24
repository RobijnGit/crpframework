local PaletoObjects = {}
local PaletoCodes = {}
local PaletoPanels = {}

FW.Functions.CreateCallback("fw-heists:Server:Paleto:GetPCCode", function(Source, Cb, PCId)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(PaletoCodes[PCId])

    if PaletoCodes[PCId] and Config.Paleto.State ~= 2 then
        PaletoCodes[PCId].Shown = true

        if PaletoCodes[1].Shown and PaletoCodes[2].Shown then
            Config.Paleto.State = 2
            TriggerClientEvent("fw-heists:Client:SyncPaleto", -1, Config.Paleto)
            TriggerEvent('fw-doors:Server:SetLockStateById', 'PALETO_HALL_TO_SECURITY', 0)
        end
    end
end)

RegisterNetEvent("fw-heists:Server:Paleto:CorrectCode")
AddEventHandler("fw-heists:Server:Paleto:CorrectCode", function(Panel)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    PaletoPanels[Panel] = true

    if PaletoPanels[1] and PaletoPanels[2] then
        Player.Functions.Notify("Kluis alarm succesvol uitgeschakeld...", "error")
        Config.Paleto.State = 3
        TriggerClientEvent("fw-heists:Client:SyncPaleto", -1, Config.Paleto)
    end
end)

RegisterNetEvent("fw-heists:Server:ResetPaleto")
AddEventHandler("fw-heists:Server:ResetPaleto", function()
    Config.Paleto.State = 0

    for k, v in pairs(Config.Paleto.Doorlocks) do
        TriggerEvent('fw-doors:Server:SetLockStateById', v, 1)
    end

    for k, v in pairs(Config.Paleto.Loot) do
        v.State = 0
    end

    for k, v in pairs(PaletoObjects) do
        DeleteEntity(v)
    end
    PaletoObjects, PaletoCodes, PaletoPanels = {}, {}, {}

    TriggerClientEvent("fw-heists:Client:SyncPaleto", -1, Config.Paleto)
end)

RegisterNetEvent("fw-heists:Server:SetPaletoState")
AddEventHandler("fw-heists:Server:SetPaletoState", function(State)
    local Src = source
    local Player = FW.Functions.GetPlayer(Src)
    if Player == nil then return end

    local CidToAdd = Player.PlayerData.citizenid
    Config.Paleto.State = State
    TriggerClientEvent("fw-heists:Client:SyncPaleto", -1, Config.Paleto)

    if State == 1 then
        PaletoPanels = { [1] = false, [2] = false }
        SpawnPaletoUSBs()
        GeneratePaletoCodes()

        Citizen.SetTimeout((60 * 1000) * 180, function()
            if Config.Paleto.State == 4 then
                IncreaseProgression(CidToAdd, 5)
            end

            TriggerEvent("fw-heists:Server:ResetPaleto")
        end)
    end

    if State == 4 then
        Citizen.SetTimeout(5000, function()
            TriggerEvent('fw-doors:Server:SetLockStateById', 'PALETO_VAULT_DOOR', 0)
        end)
    end
end)

RegisterNetEvent("fw-heists:Server:Paleto:GrabUSB")
AddEventHandler("fw-heists:Server:Paleto:GrabUSB", function(Data, Entity)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local USBId = 1

    if PaletoObjects[2] and Entity == NetworkGetNetworkIdFromEntity(PaletoObjects[2]) then
        USBId = 2
    end

    if (not PaletoObjects[USBId]) or (not DoesEntityExist(PaletoObjects[USBId])) then
        return Player.Functions.Notify("Deze USB is al opgepakt..", "error")
    end

    DeleteEntity(PaletoObjects[USBId])
    PaletoObjects[USBId] = false
    Player.Functions.AddItem("heist-usb", 1, false, false, true, "black")
end)

RegisterNetEvent("fw-heists:Server:SetPaletoLootState")
AddEventHandler("fw-heists:Server:SetPaletoLootState", function(LootId, State)
    Config.Paleto.Loot[LootId].State = State
    TriggerClientEvent("fw-heists:Client:SyncPaleto", -1, Config.Paleto)
end)

RegisterNetEvent("fw-heists:Server:PaletoLootReward")
AddEventHandler("fw-heists:Server:PaletoLootReward", function(LootId)
    local Src = source
    local Player = FW.Functions.GetPlayer(Src)
    if Player == nil then return end

    if Config.Paleto.Loot[LootId].State ~= 1 then return end

    local Item = Player.Functions.GetItemByName('heist-drill-adv')
    if Item == nil then return end

    Player.Functions.DecayItem("heist-drill-adv", Item.Slot, math.random(10, 20))

    for i = 1, 2, 1 do
        local UntrackedChance = math.random(1, 100)
        Player.Functions.AddItem("heist-loot", 1, nil, { Serial = FW.Shared.RandomInt(3) .. "-" .. FW.Shared.RandomStr(3) .. "-" .. FW.Shared.RandomInt(6) .. "-" .. FW.Shared.RandomStr(2) .. FW.Shared.RandomInt(1), Encryption = Config.LootHacks[math.random(1, #Config.LootHacks)] }, true, (UntrackedChance >= 45 and UntrackedChance <= 50) and "" or "tracked")
        Citizen.Wait(50)
    end

    Player.Functions.AddItem('markedbills', math.random(20, 30), false, nil, true)

    if math.random(1, 100) <= 8 then
        Player.Functions.AddItem('cryptostick', 1, nil, nil, true, math.random(1, 100) > 75 and 'GNE25' or 'GNE10')
    end
end)

function SpawnPaletoUSBs()
    local USB_One = GetRandomFromArray(Config.Paleto.USBLocations, {})
    local USB_Two = GetRandomFromArray(Config.Paleto.USBLocations, {USB_One})

    for k, v in pairs(PaletoObjects) do
        DeleteEntity(v)
    end

    PaletoObjects = {}
    PaletoObjects[1] = CreateObject(GetHashKey("hei_prop_hst_usb_drive"), USB_One.x, USB_One.y, USB_One.z, true, true, false)
    PaletoObjects[2] = CreateObject(GetHashKey("hei_prop_hst_usb_drive"), USB_Two.x, USB_Two.y, USB_Two.z, true, true, false)
end

function GeneratePaletoCodes()
    PaletoCodes[1] = { Code = UUID(), Shown = false }
    Citizen.Wait(1000)
    PaletoCodes[2] = { Code = UUID(), Shown = false }
end