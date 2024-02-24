local HouseGarages, OutsideVehicles, DepotVehicles, LockdownVehicles = {}, {}, {}, {}

exports("GetOutsideVehicles", function()
    return OutsideVehicles
end)

exports("GetGarages", function()
    return Config.Garages
end)

Citizen.CreateThread(function()
    local Result = exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `state` = 'in' WHERE `state` = 'out'")
    print(Result.affectedRows .. " vehicles where re-stated into their garages.")
    
    local Houses = exports['ghmattimysql']:executeSync("SELECT `name`, `garage` FROM `player_houses`")
    for k, v in pairs(Houses) do
        local Garage = json.decode(v.garage)
        if Garage.x then
            HouseGarages[v.name] = {
                Name = v.adress,
                Zone = {
                    vector3(Garage.x, Garage.y, Garage.z), -- Center
                    5.0, -- Length
                    5.0, -- Width
                    Garage.w, -- Heading,
                    Garage.z - 1.0, -- MinZ
                    Garage.z + 1.5, -- MaxZ
                },
                IsHouse = v.name,
                Spots = {
                    Garage,
                }
            }
        end
    end
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetHouseGarages", function(Source, Cb)
    Cb(HouseGarages)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:CanSpawnVehicle", function(Source, Cb, Plate)
    if OutsideVehicles[Plate] then
        local Vehicle = NetworkGetEntityFromNetworkId(OutsideVehicles[Plate])
        Cb(Vehicle > 0 and Plate == GetVehicleNumberPlateText(Vehicle))
    else
        Cb(false)
    end
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetVehicleByPlate", function(Source, Cb, Palte)
    local Vehicle = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `plate` = @Plate", {
        ['@Plate'] = Plate,
    })

    Cb(Vehicle[1])
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetVehicleCoords", function(Source, Cb, Plate)
    if OutsideVehicles[Plate] then
        local Vehicle = NetworkGetEntityFromNetworkId(OutsideVehicles[Plate])
        if Vehicle ~= 0 then
            local VehPlate = GetVehicleNumberPlateText(Vehicle)
            if Plate == VehPlate then
                return Cb(GetEntityCoords(Vehicle))
            end
        end
    end

    local Vehicle = exports['ghmattimysql']:executeSync("SELECT `state`, `garage` FROM `player_vehicles` WHERE `plate` = @Plate", {
        ['@Plate'] = Plate,
    })

    if Vehicle[1] == nil then return Cb(false) end

    if Vehicle[1].state == 'depot' then
        Cb(vector3(1002.37, -2310.99, 30.64)) -- Depot
    elseif Vehicle[1].state == 'out' then
        Cb(false) -- out, but not traceable..?
    else
        if Config.Garages[Vehicle[1].garage] then
            Cb(Config.Garages[Vehicle[1].garage].Spots[1])
        else
            Cb(false)
        end
    end
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetGarageVehicles", function(Source, Cb, Garage, Owner)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    -- Some spawned garages, either from housing/gangs.
    if Config.Garages[Garage] == nil then
        local HouseId = exports['fw-housing']:GetHouseIdByAdress(Garage)
        local Gang = exports['fw-laptop']:GetGangById(Garage)
        
        if not HouseId and not Gang then
            return Cb({})
        end

        local Vehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `garage` = @Garage", {
            ['@Garage'] = Garage,
        })

        Cb(Vehicles)
    else
        local Vehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `citizenid` = @Cid AND `garage` = @Garage", {
            ['@Cid'] = Owner and Owner or Player.PlayerData.citizenid,
            ['@Garage'] = Garage,
        })

        Cb(Vehicles)
    end
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetVehiclesFromCid", function(Source, Cb, Cid, Garage)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `citizenid` = @Cid AND `garage` = @Garage", {
        ['@Cid'] = Cid,
        ['@Garage'] = Garage,
    })

    Cb(Vehicles)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetDepotVehicles", function(Source, Cb, Garage)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `citizenid` = @Cid AND `state` = 'depot'", {
        ['@Cid'] = Player.PlayerData.citizenid,
    })

    Cb(Vehicles)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:IsVehicleOwner", function(Source, Cb, Plate, Garage)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicles = exports['ghmattimysql']:executeSync("SELECT `citizenid`, `garage` FROM `player_vehicles` WHERE `plate` = @Plate", {
        ['@Plate'] = Plate,
    })

    if Vehicles[1] == nil then
        return Cb(false)
    end

    if not Garage and (Vehicles[1].citizenid == "gov_pd" or Vehicles[1].citizenid == "gov_ems" or Vehicles[1].citizenid == "gov_doc") then
        return Cb(true)
    end

    if Vehicles[1].citizenid == Player.PlayerData.citizenid then
        return Cb(true)
    end

    local HouseId = exports['fw-housing']:GetHouseIdByAdress(Vehicles[1].garage)
    if not HouseId then
        return Cb((string.sub(Vehicles[1].citizenid, 1, 4) == "gov_" and (Garage and string.sub(Garage, 1, 4) == "gov_")) or Vehicles[1].citizenid == Player.PlayerData.citizenid)
    end

    Cb(exports['fw-housing']:HasKeyToHouse(HouseId, Vehicles[1].citizenid))
