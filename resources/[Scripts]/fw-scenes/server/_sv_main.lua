local FW = exports['fw-core']:GetCoreObject()

FW.Functions.CreateCallback("fw-scenes:Server:GetScenes", function(Source, Cb)
    Cb(Config.Scenes)
end)

function RemoveSize(Text)
    local FinalText = Text

    local _, _, FoundTextLower = FinalText:find('<font size=.[0-9]*.>(.*)')
    if FoundTextLower then
        local _, _, FoundEndLower = FoundTextLower:find('(.*)</font>')
        if FoundEndLower then
            FinalText = FoundEndLower
        else
            FinalText = FoundTextLower
        end
    end

    local _, _, FoundTextUpper = FinalText:find('<FONT SIZE=.[0-9]*.>(.*)')
    if FoundTextUpper then
        local _, _, FoundEndUpper = FoundTextUpper:find('(.*)</FONT>')
        if FoundEndUpper then
            FinalText = FoundEndUpper
        else
            FinalText = FoundTextUpper
        end
    end

    return FinalText
end

RegisterNetEvent("fw-scenes:Server:AddScene")
AddEventHandler("fw-scenes:Server:AddScene", function(Data, Coords, Offset)
    local Src = source
    local Player = FW.Functions.GetPlayer(Src)
    if Player == nil then return end

    for _, Word in pairs(Config.BannedWords) do
        if Data.Text:find(Word) then
            TriggerEvent('fw-scenes:Server:UpdateBlacklist', {State = true, Steam = Player.PlayerData.steam, Reason = "Automatische Blacklist - Blacklisted Woord: " .. Word })
            TriggerEvent('fw-logs:Server:Log', 'scenes', 'Automatic Blacklist', ("User: [%s] - %s - %s\nUser was automatticly banned for using a banned word.. %s\nData: ```json\n%s```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Word, json.encode(Data, {indent = 2})), 'red')
            return
        end
    end

    local Blacklist = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/blacklist.json"))
    if Blacklist[Player.PlayerData.steam] then
        Player.Functions.Notify("Jij kunt geen scenes plaatsen.. (Reden: " .. Blacklist[Player.PlayerData.steam] .. ")", "error")
        return
    end

    local SceneId = #Config.Scenes + 1
    Config.Scenes[SceneId] = {
        Creator = Player.PlayerData.steam,
        Coords = Coords,
        Offset = Offset,
        Text = RemoveSize(Data.Text),
        Color = Data.Color:lower(),
        Distance = tonumber(Data.Distance),
    }

    TriggerEvent('fw-logs:Server:Log', 'scenes', 'Scene Placed', ("User: [%s] - %s - %s \nData: ```json\n%s ```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, json.encode(Data, {indent = 2})), 'green')

    TriggerClientEvent('fw-scenes:Client:UpdateScene', -1, SceneId, Config.Scenes[SceneId])
end)

RegisterNetEvent("fw-scenes:Server:RemoveScene")
AddEventHandler("fw-scenes:Server:RemoveScene", function(SceneId)
    local Src = source
    local Player = FW.Functions.GetPlayer(Src)
    if Player == nil then return end

    local SceneData = Config.Scenes[SceneId]

    if Player.PlayerData.job.name ~= "police" and (not FW.Functions.HasPermission(Src, "admin") and not FW.Functions.HasPermission(Src, "god")) and SceneData.Creator ~= Player.PlayerData.steam then
        Player.Functions.Notify("Deze scene kan jij niet verwijderen..", "error")
        return
    end

    TriggerEvent('fw-logs:Server:Log', 'scenes', 'Scene Removed', ("User: [%s] - %s - %s \nScene ID: %s \nData: ```json\n%s ```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, SceneId, json.encode(SceneData, {indent = 2})), 'orange')

    table.remove(Config.Scenes, SceneId)
    TriggerClientEvent('fw-scenes:Client:UpdateScene', -1, SceneId, nil)
end)

RegisterNetEvent("fw-scenes:Server:UpdateBlacklist")
AddEventHandler("fw-scenes:Server:UpdateBlacklist", function(Data)
    local Blacklist = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/blacklist.json"))

    if Data.State then
        Blacklist[Data.Steam] = Data.Reason
    else
        Blacklist[Data.Steam] = nil
    end

    SaveResourceFile(GetCurrentResourceName(), "data/blacklist.json", json.encode(Blacklist, {indent=2}), -1)
end)