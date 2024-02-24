FW.Functions.CreateUsableItem("notepad", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    if Item.Info._Uses == 0 then
        return Player.Functions.Notify("Het notitieblokje is leeg..", "error")
    end

    TriggerClientEvent("fw-misc:Client:WriteNote", Source, Item)
end)

FW.Functions.CreateUsableItem("notepad-page", function(Source, Item)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.Functions.GetItemBySlot(Item.Slot) == nil then
        return
    end

    TriggerClientEvent("fw-misc:Client:OpenNote", Source, Item.Info)
end)

FW.RegisterServer("fw-misc:Server:WriteNotepad", function(Source, Text)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Item = Player.Functions.GetItemByName("notepad")
    if Item == nil then
        return
    end

    if Item.Info._Uses == 0 then
        return Player.Functions.Notify("Het notitieblokje is leeg..", "error")
    end

    if Item.Info._Uses > 1 then
        Player.Functions.SetItemKV("notepad", Item.Slot, "_Uses", Item.Info._Uses - 1)
    else
        Player.Functions.RemoveItem("notepad", 1, Item.Slot, true)
    end

    Player.Functions.AddItem("notepad-page", 1, nil, { _Note = Text }, true)

    TriggerEvent("fw-logs:Server:Log", 'notepads', "Notepad Created", ("User: [%s] - %s - %s\nNote: %s"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Text), "blue")
end)