end)

FW.Functions.CreateCallback("fw-vehicles:Client:GetRecentDepots", function(Source, Cb)
    Cb(DepotVehicles)
end)

FW.Functions.CreateCallback("fw-vehicles:Server:GetVehicleByPlate", function(Source, Cb, Plate)
    local Vehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `plate` = @Plate", {
        ['@Plate'] = Plate,
    })

    Cb(Vehicles[1])
end)

FW.Functions.CreateCallback("fw-vehicles:Server:PayReleaseFee", function(Source, Cb, Plate, Fee)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if exports['fw-financials']:RemoveMoneyFromAccount('1001', '1', Player.PlayerData.charinfo.account, Fee, 'PAYMENT', 'Voertuig Depot Vrijgavekosten: ' .. Plate, false) then
        Cb(true)

        for k, v in pairs(DepotVehicles) do
            if v.Plate == Plate then
                table.remove(DepotVehicles, k)
                return
            end
        end
    else
        Cb(false)
    end
end)

FW.Functions.CreateCallback("fw-vehicles:Server:CanRetreiveVehicle", function(Source, Cb, Plate)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicles = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `plate` = @Plate", { ['@Plate'] = Plate })
    if Vehicles[1] and json.decode(Vehicles[1].impounddata) then
        local ReleaseDate = json.decode(Vehicles[1].impounddata).ReleaseDate
        Cb(ReleaseDate < os.time())
    else
        Cb(true)
    end
end)

FW.Functions.CreateCallback("fw-vehicles:Server:IsVehicleLocked", function(Source, Cb, Plate)
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    Cb(LockdownVehicles[Plate])
end)

RegisterNetEvent("fw-vehicles:Client:SetHousingGarage")
AddEventHandler("fw-vehicles:Client:SetHousingGarage", function(HouseId, Coords)
    HouseGarages[HouseId] = {
        Zone = {
            vector3(Coords.x, Coords.y, Coords.z), -- Center
            5.0, -- Length
            5.0, -- Width
            Coords.w, -- Heading,
            Coords.z - 1.0, -- MinZ
            Coords.z + 1.5, -- MaxZ
        },
        IsHouse = HouseId,
        Spots = {
            Coords,
        }
    }

    TriggerClientEvent("fw-vehicles:Client:LoadHouseGarage", -1, HouseId, HouseGarages[HouseId])
end)

RegisterNetEvent("fw-vehicles:Server:SetVehicleState")
AddEventHandler("fw-vehicles:Server:SetVehicleState", function(Plate, State, NetId)
    if State == 'out' then
        OutsideVehicles[Plate] = NetId
    end

    exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `state` = @State WHERE `plate` = @Plate", {
        ['@Plate'] = Plate,
        ['@State'] = State,
    })
end)

