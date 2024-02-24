FW = exports['fw-core']:GetCoreObject()

FW.Commands.Add("neon", "Zet je Neonlampen aan of uit.", {}, false, function(source, args)
    TriggerClientEvent("fw-bennys:Client:ToggleNeon", source)
end)

FW.Functions.CreateCallback("fw-bennys:Server:SaveMods", function(Source, Cb, NetId, Mods, Plate, ButtonData)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return Cb(false) end

    local Result = exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `mods` = @Mods WHERE `plate` = @Plate", {
        ['@Mods'] = json.encode(Mods),
        ['@Plate'] = Plate,
    })

    TriggerEvent('fw-logs:Server:Log', 'bennysMenu', 'Upgrade Purchased', ("User: [%s] - %s - %s %s\nPlate: %s\nData: ```json\n%s```"):format(Player.PlayerData.source, Player.PlayerData.citizenid, Player.PlayerData.charinfo.firstname, Player.PlayerData.charinfo.lastname, Plate, json.encode(ButtonData, {indent=4})), 'green')

    Cb(Result.affectedRows > 0)
end)

FW.Functions.CreateCallback("fw-bennys:Server:IsMechanicOnline", function(Source, Cb)
    local Mechanics = 0

    local ShopsCoords = {
        Bennys = vector3(-212.31, -1324.64, 31.32),
        Hayes = vector3(-1417.13, -446.04, 35.91),
        Harmony = vector3(1178.17, 2640.04, 37.75)
    }

    for k, v in pairs(FW.GetPlayers()) do
        local IsBennys = exports['fw-businesses']:HasPlayerBusinessPermission('Bennys Motorworks', v.ServerId, 'ChargeExternal')
        local IsHayes = IsBennys or exports['fw-businesses']:HasPlayerBusinessPermission('Hayes Repairs', v.ServerId, 'ChargeExternal')
        local IsHarmony = IsBennys or IsHayes or exports['fw-businesses']:HasPlayerBusinessPermission('Harmony Repairs', v.ServerId, 'ChargeExternal')

        if IsBennys or IsHayes or IsHarmony then
            local Coords = (IsBennys and ShopsCoords.Bennys) or (IsHayes and ShopsCoords.Hayes) or (IsHarmony and ShopsCoords.Harmony)
            if #(Coords - GetEntityCoords(GetPlayerPed(v.ServerId))) < 80.0 then
                Mechanics = Mechanics + 1
                if Mechanics >= 1 then
                    return Cb(true)
                end
            end
        end
    end

    Cb(false)
end)