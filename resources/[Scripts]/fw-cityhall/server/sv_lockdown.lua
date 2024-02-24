FW.RegisterServer("fw-cityhall:Server:SetLockdownState", function(Source, Id, Label, State)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= "police" and Player.PlayerData.job.name ~= "judge" then
        return Player.Functions.Notify("Geen toegang..", "error")
    end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `police_lockdowns` WHERE `lockdown_id` = ?", {Id})
    if Result[1] and State == false then
        exports['ghmattimysql']:executeSync("DELETE FROM `police_lockdowns` WHERE `lockdown_id` = ?", {Id})
        Player.Functions.Notify("Lockdown status veranderd voor " .. Label .. ": uitgeschakeld")
    elseif not Result[1] and State == true then
        exports['ghmattimysql']:executeSync("INSERT INTO `police_lockdowns` (`cid`, `lockdown_id`, `timestamp`) VALUES(?, ?, ?)", {Player.PlayerData.citizenid, Id, os.time()})
        Player.Functions.Notify("Lockdown status veranderd voor " .. Label .. ": ingeschakeld")
    else
        Player.Functions.Notify("Lockdown status is hetzelfde..", "error")
    end
end)

FW.Functions.CreateCallback("fw-cityhall:Server:IsLockdownActive", function(Source, Cb, Id)
    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `police_lockdowns` WHERE `lockdown_id` = ?", {Id})
    Cb(Result[1] ~= nil)
end)

-- 

FW.Functions.CreateCallback("fw-cityhall:Server:GetRoomIdByCid", function(Source, Cb, Cid)
    local Target = FW.Functions.GetPlayerByCitizenId(Cid)
    if Target then
        return Cb(Target.PlayerData.metadata.apartmentid)
    end

    local MetaData = exports['ghmattimysql']:executeSync("SELECT `metadata` FROM `players` WHERE `citizenid` = ?", { Cid })[1]
    if MetaData ~= nil then
        return Cb(json.decode(MetaData.metadata).apartmentid)
    end

    Cb(false)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetGaragesByStateId", function(Source, Cb, Cid)
    local Result = exports['ghmattimysql']:executeSync("SELECT DISTINCT `garage` FROM `player_vehicles` WHERE `citizenid` = ?", {Cid})

    local Garages = exports['fw-vehicles']:GetGarages()
    local Retval = {}

    for k, v in pairs(Result) do
        local Garage = Garages[v.garage]
        if Garage then
            Retval[#Retval + 1] = {
                Label = Garage.IsHouse and "Huis Garage" or Garage.Name,
                Garage = v.garage,
                Coords = Garage.Spots[1]
            }
        end
    end

    Cb(Retval)
end)

FW.Functions.CreateCallback("fw-cityhall:Server:GetBusinesses", function(Source, Cb, Cid)
    local Result = exports['ghmattimysql']:executeSync("SELECT `business_name` FROM `phone_businesses`")
    local Retval = {}

    for k, v in pairs(Result) do
        table.insert(Retval, {
            Text = v.business_name
        })
    end

    Cb(Retval)
end)