RegisterNetEvent("fw-vehicles:Server:ParkVehicle")
AddEventHandler("fw-vehicles:Server:ParkVehicle", function(NetId, Garage, VehicleDamage)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return end

    local Plate = GetVehicleNumberPlateText(Vehicle)
    
    DeleteEntity(Vehicle)
    OutsideVehicles[Plate] = nil
    if LockdownVehicles[Plate] then
        LockdownVehicles[Plate] = nil
        Player.Functions.Notify(("Lockdown %s uitgeschakeld"):format(Plate), "success")
    end

    local Meta = GetVehicleMeta(NetId)
    Meta.Body = GetVehicleBodyHealth(Vehicle)
    Meta.Engine = GetVehicleEngineHealth(Vehicle)
    Meta.Damage = VehicleDamage

    exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `metadata` = @Meta, `garage` = @Garage, `state` = 'in' WHERE `plate` = @Plate", {
        ['@Meta'] = json.encode(Meta),
        ['@Plate'] = Plate,
        ['@Garage'] = Garage or "apartment_1",
    })
end)

RegisterNetEvent("fw-vehicles:Server:DepotVehicle")
AddEventHandler("fw-vehicles:Server:DepotVehicle", function(NetId, ImpoundId, Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local Vehicle = NetworkGetEntityFromNetworkId(NetId)
    if Vehicle == 0 then return end

    local Result = exports['ghmattimysql']:executeSync("SELECT * FROM `player_vehicles` WHERE `plate` = @Plate", {
        ['@Plate'] = GetVehicleNumberPlateText(Vehicle),
    })

    local ImpoundData, ImpoundPresets = {}, Config.ImpoundList[ImpoundId]
    ImpoundData.Issuer = Player.PlayerData.citizenid

    if Data ~= nil and Data.RetainedUntil ~= nil and (#Data.RetainedUntil == 0 or tonumber(Data.RetainedUntil) < 0) then
        Data.RetainedUntil = 24
    end

    if ImpoundId == #Config.ImpoundList then
        ImpoundData.ReleaseDate = tonumber(os.time() + (3600 * tonumber(Data.RetainedUntil)))
        ImpoundData.Fee = FW.Shared.CalculateTax('Services', tonumber(Data.Fee))
        ImpoundData.Strikes = tonumber(Data.Strikes)
        ImpoundData.Reason = Data.Reason
    else
        ImpoundData.ReleaseDate = tonumber(os.time() + (3600 * ImpoundPresets.Hours))
        ImpoundData.Fee = FW.Shared.CalculateTax('Services', tonumber(ImpoundPresets.Fee))
        ImpoundData.Strikes = tonumber(ImpoundPresets.Strikes)
        ImpoundData.Reason = ImpoundPresets.Desc
    end

    if Data and Data.ReportId then
        ImpoundData.Reason = ImpoundData.Reason .. " (#" .. Data.ReportId .. ")"
    end

    if Result[1] then
        local TempTime = os.date("*t", ImpoundData.ReleaseDate)
        local ImpoundTime = os.date("*t", os.time())
        ImpoundData.ReleaseTxt = TempTime.day .. "/" .. TempTime.month .. "/" .. TempTime.year .. ", " .. TempTime.hour .. ":" .. TempTime.min .. ":" .. TempTime.sec
        ImpoundData.ImpoundDate = ImpoundTime.day .. "/" .. ImpoundTime.month .. "/" .. ImpoundTime.year .. ", " .. ImpoundTime.hour .. ":" .. ImpoundTime.min .. ":" .. ImpoundTime.sec

        DepotVehicles[#DepotVehicles + 1] = {
            Vehicle = GetEntityModel(Vehicle),
            Plate = Result[1].plate,
            VIN = Result[1].vinnumber,
            Reason = ImpoundData.Reason,
            Fee = ImpoundData.Fee,
            Strikes = ImpoundData.Strikes,
            Issuer = ImpoundData.Issuer,
            ReleaseTxt = ImpoundData.ReleaseTxt,
            ImpoundDate = ImpoundData.ImpoundDate
        }
    end

    local ImpoundWorkers = exports['fw-phone']:GetJobGroupCount('impound')
    if ImpoundId == 1 or ImpoundWorkers == 0 then
        DeleteEntity(Vehicle)
        OutsideVehicles[GetVehicleNumberPlateText(Vehicle)] = nil

        if Result[1] and ImpoundId ~= 1 and Result[1].vinscratched == 1 then
            exports['ghmattimysql']:executeSync("DELETE FROM `player_vehicles` WHERE `plate` = @Plate", {
                ['@Plate'] = GetVehicleNumberPlateText(Vehicle),
            })
        end

        if exports['fw-boosting']:IsBoostingVehicle(GetVehicleNumberPlateText(Vehicle)) then
            TriggerEvent("fw-boosting:Server:OnImpound", GetVehicleNumberPlateText(Vehicle))
        end
    else
        TriggerEvent("fw-jobmanager:Server:Impound:AddImpoundRequest", NetId)
        Player.Functions.Notify("Een depotmedewerker is onderweg!")
    end

    if Result[1] then
        exports['ghmattimysql']:executeSync("INSERT INTO `vehicles_impound` (actor, vehicle, plate, vin, reason, fee, strikes, retained_date, retained_until) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
            Player.PlayerData.citizenid,
            FW.Shared.HashVehicles[GetEntityModel(Vehicle)].Vehicle,
            Result[1].plate,
            Result[1].vinnumber,
            ImpoundData.Reason,
            ImpoundData.Fee,
            ImpoundData.Strikes,
            os.time() * 1000,
            ImpoundData.ReleaseDate * 1000
        })
    end

    if Result[1] and Result[1].vinscratched == 0 then
        TriggerEvent('fw-logs:Server:Log', 'depot', 'Vehicle Depot', ("User: [%s] - %s - %s\nUser sent vehicle to depot:\nReason: %s\nModel: %s\nFee: %s\nStrikes: %s\nPlate - VIN: %s - %s\nRetained Until: %s"):format(
            Player.PlayerData.source,
            Player.PlayerData.citizenid,
            Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname,
            ImpoundData.Reason,
            FW.Shared.HashVehicles[DepotVehicles[#DepotVehicles].Vehicle].Name,
            ImpoundData.Fee,
            ImpoundData.Strikes,
            Result[1].plate,
            Result[1].vinnumber,
            ImpoundData.ReleaseTxt
        ), 'orange')

        local Meta = GetVehicleMeta(NetId)
        Meta.Body = GetVehicleBodyHealth(Vehicle)
        Meta.Engine = GetVehicleEngineHealth(Vehicle)
        
        exports['ghmattimysql']:executeSync("UPDATE `player_vehicles` SET `impounddata` = @Impound, `metadata` = @Meta, `state` = 'depot' WHERE `plate` = @Plate", {
            ['@Meta'] = json.encode(Meta),
            ['@Impound'] = json.encode(ImpoundData),
            ['@Plate'] = GetVehicleNumberPlateText(Vehicle),
        })
    end
end)

RegisterNetEvent('fw-vehicles:Server:SendMessageToImpound')
AddEventHandler('fw-vehicles:Server:SendMessageToImpound', function()
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    local ClockedInPlayers = exports['fw-businesses']:GetClockedInPlayers()
    local DepotWorkers = 0

    for k, v in pairs(ClockedInPlayers) do
        if v.Business == 'Los Santos Depot' and v.ClockedIn then
            DepotWorkers = DepotWorkers + 1
            TriggerClientEvent('fw-phone:Client:Notification', k, "request-depot-" .. Source, 'fas fa-car', { "white", "rgb(38, 50, 56)" }, 'Los Santos Depot', 'Iemand heeft hulp nodig bij het depot.', false, false, nil, nil, {})
        end
    end

    if DepotWorkers == 0 then
        Player.Functions.Notify("Geen depotmedewerkers aanwezig..", "error")
    end
end)

RegisterNetEvent("fw-vehicles:Server:ToggleLockdown")
AddEventHandler("fw-vehicles:Server:ToggleLockdown", function(Data)
    local Source = source
    local Player = FW.Functions.GetPlayer(Source)
    if Player == nil then return end

    if Player.PlayerData.job.name ~= 'police' and Player.PlayerData.job.name ~= 'judge' then
        return
    end

    local Plate = Data.Plate

    LockdownVehicles[Plate] = not LockdownVehicles[Plate]
    Player.Functions.Notify(("Lockdown %s %s"):format(Plate, LockdownVehicles[Plate] and "ingeschakeld" or "uitgeschakeld"), LockdownVehicles[Plate] and "error" or "success")
end)