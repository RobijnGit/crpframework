FW.Commands.Add("destaat", "Beheer de Staat.", {}, false, function(Source, Args)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'judge' and Player.PlayerData.job.name ~= 'mayor' then
        return Player.Functions.Notify("Je kan geen melding maken..", "error")
    end

    TriggerClientEvent("fw-cityhall:Client:OpenStateMenu", Source)
end)

FW.Functions.CreateCallback("fw-cityhall:Server:GetTax", function(Data, Cb)
    local Result = exports['ghmattimysql']:executeSync("SELECT `taxes` FROM server_config")
    Cb(json.decode(Result[1].taxes))
end)

FW.RegisterServer("fw-cityhall:Server:SetTax", function(Source, Data)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "mayor" and Player.PlayerData.job.name ~= "judge" then
        return
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT `taxes` FROM server_config")
    local TaxData = json.decode(Result[1].taxes)
    if not TaxData[Data.Tax] then return end

    TriggerEvent("fw-logs:Server:Log", 'mayor', "Tax Update", ("User: [%s] - %s - %s\nTax: %s\nPrevious: %s%%\nCurrent: %s%%"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname, Data.Tax, TaxData[Data.Tax], Data.Value), TaxData[Data.Tax] > Data.Value and "green" or "red")
    TaxData[Data.Tax] = Data.Value

    exports['ghmattimysql']:executeSync("UPDATE `server_config` SET `taxes` = ?", {
        json.encode(TaxData)
    })
end)